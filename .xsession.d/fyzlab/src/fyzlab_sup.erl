-module(fyzlab_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).
-define(M, fyzlab).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, {
            {one_for_one, 1, 10},
            [{?M,
                {?M, start_link, []},
                permanent,
                10,
                worker,
                [?M]}
            ]
        }
    }.
