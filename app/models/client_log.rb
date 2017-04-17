class ClientLog < ActiveRecord::Base
  belongs_to :computer

  scope :successful, where(errors_log: "")

  # Include helpers
  include ActionView::Helpers

  # Glean the runtype from the log details
  # If not present, returns nil
  def run_type
    managed_software_update_log.match(/(runtype: )(.+)(\.\.\.$)/)[2]
  rescue
  end

  # List of attributes that contain log information
  def log_attributes
    ["managed_software_update_log", "installs_log", "errors_log"]
  end

  # Time since this log was created, in words
  def time_since_created_at_in_words
    time_ago_in_words(created_at) + " ago"
  end
end
