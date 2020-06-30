# this allows us to put switches in the code depending on
# the Graph DB type (just neo4j and memgraph), that's a
# pretty cheesy thing to do, see MEMGRAPH.md in the repo
# root for a discussion

module ActiveGraph::DBType
  extend self

  def self.included(cls)
    cls.include(module_for(cls))
  end

  def neo4j?
    name == :neo4j
  end

  def memgraph?
    name == :memgraph
  end

  def module_for(scope)
    scope.const_get(module_name)
  end

  def module_name
    case name
    when :neo4j
      'Neo4j'
    when :memgraph
      'Memgraph'
    end
  end

  def name
    if env_name = ENV['GRAPH_DB'] then
      env_name_sym = env_name.to_sym
      unless [:neo4j, :memgraph].include? env_name_sym then
        raise ActiveGraph::UnknownDBTypeError, env_name
      end
      env_name_sym
    else
      :neo4j
    end
  end
end
