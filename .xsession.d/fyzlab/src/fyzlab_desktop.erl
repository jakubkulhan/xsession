-module(fyzlab_desktop).
-behavior(gen_server).
-behavior(application).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start/2, stop/1]).

-record(state, {port, kill_command}).

start(_Type, _Args) ->
    {ok, Command} = application:get_env(?MODULE, command),
    {ok, Spawnkillable} = application:get_env(?MODULE, spawnkillable),
    {ok, Host} = application:get_env(?MODULE, host),
    fyzlab_desktop_sup:start_link(Spawnkillable ++ " " ++ Command ++ " " ++ Host).

stop(_State) ->
    ok.

start_link(Command) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Command], []).

init([Command]) ->
    process_flag(trap_exit, true),
    Port = open_port({spawn, Command}, [stream, {line, 256}]),
    receive
        {Port, {data, {eol, KillCommand}}} ->
            {ok, #state{port = Port, kill_command = KillCommand}}
    after 1000 ->
            {ok, #state{port = Port}}
    end.

handle_call(_Msg, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_info({'EXIT', Port, Reason}, #state{port = Port} = State) ->
    {stop, {port_terminated, Reason}, State};

handle_info(_Msg, State) ->
    {noreply, State}.

terminate({port_terminated, _Reason}, _State) ->
    ok;

terminate(_Reason, #state{port = Port, kill_command = KillCommand} = _State) ->
    true = port_close(Port),
    os:cmd(KillCommand).
