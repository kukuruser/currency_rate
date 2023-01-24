%%%-------------------------------------------------------------------
%% @doc currency_rate top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(currency_rate_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    Updater = #{  id => updater,
                  start => {updater, start_link, []},
                  restart => permanent,
                  type => worker,
                  modules => [updater]},

    SupFlags = #{strategy => one_for_one,
                 intensity => 10,
                 period => 1},
    ChildSpecs = [Updater],
    {ok, {SupFlags, ChildSpecs}}.


%% internal functions
