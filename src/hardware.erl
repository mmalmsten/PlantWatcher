-module(hardware).

-export([start/0]).

-export([init/0]).

-define(PUMP_GPIO, 21).

-define(BUCKET_GPIO, 3).

-define(POT_GPIO, 2).

start() ->
    Pid = spawn_link(?MODULE, init, []),
    {ok, Pid}.

init() ->
    {ok, Pid_pump} = pump(?PUMP_GPIO),
    {ok, Pid_bucket} = floating_meter(?BUCKET_GPIO),
    {ok, Pid_pot} = floating_meter(?POT_GPIO),
    timer:send_interval(1000, check),
    loop(#{status => off, pump => Pid_pump,
           bucket => Pid_bucket, pot => Pid_pot}).

loop(#{status := Status} = State) ->
    receive
        check -> loop(check(State));
        {status, Pid} ->
            Pid ! Status,
            loop(State);
        _ -> loop(State)
    end.

% Get current status from the sensors and start the pump if needed
check(#{pump := Pid_pump, bucket := Pid_bucket,
        pot := Pid_pot} =
          State) ->
    Bucket = floating_meter_status(pigpio:call(Pid_bucket,
                                               read)),
    Pot = floating_meter_status(pigpio:call(Pid_pot, read)),
    io:format("Bucket ~p~n", [Bucket]),
    io:format("Pot ~p~n", [Pot]),
    Status_pump = case {Bucket, Pot} of
                      % Bucket is full and pot is empty, start pump
                      {full, empty} ->
                          io:format("Start the pump! ~n"),
                          pigpio:cast(Pid_pump, {command, setpullupdown, 2}),
                          on;
                      % All other senarios, stop pump
                      _ ->
                          io:format("Stop the pump! ~n"),
                          pigpio:cast(Pid_pump, {command, setpullupdown, 1}),
                          off
                  end,
    State#{status :=
               #{bucket => Bucket, pot => Pot, pump => Status_pump}}.

floating_meter_status(#{read := 1}) -> full;
floating_meter_status(#{read := 0}) -> empty;
floating_meter_status(_) -> unknown.

% Register a new pump
pump(Gpio) ->
    {ok, Pid} = pigpio:start_link(Gpio),
    pigpio:cast(Pid, {command, setmode, 1}),
    {ok, Pid}.

% Register a new floating meter
floating_meter(Gpio) ->
    {ok, Pid} = pigpio:start_link(Gpio),
    pigpio:cast(Pid, {command, setmode, 0}),
    pigpio:cast(Pid, {command, setpullupdown, 2}),
    pigpio:cast(Pid, {read, 1000}),
    {ok, Pid}.
