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
    Bucket = pigpio:call(Pid_bucket, read),
    Pot = pigpio:call(Pid_pot, read),
    case {Bucket, Pot} of
        % Bucket is full and pot is empty, start pump
        {0, 1} -> io:format("Start the pump! ~n");
        % pigpio:cast(Pid_pump, {command, setpullupdown, 1});
        % All other senarios, stop pump
        _ ->
            io:format("Stop the pump! ~n"),
            pigpio:cast(Pid_pump, {command, setpullupdown, 0})
    end,
    State#{status :=
               #{bucket => Bucket, pot => Pot,
                 pump => {Bucket, Pot} == {0, 1}}}.

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
    {ok, Pid}.
