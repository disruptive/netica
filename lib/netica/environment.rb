require 'singleton'
require 'redis'

module Netica
  class Environment
    include Singleton
    
    @@network_container = []
    @@processor = nil
    @@redis = nil
    @@logfile = nil

    # Initializes logging, a Netica Environ object and a connection to
    # redis, if defined.
    #
    # @param settings [Hash] Settings for initialization
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
      #@@processor.control_concurrency("ExternalThreads", "OptimizeSafely")
      @@processor.control_concurrency("ExternalThreads", "Serialize")
      if settings[:redis]
        @@redis = Redis.new(settings[:redis])
      end
      
      if settings[:network_container]
        @@network_container = settings[:network_container]
      else
        @@network_container = @@processor.active_networks
      end
      
      NeticaLogger.info "@@network_container is #{@@network_container.class} #{@@network_container.object_id}."  
      NeticaLogger.info "Initializing the Netica Environment #{@@processor.object_id}"
    end

    def processor
      @@processor
    end

    def active_networks
      @@network_container
    end

    def redis
      @@redis
    end

    def logfile_path
      @@logfile
    end
  end
end
