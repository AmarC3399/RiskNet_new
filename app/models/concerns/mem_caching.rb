module MemCaching
  extend ActiveSupport::Concern

  module ClassMethods
    attr_accessor :cache

    def is_cachable
      self.cache = Hash.new
      after_save      :update_cache
      before_destroy  :clear_cache
    end

    def setup_cache
      #todo id and jpos_key to become configurable maybe?
      self.select(:id, :jpos_key).find_each { |z| self.cache[z.jpos_key.freeze] = z.id } #During system init
    end
  end

  protected

  def update_cache
    #append to the existing cache and add/update only the related jpos_key
    self.class.cache[self.jpos_key.freeze] = self.id
  end

  def clear_cache
    self.class.cache.delete(self.jpos_key.freeze)
  end

end