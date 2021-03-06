# Special ActiveRecord::Base mixin module
module HasClientPrefs
  def self.included(_base)
    belongs_to :configuration
  end

  def client_prefs
    # Unless you already have a configuration attached to you,
    # temporarily create a blank config
    (self.configuration = Configuration.new) unless configuration

    # Pass resultant_config
    configuration.resultant_config
  end
end
