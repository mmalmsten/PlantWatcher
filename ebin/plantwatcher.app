{application, 'plantwatcher', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['callback','hardware','pigpio','plantwatcher_app','plantwatcher_handler','plantwatcher_sup']},
	{registered, [plantwatcher_sup]},
	{applications, [kernel,stdlib,cowboy,jiffy]},
	{mod, {plantwatcher_app, []}},
	{env, []}
]}.