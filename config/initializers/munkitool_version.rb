Munki::Application::MUNKITOOLS_VERSION = if Munki::Application::MUNKI_TOOLS_AVAILABLE
                                           `/usr/local/munki/makepkginfo -V`
                                         else
                                           "not installed"
                                         end
