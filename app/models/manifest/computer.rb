class Computer < ActiveRecord::Base
  include IsAManifest
  include HasAUnit
  include HasAnEnvironment
  include HasAnIcon
  include IsAsyncDestroyable

  belongs_to :computer_model
  belongs_to :computer_group

  has_one :system_profile, dependent: :destroy, autosave: true
  has_one :warranty, dependent: :destroy, autosave: true
  has_many :client_logs, dependent: :destroy
  has_many :managed_install_reports, order: "created_at DESC", dependent: :destroy

  # Validations
  validate :computer_model

  validates_presence_of :name, :mac_address

  validates_format_of :hostname,
                      with: /^[a-zA-Z0-9\-\.]*$/,
                      message: "must only contain alphanumeric characters, hyphens, and periods",
                      allow_blank: true

  validates_format_of :mac_address, with: /^([0-9a-f]{2}(:|$)){6}$/ # mac_address attribute must look something like ff:12:ff:34:ff:56

  validates_uniqueness_of :name
  validates_uniqueness_of :mac_address

  validates_uniqueness_of :hostname, allow_blank: true

  default_scope where(deleted_at: nil).order(:name)

  scope :search, ->(column, term) { where(["#{column} LIKE ?", "%#{term}%"]) unless term.blank? || column.blank? }
  scope :eager_manifests, includes(bundle_includes + [{ computer_group: item_includes + bundle_includes }])
  scope :deleted, where("deleted_at IS NOT NULL").order(:name)

  # before_save :require_computer_group

  # Maybe I shouldn't be doing this
  include ActionView::Helpers

  # Computers are considered dormant when they haven't checked in for
  # longer than value of dormant_interval.  Value stored in method
  # instead of constant to ensure the value is up-to-date at all times
  def self.dormant_interval
    7.days.ago
  end

  # Overwrite computer_model association method to return
  # computer model based on system_profile
  def computer_model
    model = ComputerModel.where(name: system_profile.machine_model).first if system_profile.present?
    model ||= ComputerModel.find(computer_model_id) if computer_model_id.present?
    model ||= ComputerModel.default
  end

  def computer_group_options_for_select(unit, environment_id = nil)
    environment = Environment.where(id: environment_id).first
    environment ||= self.environment
    environment ||= Environment.start
    ComputerGroup.unit(unit).environment(environment).map { |cg| [cg.name, cg.id] }
  end

  # Alias the computer_model icon to this computer
  def icon
    computer_model.icon
  end

  # Returns a hash representing the ManagedInstalls.plist
  # that should be placed in /Library/Preferences on this client
  def client_prefs
    url = ActionMailer::Base.default_url_options[:host]
    url ||= "localhost"
    { ClientIdentifier: client_identifier,
      DaysBetweenNotifications: 1,
      InstallAppleSoftwareUpdates: true,
      LogFile: "/Library/Managed Installs/Logs/ManagedSoftwareUpdate.log",
      LoggingLevel: 1,
      ManagedInstallsDir: "/Library/Managed Installs",
      ManifestURL: url,
      SoftwareRepoURL: url,
      UseClientCertificate: false }
  end

  # For will_paginate gem.  Sets the default number of records per page.
  def self.per_page
    10
  end

  # Filters dormant computers from Computer model.  Because this method
  # must filter based on ClientLog relationships, this method does not
  # return an ActiveRecord::Relation instance.  If you pass a unit, it
  # return dormant computers from that unit only.
  def self.dormant(unit = nil)
    dormant = []
    computers = Computer.unit(unit) if unit.present?
    computers ||= Computer.all
    computers.each do |computer|
      dormant << computer if computer.dormant?
    end
    dormant
  end

  # Examines the client logs of a computer to determine if it has been dormant
  def dormant?
    # (self.last_successful_run.nil? and self.created_at < self.class.dormant_interval) or (self.last_successful_run.created_at < self.class.dormant_interval)
    false
  end

  # Extend manifest by removing name attribute and adding the catalogs
  def serialize_for_plist
    h = serialize_for_plist_super
    h.delete(:name)
    h[:catalogs] = catalogs
    h
  end

  # Add mac_address matching
  def self.find_for_show(unit, id)
    find_for_show_super(unit, id) || where(mac_address: id).first
  end

  def self.find_for_show_fast(shortname, unit)
    Computer.unit(unit).where(shortname: shortname).eager_items.eager_manifests.first
  end

  def client_identifier
    mac_address + ".plist"
  end

  # Validates the presence of a computer model
  # and puts in the default model otherwise
  def presence_of_computer_model
    computer_model = ComputerModel.default if computer_model.nil?
  end

  # Return the latest instance of ClientLog
  def last_report
    managed_install_reports.first
  end

  # Returns, in words, the time since last run
  def last_report_at_time
    if last_report_at.present?
      time_ago_in_words(last_report_at) + " ago"
    else
      "never"
    end
  end

  def time_since_last_error_free_report
    if last_error_free_report.present?
      time_ago_in_words(last_error_free_report.created_at) + " ago"
    else
      "never"
    end
  end

  def last_error_free_report
    managed_install_reports.error_free.last if managed_install_reports.error_free.present?
  end

  def recent_reports(num = 15)
    ManagedInstallReport.where(computer_id: id).limit(num).order("created_at desc")
  end

  # Check the last managed install report and determine if
  # this item has been installed or not
  def installed?(pkg)
    package_installed = false
    report = last_report
    if report.present? && report.managed_installs.present?
      report.managed_installs.each do |mi|
        if mi["name"] == pkg.name && mi["installed_version"] == pkg.version && mi["installed"]
          package_installed = true
        end
      end
    end
    package_installed
  end

  # True if an AdminMailer computer report is due
  def report_due?
    last_report.present? && last_report.issues?
  end

  # Get the status of the computer based on the last report
  # => Status Unknown
  # => OK
  # => Reported Errors
  # => Reported Warnings
  def status
    status = "Status Unknown"
    if last_report.present?
      status = "OK" if last_report.ok?
      status = "Reported Warnings" if last_report.warnings?
      status = "Reported Errors" if last_report.errors?
    end
    status
  end

  # Do some reformatting before writing to attribute
  def mac_address=(value)
    # Remove non-alphanumeric
    value = value.gsub(/[^a-zA-Z0-9]/, "")
    # Lower case
    value = value.downcase
    # Replace hyphens with colons
    i = 0
    formatted = []
    while i < 12 && i < value.length
      formatted << value[i, 1]
      formatted << ":" if i.odd? && i != 11
      i += 1
    end
    write_attribute(:mac_address, formatted.join(""))
  end

  # Bulk update
  def self.bulk_update_attributes(computers, computer_attributes)
    if computer_attributes.nil? || computers.empty?
      raise ComputerError, "Nothing to update"
    else
      computers.each do |c|
        c.update_attributes(computer_attributes)
      end
    end
  end

  def serial_number
    system_profile.serial_number if system_profile.present?
  end

  # updates warranty, return true upon success
  def update_warranty
    if serial_number
      warranty = Warranty.find_or_create_by_serial_number(serial_number)
      warranty_hash = {}
      begin
        warranty_hash = Warranty.get_warranty_hash(serial_number)
      rescue WarrantyException
        # Just catch and return false for now
        return false
      end
      # append computer_id into the hash
      warranty_hash[:computer_id] = id
      warranty_hash[:updated_at] = Time.now
      update_successful = warranty.update_attributes(warranty_hash)
      # Send notification, if due
      deliver_warranty_notification if warranty_notification_due?
      update_successful
    end
  end

  # Return true if warranty notification is due
  def warranty_notification_due?
    if warranty.present?
      warranty.notification_due?
    else
      false
    end
  end

  def deliver_warranty_notification
    AdminMailer.warranty_notification(self).deliver
    warranty.notifications.create
  end

  def warranty_expiry_date
    if warranty.present? && warranty.hw_coverage_end_date.present?
      warranty.hw_coverage_end_date.to_s(:readable_date)
    else
      "unknown"
    end
  end
end
