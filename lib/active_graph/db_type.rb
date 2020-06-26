# methods describe the behaviour (attributes) of graph DBs,
# this so that we can avoid littering the code with per-db
# conditionals

module ActiveGraph::DBType
  extend self

  def neo4j?
    name == :neo4j
  end

  def memgraph?
    name == :memgraph
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
