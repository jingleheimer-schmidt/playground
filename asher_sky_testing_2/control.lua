
--[[
Spider Trails control script © 2022 by asher_sky is licensed under Attribution-NonCommercial-ShareAlike 4.0 International. See LICENSE.txt for additional information
--]]

local table = require("__flib__.table")
local math = require("__flib__.math")

local speeds = {
  veryslow = 0.010,
  slow = 0.025,
  default = 0.050,
  fast = 0.100,
  veryfast = 0.200,
}

local palette = {
  light = {amplitude = 15, center = 240},           -- light
  pastel = {amplitude = 55, center = 200},          -- pastel <3
  default = {amplitude = 127.5, center = 127.5},    -- default (nyan)
  vibrant = {amplitude = 50, center = 100},         -- muted
  deep = {amplitude = 25, center = 50},             -- dark
}

local sin = math.sin
local pi_0 = 0 * math.pi / 3
local pi_2 = 2 * math.pi / 3
local pi_4 = 4 * math.pi / 3

function make_rainbow(event_tick, unit_number, frequency, palette_choice)
  -- local frequency = speeds[settings["biter-trails-speed"]]
  -- local modifier = unit_number + event_tick
  local freq_mod = frequency * (unit_number + event_tick)
  local amplitude = palette_choice.amplitude
  local center = palette_choice.center
  return {
    r = sin(freq_mod+pi_0)*amplitude+center,
    g = sin(freq_mod+pi_2)*amplitude+center,
    b = sin(freq_mod+pi_4)*amplitude+center,
    a = 255,
  }
end

local function initialize_settings()
  if not global.data.settings then
    global.data.settings = {}
  end
  local settings = settings.global
  global.data.settings = {}
  global.data.settings["biter-trails-color"] = settings["biter-trails-color"].value
  global.data.settings["biter-trails-glow"] = settings["biter-trails-glow"].value
  global.data.settings["biter-trails-length"] = settings["biter-trails-length"].value
  global.data.settings["biter-trails-scale"] = settings["biter-trails-scale"].value
  global.data.settings["biter-trails-color-type"] = settings["biter-trails-color-type"].value
  global.data.settings["biter-trails-speed"] = settings["biter-trails-speed"].value
  global.data.settings["biter-trails-palette"] = settings["biter-trails-palette"].value
  global.data.settings["biter-trails-balance"] = settings["biter-trails-balance"].value
end

local function get_all_biters()
  if not global.data.biters then
    global.data.biters = {}
  end
  if not global.data.sleeping_biters then
    global.data.sleeping_biters = {}
  end
  for each, surface in pairs(game.surfaces) do
    local biters = surface.find_entities_filtered{type={"unit"}, force={"enemy"}}
    for every, biter in pairs(biters) do
      global.data.sleeping_biters[biter.unit_number] = {
        biter = biter,
        position = biter.position,
        counter = 1
      }
    end
  end
end

local function add_biter(event)
  local biter = event.created_entity or event.entity
  global.data.biters[biter.unit_number] = {
    biter = biter,
    position = biter.position,
    counter = 1
  }
end

local function get_player_forces()
  if not global.data.player_forces then
    global.data.player_forces = {}
  end
  for each, player in pairs(game.players) do
    if player.valid and player.force then
      local forces = global.data.player_forces
      local force_name = player.force.name
      if not forces[force_name] then
        global.data.player_forces[force_name] = {
          force = player.force,
          number_of_players = 1
        }
      else
        global.data.player_forces[force_name].number_of_players = forces[force_name].number_of_players + 1
      end
    end
  end
end

script.on_event(defines.events.on_player_changed_force, function(event)
  if not global.data.player_forces then
    global.data.player_forces = {}
  end
  local forces = global.data.player_forces
  local player = game.get_player(event.player_index)
  local force_name = player.force.name
  if not forces[force_name] then
    global.data.player_forces[force_name] = {
      force = player.force,
      number_of_players = 1
    }
  else
    global.data.player_forces[force_name].number_of_players = forces[force_name].number_of_players + 1
  end
  local old_force_name = event.force.name
  if forces[old_force_name] then
    local number_of_players = forces[old_force_name].number_of_players
    if number_of_players == 1 then
      global.data.player_forces[old_force_name] = nil
    else
      global.data.player_forces[old_force_name].number_of_players = number_of_players - 1
    end
  end
end)

