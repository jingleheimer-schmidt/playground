
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

function make_rainbow(event_tick, unit_number, settings, frequency, palette_choice)
  -- local frequency = speeds[settings["robot-trails-speed"]]
  local modifier = unit_number + event_tick
  -- local palette_choice = palette[settings["robot-trails-palette"]]
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
  global.settings["robot-trails-color"] = settings["robot-trails-color"].value
  global.settings["robot-trails-glow"] = settings["robot-trails-glow"].value
  global.settings["robot-trails-length"] = settings["robot-trails-length"].value
  global.settings["robot-trails-scale"] = settings["robot-trails-scale"].value
  global.settings["robot-trails-color-type"] = settings["robot-trails-color-type"].value
  global.settings["robot-trails-speed"] = settings["robot-trails-speed"].value
  global.settings["robot-trails-palette"] = settings["robot-trails-palette"].value
  global.settings["robot-trails-balance"] = settings["robot-trails-balance"].value
  global.settings["robot-trails-passengers-only"] = settings["robot-trails-passengers-only"].value
  global.settings["robot-trails-tiptoe-mode"] = settings["robot-trails-tiptoe-mode"].value
end

local function get_all_robots()
  if not global.robots then
    global.robots = {}
  end
  for each, surface in pairs(game.surfaces) do
    local robots = surface.find_entities_filtered{type={"construction-robot", "logistic-robot"}}
    for every, robot in pairs(robots) do
      global.robots[robot.unit_number] = {
        robot = robot,
        position = robot.position,
        counter = 1
      }
      -- for each, leg in pairs(global.robots[spider.unit_number].legs) do
      --   global.robots[spider.unit_number].leg_positions[leg.name] = {
      --     position = leg.position,
      --     counter = 1,
      --   }
      -- end
    end
  end
end

local function add_robot(event)
  local robot = event.created_entity or event.entity
  global.robots[robot.unit_number] = {
    robot = robot,
    position = robot.position,
    counter = 1
  }
  game.print("robot added: "..robot.unit_number)
end

script.on_event(defines.events.on_built_entity, function(event)
  add_robot(event)
end,
{{filter = "type", type = "construction-robot"}})

script.on_event(defines.events.on_built_entity, function(event)
  add_robot(event)
end,
{{filter = "type", type = "logistic-robot"}})

-- script.on_event(defines.events.on_built_entity, function(event)
--   add_robot(event)
-- end,
-- {{filter = "type", type = {"construction-robot", "logistic-robot"}}})
--
-- script.on_event(defines.events.on_robot_built_entity, function(event)
--   add_robot(event)
-- end,
-- {{filter = "type", type = {"construction-robot", "logistic-robot"}}})

script.on_event(defines.events.script_raised_built, function(event)
  add_robot(event)
end,
{{filter = "type", type = "construction-robot"}})

script.on_event(defines.events.script_raised_built, function(event)
  add_robot(event)
end,
{{filter = "type", type = "logistic-robot"}})

script.on_event(defines.events.on_entity_spawned, function(event)
  if event.entity
  and event.entity.type
  -- and (event.entity.type == "construction-robot"
  -- or event.entity.type == "logistic-robot")
  then
    add_robot(event)
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function()
  initialize_settings()
end)

script.on_configuration_changed(function()
  initialize_settings()
  get_all_robots()
end)

script.on_init(function()
  initialize_settings()
  get_all_robots()
end)

local function make_trails(settings, event)
  local sprite = settings["robot-trails-color"]
  local light = settings["robot-trails-glow"]
  if sprite or light then
    local length = tonumber(settings["robot-trails-length"])
    local scale = tonumber(settings["robot-trails-scale"])
    local color_mode = settings["robot-trails-color-type"]
    local passengers_only = settings["robot-trails-passengers-only"]
    local frequency = speeds[settings["robot-trails-speed"]]
    local palette_choice = palette[settings["robot-trails-palette"]]
    local tiptoe_mode = settings["robot-trails-tiptoe-mode"]
    local robots = global.robots
    if robots then
      -- game.print("robots exist")
      for unit_number, data in pairs(robots) do
        -- game.print(game.tick..": robot "..unit_number.." exists")
        local robot = data.robot
        if not robot.valid then
          game.print("robot invalid: "..unit_number)
          global.robots[unit_number] = nil
        else
          game.print(game.tick.."robot: "..unit_number.." checked")
          -- game.print(game.tick.."robot: "..unit_number.." position: "..serpent.block(robot.position))
          local event_tick = event.tick
          local color = {}
          if color_mode == "robot" then
            color = robot.color
            color.a = 1
          else
            color = make_rainbow(event_tick, unit_number, settings, frequency, palette_choice)
          end
          local last_position = data.position
          local counter = data.counter
          local current_position = robot.position
          local surface = robot.surface
          local same_position = last_position and (last_position.x == current_position.x) and (last_position.y == current_position.y)
          local counter_is_less_than_goal = counter and (counter < 15)
          -- game.print(game.tick.."robot: "..unit_number.." checked again 1")
          -- if ((not same_position) and (not tiptoe_mode)) or (same_position and counter_is_less_than_goal) then
            -- game.print(game.tick.."robot: "..unit_number.." checked again 2")
            if sprite then
              sprite = rendering.draw_sprite{
                sprite = "robot-trail",
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
              light = rendering.draw_light{
                sprite = "robot-trail",
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
          -- global.robots[unit_number].position = current_position
          -- if counter and counter < 15 then
          --   global.robots[unit_number].counter = counter + 1
          -- else
          --   global.robots[unit_number].counter = 1
          -- end
        -- end
      end
    end
  end
end

script.on_event(defines.events.on_tick, function(event)
  if not global.settings then
    initialize_settings()
  end
  local settings = global.settings
  if settings["robot-trails-balance"] == "super-pretty" then
    make_trails(settings, event)
  end
end)

script.on_nth_tick(2, function(event)
  local settings = global.settings
  if settings["robot-trails-balance"] == "pretty" then
    make_trails(settings, event)
  end
end)

script.on_nth_tick(3, function(event)
  local settings = global.settings
  if settings["robot-trails-balance"] == "balanced" then
    make_trails(settings, event)
  end
end)

script.on_nth_tick(4, function(event)
  local settings = global.settings
  if settings["robot-trails-balance"] == "performance" then
    make_trails(settings, event)
  end
end)
