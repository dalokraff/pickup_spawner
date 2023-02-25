local mod = get_mod("pickup_spawner")

--[[
    author: dalo_kraff
	
	-----
 
	Copyright 2022 dalo_kraff

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
	-----

	Description: Perfroms similar to VT2's item spawner mod but spawns only "pickups"
    Default keybindings are left arrow("left")/right arrow("right") to cycle through items and down arrow("down") to spawn item.
    Can change the keybind table keys to any found at https://help.autodesk.com/view/Stingray/ENU/?guid=__lua_ref_ns_stingray_Keyboard_html
--]]

-- local mod_name = "pickup_spawner"
-- Mods[mod_name] = Mods[mod_name] or {}
-- local mod = Mods[mod_name]

-- ##########################################################
-- ################## Variables #############################
mod.pickup_to_spawn = 1
local Managers = Managers
local Pickups = require("scripts/settings/pickup/pickups")

local ordered_pickups = {}
local num_pickups = 0
for k,v in pairs(Pickups.by_name) do
    num_pickups = #ordered_pickups + 1
    ordered_pickups[num_pickups] = k
end

local GameModeSettings = require("scripts/settings/game_mode/game_mode_settings")
local allowed_game_modes = {}

for name, settings in pairs(GameModeSettings) do
	allowed_game_modes[name] = false
end

allowed_game_modes.shooting_range = true

-- ##########################################################
-- ################## Functions #############################

local function printf(...)
    print(string.format(...))
end

local function is_available(type, name)
    local query = Application.can_get_resource(type, name)
	printf("%s.%s : available? => %s", name, type, query)
    return query 
end

local function spawn_pickup(pickup_name, position, rotation, apply_objective_marker)
	local pickup_system = Managers.state.extension:system("pickup_system")
	local pickup_unit, pickup_unit_go_id = pickup_system:spawn_pickup(pickup_name, position, rotation)

	if apply_objective_marker then
		add_objective_marker(pickup_unit, "training_grounds", false, {
			ui_target_type = "interact"
		})
	end

	return pickup_unit, pickup_unit_go_id
end

local function spawn_pickup_item(pickup_name)
    local world = Managers.world:world("level_world")
    local player = Managers.player:local_player(1)
    local player_unit = player.player_unit
    local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")

    local first_person_read_component = unit_data_extension:read_component("first_person")
	local player_1p_position = first_person_read_component.position
    local player_1p_rotation = first_person_read_component.rotation

    local locomotion_read_component = unit_data_extension:read_component("locomotion")
	local player_position = locomotion_read_component.position
    local player_rotation = locomotion_read_component.rotation

    local pickup_unit, pickup_unit_go_id = spawn_pickup(pickup_name, player_position, player_rotation, false)
    Unit.enable_physics(pickup_unit)
    mod:echo("Spawned: "..pickup_name)
end

local function cycle_items(index)
    if index > num_pickups then
        index = 1
    elseif index <= 0 then
        index = num_pickups
    end
    return index
end

local is_in_allowed_mode = function()
	if Managers and Managers.state and Managers.state.game_mode then
		return allowed_game_modes[Managers.state.game_mode:game_mode_name()]
	end
end

local can_spawn_item = function()
	return is_in_allowed_mode() and (not mod.chat_open)
end

mod.cycle_forward = function(self)
    local ui_manager = Managers and Managers.ui
    local active_menu = ui_manager:has_active_view() and not ui_manager:chat_using_input()
    if can_spawn_item() and not active_menu then
        mod.pickup_to_spawn = cycle_items(mod.pickup_to_spawn + 1)
        mod:echo(tostring(ordered_pickups[mod.pickup_to_spawn]))
    end
end

mod.cycle_backward = function(self)
    local ui_manager = Managers and Managers.ui
    local active_menu = ui_manager:has_active_view() and not ui_manager:chat_using_input()
    if can_spawn_item() and not active_menu then
        mod.pickup_to_spawn = cycle_items(mod.pickup_to_spawn - 1)
        mod:echo(tostring(ordered_pickups[mod.pickup_to_spawn]))
    end
end

mod.spawn_selected_pickup = function(self)
    local ui_manager = Managers and Managers.ui
    local active_menu = ui_manager:has_active_view() and not ui_manager:chat_using_input()
    if can_spawn_item() and not active_menu then
        local pickup_name = ordered_pickups[mod.pickup_to_spawn]
        spawn_pickup_item(pickup_name)
    end
end

-- ##########################################################
-- #################### Hooks ###############################

-- mod:hook(ConstantElementChat, "using_input", function (func, self)
--     local results = func(self)
--     mod.chat_open = results 
--     return results
-- end)
