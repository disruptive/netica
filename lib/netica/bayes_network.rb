module Netica
  class BayesNetwork
    attr_accessor :current_network, :dne_file_path

    def initialize(dne_file_path = nil)
      if dne_file_path
        self.dne_file_path = dne_file_path
        load_dne_file
      end
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
      NeticaLogger.info "network_hash => #{network_hash}"
      network_hash["decision_nodes"].each do |node_name, node_value|
        getNode(node_name).value = node_value
      end
    end

    def state
      { :dne_file_path => dne_file_path, :decision_nodes => node_hash(decision_nodes), :nature_nodes => node_hash(nature_nodes) }
    end

    def node_hash(nodes)
      node_hash = {}
      nodes.collect{|dn| node_hash.store(dn.name, dn.value) }
      node_hash
    end

    private

    def load_dne_file
      NeticaLogger.info "Looking for BayesNet .dne file at #{dne_file_path}..."
      streamer = Java::NorsysNetica::Streamer.new(dne_file_path)
      self.current_network = Java::NorsysNetica::Net.new(streamer)
      self.current_network.compile()
      NeticaLogger.info "Initialized BayesNet -- #{self.current_network.object_id}"
      self.decision_nodes.each{ |n| n.value = 0 }
    end
  end
end