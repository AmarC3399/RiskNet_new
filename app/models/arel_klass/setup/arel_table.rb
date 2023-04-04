module ArelKlass
  class Setup
    class ArelTable < ArelKlass::TableRelation::SqlQuery
      attr_reader :scope

      def initialize(scope=nil)
        @scope = Arel::Table.new scope.table_name
      end
    end
  end
end