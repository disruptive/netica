class Java::NorsysNetica::NodeList
  def sort_by_belief
    nodes.sort{|a,b| b.beliefs <=> a.beliefs }
  end

  def nodes
    (0...size).map{|i| getNode(i) }
  end

  def to_s
    "Node List: #{self.object_id}"
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