class UserSetting < ActiveRecord::Base
  belongs_to :user

  DEFAULTS = { :receive_email_notifications => true }.freeze

  # Sets up defaults
  def initialize
    super
    if new_record?
      update_attributes(DEFAULTS)
    end
  end
end
