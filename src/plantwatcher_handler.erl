-module(plantwatcher_handler).

-export([init/2]).

init(Req0, State) ->
	hardware ! {self(), status},
	Body = status(),
    Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
		Body,
        Req0),
    {ok, Req, State}.


status() ->
	receive
		{Time, Should_refill, Pump_status, Pump_running_time} ->
			jiffy:encode(#{
				<<"time">> => Time,
				<<"should_refill">> => Should_refill,
				<<"pump_status">> => Pump_status,
				<<"pump_running_time">> => Pump_running_time
			});
		_ -> status()
	end.