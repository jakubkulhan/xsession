-module(fyzlab_desktop_sup).
-behaviour(supervisor).
-export([start_link/1, init/1]).

start_link(Command) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Command]).

init([Command]) ->
    {ok, {
            {one_for_one, 1, 10},
            [{fyzlab_desktop,
                {fyzlab_desktop, start_link, [Command]},
                permanent,
                10,
                worker,
                [fyzlab_desktop]}
            ]
        }
    }.
