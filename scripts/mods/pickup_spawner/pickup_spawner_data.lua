local mod = get_mod("pickup_spawner")

return {
	name = "Pickup Spawner",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "next_pickup",
				type            = "keybind",
				default_value   = {},
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "cycle_forward",
			},
			{
				setting_id      = "prev_pickup",
				type            = "keybind",
				default_value   = {},
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "cycle_backward",
			},
			{
				setting_id      = "spawn_pickup",
				type            = "keybind",
				default_value   = {},
				keybind_trigger = "pressed",
				keybind_type    = "function_call",
				function_name   = "spawn_selected_pickup",
			},
		}
	}
}
