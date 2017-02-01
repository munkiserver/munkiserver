class PackagesController < ApplicationController
  cache_sweeper :package_sweeper, :only => [:create, :update,  :update_multiple, :destroy]

  def index
    @package_branches = PackageBranch
                          .find_for_index(current_unit, current_environment)
                          .includes(:package_category, :unit, :packages => [:unit], :version_tracker => [:download_links])
                          .uniq_by {|branch| branch.id }
    @environments = Environment.all

    respond_to do |format|
      format.html
    end
  end

  def show
    respond_to do |format|
      if @package.present?
        format.html
        format.plist { render :text => @package.to_plist }
      else
        format.html { render page_not_found }
        format.plist { render page_not_found }
      end
    end
  end

  def edit
    @package.environment_id = params[:environment_id] if params[:environment_id].present?
  end

  def update
    respond_to do |format|
      if @package.update_attributes(params[:package])
        flash[:notice] = "Package was successfully updated."
        format.html { redirect_to package_path(@package.to_params) }
        format.xml { head :ok }
      else
        flash[:error] = "Could not update package!"
        format.html { render :action => "edit" }
        format.xml { render :xml => @package.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new
  end

  def create
    process_package_upload = ProcessPackageUpload.new(:package_file => params[:package_file],
                                                      :file_url => params[:file_url],
                                                      :pkginfo_file => params[:pkginfo_file],
                                                      :makepkginfo_options => params[:makepkginfo_options],
                                                      :special_attributes => {:unit_id => current_unit.id})
    process_package_upload.process

    respond_to do |format|
      if process_package_upload.processed?
        flash[:notice] = "Package successfully uploaded"
        format.html { redirect_to edit_package_path process_package_upload.package.to_params }
      else
        flash[:error] = "A problem occurred while processing package upload: #{process_package_upload.error_message}"
        format.html { render :action => :new }
      end
    end
  end

  def destroy
    if @package.destroy
        flash[:notice] = "Package was destroyed successfully"
    end

    respond_to do |format|
      format.html { redirect_to packages_path(current_unit) }
    end
  end

  # Allows multiple edits
  def edit_multiple
    @packages = Package.find(params[:selected_records])
  end

  def update_multiple
    @packages = Package.where(id: params[:selected_records])
    results = {}
    exceptionMessage = nil

    if params[:commit] == 'Delete'
      destroyed_packages = @packages.destroy_all
      redirect_to packages_path, :flash => { :notice => "All #{destroyed_packages.length} selected packages were successfully deleted." }
      return
    end

    begin
      results = Package.bulk_update_attributes(@packages, params[:package])
    rescue PackageError => e
      exceptionMessage = e.to_s
    end
    respond_to do |format|
      flash[:error] = results[:messages].join('</br>').html_safe if results[:messages]
      flash[:error] += exceptionMessage if exceptionMessage
      if results[:successes] == results[:total]
        flash[:notice] = "All #{results[:total]} #{'package'.pluralize if results[:total] > 1} were updated successfully"
      else
        flash[:warning] = "#{results[:successes]} #{'package'.pluralize if results[:successes] > 1} of #{results[:total]} #{'package'.pluralize if results[:total] > 1} were updated."
      end
      format.html { redirect_to packages_path }
    end
  end


  # Used to download the actual package (typically a .dmg)
  def download
    respond_to do |format|
      if @package.present?
        format.html do
          send_file Munki::Application::PACKAGE_DIR + @package.installer_item_location, :filename => @package.to_s(:download_filename)
          fresh_when :etag => @package, :last_modified => @package.updated_at.utc, :public => true
        end

        format.json { render :text => @package.to_json(:methods => [:name, :display_name]) }
      else
        render page_not_found
      end
    end
  end

  # Used to download the package icon for Munki 2 as a .png
  def icon
    respond_to do |format|
      if @package.present?
        format.png do
          send_file @package.icon.photo.path, :url_based_filename => true, :type => "image/png", :disposition => "inline"
          fresh_when :etag => @package, :last_modified => @package.created_at.utc, :public => true
        end
      else
        render page_not_found
      end
    end
  end



  # Used to check for available updates across all units
  def check_for_updates
    Backgrounder.call_rake("packages:check_for_updates")
    flash[:notice] = "Checking for updates now"
    redirect_to :back
  end

  def environment_change
    @environment_id = params[:environment_id] if params[:environment_id].present?

    respond_to do |format|
      format.js
    end
  end

  def index_shared
    @branches = PackageBranch.not_unit(current_unit).shared.paginate(
      :page => params[:page],
      :per_page => params[:per_page] || 20
    ).includes(:shared_packages, :unit, :packages => [:require_items, :update_for_items]).find(:all, :joins => :packages, :order => 'packages.updated_at DESC')
  end

  # Import shared packages from another unit
  def import_multiple_shared
    cloned_packages = Package.clone_packages(Package.shared.where(:id => params[:selected_records]), current_unit)
    save_results = cloned_packages.map(&:save)

    respond_to do |format|
      unless save_results.include?(false)
        flash[:notice] = "Successfully imported packages"
      else
        flash[:error] = "Failed to import all or some packages"
      end

      format.html { redirect_to shared_packages_path(current_unit) }
    end
  end

  # Load a singular resource into @package for all actions
  def load_singular_resource
    action = params[:action].to_sym
    if [:show, :edit, :update, :destroy].include?(action)
      @package = Package.find_where_params(params)
    elsif [:index, :new, :create, :edit_multiple, :update_multiple, :check_for_updates, :index_shared, :import_shared, :import_multiple_shared].include?(action)
      @package = Package.new(:unit_id => current_unit.id)
    elsif [:download].include?(action)
      @package = Package.find(params[:id].to_i)
    elsif [:icon].include?(action)
      package_branch = PackageBranch.where(:name => params[:package_branch]).first
      @package = Package.where(:package_branch_id => package_branch.id).last
    elsif [:environment_change].include?(action)
      @package = Package.find(params[:package_id])
    else
      raise Exception.new("Unable to load singular resource for #{action} action in #{params[:controller]} controller.")
    end
  end
end
