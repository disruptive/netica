module Netica
  require 'json'

  class ActiveNetwork
    attr_accessor :network, :token

    def initialize(token, filepath = nil)
      NeticaLogger.info "initializing active network for #{token}"
      self.token   = token
      if filepath
        self.network = BayesNetwork.new(filepath)
      end
      processor = Netica::Environment.instance
      processor.active_networks << self
    end

    def to_s
      token
    end

    def incr_node(nodeName)
      network.getNode(nodeName).incr() if network
    end

    def state
      {
        :network => network.state,
        :class   => self.class.to_s
      }
    end

    def save
      if Netica::Environment.instance.redis
        Netica::Environment.instance.redis.set(token, JSON.dump(state))
      end
    end

    def self.find(token)
      Netica::Environment.instance.active_networks.each do |an|
        return an if an.token == token
      end
      if Netica::Environment.instance.redis
        stored_state = Netica::Environment.instance.redis.get(token)
        if stored_state
          hash = JSON.parse(stored_state)
          active_network = Object.const_get(hash['class']).new(token)
          active_network.load_from_saved_state(hash)
          return active_network
        end
      end
      return nil
    end

    def load_from_saved_state(hash)
      self.network = BayesNetwork.new(hash["network"]["dne_file_path"])
      network.load_from_state(hash["network"])
    end
  end
end