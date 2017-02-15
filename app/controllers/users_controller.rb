class UsersController < ApplicationController  
  def index
    @users = User.all
  end

  def new
  end

  def create
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = "#{@user.username} was successfully created."
        format.html { redirect_to(users_path) }
      else
        flash[:error] = "Failed to create user!"
        format.html { render :action => "new"}
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = "#{@user.username} was successfully updated."
        format.html { redirect_to edit_user_path(@user) }
        format.xml  { head :ok }
      else
        flash[:error] = 'Could not update user!'
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @user.destroy
        flash[:notice] = "#{@user.username} was successfully removed."
        format.html { redirect_to(users_path) }
      else
        format.html { render :action => "index" }
      end
    end
  end

  def create_api_key
    respond_to do |format|
      if key = @user.api_keys.create
        flash[:notice] = "#{@user.username} now has an API key: #{key.key}."
      else
        flash[:error] = "Failed to create API Key!"
      end
      
      format.html { redirect_to(edit_user_path(@user)) }
    end
  end

  def destroy_api_key
    respond_to do |format|
      if key = @user.api_keys.find_by_key(params[:key].strip)
        key.destroy
        flash[:notice] = "API Key successfully removed."
      else
        flash[:error] = "Failed to delete API Key"
      end
      format.html { redirect_to(edit_user_path(@user)) }
    end
  end

  private
  def load_singular_resource
    action = params[:action].to_sym
    if [:show, :edit, :update, :destroy, :create_api_key, :destroy_api_key].include?(action)      
      @user = User.find_by_username(params[:id])
    elsif [:index, :new, :create].include?(action)
      @user = User.new
    end
  end
end
