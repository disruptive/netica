module Netica
  require 'json'

  # provides a persistable object container for a Netica Bayes net.
  class ActiveNetwork
    class ActiveNetwork::NodeNotFound < RuntimeError; end
    class ActiveNetwork::NetworkNotFound < RuntimeError; end

    attr_accessor :network, :token

    def initialize(token, filepath = nil)
      Netica::NeticaLogger.info "initializing active network for #{token}"
      self.token = token
      if filepath
        self.network = BayesNetwork.new(filepath)
      end
      processor = Netica::Environment.instance
      processor.active_networks << self
    end

    def to_s
      token
    end

    # Increment a specified network node
    #
    # @param nodeName [String] name of the node to be incremented
    # @return [true,false,nil] outcome of the incr() attempt
    def incr_node(nodeName)
      if network
        node = network.node(nodeName)
        if node
          return node.incr()
        else
          raise ActiveNetwork::NodeNotFound
        end
      else
        raise ActiveNetwork::NetworkNotFound
      end
    end

    # Export the state of the ActiveNetwork as a Hash
    #
    # @param nodeName [String] name of the node to be incremented
    # @return [Hash] network state and object class name
    def state
      {
        :network => network.state,
        :class   => self.class.to_s
      }
    end

    # Save ActiveNetwork to an associated redis store, if one is defined.
    #
    # @return [true,false,nil] outcome of redis.set, or nil if redis is not found
    def save
      if Netica::Environment.instance.redis
        return Netica::Environment.instance.redis.set(token, JSON.dump(state))
      end
    end

    # Retrieve ActiveNetwork from current Netica Environment instance
    # or an associated redis store, if one is defined.
    #
    # @param token [String] identifying token for ActiveNetwork sought
    # @return [ActiveNetwork] ActiveNetwork object found
    def self.find(token)
      Netica::Environment.instance.active_networks.each do |an|
        return an if an.token == token
      end
      Netica::NeticaLogger.info "Network #{token} not found in current instance."
      if Netica::Environment.instance.redis
        stored_state = Netica::Environment.instance.redis.get(token)
        if stored_state
          hash = JSON.parse(stored_state)
          active_network = Object.const_get(hash['class']).new(token)
          active_network.load_from_saved_state(hash)
          return active_network
        else
          Netica::NeticaLogger.info "Network #{token} not found in redis."
        end
      end
      return nil
    end

    # Export the state of the ActiveNetwork as a Hash
    #
    # @param hash [Hash] network state to be restored
    # @return [Hash] network state and object class name
    def load_from_saved_state(hash)
      self.network = BayesNetwork.new(hash["network"]["dne_file_path"])
      self.network.load_from_state(hash["network"])
    end
  end
end