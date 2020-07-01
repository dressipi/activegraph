require_relative 'schema/neo4j'
require_relative 'schema/memgraph'

module ActiveGraph
  module Core
    module Schema
      include ActiveGraph::DBType.module_for(self)
    end
  end
end
