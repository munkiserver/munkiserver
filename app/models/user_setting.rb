class UserSetting < ActiveRecord::Base
  belongs_to :user

  DEFAULTS = { receive_email_notifications: true }.freeze

  # Sets up defaults
  def initialize
    super
    update_attributes(DEFAULTS) if new_record?
  end
end
