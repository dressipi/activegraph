# methods describe the behaviour (attributes) of graph DBs,
# this so that we can avoid littering the code with per-db
# conditionals

module ActiveGraph::DBAttribute
  extend self

  def db_delete_all_without_detach?
    neo4j?
  end

  def db_module_constraint_delete?
    neo4j?
  end

  private

  def neo4j?
    db_name == :neo4j
  end

  def memgraph?
    db_name == :memgraph
  end

  def db_name
    (ENV['GRAPH_DB'] || 'neo4j').to_sym
  end
end
