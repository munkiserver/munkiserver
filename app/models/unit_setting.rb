class UnitSetting < ActiveRecord::Base
  belongs_to :unit
  attr_accessible :regular_events, :warning_events, :error_events
  # Unit setting defaults
  # New records initialized with the following values
  DEFAULTS = { notify_users: true,
               regular_events: { new_package_added: true }.to_yaml,
               warning_events: { something_might_break: true }.to_yaml,
               error_events: { invalid_plist: true }.to_yaml,
               version_tracking: true }.freeze

  attr_is_hash :regular_events
  attr_is_hash :warning_events
  attr_is_hash :error_events

  # Sets up defaults
  def initialize
    super
    update_attributes(DEFAULTS) if new_record?
  end

  def to_params
    name
  end
end
