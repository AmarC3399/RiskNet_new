# require 'action_dispatch/middleware/session/cache_store'

module LowLevelCache
  def create_cache(cache_bust = false)
      clear_cache if cache_bust
      Rails.cache.fetch(default_cache_key, expires_in: 12.hours) { query }
  end

  def clear_cache
      Rails.cache.delete(default_cache_key)
  end

  def default_cache_key
    self.class.name.constantize.new.cache_key
  end
end