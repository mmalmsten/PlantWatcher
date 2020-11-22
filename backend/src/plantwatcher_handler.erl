-module(plantwatcher_handler).

-export([init/2]).

init(Req0, Pid) ->
    Map = gen_server:call(Pid, read),
    Req = cowboy_req:reply(200,
      #{<<"content-type">> => <<"application/json">>},
      jiffy:encode(maps:put(time, os:system_time(second), Map)), 
      Req0
    ),
    {ok, Req, Pid}.