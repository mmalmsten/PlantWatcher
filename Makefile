PROJECT = plantwatcher
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = pigpio cowboy jiffy

dep_cowboy_commit = 2.8.0

dep_pigpio = git https://github.com/mmalmsten/pigpio.git
dep_pigpio_commit = master

DEP_PLUGINS = cowboy

include erlang.mk
