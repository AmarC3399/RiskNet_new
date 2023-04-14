module NestedResourceFor
  extend ActiveSupport::Concern


  module ClassMethods
    def nested_resource_for(resources)
      cattr_accessor :parent_klasses
      self.parent_klasses = Array(resources)

      # Include our callbacks and setup the callback
      include CallbackMethods

      before_action :load_parent_resource
    end
  end

  module CallbackMethods

    def load_parent_resource
      klasses = self.class.parent_klasses.map(&:to_s)

      if klass = klasses.detect { |k| params[:"#{k}_id"].present? }
        name = klass.downcase.singularize
        parent = klass.camelize.constantize.find(params[:"#{klass}_id"].to_s.split(CompositePrimaryKeys::ID_SEP))
        parent = parent[0] if parent.is_a?(Array)

        instance_variable_set("@#{name}", parent)
        instance_variable_set('@parent', parent) # Easier than checking which is defined
      end
    end

  end

end