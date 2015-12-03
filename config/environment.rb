# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Munki::Application.initialize!

# Monkey patch for AR
require File.expand_path('../../lib/patches/abstract_mysql_adapter', __FILE__)
