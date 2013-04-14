class Java::NorsysNetica::NodeList
  def sort_by_belief
    nodes.sort{|a,b| b.beliefs <=> a.beliefs }
  end

  def nodes
    (0...size).map{|i| getNode(i) }
  end

  def to_s
    "NodeList:#{object_id}"
  end

  def inspect
    "#<Java::NorsysNetica::NodeList:#{object_id} size:#{size} nodes:#{nodes.collect{|n| n.to_s }}>"
  end

  def free
    begin
      NeticaLogger.info "Deleting #{self.to_s}"
      finalize()
      nodes.each{|n| n==nil or n.free() }
    rescue Java::NorsysNetica::NeticaException
    end
  end
end