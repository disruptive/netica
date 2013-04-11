class Java::NorsysNetica::Environ
  def finalize()
    Netica::NeticaLogger.info "Destroying Netica Environment Object: #{object_id}..."
    super
  end
end

class Java::NorsysNetica::Net
  def finalize()
    Netica::NeticaLogger.info "Destroying Netica Network Object: #{object_id}..."
    super
  end
end

class Java::NorsysNetica::Node
  attr_accessor :value

  NODE_KINDS = {
   Java::NorsysNetica::Node::NATURE_NODE => :nature,
   Java::NorsysNetica::Node::DECISION_NODE => :decision,
   Java::NorsysNetica::Node::UTILITY_NODE => :utility,
   Java::NorsysNetica::Node::CONSTANT_NODE => :constant,
   Java::NorsysNetica::Node::DISCONNECTED_NODE => :disconnected,
  }

  NODE_TYPES = {
   Java::NorsysNetica::Node::DISCRETE_TYPE => :nature,
   Java::NorsysNetica::Node::CONTINUOUS_TYPE => :decision,
  }

  def name
    getName()
  end

  def decision_node?
    getTypeSym == :decision
  end

  def nature_node?
    getTypeSym == :nature
  end

  def beliefs
    states.collect{ |st| getBelief(st.to_s) }
  end

  def hint
    user().getString("Hint")
  end

  def top_parent_node
    getParents().sort_by_belief()[0]
  end

  def value
    if decision_node?
      finding().getReal()
    else
      state_values = {}
      states.collect{ |st| state_values.store(st.to_s, getBelief(st.to_s)) }
      state_values
    end
  end

  def value=(new_value)
    finding().setReal(new_value) if decision_node?
  end

  def incr()
    if decision_node?
      self.value = value + 1
    end
  end

  def getKindSym()
    return NODE_KINDS[getKind()]
  end

  def getTypeSym()
    return NODE_TYPES[getType()]
  end

  def to_s
   "Node" +
      " Name:#{getName()}" +
      " Kind:#{getKindSym()}" +
      " Type:#{getTypeSym()}" +
      " BeliefUpdated:#{isBeliefUpdated()}" +
      " Deterministic:#{isDeterministic()}" +
      " NumStates:#{getNumStates}"
  end

  def to_ss
    to_s + "\n" + states.map{|s| s.to_ss}.join("\n")
  end

  def pretty_print(q)
    q.group(1) {
      q.text "Node"
      q.breakable
      q.text "Name:#{getName()}"
      q.comma_breakable
      q.text "Kind:#{getKindSym()}"
      q.comma_breakable
      q.text "Type:#{getTypeSym()}"
      q.comma_breakable
      q.text "BeliefUpdated:#{isBeliefUpdated()}"
      q.comma_breakable
      q.text "Deterministic:#{isDeterministic()}"
      q.comma_breakable
      q.text "NumStates:#{getNumStates}"
      q.comma_breakable
    }
  end

  def states()
    return (0...getNumStates()).map{|i| state(i) }
  end

  def free()
    begin
      finalize()
      delete()
      states.each{|s| s==nil or s.free() }
    rescue Java::NorsysNetica::NeticaException
    end
  end

  def state_belief_inspect
    states.map{|state|
     k = state.getName()
     v = getBelief(k)
      "#{k}:#{v}"
    }.join(",")
  end
end

class Java::NorsysNetica::NodeList
  def sort_by_belief
    nodes.sort{|a,b| b.beliefs <=> a.beliefs }
  end

  def nodes()
    return (0...size).map{|i| getNode(i) }
  end

  def free()
    begin
      finalize()
      nodes.each{|n| n==nil or n.free() }
    rescue Java::NorsysNetica::NeticaException
    end
  end

  def getName()
   ""
  end

  def to_ss
    to_s + "\n" + nodes.map{|n| n.to_ss}.join("\n")
  end
end