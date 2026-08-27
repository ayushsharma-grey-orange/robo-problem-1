-module(robo_nav_server).

-behaviour(gen_server).

%% Public API
-export([
    start_link/0,
    get_state/0
]).

%% gen_server callbacks
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3,
    set_robot/1,
    set_goal/1,
    add_obstacle/1,
    remove_obstacle/1,
    find_path/0,
    print_grid/0,
    print_path/0,
    run/0,
    run_random/1,
    run_two_robots/0,
    add_second_robot/2,
    simulate_two_robots/0,
    find_path/2
    
]).

start_link() ->
    gen_server:start_link(
        {local, ?MODULE},
        ?MODULE,
        [],
        []
    ).

get_state() ->
    gen_server:call(?MODULE, get_state).

init([]) ->
    State = #{
        grid => robo_nav_grid:new(),
        robot => {1, 1},
        goal => {9, 9}
    },

    {ok, State}.


handle_call({add_second_robot, Start, Goal}, _From, State) ->
    Grid = maps:get(grid, State),
    ValidStart = robo_nav_grid:valid_position(Grid, Start)
                 andalso not robo_nav_grid:blocked(Grid, Start),
    ValidGoal = robo_nav_grid:valid_position(Grid, Goal)
                andalso not robo_nav_grid:blocked(Grid, Goal),

    case {ValidStart, ValidGoal} of
        {true, true} ->
            NewState = State#{robot2=> Start, goal2 => Goal},
            {reply, ok, NewState};
        _ ->
            {reply, {error, invalid_position}, State}
    end;
handle_call(remove_all_obstacles, _From, State) ->
    %% Assuming your state is a map containing an 'obstacles' key
    Grid = maps:get(grid, State),
    NewGrid = Grid#{obstacles => sets:new()},
    NewState = State#{grid => NewGrid},
    {reply, ok, NewState};
handle_call(find_path, _From, State) ->
    Grid = maps:get(grid, State),
    Robot = maps:get(robot, State),
    Goal = maps:get(goal, State),

    Result = robo_nav_pathfinder:find_path(Grid, Robot, Goal),

    {reply, Result, State};

handle_call({find_path_2, Start, Goal}, _From, State) ->
    Grid = maps:get(grid, State),
    Result = robo_nav_pathfinder:find_path(Grid, Start, Goal),
    {reply, Result, State};
handle_call(get_state, _From, State) ->
    {reply, State, State}.


handle_cast({set_robot, Position}, State) ->
    Grid = maps:get(grid, State),
    Valid = robo_nav_grid:valid_position(Grid, Position)
            andalso not robo_nav_grid:blocked(Grid, Position),
    
    case Valid of
        false ->
            {noreply, State};
        true ->
            NewState = State#{robot := Position},
            {noreply, NewState}
    end;

handle_cast({set_goal, Position}, State) ->
    Grid = maps:get(grid, State),
    Valid = robo_nav_grid:valid_position(Grid, Position)
            andalso not robo_nav_grid:blocked(Grid, Position),

    case Valid of
        false ->
            {noreply, State};
        true ->
            NewState = State#{goal := Position},
            {noreply, NewState}
    end;

% handle_cast({add_obstacle, Position}, State) ->
%     Grid = maps:get(grid, State),
%     NewGrid = robo_nav_grid:add_obstacle(Grid, Position),
%     NewState = State#{grid := NewGrid},

%     {noreply, NewState};

handle_cast({add_obstacle, Position}, State) ->
    Grid = maps:get(grid, State),
    Robot = maps:get(robot, State),
    Goal = maps:get(goal, State),

    Valid =
        robo_nav_grid:valid_position(Grid, Position)
        andalso Position =/= Robot
        andalso Position =/= Goal,

    case Valid of
        true ->
            NewGrid = robo_nav_grid:add_obstacle(Grid, Position),
            NewState = State#{grid := NewGrid},
            {noreply, NewState};

        false ->
            {noreply, State}
    end;

handle_cast({remove_obstacle, Position}, State) ->
    Grid = maps:get(grid, State),
    NewGrid = robo_nav_grid:remove_obstacle(Grid, Position),
    NewState = State#{grid := NewGrid},

    {noreply, NewState};

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVersion, State, _Extra) ->
    {ok, State}.

set_robot(Position) ->
    gen_server:cast(?MODULE, {set_robot, Position}).

set_goal(Position) ->
    gen_server:cast(?MODULE, {set_goal, Position}).

add_obstacle(Position) ->
    gen_server:cast(?MODULE, {add_obstacle, Position}).

remove_obstacle(Position) ->
    gen_server:cast(?MODULE, {remove_obstacle, Position}).

find_path() ->
    gen_server:call(?MODULE, find_path).

find_path(Start, Goal) ->
    gen_server:call(?MODULE, {find_path_2, Start, Goal}).

print_grid() ->
    robo_nav_grid:print_grid(get_state()).

print_path()->
    Result=find_path(),
    case Result of
        {error, Reason} ->
            io:format("Error finding path: ~p~n", [Reason]);
        {ok, Path} ->
            ToPrint=robo_nav_grid:print_path(get_state(),Path),
            io:format("Path: ~p~n", [ToPrint])
    end.

run()->
    % Set up robo and Goal
    set_robot({1,1}),
    set_goal({9,9}),


    % set up obstacles
    add_obstacle({2,1}),
    add_obstacle({2,2}),
    add_obstacle({2,3}),
    add_obstacle({2,4}),
    add_obstacle({2,5}),
    add_obstacle({5,5}),
    add_obstacle({5,4}),
    add_obstacle({5,3}),
    add_obstacle({5,6}),
    add_obstacle({5,7}),
    add_obstacle({5,8}),

    add_obstacle({5,9}),


% print the path
    print_path(),
    remove_all_obstacles().


run_random(X)->
    % Set up robo and Goal
    set_robot({1,1}),
    set_goal({9,9}),

    % set up random obstacles
    RandomObstacles = [{rand:uniform(9), rand:uniform(9)} || _ <- lists:seq(1, X)],

    lists:foreach(fun add_obstacle/1, RandomObstacles),

    print_grid(),
    % print the path
    print_path(),
    % remove obstances 
    remove_all_obstacles().

run_two_robots()->
    add_second_robot({3,4},{7,8}),
    simulate_two_robots().

remove_all_obstacles()->
    gen_server:call(?MODULE, remove_all_obstacles).

add_second_robot(Start={_X1, _Y1},Goal={_X2, _Y2})->
    % robo_nav_server:add_second_robot({3,4},{7,8}).
    gen_server:call(?MODULE, {add_second_robot, Start, Goal}).


simulate_two_robots()->
%   robo_nav_server:simulate_two_robots().
    State=get_state(),
    {ok,Robo1Path}=find_path(),
    io:format("Robo1 : ~p~n", [Robo1Path]),

    {ok,Robo2Path}=find_path(maps:get(robot2,State),maps:get(goal2,State)),
    io:format("Robo2 Path: ~p~n", [Robo2Path]),

    robo_nav_window:simulate_two_robots(Robo1Path,Robo2Path,State),
    % Now you can simulate the movement of both robots along their paths.


    0.