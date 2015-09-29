Munki::Application.routes.draw do
  resources :units, :except => [:show] do
    member do
      get 'settings/edit' => 'unit_settings#edit'
      put 'settings' => 'unit_settings#update'
    end
  end

  resources :users, :except => [:show]

  # Session
  match '/login' => "sessions#new", :via => [:get, :post]
  post 'create_session' => 'sessions#create'
  post '/logout' => 'sessions#destroy'

  # Computer checkin URL
  post 'checkin/:id' => 'computers#checkin'

  # Make munki client API
  get ':id.plist', :controller => 'computers', :action => 'show_plist', :format => 'manifest', :id => /[A-Za-z0-9_\-\.%:]+/, :as => "computer_manifest"
  get 'computers/:id.plist', :controller => 'computers', :action => 'show_plist', :format => 'manifest', :id => /[A-Za-z0-9_\-\.%:]+/
  get 'site_default', :controller => 'computers', :action => 'show_plist', :format => 'manifest', :id => '00:00:00:00:00:00'
  get 'client_resources/:id.plist.zip', :controller => 'computers', :action => 'show_resource', :format => :zip, :id => /[A-Za-z0-9_\-\.%:]+/, :as => "computer_resource"
  get 'client_resources/site_default.zip', :controller => 'computers', :action => 'show_resource', :format => :zip, :id => '00:00:00:00:00:00'

  get 'pkgs/:id.json' => 'packages#download', :format => :json, :id => /[A-Za-z0-9_\-\.%]+/
  get 'icons/:package_branch.png' => 'packages#icon', :format => :png, :package_branch => /[A-Za-z0-9_\-\.%]+/
  get 'catalogs/:unit_environment' => 'catalogs#show', :format => 'plist'
  get 'pkgs/:id' => 'packages#download', :as => 'download_package', :id => /[A-Za-z0-9_\-\.%]+/
  get 'icons/:id.png' => 'package_branches#download_icon', :as => 'download_icon', :format => 'png', :id => /[A-Za-z0-9_\-\.%]+/
  get '/configuration/:id.plist', :controller => 'computers', :action => 'show', :format => 'client_prefs', :id => /[A-Za-z0-9_\-\.:]+/

  # add units into URLs
  scope "/:unit_shortname" do
    resources :computers do
      get :import, :on => :new
      get 'managed_install_reports/:id' => 'managed_install_reports#show', :on => :collection, :as => "managed_install_reports"
      get 'environment_change(.:format)', :action => "environment_change", :as => 'environment_change'
      get 'unit_change(.:format)', :action => "unit_change", :as => 'unit_change'
      get 'update_warranty', :action => "update_warranty", :as => 'update_warranty'
      get 'client_prefs', :on => :member, :as => "client_prefs"

      collection do
        post :create_import#, :force_redirect
        put :update_multiple
        get :edit_multiple
      end
    end

    controller :packages do
      get 'packages(.:format)', :action => 'index', :as => 'packages'
      post 'packages(.:format)', :action => 'create'

      scope '/packages' do
        get 'add(.:format)', :action => 'new', :as => 'new_package'
        put "shared/import_multiple_shared", :action => 'import_multiple_shared', :as => "import_multiple_shared_packages"
        get "shared", :action => 'index_shared', :as => "shared_packages"
        get 'multiple(.:format)', :action => 'edit_multiple', :as => 'edit_multiple_packages'
        put 'multiple(.:format)', :action => 'update_multiple'
        get 'check_for_updates', :action => 'check_for_updates', :as => 'check_for_package_updates'
        get ':package_id/environment_change(.:format)', :action => "environment_change", :as => 'package_environment_change'
        constraints({:version => /.+/}) do
          get ':package_branch/:version/edit(.:format)', :action => 'edit', :as => 'edit_package'
          get ':package_branch/:version(.:format)', :action => 'show', :as => 'package'
          put ':package_branch/:version(.:format)', :action => 'update'
          delete ':package_branch/:version(.:format)', :action => 'destroy'
        end
      end
    end

    controller :package_branches do
      scope "/packages" do
        get ":name(.:format)", :action => "edit", :as => "edit_package_branch"
        put ":name(.:format)", :action => 'update'
      end
    end

    resources :user_groups, :except => :show

    resources :computer_groups do
      get 'environment_change(.:format)', :action => "environment_change", :as => 'environment_change'
    end

    resources :bundles do
      get 'environment_change(.:format)', :action => "environment_change", :as => 'environment_change'
    end

    get 'install_items/edit_multiple/:computer_id' => 'install_items#edit_multiple', :as => "edit_multiple_install_items"
    put 'install_items/update_multiple' => 'install_items#update_multiple', :as => "update_multiple_install_items"
  end

  get 'dashboard' => "dashboard#index", :as => "dashboard"
  get 'dashboard/widget/:name' => 'dashboard#widget', :as => "widget"
  get 'dashboard/dismiss_manifest/:id' => 'dashboard#dismiss_manifest', :as => "dismiss_manifest"

  get "permissions" => "permissions#index", :as => "permissions"
  get "permissions/edit/:principal_pointer(/:unit_id)" => "permissions#edit", :as => "edit_permissions"
  put "permissions" => "permissions#update", :as => "update_permissions"

  # Redirect unit hostname to computer index
  get "/:unit_shortname" => redirect("/%{unit_shortname}/computers")

  root :to => redirect("/login")
end
