module Netica
  class ExplorationNetwork
    attr_accessor :exploration_token, :exploration_id, :network, :level, :a_identifier, :dne_files

    # look for exploration_events with the same assignment_id
    # get last eventKey for bayesResponse, then load network from there
    # using load_from_saved_state_xml(xml_string)
    def initialize(exploration_token, exploration_id, a_identifier, dne_files, level)
      NeticaLogger.info "Creating Exploration Network for #{exploration_id}"
      self.level              = level
      self.exploration_token  = exploration_token
      self.exploration_id     = exploration_id
      self.a_identifier       = a_identifier
      self.dne_files          = dne_files

      #assessment_level = AssessmentLevel.find(:first, :conditions => ["assessment_id = ? AND name = ?", assessment_id, level])
      filepath = "/Users/jerry/Code/repositories/sim_netica/networks/vtg/IquanaLevel1_V3.dnet"
      self.network            = BayesNetwork.new(filepath)

      # exploration = Exploration.find(exploration_id)
#
#       if exploration
#         NeticaLogger.info "Looking for stored network for #{exploration_id} #{level}"
#         net_state = exploration.stored_network_state(level)
#         if net_state && net_state.length > 0
#           NeticaLogger.info "Loading stored network for #{exploration_id} #{level}"
#           NeticaLogger.info net_state
#           hash = Hash.from_xml(net_state)
#           network.load_from_state(hash["network"])
#           NeticaLogger.info network.state
#         end
#       end

      processor = Netica::Environment.instance
      processor.exploration_networks << self
    end

    def self.find(exploration_token, exploration_id, a_identifier, dne_files, level)
      active_network = nil
      processor = Netica::Environment.instance
      processor.exploration_networks.each do |active_network|
        return active_network if active_network.exploration_token == exploration_token && active_network.level == level
      end
      ExplorationNetwork.new(exploration_token, exploration_id, a_identifier, dne_files, level)
    end

    def incr_node(nodeName)
      network.getNode(nodeName).incr()
    end

    def explore(supportable_events)
      supportable_events.each do |supportable_event|
        incr_node(supportable_event)
      end
    end

    def needs_assistance?
      assistance_value > 0.50
    end

    def assistance_node
      network.getNode("NeedsAssistance")
    end

    def assistance_value
      assistance_node.getBelief("Yes")
    end

    def hints
      lvl2 = assistance_node.top_parent_node
      lvl3 = lvl2.top_parent_node
      [network.getNode("PoorDataCollection").hint, lvl2.hint, lvl3.hint]
    end

    def load_from_saved_state_xml(xml_string)
      hash = Hash.from_xml(xml_string)
      network.load_from_state(hash["exploration_network"]["network"])
    end

    def state_xml
      state.to_xml(:root => "exploration_network")
    end

    def state
      NeticaLogger.info "Assistance Value => #{assistance_value}"
      { :exploration_token => exploration_token, :network => network_state, :assistance_state => assistance_state }
    end

    def assistance_state
      { :needs_assistance => needs_assistance?, :hints => hints }
    end

    def network_state
      network.state
    end
  end
end