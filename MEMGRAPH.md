Memgraph
========

This repository is a spike, to judge the feasibility of modifying
the wonderful ActiveGraph ORM to support Memgraph (as well as Neo4j).
To this end I have added a _temporary_ module `ActiveGraph::DBType`
which selects which DB is the target from the environment variable
`GRAPH_DB`, and made some initial modifications to allow the specs
to run.  As of 1 July, 2020

    GRAPH_DB=memgraph NEO4J_URL=bolt://localhost:7687 \
        bundle exec rake spec
      :
    Finished in 1 minute 31.93 seconds (files took 1.37 seconds to load)
    1907 examples, 51 failures, 9 pending

Looks increasingly feasible.

Design
------

From initial investigations, it seems like there are some parts
of the code where the Memgraph and Neo4j code would be very different
while for most of it only trivial changes would be needed.  From
this, I think a better design would be to have those divergent
classes subclassed, then have a generic mechanism to route to
the appropriate subclass by type.  I've a hacky mechanism in-place
but I'm not terribly happy with it, my metaprogramming-foo is weak.


Running
-------

You'd need to [install Memgraph][1] and the [Seabolt driver][2].  There is
a small bug in the master branch which prevents it working with Memgraph
and the `none` authorisation scheme, [fixed here][3] (PR issued), so clone
the latter and follow the build instruction.


Status
------

This is paused, pending other commitments.  I'd be most interested
in comments, suggestions.

[1]: https://memgraph.com/download
[2]: https://github.com/neo4j-drivers/seabolt
[3]: https://github.com/dressipi/seabolt
