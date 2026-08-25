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
    code_change/3
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
        grid_size => {9, 9},
        robot => {1, 1},
        goal => {9, 9},
        obstacles => []
    },

    {ok, State}.

handle_call(get_state, _From, State) ->
    {reply, State, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVersion, State, _Extra) ->
    {ok, State}.