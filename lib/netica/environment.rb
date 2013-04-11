require 'singleton'

module Netica
  class Environment
    include Singleton

    @@exploration_networks = []
    @@explorations = []
    @@processor = nil

    def initialize(license_key)
      @@processor = Java::NorsysNetica::Environ.new(license_key)
      NeticaLogger.info "Initializing the Netica Environment #{@@processor.object_id}"
    end

    def processor
      @@processor
    end

    def exploration_networks
      current_explorations = @@exploration_networks.collect{ |exp_net| [exp_net.exploration_id, exp_net.object_id, exp_net.network.object_id] }
      NeticaLogger.info current_explorations
      @@exploration_networks
    end

    def process_event(sim_event_hash)
      level         = /\A(\S+) .+\z/.match(sim_event_hash['problemName'])[1]
      node_name     = sim_event_hash['nodeName']
      se_id         = sim_event_hash['supportable_event_id']
      exp_token     = sim_event_hash['exploration_token']
      exp_id        = sim_event_hash['exploration_id']
      assessment_id = sim_event_hash['assessment_id']
      a_identifier  = sim_event_hash['a_identifier']
      dne_files     = sim_event_hash['dne_files']

      @exp_network = ExplorationNetwork.find(exp_token, exp_id, a_identifier, dne_files, level)

      NeticaLogger.info "env_object_id: #{@@processor.object_id}, exp_id: #{exp_id}, level: #{level}, node_name: #{node_name}, supportable_event_id: #{se_id}, assessment_id: #{assessment_id}, bn_object: #{@exp_network.network.current_network.object_id}"
      @exp_network.incr_node(node_name)
      @exp_network.state.merge({ :ee_key => "#{se_id}.bayesResponse", :ee_screen => sim_event_hash['screen_name'] })
    end
  end
end