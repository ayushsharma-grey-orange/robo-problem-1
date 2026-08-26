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
    % Queue stores {current,[Visited]} positions
    Queue = queue:from_list([{Start, [Start]}]),
    Visited = sets:add_element(Start, sets:new()),

    bfs_loop(Grid, Goal, Queue, Visited).


bfs_loop(Grid, Goal, Queue, Visited) ->

%      TAKING first element from the queue   
    case queue:out(Queue) of
        {empty, _Queue} ->
            {error, no_path};

    % Current is the current grid
    % path is the path traversed so far
    %  And Queue1 is the queue after removing this item.
        {{value, {Current, Path}}, Queue1} ->

            % Find the Neighbours of the current position
            Neighbors = robo_nav_grid:neighbors(Grid, Current),

            % This checks whether the goal is in the neighbors and if 
        % it is not then it adds the neighbors to the queue and continues the search.
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



%  No neighbor to add
add_neighbors([], _Path, Queue, Visited) ->
    {Queue, Visited};

add_neighbors([Neighbor | Rest], Path, Queue, Visited) ->
    % Adds the neighbor to the queue if it has not been visited yet. 
    % If it has been visited, it skips to the next neighbor in the Array.
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