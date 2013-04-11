module Netica
  class BayesNetwork
    attr_accessor :current_network

    def initialize(dne_file_path)
      NeticaLogger.info "Looking for BayesNet .dne file at #{dne_file_path}..."
      streamer = Streamer.new(dne_file_path)
      self.current_network = Java::NorsysNetica::Net.new(streamer)
      self.current_network.compile()
      NeticaLogger.info "Initialized BayesNet -- #{self.current_network.object_id}"
      self.decision_nodes.each{ |n| n.value = 0 }
    end

    # retrieve a node from the associated network
    # @param String nodeName
    # @return Node
    def getNode(nodeName)
      nodes.select{ |n| n if n.name == nodeName }[0]
    end

    def nodes
      current_network.nodes
    end

    def decision_nodes
      nodes.collect{ |n| n if n.decision_node? }.compact
    end

    def nature_nodes
      nodes.collect{ |n| n if n.nature_node? }.compact
    end

    def load_from_state(network_hash)
      NeticaLogger.info "Reloading Network State from Hash..."
      network_hash["decision_nodes"].each do |node_name, node_value|
        getNode(node_name).value = node_value
      end
    end

    def state
      # NeticaLogger.info node_hash(nature_nodes)
      { :decision_nodes => node_hash(decision_nodes), :nature_nodes => node_hash(nature_nodes) }
    end

    def node_hash(nodes)
      node_hash = {}
      nodes.collect{|dn| node_hash.store(dn.name, dn.value) }
      node_hash
    end
  end
end