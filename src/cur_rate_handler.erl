-module(cur_rate_handler).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->

     Body = updater:get_currency_rate(),
     Req = cowboy_req:reply(200,
         #{<<"content-type">> => <<"text/xml">>},
         Body,
         Req0),

     {ok, Req, State}.