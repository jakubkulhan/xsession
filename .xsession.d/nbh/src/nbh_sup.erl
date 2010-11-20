%% @doc Neighbour nodes search supervisor
%% @author Jakub Kulhan <jakub.kulhan@gmail.com>

-module(nbh_sup).
-behaviour(supervisor).
-export([start_link/2, start_link/3, init/1]).

%% @doc Starts supervisor
%% @equiv start_link(Addr, Port, 1)
start_link(Addr, Port) ->
    start_link(Addr, Port, 1).

%% @doc Starts supervisor
%% @spec (ip_address(), integer(), integer()) -> {ok, pid()}
start_link(Addr, Port, TTL) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Addr, Port, TTL]).

%% @doc Initialization implementation
%% @spec (term()) -> {ok, term()}
init([Addr, Port, TTL]) ->
    {ok, {
            {one_for_one, 1, 10},
            [{nbh,
                {nbh, start_link, [Addr, Port, TTL]},
                permanent,
                10,
                worker,
                [nbh]}
            ]
        }
    }.
