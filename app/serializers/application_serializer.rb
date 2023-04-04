class ApplicationSerializer < ActiveModel::Serializer

  # delegate :cache_key, to: :object

  # def to_json(*args)
    # puts expand_cache_key(self.class.to_s.underscore, cache_key, @options[:action].try(:to_s), 'to-json')
    # Rails.cache.fetch(expand_cache_key(self.class.to_s.underscore, cache_key, @options[:action].try(:to_s), 'to-json')) do
    #   # puts "OH YEAH!!!!"
    #   # MultiJson.dump(self.as_json)
    #   super
    # end
    # MultiJson.dump(self.serializable_hash)
  # end

  # def serializable_hash
  #   puts "OPTs = #{@options}"
  #   puts "KEY = #{expand_cache_key(self.class.to_s.underscore, cache_key, @options[:action].try(:to_s), 'serializable-hash')}"
  #   Rails.cache.fetch(expand_cache_key(self.class.to_s.underscore, cache_key, @options[:action].try(:to_s), 'serializable-hash')) do
  #     super
  #   end
  # end


  # private
  # def expand_cache_key(*args)
  #   ActiveSupport::Cache.expand_cache_key args
  # end

end