-module(robo_nav_pathfinder).

-export([find_path/3]).

find_path(Grid, Start, Goal) ->
    case robo_nav_grid:valid_position(Grid, Start) andalso
         robo_nav_grid:valid_position(Grid, Goal) of
        false ->
            {error, invalid_position};

        true ->
            bfs(Grid, Start, Goal)
    end.


bfs(_Grid, Goal, Goal) ->
    {ok, [Goal]};

bfs(Grid, Start, Goal) ->
    Queue = queue:from_list([{Start, [Start]}]),
    Visited = sets:add_element(Start, sets:new()),

    bfs_loop(Grid, Goal, Queue, Visited).


bfs_loop(Grid, Goal, Queue, Visited) ->
    case queue:out(Queue) of
        {empty, _Queue} ->
            {error, no_path};

        {{value, {Current, Path}}, Queue1} ->
            Neighbors = robo_nav_grid:neighbors(Grid, Current),

            case find_goal(Neighbors, Goal, Visited) of
                {found, Goal} ->
                    {ok, Path ++ [Goal]};

                not_found ->
                    {Queue2, Visited2} =
                        add_neighbors(
                            Neighbors,
                            Path,
                            Queue1,
                            Visited
                        ),

                    bfs_loop(
                        Grid,
                        Goal,
                        Queue2,
                        Visited2
                    )
            end
    end.
find_goal([], _Goal, _Visited) ->
    not_found;

find_goal([Goal | _], Goal, Visited) ->
    case sets:is_element(Goal, Visited) of
        true ->
            not_found;
        false ->
            {found, Goal}
    end;

find_goal([_ | Rest], Goal, Visited) ->
    find_goal(Rest, Goal, Visited).


% add_neighbors([], _Goal, _Path, Queue, Visited) ->
%     {Queue, Visited};

% add_neighbors([Neighbor | Rest], Goal, Path, Queue, Visited) ->
%     case sets:is_element(Neighbor, Visited) of
%         true ->
%             add_neighbors(Rest, Goal, Path, Queue, Visited);

%         false ->
%             NewQueue =
%                 queue:in(
%                     {Neighbor, Path ++ [Neighbor]},
%                     Queue
%                 ),
% 
%             NewVisited =
%                 sets:add_element(Neighbor, Visited),

%             add_neighbors(
%                 Rest,
%                 Goal,
%                 Path,
%                 NewQueue,
%                 NewVisited
%             )
%     end.

add_neighbors([], _Path, Queue, Visited) ->
    {Queue, Visited};

add_neighbors([Neighbor | Rest], Path, Queue, Visited) ->
    case sets:is_element(Neighbor, Visited) of
        true ->
            add_neighbors(Rest, Path, Queue, Visited);

        false ->
            NewQueue =
                queue:in(
                    {Neighbor, Path ++ [Neighbor]},
                    Queue
                ),

            NewVisited =
                sets:add_element(Neighbor, Visited),

            add_neighbors(
                Rest,
                Path,
                NewQueue,
                NewVisited
            )
    end.