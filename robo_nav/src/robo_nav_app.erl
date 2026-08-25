%%%-------------------------------------------------------------------
%% @doc robo_nav public API
%% @end
%%%-------------------------------------------------------------------

-module(robo_nav_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    robo_nav_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
