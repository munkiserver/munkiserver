class RemoveRelationshipsForPackage

  def initialize(package, new_environment)
    @package = package
    @new_environment = new_environment
  end

  def perform
    sever_all_connections
    @package.save
  end

  private

  PLURAL_CONNECTIONS = %w[update_for_items require_items]
  SINGULAR_CONNECTIONS = %w[]
  INCOMING_CONNECTIONS = %w[
    ManagedUpdateItem
    OptionalInstallItem
    UninstallItem
    InstallItem
  ]

  def sever_all_connections
    sever_plural_connections
    sever_singular_connections
    sever_incoming_connections
  end

  def sever_plural_connections
    PLURAL_CONNECTIONS.each do |relationship|
      @package.send(
        [relationship, '='].join.to_sym,
        @package.send(relationship).select { |val|
          val.manifest.environment == @new_environment
      })
    end
  end

  def sever_singular_connections
    SINGULAR_CONNECTIONS.each do |relationship|
      if @package.send(relationship).environment != @new_environment
        @package.send(
          [relationship, '='].join.to_sym,
          nil
        )
      end
    end
  end

  def sever_incoming_connections
    INCOMING_CONNECTIONS.map(&:constantize).each do |klass|
      klass.where(package_id: @package.id)
           .each { |manifest|
             if manifest.manifest.respond_to? environment
               manifest.destroy unless manifest.manifest.environment == @new_environment
             end
           }
    end
  end
end

