-module(whca_server).
-behaviour(gen_server).


-export([
    start_link/0,
    get_state/0
]).


-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    generate_random_obstacles/0,
    generate_random_obstacles/1
]).
% -export([start_link/0, stop/0, get_state/0]).




get_state() ->
    gen_server:call(?MODULE, get_state).

start_link() ->
    gen_server:start_link(
        {local, ?MODULE},
        ?MODULE,
        [],
        []
    ).

init([]) ->
    State = #{
        grid => robo_nav_grid:new(),
        obstacles => sets:new(),    
        robo1 => #{
            current => {1, 1},
            goal => {9, 9},
            steps_taken=>0,
            esitmated_path=>[]
        },
        robo2 => #{
            current => {1, 3},
            goal => {8, 2},
            steps_taken=>0,
            esitmated_path=>[]
        }
    },

    {ok, State}.

handle_call(get_state, _From, State) ->
    {reply, State, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

generate_random_obstacles()->
    generate_random_obstacles(7).
generate_random_obstacles(Count)->
    State=get_state(),
    Grid=maps:get(grid,State),
    RandomObstacles = [{rand:uniform(9), rand:uniform(9)} || _ <- lists:seq(1, Count)],

    % generate_random_obstacles(Grid,Count).
    0.





