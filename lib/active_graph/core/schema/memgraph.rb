module ActiveGraph
  module Core
    module Schema
      module Memgraph

        def indexes
          result = list_indexes_query
          result.map do |row|
            {
              type: row[:'index type'].to_sym,
              label: row[:label].to_sym,
              properties: [row[:property].to_sym],
              state: nil
            }
          end
        end

        private

        def list_indexes_cypher
          'SHOW INDEX INFO'
        end

      end
    end
  end
end
