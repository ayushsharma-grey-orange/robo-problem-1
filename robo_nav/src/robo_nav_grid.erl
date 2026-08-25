-module(robo_nav_grid).

-export([
    new/0,
    new/1,
    valid_position/2,
    blocked/2,
    add_obstacle/2,
    remove_obstacle/2,
    neighbors/2
]).

-type position() :: {pos_integer(), pos_integer()}.

-type grid() :: #{
    rows := pos_integer(),
    cols := pos_integer(),
    obstacles := sets:set(position())
}.

-export_type([position/0, grid/0]).

-spec new() -> grid().
new() ->
    new({9, 9}).

-spec new({pos_integer(), pos_integer()}) -> grid().
new({Rows, Cols}) ->
    #{
        rows => Rows,
        cols => Cols,
        obstacles => sets:new()
    }.

-spec valid_position(grid(), position()) -> boolean().
valid_position(Grid, {Row, Col}) ->
    Row >= 1 andalso
    Row =< maps:get(rows, Grid) andalso
    Col >= 1 andalso
    Col =< maps:get(cols, Grid).

-spec blocked(grid(), position()) -> boolean().
blocked(Grid, Position) ->
    sets:is_element(Position, maps:get(obstacles, Grid)).

-spec add_obstacle(grid(), position()) -> grid().
add_obstacle(Grid, Position) ->
    case valid_position(Grid, Position) of
        true ->
            Obstacles = maps:get(obstacles, Grid),
            Grid#{obstacles := sets:add_element(Position, Obstacles)};
        false ->
            error({invalid_position, Position})
    end.

-spec remove_obstacle(grid(), position()) -> grid().
remove_obstacle(Grid, Position) ->
    Obstacles = maps:get(obstacles, Grid),
    Grid#{obstacles := sets:del_element(Position, Obstacles)}.

-spec neighbors(grid(), position()) -> [position()].
neighbors(Grid, {Row, Col}) ->
    Candidates = [
        {Row - 1, Col},
        {Row + 1, Col},
        {Row, Col - 1},
        {Row, Col + 1}
    ],

    [
        Position
     || Position <- Candidates,
        valid_position(Grid, Position),
        not blocked(Grid, Position)
    ].