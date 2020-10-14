-module(hardware).

-export([start/0]).

-export([init/0]).

start() ->
    Pid = spawn_link(?MODULE, init, []),
    register(hardware, Pid),
    {ok, Pid}.

init() ->
    {ok, Pid1} = pigpio:start_link("192.168.0.20", 8888, 1),
    register(bucket, Pid1),
    {ok, Pid2} = pigpio:start_link("192.168.0.20", 8888, 2),
    register(pot, Pid2),
    {ok, Pid3} = pigpio:start_link("192.168.0.20", 8888, 3),
    register(pump, Pid3),
    % Msg = pigpio:read(whereis(pump))
    % Msg = pigpio:write(Gpio, Msg)
    timer:send_interval(1000, check_water_level),
    loop(true, on, 0, 0).

loop(Bucket_empty, Pump_status, Pump_running,
     Pump_start) ->
    io:format("~p~n",
	      [[Bucket_empty, Pump_status, Pump_running,
		Pump_start]]),
    receive
      % Get current status
      {Pid, status} ->
	  Pid !
	    {os:system_time(), Bucket_empty, Pump_status,
	     Pump_running},
	  loop(Bucket_empty, Pump_status, Pump_running,
	       Pump_start);
      % Turn on the pump
      {pump_status, on} ->
	  pigpio:write(whereis(pump), on),
	  loop(Bucket_empty, on, 0, os:system_time(seconds));
      % Turn off the pump
      {pump_status, off} ->
	  pigpio:write(whereis(pump), off),
	  case Pump_start of
	    false -> loop(Bucket_empty, off, 0, false);
	    _ ->
		loop(Bucket_empty, off,
		     os:system_time(seconds) - Pump_start, false)
	  end;
      % Check the water levels and act accordingly
      check_water_level ->
	  check_water_level(Bucket_empty,
			    pigpio:read(whereis(bucket)),
			    pigpio:read(whereis(pot))),
	  loop(Bucket_empty, Pump_status, Pump_running,
	       Pump_start);
      % Act on empty bucket
      bucket_empty ->
	  self() ! {pump_status, off},
	  loop(true, Pump_status, Pump_running, Pump_start);
      % Act on refilled bucket
      bucket_full -> loop(false, Pump_status, 0, Pump_start);
      % Fallback
      X ->
	  io:format("~p~n", [X]),
	  loop(Bucket_empty, Pump_status, Pump_running,
	       Pump_start)
    end.

%% -----------------------------------------------------------------------------
%% Check the water levels and act accordingly
%% -----------------------------------------------------------------------------
-spec check_water_level(Bucket_empty :: boolean(),
			Bucket_status :: boolean(),
			Pot_status :: boolean()) -> {true, Req :: map(),
						     State :: list()}.

%% -----------------------------------------------------------------------------
%% Bucket has been refilled
%% -----------------------------------------------------------------------------
check_water_level(true, true, Pot_status) ->
    self() ! bucket_full,
    check_water_level(false, true, Pot_status);
% Both buckets and pots are filled with water
check_water_level(_, true, true) -> ok;
% The bucket is empty. Never start the pump
check_water_level(_, false, _) -> self() ! bucket_empty;
% Pot is empty. Ensure the pump is on.
check_water_level(_, _, false) ->
    self() ! {pump_status, on}.
