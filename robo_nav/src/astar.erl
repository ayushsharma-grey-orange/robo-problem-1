-module(astar).

% -export([find_path/3]).

% -include("header.hrl").


% %% ============================================================
% %% Public API
% %% ============================================================

% -spec find_path(position(), position(), grid()) ->
%     {ok, [position()]} | {error, no_path}.

% find_path(Start, Goal, Grid) ->
%     OpenSet = [{heuristic(Start, Goal), 0, Start, [Start]}],
%     ClosedSet = sets:new(),

%     astar(OpenSet, ClosedSet, Goal, Grid).


% %% ============================================================
% %% A* main loop
% %% ============================================================

% astar([], _ClosedSet, _Goal, _Grid) ->
%     {error, no_path};

% astar(OpenSet, ClosedSet, Goal, Grid) ->
%     %% Get node with smallest F score
%     {_F, G, Current, Path, RestOpenSet} =
%         pop_lowest_f(OpenSet),

%     %% Goal reached
%     case Current =:= Goal of
%         true ->
%             {ok, lists:reverse(Path)};

%         false ->
%             case sets:is_element(Current, ClosedSet) of
%                 true ->
%                     %% Already processed
%                     astar(RestOpenSet, ClosedSet, Goal, Grid);

%                 false ->
%                     NewClosedSet =
%                         sets:add_element(Current, ClosedSet),

%                     Neighbors =
%                         valid_neighbors(Current, Grid),

%                     NewOpenSet =
%                         add_neighbors(
%                             Neighbors,
%                             G,
%                             Path,
%                             RestOpenSet,
%                             NewClosedSet,
%                             Goal
%                         ),

%                     astar(
%                         NewOpenSet,
%                         NewClosedSet,
%                         Goal,
%                         Grid
%                     )
%             end
%     end.


% %% ============================================================
% %% Add neighbors to Open Set
% %% ============================================================

% add_neighbors(
%     [],
%     _CurrentG,
%     _Path,
%     OpenSet,
%     _ClosedSet,
%     _Goal
% ) ->
%     OpenSet;

% add_neighbors(
%     [Neighbor | Rest],
%     CurrentG,
%     Path,
%     OpenSet,
%     ClosedSet,
%     Goal
% ) ->
%     case sets:is_element(Neighbor, ClosedSet) of
%         true ->
%             add_neighbors(
%                 Rest,
%                 CurrentG,
%                 Path,
%                 OpenSet,
%                 ClosedSet,
%                 Goal
%             );

%         false ->
%             NewG = CurrentG + 1,
%             H = heuristic(Neighbor, Goal),
%             F = NewG + H,

%             NewOpenSet =
%                 [{F, NewG, Neighbor, [Neighbor | Path]}
%                  | OpenSet],

%             add_neighbors(
%                 Rest,
%                 CurrentG,
%                 Path,
%                 NewOpenSet,
%                 ClosedSet,
%                 Goal
%             )
%     end.


% %% ============================================================
% %% Get valid neighboring cells
% %% ============================================================

% valid_neighbors({Row, Col}, Grid) ->
%     Candidates = [
%         {Row - 1, Col}, %% Up
%         {Row + 1, Col}, %% Down
%         {Row, Col - 1}, %% Left
%         {Row, Col + 1}  %% Right
%     ],

%     [
%         Position
%         || Position <- Candidates,
%            is_valid_position(Position, Grid)
%     ].


% %% ============================================================
% %% Check whether a position can be visited
% %% ============================================================

% is_valid_position({Row, Col}, Grid) ->
%     Rows = maps:get(rows, Grid),
%     Cols = maps:get(cols, Grid),
%     Obstacles = maps:get(obstacles, Grid),

%     Row >= 1 andalso
%     Row =< Rows andalso
%     Col >= 1 andalso
%     Col =< Cols andalso
%     not sets:is_element({Row, Col}, Obstacles).


% %% ============================================================
% %% Manhattan distance heuristic
% %% ============================================================

% heuristic({R1, C1}, {R2, C2}) ->
%     abs(R1 - R2) + abs(C1 - C2).


% %% ============================================================
% %% Get node with smallest F
% %% ============================================================

% pop_lowest_f([First | Rest]) ->
%     pop_lowest_f(Rest, First, []).

% pop_lowest_f([], {F, G, Pos, Path}, Acc) ->
%     {
%         F,
%         G,
%         Pos,
%         Path,
%         lists:reverse(Acc)
%     };

% pop_lowest_f(
%     [{F, G, Pos, Path} = Current | Rest],
%     {BestF, BestG, BestPos, BestPath},
%     Acc
% ) ->
%     case F < BestF of
%         true ->
%             pop_lowest_f(
%                 Rest,
%                 Current,
%                 [BestF, BestG, BestPos, BestPath | Acc]
%             );

%         false ->
%             pop_lowest_f(
%                 Rest,
%                 {BestF, BestG, BestPos, BestPath},
%                 [Current | Acc]
%             )
%     end.