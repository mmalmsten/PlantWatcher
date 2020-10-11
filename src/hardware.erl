-module(hardware).

-export([start/0]).

-export([init/0]).


start() -> 
    Pid = spawn_link(?MODULE, init, []), 
    register(hardware, Pid),
    {ok, Pid}.

init() -> 
    timer:send_interval(1000, check_water_level),
    loop(true, on, 0, 0).

loop(Should_refill, Pump_status, Pump_running_time, Pump_start) ->
    receive

        % Get current status
        {Pid, status} -> 
            io:format("~p~n", [status]), 
            Pid ! {os:system_time(), Should_refill, Pump_status, Pump_running_time},
            loop(Should_refill, Pump_status, Pump_running_time, Pump_start);

        % Turn on the pump
        {pump_status, on} -> 
            io:format("~p~n", [[pump_status, on]]), 
            pump_simulator(on),
            loop(Should_refill, on, 0, os:system_time(seconds));
        
        % Turn off the pump
        {pump_status, off} -> 
            io:format("~p~n", [[pump_status, off]]), 
            pump_simulator(off),
            case Pump_start of
                false -> loop(Should_refill, off, 0, false);
                _ -> loop(Should_refill, off, os:system_time(seconds) - Pump_start, false)
            end;

        % Check the water levels and act accordingly
        check_water_level ->
            io:format("~p~n", [check_water_level]), 
            check_water_level(Should_refill, bucket_simulator(), pot_simulator()),
            loop(Should_refill, Pump_status, Pump_running_time, Pump_start);

        % Act on empty bucket
        bucket_empty -> 
            io:format("~p~n", [bucket_empty]), 
            self() ! {pump_status, off},
            loop(true, Pump_status, Pump_running_time, Pump_start);

        % Act on refilled bucket
        bucket_full -> 
            io:format("~p~n", [bucket_full]), 
            loop(false, Pump_status, 0, Pump_start);

        % Fallback
        X -> 
            io:format("~p~n", [X]),
            loop(Should_refill, Pump_status, Pump_running_time, Pump_start)
    end.

% Check the water levels and act accordingly
-spec check_water_level(Should_refill::boolean(), Bucket_status::boolean(), Pot_status::boolean()) -> {true, Req::map(), State::list()}.
check_water_level(true, true, Pot_status) -> self() ! bucket_full, check_water_level(false, true, Pot_status); % Bucket has been refilled
check_water_level(_, true, true) -> ok; % Both buckets and pots are filled with water
check_water_level(_, false, _) -> self() ! bucket_empty; % The bucket is empty. Never start the pump
check_water_level(_, _, false) -> self() ! {pump_status, on}. % Pot is empty. Ensure the pump is on.

% Simulators until sensors are in use
pump_simulator(New_status) -> {ok, New_status}.
bucket_simulator() -> round(rand:uniform()) == 1.
pot_simulator() -> round(rand:uniform()) == 1.