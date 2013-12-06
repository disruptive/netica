# provides a persistable object container for a Netica Bayes net.
class StorableNetwork < Netica::ActiveNetwork

  # Save StorableNetwork to an associated redis store, if one is defined.
  #
  # @return [true,false,nil] outcome of redis.set, or nil if redis is not found
  def save
    if Netica::Environment.instance.redis
      return Netica::Environment.instance.redis.set(token, JSON.dump(state))
    end
  end

  # Retrieve ActiveNetwork from current Netica Environment instance
  # or an associated redis store, if one is defined.
  #
  # @param token [String] identifying token for ActiveNetwork sought
  # @return [ActiveNetwork] ActiveNetwork object found
  def self.find(token, load_from_storage = true, filepath = nil)
    environment = Netica::Environment.instance
    redis = environment.redis
    found_network = super(token)
    if found_network.nil? && redis
      stored_state = redis.get(token)
      if stored_state && load_from_storage
        hash = JSON.parse(stored_state)
        found_network = Object::const_get(hash['class']).new(token)
        found_network.filepath = filepath
        found_network.load_from_saved_state(hash)
        Netica::NeticaLogger.info "Network #{token} reloaded from saved state: #{hash}"
        Netica::NeticaLogger.info "#{token} reloaded state: #{found_network.state}"
        return found_network
      elsif stored_state
        return stored_state
      else
        Netica::NeticaLogger.info "Network #{token} not found in redis."
      end
    end
    return nil
  end
  
  # Destroy the ActiveNetwork
  #
  # @param memory [Boolean] destroy the in-memory object?, default is `true`
  # @param storage [Boolean] destroy object in redis?, default is `true`
  # @return [Hash] outcome of deletion attempts per storage location
  def destroy(memory = true, storage = true)
    outcome = { token: token, deletion: { memory: nil, redis: nil}}
    environment = Netica::Environment.instance

    if memory
      rejection = environment.network_container.reject!{|network| network.token == token}
      outcome[:deletion][:memory] = rejection.is_a?(Array)
    end
      
    if environment.redis && storage == true
      outcome[:deletion][:redis] = (environment.redis.del(token) > 0)
    end
    outcome
  end
  
  # Destroy a saved network
  #
  # @return [Hash] outcome of deletion attempts per storage location
  def self.destroy_by_token(token)
    outcome = { token: token, deletion: { memory: nil, redis: nil}}
    environment = Netica::Environment.instance

    if environment.redis
      outcome[:deletion][:redis] = (environment.redis.del(token) > 0)
    end

    outcome
  end
end
