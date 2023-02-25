return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`pickup_spawner` encountered an error loading the Darktide Mod Framework.")

		new_mod("pickup_spawner", {
			mod_script       = "pickup_spawner/scripts/mods/pickup_spawner/pickup_spawner",
			mod_data         = "pickup_spawner/scripts/mods/pickup_spawner/pickup_spawner_data",
			mod_localization = "pickup_spawner/scripts/mods/pickup_spawner/pickup_spawner_localization",
		})
	end,
	packages = {},
}