-- script.on_event(defines.events.on_built_entity, function(event)
--   add_biter(event)
-- end,
-- {{filter = "type", type = "unit"}})

-- script.on_event(defines.events.on_built_entity, function(event)
--   add_biter(event)
-- end,
-- {{filter = "type", type = "logistic-robot"}})

-- script.on_event(defines.events.on_built_entity, function(event)
--   add_biter(event)
-- end,
-- {{filter = "type", type = {"construction-robot", "logistic-robot"}}})
--
-- script.on_event(defines.events.on_robot_built_entity, function(event)
--   add_biter(event)
-- end,
-- {{filter = "type", type = {"construction-robot", "logistic-robot"}}})

-- script.on_event(defines.events.script_raised_built, function(event)
--   add_biter(event)
-- end,
-- {{filter = "type", type = "unit"}})

-- script.on_event(defines.events.script_raised_built, function(event)
--   add_biter(event)
-- end,
-- {{filter = "type", type = "logistic-robot"}})

script.on_event(defines.events.on_entity_spawned, function(event)
  if event.entity
  and event.entity.type
  -- and (event.entity.type == "construction-robot"
  -- or event.entity.type == "logistic-robot")
  then
    add_biter(event)
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function()
  initialize_settings()
end)

script.on_configuration_changed(function()
  if not global.data then
    global.data = {}
  end
  initialize_settings()
  get_all_biters()
  get_player_forces()
end)

script.on_init(function()
  if not global.data then
    global.data = {}
  end
  initialize_settings()
  get_all_biters()
  get_player_forces()
end)

