class Java::NorsysNetica::Node
  attr_accessor :value

  # from https://github.com/SixArm/sixarm_ruby_netica
  NODE_KINDS = {
   Java::NorsysNetica::Node::NATURE_NODE => :nature,
   Java::NorsysNetica::Node::DECISION_NODE => :decision,
   Java::NorsysNetica::Node::UTILITY_NODE => :utility,
   Java::NorsysNetica::Node::CONSTANT_NODE => :constant,
   Java::NorsysNetica::Node::DISCONNECTED_NODE => :disconnected
  }

  NODE_TYPES = {
   Java::NorsysNetica::Node::DISCRETE_TYPE => :nature,
   Java::NorsysNetica::Node::CONTINUOUS_TYPE => :decision
  }

  def name
    getName
  end

  def kind
    NODE_KINDS[getKind]
  end

  def type
    NODE_TYPES[getType]
  end

  def decision_node?
    type == :decision
  end

  def nature_node?
    type == :nature
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

  def value(state_name = nil)
    if decision_node?
      finding().getReal()
    elsif state_name
      states.collect{ |st| return getBelief(st.to_s) if state_name == st.to_s }
    else
      state_values = {}
      states.collect{ |st| state_values.store(st.to_s, getBelief(st.to_s)) }
      state_values
    end
  end

  def value=(new_value)
    if decision_node?
      Netica::NeticaLogger.info "Decision Node: Setting #{kind} #{type} node #{self.name} to #{new_value}"
      finding().setReal(new_value)
    elsif nature_node?
      Netica::NeticaLogger.info "Nature Node: Setting #{kind} #{type} node #{self.name} to #{new_value}"
      finding.enterState(new_value)
    else
      throw "Could not set value for #{kind} #{type} node #{self.name} to #{new_value}"
    end
  end

  def incr
    if decision_node?
      self.value = value + 1
    end
  end

  def to_s
    if type == kind
      prefix = type.capitalize
    else
      prefix = "#{type.capitalize}#{kind.capitalize}"
    end

    "#{prefix}Node:#{name}"
  end

  def inspect
    "#<Java::NorsysNetica::#{self.to_s} value:#{value}>"
  end

  def states
    (0...getNumStates()).map{|i| state(i) }
  end

  def free
    begin
      NeticaLogger.info "Deleting #{self.to_s}"
      finalize()
      delete()
      states.each{|s| s==nil or s.free() }
    rescue Java::NorsysNetica::NeticaException
    end
  end
end
