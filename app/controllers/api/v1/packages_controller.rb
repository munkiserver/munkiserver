module Api
  module V1
    class PackagesController < ApiController
      def index
        package_branches = PackageBranch.where(unit_id: current_unit.id)
                                        .includes(:package_category, :unit, packages: [:unit])
                                        .uniq_by(&:id)
        respond_to do |format|
          format.json do
            render(json: index_message_for(package_branches), status: :ok)
          end
        end
      end

      def show
        respond_to do |format|
          format.json do
            render(json: show_message_for(@package))
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
            "category": package_branch.package_category.name,
            "packages": version_details_for(package_branch.packages)
          }
        }
      end

      def version_details_for(packages)
        packages.map do |p|
          {
            "version": p.version,
            "environment": p.environment.name.downcase
          }
        end
      end

      def show_message_for(package)
        {
          "exists" => package.persisted?,
          "version" => package.version,
          "environment" => package.environment.try(:name).try(:downcase)
        }
      end

      def environments
        @environments ||= Environment.all
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

        case action
        when :index, :create
          @package = Package.new(unit_id: current_unit.id)
        when :show
          params["version"] = Package.version_fixer(params["version"])
          @package = Package.find_where_params(params) || Package.new(unit_id: current_unit.id)
        else
          raise Exception, "Unable to load singular resource for #{action} action in #{params[:controller]} controller."
        end
      end
    end
  end
end
