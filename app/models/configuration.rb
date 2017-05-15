class Configuration < ActiveRecord::Base
  has_one :computer
  has_one :computer_group
  has_one :unit

  # Internally use configuration, externally use config
  serialize :configuration, Hash

  def owner
    return computer if computer
    return computer_group if computer_group
    return unit if unit
  end

  def parent_config
    computer.computer_group.client_pref if owner.is_a? Computer

    computer_group.unit.client_pref if owner.is_a? ComputerGroup

    MunkiService.client_pref if owner.is_a? Unit
  end

  def resultant_config
    if inherit
      owner.parent_config.merge(configuration)
    else
      configuration
    end
  end

  def config
    configuration
  end

  def config=(config)
    configuration = config
  end

  def self.configuration_options; end

  def self.configuration_helpers; end
end
