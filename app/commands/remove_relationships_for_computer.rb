class RemoveRelationshipsForComputer

  def initialize(computer, new_environment)
    @computer = computer
    @new_environment = new_environment
  end

  def perform
    sever_all_connections
    @computer.save
  end

  private

  PLURAL_CONNECTIONS = %w[bundles installs uninstalls]
  SINGULAR_CONNECTIONS = %w[computer_group]

  # bundles, installs, uninstalls, managed_update, optional_installs
  def sever_all_connections
    sever_plural_connections
    sever_singular_connections
  end

  def sever_plural_connections
    PLURAL_CONNECTIONS.each do |relationship|
      @computer.send(
        [relationship, '='].join.to_sym,
        @computer.send(relationship).select { |val |
          val.environment == @new_environment
      })
    end
  end

  def sever_singular_connections
    SINGULAR_CONNECTIONS.each do |relationship|
      if @computer.send(relationship).environment != @new_environment
        @computer.send(
          [relationship, '='].join.to_sym,
          nil
        )
      end
    end
  end
end
