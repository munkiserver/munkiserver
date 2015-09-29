require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Munki
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    settings = nil
    begin
      settings = YAML.load(File.read("#{Rails.root}/config/settings.yaml"))
    rescue Errno::ENOENT
      # config/settings.yaml doesn't exist
    end   # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths += %W(
      #{Rails.root}/app/models/widgets
      #{Rails.root}/app/models/join_models
      #{Rails.root}/app/models/behaviours
      #{Rails.root}/app/models/manifest
      #{Rails.root}/app/models/service
      #{Rails.root}/app/models/privilege_granters
      #{Rails.root}/app/models/null
      #{Rails.root}/lib
    )

    # Add custom mime types
    Mime::Type.register "text/plist", :plist

    # Where we store the packages
    package_dir = ENV['PACKAGE_DIR'] || 'packages'
    PACKAGE_DIR = Rails.root + package_dir

    # Make sure the dir exists
    FileUtils.mkdir_p(PACKAGE_DIR)
    # Command line utilities
    MAKEPKGINFO = Pathname.new("/usr/local/munki/makepkginfo")


    # A secret is required to generate an integrity hash for cookie session data
    config.secret_token = "407738ccc1518e5a71714d7dc16365c424732e543d791c22bffca1d6d8ac6949e08688836cc69635dc29a8d48b607bd73cb26bcad384c1fbecee44f552f8070c"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
    config.filter_parameters << :pass # Create session uses params[:pass]
  end
end