local function make_trails(settings, event)
  local sprite = settings["biter-trails-color"]
  local light = settings["biter-trails-glow"]
  if sprite or light then
    local length = tonumber(settings["biter-trails-length"])
    local scale = tonumber(settings["biter-trails-scale"])
    -- local color_mode = settings["biter-trails-color-type"]
    -- local passengers_only = settings["biter-trails-passengers-only"]
    local frequency = speeds[settings["biter-trails-speed"]]
    local palette_choice = palette[settings["biter-trails-palette"]]
    -- local tiptoe_mode = settings["biter-trails-tiptoe-mode"]
    local global_data = global.data
    local new_biter_data = global_data.biters
    local new_sleeping_biter_data = global_data.sleeping_biters
    local forces = global_data.player_forces
    local num = 0
    local event_tick = event.tick
    local group_colors = global_data.group_colors
    if not group_colors then
      group_colors = {}
      global.data.group_colors = {}
    else
      for group_number, data in pairs(group_colors) do
        if not data.group and data.group.valid then
          group_colors[group_number] = nil
        else
          group_colors[group_number].color = make_rainbow(event_tick, group_number, frequency, palette_choice)
        end
      end
    end
    if new_sleeping_biter_data then
      -- local sleeping_biters = new_sleeping_biter_data
      -- local nth_tick = 1
      -- if event.nth_tick then
      --   nth_tick = event.nth_tick
      -- end
      -- num = table_size(sleeping_biters) / 120 * nth_tick
      num = table_size(new_sleeping_biter_data) * 0.008
      global.data.from_key = table.for_n_of(new_sleeping_biter_data, global_data.from_key, num, function(data, key)
        if data.biter and data.biter.valid then
          local biter = data.biter
          local last_position = data.position
          local current_position = data.biter.position
          local current_x = current_position.x
          local current_y = current_position.y
          local same_position = last_position and (last_position.x == current_x) and (last_position.y == current_position.y)
          local chunk_is_visible = false
          for _, data in pairs(forces) do
            if data.force.is_chunk_visible(biter.surface, {current_x / 32, current_y / 32}) then
              chunk_is_visible = true
            end
          end
          if (not same_position) and chunk_is_visible then
            new_biter_data[biter.unit_number] = {
              biter = biter,
              position = current_position,
              counter = 1
            }
            new_sleeping_biter_data[data.biter.unit_number] = nil
          end
        end
      end)
    end
    -- local biters = global_data.biters
    if new_biter_data then
      -- local new_biter_data = {}
      for unit_number, data in pairs(new_biter_data) do
        local biter = data.biter
        if not biter.valid then
          new_biter_data[unit_number] = nil
        else
          local last_position = data.position
          local current_position = biter.position
          local current_x = current_position.x
          local current_y = current_position.y
          local same_position = last_position and (last_position.x == current_x) and (last_position.y == current_y)
          local chunk_is_hidden = false
          local visible_check_timer = data.visible_check_timer
          if visible_check_timer then
            if visible_check_timer > 900 then
              for _, data in pairs(forces) do
                if not data.force.is_chunk_visible(biter.surface, {current_x / 32, current_y / 32}) then
                  chunk_is_hidden = true
                end
              end
              visible_check_timer = 1
            else
              visible_check_timer = visible_check_timer + 1
            end
          else
            new_biter_data[unit_number].visible_check_timer = 1
          end
          -- if not same_position then
          if (not same_position) and (not chunk_is_hidden) then
            -- local event_tick = event.tick
            -- local uuid = unit_number
            local color = {}
            if biter.unit_group then
              local group_number = biter.unit_group.group_number
              if group_colors then
                if group_colors[group_number] then
                  color = group_colors[group_number].color
                else
                  color = make_rainbow(event_tick, group_number, frequency, palette_choice)
                  group_colors[group_number] = {
                    group = biter.unit_group,
                    color = color
                  }
                end
              end
            else
              color = make_rainbow(event_tick, unit_number, frequency, palette_choice)
            end
            local surface = biter.surface

            if sprite then
              -- sprite = rendering.draw_sprite{
              rendering.draw_sprite{
                sprite = "biter-trail",
                target = current_position,
                surface = surface,
                x_scale = scale,
                y_scale = scale,
                render_layer = "radius-visualization",
                time_to_live = length,
                tint = color,
              }
            end
            if light then
              -- light = rendering.draw_light{
              rendering.draw_light{
                sprite = "biter-trail",
                target = current_position,
                surface = surface,
                intensity = .175,
                scale = scale * 1.75,
                render_layer = "light-effect",
                time_to_live = length,
                color = color,
              }
            end
            -- if sprite or light then
            --   surface.create_particle{
            --     name = "explosion-stone-particle-medium",
            --     position = current_position,
            --     movement = {0,0},
            --     height = 10,
            --     vertical_speed = 10,
            --     frame_speed = 10
            --   }
            -- end
            -- game.print("[gps="..biter.position.x..","..biter.position.y.."]")
            new_biter_data[unit_number] = {
              biter = biter,
              position = current_position,
              counter = 1
            }
          else
            local counter = data.counter
            if counter > 333 then
              new_sleeping_biter_data[unit_number] = {
                biter = biter,
                position = current_position,
                counter = 1
              }
              new_biter_data[unit_number] = nil
            else
              new_biter_data[unit_number] = {
                biter = biter,
                position = current_position,
                counter = counter + 1
              }
            end
          end
        end
      end
      global.data.biters = new_biter_data
      global.data.sleeping_biters = new_sleeping_biter_data
      global.data.group_colors = group_colors
      global.data.visible_check_timer = visible_check_timer
    end
    -- game.print("[color=blue]active biters: "..table_size(global.data.biters)..", sleeping biters: "..math.round(table_size(global.data.sleeping_biters))..", checked: "..num..", group_colors: "..table_size(global.data.group_colors).."[/color]")
    game.print("[color=blue]active biters: "..table_size(global.data.biters)..", sleeping biters: "..math.round(table_size(global.data.sleeping_biters))..", checked: "..num.."[/color]")
  end
end

script.on_event(defines.events.on_tick, function(event)
  if not global.data.settings then
    initialize_settings()
  end
  local settings = global.data.settings
  if settings["biter-trails-balance"] == "super-pretty" then
    make_trails(settings, event)
    -- test()
  end
end)

script.on_nth_tick(2, function(event)
  local settings = global.data.settings
  if settings["biter-trails-balance"] == "pretty" then
    make_trails(settings, event)
    -- test()
  end
end)

script.on_nth_tick(3, function(event)
  local settings = global.data.settings
  if settings["biter-trails-balance"] == "balanced" then
    make_trails(settings, event)
    -- test()
  end
end)

script.on_nth_tick(4, function(event)
  local settings = global.data.settings
  if settings["biter-trails-balance"] == "performance" then
    make_trails(settings, event)
    -- test()
  end
end)
