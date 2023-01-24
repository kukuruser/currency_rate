-module(cur_rate_handler).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->

     Body = gen_server:call(updater, getCurrentRate),
     Req = cowboy_req:reply(200,
         #{<<"content-type">> => <<"text/xml">>},
         Body,
         Req0),

     {ok, Req, State}.