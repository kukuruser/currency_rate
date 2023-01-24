-module(updater).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {tref}).

-define(INTERVAL, 60000).
-define(SHORTINTERVAL, 5000).
-define(URL, "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5").

start_link() ->
    Return = gen_server:start_link({local, ?MODULE}, ?MODULE, [], []),
    Return.

init([]) ->
    rates = ets:new(rates,[set, named_table]),
    true = ets:insert(rates, {currentRate, <<"<exchangerates></exchangerates>">>}),

    TRef = erlang:start_timer(1, self(), trigger),

    State = #state{tref = TRef},
    Return = {ok, State},
    Return.

handle_info(_Info, State) ->
   erlang:cancel_timer(State#state.tref),
   Resp = httpc:request(get, {?URL, []}, [], [{body_format, binary}]),
   case Resp of
     {ok,{StatusCode, _Headers, Body}} ->
       case StatusCode of
         {"HTTP/1.1",200,[]} ->
           true = ets:insert(rates, {currentRate, to_xml:to_xml(jsx:decode(Body))}),
           TRef = erlang:send_after(?INTERVAL, self(), check);
         _ ->
           %if response != 200 timer interval = 5s
           io:format("Error response from server. Status code not 200: ~p ~n",[Resp]),
           TRef = erlang:send_after(?SHORTINTERVAL, self(), check)
       end;
     _ ->
       io:format("Error response from server. Wrong format: ~p ~n",[Resp]),
       TRef = erlang:send_after(?SHORTINTERVAL, self(), check)
   end,

   io:format("handle_info rates updated. ~n", []),
   NewState = #state{tref = TRef},
   Return = {noreply, NewState},
   Return.

handle_call(_Request, _From, State) ->
    [{currentRate, CurrentRate}] = ets:lookup(rates, currentRate),
    Return = {reply, CurrentRate, State},
    Return.
    
handle_cast(_Msg, State) ->
    Return = {noreply, State},
    Return.

terminate(_Reason, _State) ->
    Return = ok,
    Return.

code_change(_OldVsn, State, _Extra) ->
    Return = {ok, State},
    Return.