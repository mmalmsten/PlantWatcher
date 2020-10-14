{application, 'plantwatcher', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['hardware','plantwatcher_app','plantwatcher_handler','plantwatcher_sup']},
	{registered, [plantwatcher_sup]},
	{applications, [kernel,stdlib,cowboy,jiffy,pigpio]},
	{mod, {plantwatcher_app, []}},
	{env, []}
]}.