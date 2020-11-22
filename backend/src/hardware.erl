-module(hardware).

-behaviour(gen_server).

-export([start_link/0]).

-export([handle_call/3, handle_cast/2, handle_info/2,
	 init/1]).

-define(PUMP_GPIO, 17).
-define(BUCKET_GPIO, 25).
-define(POT_GPIO, 24).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_) ->
    {ok, Pid_pump} = pigpio:start_link(?PUMP_GPIO), 
    gen_server:cast(Pid_pump, {command, setmode, 1}),

    {ok, Pid_bucket} = pigpio:start_link(?BUCKET_GPIO), 
    gen_server:cast(Pid_bucket, {command, setmode, 0}),
    gen_server:cast(Pid_bucket, {command, setpullupdown, 2}),

    {ok, Pid_pot} = pigpio:start_link(?POT_GPIO), 
    gen_server:cast(Pid_pot, {command, setmode, 0}),
    gen_server:cast(Pid_pot, {command, setpullupdown, 2}),

    {ok, [#{}, Pid_pump, Pid_bucket, Pid_pot]}.

handle_call(read, _, [Map|_] = State) -> {reply, Map, State}.

handle_cast(check, State) -> {noreply, check(State)};
handle_cast(_, State) -> {noreply, State}.

%% Receive sensor data
handle_info(_, State) -> {noreply, State}.

check([_, Pid_pump, Pid_bucket, Pid_pot]) ->
    Bucket = gen_server:call(Pid_bucket, check),
    Pot = gen_server:call(Pid_pot, check),
    Pump = case {Bucket, Pot} of
        {0, 1} -> % Bucket is full and pot is empty, start engine
            gen_server:cast(Pid_pump, {command, setpullupdown, 0}), 
            % gen_server:cast(Pid_bucket, {command, setpullupdown, 2}), 
            2;
        _ -> % All other senarios, stop engine
            gen_server:cast(Pid_pump, {command, setpullupdown, 0}), 
            % gen_server:cast(Pid_bucket, {command, setpullupdown, 1}), 
            1
    end,
    [#{<<"bucket">> => Bucket, <<"pot">> => Pot, <<"pump">> => Pump}, Pid_pump, Pid_bucket, Pid_pot].