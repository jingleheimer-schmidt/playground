
--[[
Spider Trails control script © 2022 by asher_sky is licensed under Attribution-NonCommercial-ShareAlike 4.0 International. See LICENSE.txt for additional information
--]]

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
  local modifier = unit_number + event_tick
  -- local palette_choice = palette[settings["biter-trails-palette"]]
  local amplitude = palette_choice.amplitude
  local center = palette_choice.center
  return {
    r = sin(frequency*(modifier)+pi_0)*amplitude+center,
    g = sin(frequency*(modifier)+pi_2)*amplitude+center,
    b = sin(frequency*(modifier)+pi_4)*amplitude+center,
    a = 255,
  }
end

local function initialize_settings()
  if not global.settings then
    global.settings = {}
  end
  local settings = settings.global
  global.settings = {}
  global.settings["biter-trails-color"] = settings["biter-trails-color"].value
  global.settings["biter-trails-glow"] = settings["biter-trails-glow"].value
  global.settings["biter-trails-length"] = settings["biter-trails-length"].value
  global.settings["biter-trails-scale"] = settings["biter-trails-scale"].value
  global.settings["biter-trails-color-type"] = settings["biter-trails-color-type"].value
  global.settings["biter-trails-speed"] = settings["biter-trails-speed"].value
  global.settings["biter-trails-palette"] = settings["biter-trails-palette"].value
  global.settings["biter-trails-balance"] = settings["biter-trails-balance"].value
end

local function get_all_biters()
  if not global.biters then
    global.biters = {}
  end
  for each, surface in pairs(game.surfaces) do
    local biters = surface.find_entities_filtered{type={"unit"}, force={"enemy"}}
    for every, biter in pairs(biters) do
      global.biters[biter.unit_number] = {
        biter = biter,
        position = biter.position,
        counter = 1
      }
    end
  end
end

local function add_biter(event)
  local biter = event.created_entity or event.entity
  global.biters[biter.unit_number] = {
    biter = biter,
    position = biter.position,
    counter = 1
  }
  -- game.print("robot added: "..robot.unit_number)
end

script.on_event(defines.events.on_built_entity, function(event)
  add_biter(event)
end,
{{filter = "type", type = "unit"}})

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

script.on_event(defines.events.script_raised_built, function(event)
  add_biter(event)
end,
{{filter = "type", type = "unit"}})

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
  initialize_settings()
  get_all_biters()
end)

script.on_init(function()
  initialize_settings()
  get_all_biters()
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
    local biters = global.biters
    if biters then
      -- game.print("robots exist")
      for unit_number, data in pairs(biters) do
        -- game.print(game.tick..": robot "..unit_number.." exists")
        local biter = data.biter
        if not biter.valid then
          -- game.print("robot invalid: "..unit_number)
          global.biters[unit_number] = nil
        else
          if biter.active then
            local last_position = data.position
            local current_position = biter.position
            local same_position = last_position and (last_position.x == current_position.x) and (last_position.y == current_position.y)
            if not same_position then
            -- if biter.moving then
              -- game.print(game.tick.."robot: "..unit_number.." checked")
              -- game.print(game.tick.."robot: "..unit_number.." position: "..serpent.block(robot.position))
              local event_tick = event.tick
              -- local color = {}
              -- if color_mode == "biter" then
              --   color = biter.color
              --   color.a = 1
              -- else
              --   color = make_rainbow(event_tick, unit_number, settings, frequency, palette_choice)
              -- end
              local color = make_rainbow(event_tick, unit_number, frequency, palette_choice)
              -- local color = {.5,.5,.5}
              -- local last_position = data.position
              -- local counter = data.counter
              -- local current_position = biter.position
              local surface = biter.surface
              -- local same_position = last_position and (last_position.x == current_position.x) and (last_position.y == current_position.y)
              -- local counter_is_less_than_goal = counter and (counter < 15)
              -- game.print(game.tick.."robot: "..unit_number.." checked again 1")
              -- if ((not same_position) or (same_position and counter_is_less_than_goal)) then
                -- game.print(game.tick.."robot: "..unit_number.." checked again 2")
              -- if biter.effective_speed > 0 then
              -- if not same_position then
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
            end
            global.biters[unit_number].position = current_position
            -- if counter and counter < 15 then
            --   global.biters[unit_number].counter = counter + 1
            -- else
            --   global.biters[unit_number].counter = 1
            -- end
          end
        end
      end
    end
  end
end

script.on_event(defines.events.on_tick, function(event)
  if not global.settings then
    initialize_settings()
  end
  local settings = global.settings
  if settings["biter-trails-balance"] == "super-pretty" then
    make_trails(settings, event)
  end
end)

script.on_nth_tick(2, function(event)
  local settings = global.settings
  if settings["biter-trails-balance"] == "pretty" then
    make_trails(settings, event)
  end
end)

script.on_nth_tick(3, function(event)
  local settings = global.settings
  if settings["biter-trails-balance"] == "balanced" then
    make_trails(settings, event)
  end
end)

script.on_nth_tick(4, function(event)
  local settings = global.settings
  if settings["biter-trails-balance"] == "performance" then
    make_trails(settings, event)
  end
end)
