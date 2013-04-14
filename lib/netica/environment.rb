require 'singleton'
require 'redis'

module Netica
  class Environment
    include Singleton

    @@active_networks = []
    @@explorations = []
    @@processor = nil
    @@redis = nil
    @@logfile = nil

    def self.engage(settings = {})
      if settings[:logfile]
        @@logfile = settings[:logfile]
      else
        @@logfile = "#{File.dirname(__FILE__)}/../../log/netica.log"
      end
      if settings[:license_key]
        @@processor = Java::NorsysNetica::Environ.new(settings[:license_key])
      else
        @@processor = Java::NorsysNetica::Environ.new(nil)
      end
      if settings[:redis]
        @@redis = Redis.new(settings[:redis])
      end
      NeticaLogger.info "Initializing the Netica Environment #{@@processor.object_id}"
    end

    def processor
      @@processor
    end

    def active_networks
      @@active_networks
    end

    def redis
      @@redis
    end

    def logfile_path
      @@logfile
    end
  end
end