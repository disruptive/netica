module Netica
  require 'json'

  # provides a persistable object container for a Netica Bayes net.
  class ActiveNetwork
    class ActiveNetwork::NodeNotFound < RuntimeError; end
    class ActiveNetwork::NetworkNotFound < RuntimeError; end

    attr_accessor :network, :token, :created_at, :updated_at, :reloaded_at, :in_use, :filepath

    def initialize(token, filepath = nil)
      Netica::NeticaLogger.info "Initializing #{self.class} for #{token}."
      self.created_at = Time.now
      self.updated_at = Time.now
      self.token      = token
      self.in_use     = false
      
      if filepath
        self.filepath = filepath
        self.network  = BayesNetwork.new(filepath)
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

    # Retrieve ActiveNetwork from current Netica Environment instance
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
      return nil
    end
    
    # Destroy the ActiveNetwork
    #
    # @return [Hash] outcome of deletion attempt
    def destroy
      outcome = { token: token, deletion: { memory: nil }}
      environment = Netica::Environment.instance
      rejection = environment.network_container.reject!{|network| network.token == token}
      outcome[:deletion][:memory] = rejection.is_a?(Array)
      outcome
    end
    
    
    # Load ActiveNetwork from a Hash
    #
    # @param hash [Hash] network state to be restored
    def load_from_saved_state(hash)
      if filepath
        self.network = BayesNetwork.new(filepath)
      else
        self.filepath = hash["network"]["dne_file_path"]
        self.network = BayesNetwork.new(hash["network"]["dne_file_path"])
      end
      self.reloaded_at = Time.now
      self.network.load_from_state(hash["network"])
    end
  end
end
