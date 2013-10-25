module Netica
  require 'json'

  # provides a persistable object container for a Netica Bayes net.
  class ActiveNetwork
    class ActiveNetwork::NodeNotFound < RuntimeError; end
    class ActiveNetwork::NetworkNotFound < RuntimeError; end

    attr_accessor :network, :token, :created_at, :updated_at, :reloaded_at, :in_use

    def initialize(token, filepath = nil)
      Netica::NeticaLogger.info "Initializing #{self.class} for #{token}."
      self.created_at = Time.now
      self.updated_at = Time.now
      self.token      = token
      self.in_use     = false
      
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
      Netica::NeticaLogger.info "Incrementing #{nodeName} for #{token}, object_id: #{self.object_id}."
      if network
        node = network.node(nodeName)
        if node
          self.updated_at = Time.now
          return node.incr()
        else
          raise ActiveNetwork::NodeNotFound, "Node #{nodeName} not found in network."
        end
      else
        raise ActiveNetwork::NetworkNotFound
      end
    end

    # Export the state of the ActiveNetwork as a Hash
    #
    # @return [Hash] network state and object class name
    def state
      {
        :network     => network.state,
        :class       => self.class.to_s,
        :created_at  => self.created_at,
        :updated_at  => self.updated_at,
        :reloaded_at => self.reloaded_at
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
      environment = Netica::Environment.instance
      Netica::NeticaLogger.info "Searching in #{environment.network_container.class} #{environment.network_container.object_id} (length: #{environment.network_container.length}) for #{token}."
      environment.network_container.each do |an|
        if an.token == token
          until !an.in_use
            Netica::NeticaLogger.info "Network #{token} is locked."
            sleep 1
          end
          return an
        end
      end
      Netica::NeticaLogger.info "Network #{token} not found in current instance #{environment.object_id}."
      if Netica::Environment.instance.redis
        stored_state = Netica::Environment.instance.redis.get(token)
        if stored_state
          hash = JSON.parse(stored_state)
          active_network = Object.const_get(hash['class']).new(token)
          active_network.load_from_saved_state(hash)
          Netica::NeticaLogger.info "Network #{token} reloaded from saved state: #{hash}"
          return active_network
        else
          Netica::NeticaLogger.info "Network #{token} not found in redis."
        end
      end
      return nil
    end
    
    def destroy
      environment = Netica::Environment.instance
      environment.network_container.delete_if{|network| network.token == token}
      if environment.redis
        environment.redis.del(token)
      end
    end

    # Export the state of the ActiveNetwork as a Hash
    #
    # @param hash [Hash] network state to be restored
    # @return [Hash] network state and object class name
    def load_from_saved_state(hash)
      self.network = BayesNetwork.new(hash["network"]["dne_file_path"])
      self.network.load_from_state(hash["network"])
      self.reloaded_at = Time.now
    end
  end
end
