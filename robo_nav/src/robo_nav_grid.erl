-module(robo_nav_grid).

-export([
    new/0,
    new/1,
    valid_position/2,
    blocked/2,
    add_obstacle/2,
    remove_obstacle/2,
    neighbors/2,
    print_grid/1,
    print_path/2
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

% print_grid(State) ->
%     Grid = maps:get(grid, State),
%     Rows = maps:get(rows, Grid),
%     Cols = maps:get(cols, Grid),
%     Obstacles = maps:get(obstacles, Grid),
%     Robot = maps:get(robot, State),
%     Goal = maps:get(goal, State),




    % lists:foreach(
    %     fun(Row) ->
    %         lists:foreach(
    %             fun(Col) ->
    %                 Position = {Row, Col},
    %                 if
    %                     sets:is_element(Position, Obstacles) ->
    %                         io:format(" X ");
    %                     true ->
    %                         io:format(" . ")
    %                 end
    %             end,
    %             lists:seq(1, Cols)
    %         ),
    %         io:format("~n")
    %     end,
    %     lists:seq(1, Rows)
    % )


%     io:format("Rows, Cols, and Obstacles (~p x ~p ) ~p:~n", [Rows,Cols, Obstacles])
% .





print_grid( State) ->
    Grid= maps:get(grid, State),
    Rows = maps:get(rows, Grid),
    Cols = maps:get(cols, Grid),
    Obstacles = maps:get(obstacles, Grid),
    Robot = maps:get(robot, State),
    Goal = maps:get(goal, State),

    io:format("Rows, Cols, and Obstacles (~p x ~p) ~p:~n", [Rows, Cols, Obstacles]),
    
    %% Loop through each row from 1 to Rows
    lists:foreach(fun(R) ->
        %% Loop through each column from 1 to Cols for the current row
        RowStr = lists:flatten([
            begin
                Coord = {R, C},
                cond_char(Coord, Robot, Goal, Obstacles)
            end || C <- lists:seq(1, Cols)
        ]),
        io:format("~s~n", [RowStr])
    end, lists:seq(1, Rows)).

%% Helper to determine which character to print at a given coordinate
cond_char(Coord, Robot, Goal, Obstacles) ->
    if
        Coord =:= Robot -> " R ";
        Coord =:= Goal -> " G ";
        is_map_key(Coord, Obstacles) -> " # ";
        true -> " . "
    end.


print_path( State, Path) ->
    Grid= maps:get(grid, State),
    Rows = maps:get(rows, Grid),
    Cols = maps:get(cols, Grid),
    Obstacles = maps:get(obstacles, Grid),

    io:format("Grid (~p x ~p),~n Steps Taken=~p with Path:~n", [Rows, Cols,length(Path)]),
    
    %% Convert Path list into a set/map for efficient O(1) lookup
    PathSet = maps:from_list([{Coord, true} || Coord <- Path]),
    
    %% Loop through each row from 1 to Rows
    lists:foreach(fun(R) ->
        RowStr = lists:flatten([
            begin
                Coord = {R, C},
                path_char(Coord, PathSet, Obstacles)
            end || C <- lists:seq(1, Cols)
        ]),
        io:format("~s~n", [RowStr])
    end, lists:seq(1, Rows)).

%% Helper to determine the character for the path visualization
path_char(Coord, PathSet, Obstacles) ->
    if
        is_map_key(Coord, Obstacles) -> " # ";
        is_map_key(Coord, PathSet) -> " P ";
        true -> " . "
    end.