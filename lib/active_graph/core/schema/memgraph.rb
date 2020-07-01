module ActiveGraph
  module Core
    module Schema
      module Memgraph

        # this is not, of course, the version of Memgraph, but for now
        # we will code to make Memgraph appear like Neo4j v4

        def version
          '4.0'
        end

        # at present, this contains only the indexes proper (which seems
        # sesnible), but the Neo4j method also includes the constraints,
        # not quite sure what the thinking there is ...

        def indexes
          list_indexes_query.map do |row|
            {
              type: row[:'index type'].to_sym,
              label: row[:label].to_sym,
              properties: [row[:property].to_sym],
            }
          end
        end

        def constraints
          list_constraints_query.map do |row|
            {
              type: :uniqueness,
              label: row[:label].to_sym,
              properties: [row[:properties].to_sym]
            }
          end
        end

        private

        def query_uninstrumented(cypher)
          query(cypher, {}, skip_instrumentation: true)
        end

        def list_indexes_query
          query_uninstrumented('SHOW INDEX INFO')
        end

        def list_constraints_query
          query_uninstrumented('SHOW CONSTRAINT INFO')
        end
      end
    end
  end
end
