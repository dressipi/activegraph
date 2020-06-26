Memgraph
========

This repository is a spike, to judge the feasibility of modifying
the wonderful ActiveGraph ORM to support Memgraph (as well as Neo4j).
To this end I have added a _temporary_ module `ActiveGraph::DBType`
which selects which DB is the target from the environment variable
`GRAPH_DB`, and made some initial modifications to allow the specs
to run.  As of 26 June, 2020

    $ GRAPH_DB=memgraph \
        NEO4J_URL=bolt://localhost:7687 \
        bundle exec rspec -c -fd spec/active_graph/base_spec.rb

    ActiveGraph::Base
      #query
        Can make a query
        can make a query with a large payload
        :

    Finished in 0.34751 seconds (files took 0.66807 seconds to load)
    68 examples, 6 failures


and some of these errors are expectations on error messages, so
trivally fixable.  So feasibility looks likely.


Design
------

Switching on a type is a classic OO antipattern, and I'd not offer
such as a PR to the ActiveGraph project.  But it is at least quick
and fairly non-invasive.

From initial investigations, it seems like there are some parts
of the code where the Memgraph and Neo4j code would be very different
while for most of it only trivial changes would be needed.  From
this, I think a better design would be to have those divergent
classes subclassed, then have a generic mechanism to route to
the appropriate subclass by type.  But I'm open to ideas on this.


Running
-------

You'd need to [install Memgraph][1] of course, and then install the
[Seabolt driver][2].  There is a small bug in the master branch which
prevents it working with Memgraph and the `none` authorisation scheme,
[fixed here][3] (PR issued), so clone the latter and follow the build
instruction.


Status
------

This is paused, pending other commitments.  I'd be most interested
in comments, suggestions.



[1]: https://memgraph.com/download
[2]: https://github.com/neo4j-drivers/seabolt
[2]: https://github.com/dressipi/seabolt
