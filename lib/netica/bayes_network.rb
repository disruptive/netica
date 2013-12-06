module Netica
  class BayesNetwork
    require 'json'

    attr_accessor :current_network, :dne_file_path

    def initialize(dne_file_path = nil)
      Netica::NeticaLogger.info "Initializing #{self.class} #{self.object_id}"
      if dne_file_path
        self.dne_file_path = dne_file_path
        load_dne_file
      end
    end

    # retrieve the node from the associated network whose name matches
    # the "nodeName" supplied.
    #
    # @param nodeName [String] Name of the node to find
    # @return [Node]
    def node(nodeName)
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

    def node_sets
      current_network.getAllNodesets(false).split(",").collect{|ns_name| node_set(ns_name)}
    end

    def node_set(name)
      nodes.collect{ |n| n if n.isInNodeset(name) }.compact.sort{|a,b| b.beliefs <=> a.beliefs }
    end

    def load_from_state(network_hash)
      network_hash["decision_nodes"].each do |node_name, node_value|
        Netica::NeticaLogger.info "Setting #{node_name} => #{node_value}"
        node(node_name).value = node_value
      end
      
      network_hash["nature_nodes"].each do |node_name, node_value_hash|
        next unless node_name == 'XRay'
        Netica::NeticaLogger.info "Setting #{node_name} => #{node_value_hash}"
        node(node_name).value = node_value_hash
      end
    end

    def state
      {
        :dne_file_path  => dne_file_path,
        :decision_nodes => node_hash(decision_nodes),
        :nature_nodes   => node_hash(nature_nodes)
      }
    end

    def node_hash(nodes)
      node_hash = {}
      nodes.collect{|dn| node_hash.store(dn.name, dn.value) }
      node_hash
    end

    def analyze(input_values, output_nodes)
      outcome = []
      input_values.each do |value_collection|
        id = value_collection.delete("id")
        value_collection.each do |nodeName, value|
          node(nodeName).enterValue(value)
        end
        result = { :id => id }
        output_nodes.each do |nodeName|
          result[nodeName] = node(nodeName).value
        end
        outcome << result
        current_network.retractFindings
      end
      outcome
    end

    private

    def load_dne_file
      NeticaLogger.info "Looking for BayesNet .dne file at #{dne_file_path}..."
      streamer = Java::NorsysNetica::Streamer.new(dne_file_path)
      self.current_network = Java::NorsysNetica::Net.new(streamer)
      NeticaLogger.info "Initialized BayesNet -- #{self.current_network.object_id}"
      self.decision_nodes.each{ |n| n.value = 0 }
      self.current_network.compile()
    end
  end
end
