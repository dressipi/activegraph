require_relative 'schema/neo4j'
require_relative 'schema/memgraph'

module ActiveGraph
  module Core
    module Schema

      case ActiveGraph::DBType.name
      when :neo4j
        include Neo4j
      when :memgraph
        include Memgraph
      end

      def version
        result = query('CALL dbms.components()', {}, skip_instrumentation: true)

        # BTW: community / enterprise could be retrieved via `result.first.edition`
        result.first[:versions][0]
      end

      def constraints
        result = list_indexes_query
        result.select(&method(v4?(result) ? :v4_filter : :v3_filter)).map do |row|
          {
            type: :uniqueness,
            label: label(result, row),
            properties: properties(row)
          }
        end
      end

      private

      def list_indexes_query
        query(list_indexes_cypher, {}, skip_instrumentation: true)
      end

      def v4_filter(row)
        row[:uniqueness] == 'UNIQUE'
      end

      def v3_filter(row)
        row[:type] == 'node_unique_property'
      end

      def label(result, row)
        if v34?(result)
          row[:label]
        else
          (v4?(result) ? row[:labelsOrTypes] : row[:tokenNames]).first
        end.to_sym
      end

      def v4?(result)
        return @v4 unless @v4.nil?
        @v4 = result.keys.include?(:labelsOrTypes)
      end

      def v34?(result)
        return @v34 unless @v34.nil?
        @v34 = result.keys.include?(:label)
      end

      def properties(row)
        row[:properties].map(&:to_sym)
      end
    end
  end
end
