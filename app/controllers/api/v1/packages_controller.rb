module Api
  module V1
    class PackagesController < ApiController
      def index
        packages_branches = PackageBranch.where(unit_id: current_unit.id)
                                         .includes(:package_category, :unit, packages: [:unit])
                                         .uniq_by(&:id)
        respond_to do |format|
          format.json do
            render(json: index_message_for(package_branches), status: :ok)
          end
        end
      end

      def create
        process_package_upload = ProcessPackageUpload.new(package_file: params[:package_file],
                                                          pkginfo_file: params[:pkginfo_file],
                                                          special_attributes: { unit_id: current_unit.id })

        process_package_upload.process

        respond_to do |format|
          if process_package_upload.processed?
            format.json do
              render(json: creation_success_message(process_package_upload), status: :ok)
            end
          else
            format.json do
              render(json: creation_failure_message(process_package_upload), status: :unprocessable_entity)
            end
          end
        end
      end

      private

      def index_message_for(package_branches)
        package_branches.map do |pb|
          package_branch_item(pb)
        end
      end

      def package_branch_item(package_branch)
        {
          "package_branch": {
            "name": package_branch.name,
            "display": package_branch.display_name,
            "category": package_branch.package_category,
            "versions": {
              "summary": versions_for(package_branch.packages),
              "details": version_details_for(package_branch.packages)
            }
          }
        }
      end

      def version_details_for(packages)
        # Return an array of hashes where key is environment name
        # and value is an array of version strings. I.e.
        # "staging": ["10.1.3"],
        # "production": ["10.1.1", "10.1.2"]
        version_hash = {}

        environments.each do |e|
          p = packages.where(environment_id: e.id)
          version_hash[environment.name.lcase] = versions_for(p)
        end

        version_hash
      end

      def versions_for(packages)
        packages.map(&:version)
      end

      def environments
        @environments ||= Environments.all
      end

      def creation_success_message(process_package_upload)
        processed_package_upload_params = process_package_upload.package.to_params

        {
          type: :success,
          message: "Package successfully uploaded",
          url: package_url(processed_package_upload_params),
          edit_url: edit_package_url(processed_package_upload_params)
        }
      end

      def creation_failure_message(process_package_upload)
        {
          type: :failure,
          message: "A problem occurred while processing package upload: #{process_package_upload.error_message}"
        }
      end

      def load_singular_resource
        action = params[:action].to_sym

        if action == :create
          @package = Package.new(unit_id: current_unit.id)
        else
          raise Exception, "Unable to load singular resource for #{action} action in #{params[:controller]} controller."
        end
      end
    end
  end
end
