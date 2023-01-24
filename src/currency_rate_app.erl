%%%-------------------------------------------------------------------
%% @doc currency_rate public API
%% @end
%%%-------------------------------------------------------------------

-module(currency_rate_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->

     CurRateRoute = { "/", cur_rate_handler, [] },
     CatchAllRoute = {"/[...]", no_matching_route_handler, []},

     Dispatch = cowboy_router:compile([
         {'_', [CurRateRoute, CatchAllRoute]}
     ]),


     {ok, _} = cowboy:start_clear(cur_rate_http_listener,
         [{port, 8080}],
         #{env => #{dispatch => Dispatch} }
     ),

    currency_rate_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
