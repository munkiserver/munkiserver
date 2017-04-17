module Api
  module V1
    class PackagesController < ApiController
      def create
        process_package_upload = ProcessPackageUpload.new(package_file: params[:package_file],
                                                          pkginfo_file: params[:pkginfo_file],
                                                          special_attributes: { unit_id: current_unit.id })

        process_package_upload.process

        respond_to do |format|
          if process_package_upload.processed?
            format.json do
              render(json: success_message(process_package_upload), status: :ok)
            end
          else
            format.json do
              render(json: failure_message(process_package_upload), status: :unprocessable_entity)
            end
          end
        end
      end

      private

      def success_message(process_package_upload)
        processed_package_upload_params = process_package_upload.package.to_params

        {
          type: :success,
          message: "Package successfully uploaded",
          url: package_url(processed_package_upload_params),
          edit_url: edit_package_url(processed_package_upload_params)
        }
      end

      def failure_message(process_package_upload)
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
