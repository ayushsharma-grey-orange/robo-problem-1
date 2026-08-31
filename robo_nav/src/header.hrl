
-type position() :: {pos_integer(), pos_integer()}.
-type grid() :: #{
    rows := pos_integer(),
    cols := pos_integer(),
    obstacles := sets:set(position())
}.