Munki::Application::MUNKI_TOOLS_AVAILABLE =
  if File.exists?("/usr/bin/hdiutil") && File.directory?("/usr/local/munki")
    true
  else
    false
  end
