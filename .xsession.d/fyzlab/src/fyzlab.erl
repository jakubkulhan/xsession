-module(fyzlab).
-behavior(gen_server).
-behavior(application).
-export([start/0]).
-export([start/2, stop/1]).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([share_desktop/0, stop_share_desktop/0]).

-record(state, {}).

start() ->
    case start_apps([crypto, nbh, fyzlab]) of
        ok ->
            case init:get_argument(fyzlab_desktop_spawnkillable) of
                {ok, [[Spawnkillable]]} ->
                    application:set_env(fyzlab_desktop, spawnkillable, Spawnkillable),
                    case get_master() of
                        not_found ->
                            error_cmd(cant_find_master);
                        MasterNode ->
                            MasterNodeHost = get_nodehost(MasterNode),
                            case init:get_argument(fyzlab_continue) of
                                {ok, [[ContinueCmd]]} ->
                                    Cmd = ContinueCmd ++ " " ++ MasterNodeHost,
                                    io:format("executing: ~s~n", [Cmd]),
                                    os:cmd(Cmd);
                                _ ->
                                    error_cmd(badarg_continue)
                            end
                    end;
                _ ->
                    error_cmd(badarg_spawnkillable)
            end;
        {error, _} ->
            error_cmd(cant_start)
    end,
    init:stop().

start_apps([]) ->
    ok;

start_apps([App|Rest]) ->
    case application:start(App) of
        ok ->
            start_apps(Rest);
        {error, {already_started, App}} ->
            start_apps(Rest);
        {error, _Reason} ->
            {error, {cant_start, App}}
    end.

get_master() ->
    get_master(nodes(), 10).

get_master(Nodes, 0) ->
    get_master(Nodes);

get_master(Nodes, N) ->
    case get_master(Nodes) of
        not_found ->
            timer:sleep(1000),
            get_master(Nodes, N - 1);
        Node ->
            Node
    end.

get_master([]) ->
    not_found;

get_master([Node|Rest]) ->
    case get_nodename(Node) of
        "master" ->
            Node;
        _ ->
            get_master(Rest)
    end.

get_peers() ->
    nbh:discover(),
    get_peers(nodes()).

get_peers(Nodes) ->
    get_peers(Nodes, [], get_nodehost()).

get_peers([], Acc, _MyNodeHost) ->
    Acc;

get_peers([Node|Rest], Acc, MyNodeHost) ->
    case get_nodename(Node) of
        "node" ->
            case get_nodehost(Node) of
                MyNodeHost ->
                    get_peers(Rest, Acc, MyNodeHost);
                _ ->
                    get_peers(Rest, [Node|Acc], MyNodeHost)
            end;
        _ ->
            get_peers(Rest, Acc, MyNodeHost)
    end.

error_cmd(Key) ->
    {ok, Cmd} = application:get_env(?MODULE, Key),
    os:cmd(Cmd).

share_desktop() ->
    once_send_peers({start_desktop, get_nodehost()}).

stop_share_desktop() ->
    once_send_peers(stop_desktop).

once_send_peers(Msg) ->
    case start_apps([crypto, nbh]) of
        ok ->
            nbh:discover(),
            timer:sleep(500),
            lists:foreach(fun (Node) ->
                io:format("~p~n", [Node]),
                gen_server:call({?MODULE, Node}, Msg)
            end, get_peers());
        {error, _} ->
            error_cmd(cant_start)
    end,
    init:stop().

%start_desktop(Node) ->
%    gen_server:call({?MODULE, Node}, {start_desktop, get_nodehost(node())}).
%
%start_desktops([]) ->
%    ok;
%
%start_desktops([Node|Rest]) ->
%    start_desktop(Node),
%    start_desktops(Rest).
%
%stop_desktop(Node) ->
%    gen_server:call({?MODULE, Node}, stop_desktop).
%
%stop_desktops([]) ->
%    ok;
%
%stop_desktops([Node|Rest]) ->
%    stop_desktop(Node),
%    stop_desktops(Rest).

get_nodehost() ->
    get_nodehost(node()).

get_nodehost(Node) when is_atom(Node) ->
    get_nodehost(atom_to_list(Node));

get_nodehost([]) ->
    "";

get_nodehost([$@|Rest]) ->
    Rest;

get_nodehost([_|Rest]) ->
    get_nodehost(Rest).

get_nodename(Node) when is_atom(Node) ->
    get_nodename(atom_to_list(Node), []);

get_nodename(Node) ->
    get_nodename(Node, []).

get_nodename([$@|_], Acc) ->
    lists:reverse(Acc);

get_nodename([Char|Rest], Acc) ->
    get_nodename(Rest, [Char|Acc]).

start(_Type, _Args) ->
    fyzlab_sup:start_link().

stop(_State) ->
    ok.

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_Args) ->
    {ok, #state{}}.

handle_call({start_desktop, Host}, _From, State) ->
    ok = application:set_env(fyzlab_desktop, host, Host),
    Reply = application:start(fyzlab_desktop),
    {reply, Reply, State};

handle_call(stop_desktop, _From, State) ->
    Reply = application:stop(fyzlab_desktop),
    {reply, Reply, State};

handle_call(_Msg, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_info(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.
