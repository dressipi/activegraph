module ActiveGraph
  module Core
    module Schema
      module Neo4j

        def indexes
          result = list_indexes_query
          result.map do |row|
            {
              type: row[:type].to_sym,
              label: label(result, row),
              properties: properties(row),
              state: row[:state].to_sym
            }
          end
        end

        private

        def list_indexes_cypher
          'CALL db.indexes()'
        end

      end
    end
  end
end
