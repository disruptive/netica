require 'singleton'
require 'redis'

module Netica
  class Environment
    include Singleton

    @@active_networks = []
    @@explorations = []
    @@processor = nil
    @@redis = nil

    def self.engage(settings)
      NeticaLogger.start_logging(settings[:logfile])
      @@processor = Java::NorsysNetica::Environ.new(settings[:license_key])
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
  end
end