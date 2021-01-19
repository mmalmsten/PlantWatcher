-module(plantwatcher_app).

-behaviour(application).

-export([start/2]).

-export([stop/1]).

start(_Type, _Args) ->
    {ok, Pid} = hardware:start(),
    Dispatch = cowboy_router:compile([{'_',
				       [{"/", plantwatcher_handler, Pid}]}]),
    {ok, _} = cowboy:start_clear(my_http_listener,
				 [{port, 8080}],
				 #{env => #{dispatch => Dispatch}}),
    plantwatcher_sup:start_link().

stop(_State) -> ok.
