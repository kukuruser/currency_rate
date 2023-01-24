-module(no_matching_route_handler).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
     Req = cowboy_req:reply(404,
         #{<<"content-type">> => <<"text/plain">>},
         <<"404. Not found">>,
         Req0),
     {ok, Req, State}.