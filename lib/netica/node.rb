class Java::NorsysNetica::Node
  attr_accessor :value

  def name
    getName()
  end

  def decision_node?
    getKind() == Java::NorsysNetica::Node::DECISION_NODE
  end

  def nature_node?
    getType() == Java::NorsysNetica::Node::DISCRETE_TYPE
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

  def incr
    if decision_node?
      self.value = value + 1
    end
  end

  def to_s
   "Node: #{getName()} #{self.object_id}"
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
