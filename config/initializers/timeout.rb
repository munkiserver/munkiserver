Rack::Timeout.timeout = Integer(ENV.fetch('RACK_TIMEOUT', 600)) # seconds
