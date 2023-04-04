# Construct a table relation and convert it to SQL
module ArelKlass
  class TableRelation
    class MysqlQuery
      def all
        scope.project(Arel.mysql('*'))
      end

      def where(args)
        scope.where(scope[args.keys.first].eq(args.values.first))
      end

      def find

      end
    end
  end
end
