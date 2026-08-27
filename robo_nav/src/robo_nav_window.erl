-module(robo_nav_window).

-export([
    simulate_two_robots/3
]).

-define(WINDOW_SIZE, 3).


simulate_two_robots(Path1, Path2, State) ->
    io:format(
        "~nSimulating two robots using a ~p-step window:~n",
        [?WINDOW_SIZE]
    ),

    Grid = maps:get(grid, State),

    simulate_two_robots_loop(
        Path1,
        Path2,
        Grid,
        State
    ).


%% Both robots have finished.
simulate_two_robots_loop([], [], _Grid, _State) ->
    io:format(
        "~nBoth robots have reached their goals.~n",
        []
    );


%% Robot 1 has finished, Robot 2 continues.
simulate_two_robots_loop([], Path2, Grid, State) ->
    io:format(
        "~nRobot 1 has reached its goal.~n",
        []
    ),

    simulate_single_robot(
        2,
        Path2,
        Grid,
        State
    );


%% Robot 2 has finished, Robot 1 continues.
simulate_two_robots_loop(Path1, [], Grid, State) ->
    io:format(
        "~nRobot 2 has reached its goal.~n",
        []
    ),

    simulate_single_robot(
        1,
        Path1,
        Grid,
        State
    );


%% Both robots are still moving.
simulate_two_robots_loop(Path1, Path2, Grid, State) ->
    io:format(
        "~n Executing window of size:~p~n-----------------------------------~n",
        [?WINDOW_SIZE]
    ),

    % io:format(
    %     "New window (max ~p steps)~n",
    %     [?WINDOW_SIZE]
    % ),

    {NewPath1, NewPath2} =
        simulate_window(
            Path1,
            Path2,
            Grid,
            State,
            ?WINDOW_SIZE
        ),

    simulate_two_robots_loop(
        NewPath1,
        NewPath2,
        Grid,
        State
    ).


%% =========================================================
%% Window simulation
%  Simulates a window of size ?WINDOW_SIZE step by step for
%  both robots, checking for collisions.
%% =========================================================

simulate_window(Path1, Path2, _Grid, _State, 0) ->
    {Path1, Path2};

simulate_window([], Path2, _Grid, _State, _Steps) ->
    {[], Path2};

simulate_window(Path1, [], _Grid, _State, _Steps) ->
    {Path1, []};

simulate_window(
    [Current1 | Rest1],
    [Current2 | Rest2],
    Grid,
    State,
    Steps
) ->

    %% The first element represents the robot's
    %% current position, so the next element is
    %% the position it wants to move to.
    case {Rest1, Rest2} of

        %% Both robots are already at their goals.
        {[], []} ->
            io:format(
                "Both robots are at their goals.~n",
                []
            ),

            {[], []};


        %% Robot 1 has reached its goal.
        {[], _} ->
            io:format(
                "Robot 1 reached its goal at ~p.~n",
                [Current1]
            ),

            simulate_window(
                [],
                Rest2,
                Grid,
                State,
                Steps - 1
            );


        %% Robot 2 has reached its goal.
        {_, []} ->
            io:format(
                "Robot 2 reached its goal at ~p.~n",
                [Current2]
            ),

            simulate_window(
                Rest1,
                [],
                Grid,
                State,
                Steps - 1
            );


        %% Both robots have another step.
        {[Next1 | Remaining1], [Next2 | Remaining2]} ->

            case has_collision(
                Current1,
                Next1,
                Current2,
                Next2
            ) of

                %% No collision.
                false ->
                    io:format(
                        "R1: ~p -> ~p~n",
                        [Current1, Next1]
                    ),

                    io:format(
                        "R2: ~p -> ~p~n",
                        [Current2, Next2]
                    ),

                    io:format(
                        "Both robots move.~n",
                        []
                    ),

                    simulate_window(
                        [Next1 | Remaining1],
                        [Next2 | Remaining2],
                        Grid,
                        State,
                        Steps - 1
                    );


                %% Collision detected.
                true ->
                    io:format(
                        "COLLISION DETECTED!~n"
                    ),

                    io:format(
                        "R1 wants: ~p -> ~p~n",
                        [Current1, Next1]
                    ),

                    io:format(
                        "R2 wants: ~p -> ~p~n",
                        [Current2, Next2]
                    ),

                    io:format(
                        "Robot 1 has priority. Robot 2 waits.~n",
                        []
                    ),

                    io:format(
                        "R1 moves: ~p -> ~p~n",
                        [Current1, Next1]
                    ),

                    io:format(
                        "R2 waits at: ~p~n",
                        [Current2]
                    ),

                    simulate_window(
                        [Next1 | Remaining1],
                        [Current2 | Rest2],
                        Grid,
                        State,
                        Steps - 1
                    )
            end
    end.


%% =========================================================
%% Collision detection
%% =========================================================

%% Same destination OR position swapping.
has_collision(Current1, Next1, Current2, Next2) ->

    Same_destination =
        Next1 =:= Next2,

    % Deadlock, both robots stand at each other's next position.
    Swapping =
        Current1 =:= Next2
        andalso
        Current2 =:= Next1,

    Same_destination orelse Swapping.


%% =========================================================
%% Single robot simulation
%% =========================================================

simulate_single_robot(_RobotId, [], _Grid, _State) ->
    io:format(
        "Robot has reached its goal.~n",
        []
    );

simulate_single_robot(
    RobotId,
    [Current | Rest],
    Grid,
    State
) ->

    case Rest of

        [] ->
            io:format(
                "Robot ~p reached its goal at ~p.~n",
                [RobotId, Current]
            );

        [Next | Remaining] ->
            io:format(
                "Robot ~p: ~p -> ~p~n",
                [RobotId, Current, Next]
            ),

            simulate_single_robot(
                RobotId,
                [Next | Remaining],
                Grid,
                State
            )
    end.