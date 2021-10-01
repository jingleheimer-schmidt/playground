-- data.lua
-- we need to find all the sprites and animations and set their tint to ghost_tint

local spooky = data.raw["utility-constants"]["default"].ghost_tint

for a,b in pairs(data.raw["accumulator"]) do
  if b.picture then 
    data.raw["accumulator"][a].picture.tint = spooky
  end
  if b.charge_animation then 
    data.raw["accumulator"][a].charge_animation.tint = spooky
  end
  if b.discharge_animation then 
    data.raw["accumulator"][a].discharge_animation.tint = spooky
  end
  if b.circuit_connector_sprites then
    if b.circuit_connector_sprites.led_red then 
      data.raw["accumulator"][a].circuit_connector_sprites.led_red.tint = spooky
    end
    if b.circuit_connector_sprites.led_green then 
      data.raw["accumulator"][a].circuit_connector_sprites.led_green.tint = spooky
    end
    if b.circuit_connector_sprites.led_blue then 
      data.raw["accumulator"][a].circuit_connector_sprites.led_blue.tint = spooky
    end
    if b.circuit_connector_sprites.connector_main then 
      data.raw["accumulator"][a].circuit_connector_sprites.connector_main.tint = spooky
    end
    if b.circuit_connector_sprites.connector_shadow then 
      data.raw["accumulator"][a].circuit_connector_sprites.connector_shadow.tint = spooky
    end
    if b.circuit_connector_sprites.wire_pins then 
      data.raw["accumulator"][a].circuit_connector_sprites.wire_pins.tint = spooky
    end
    if b.circuit_connector_sprites.wire_pins_shadow then 
      data.raw["accumulator"][a].circuit_connector_sprites.wire_pins_shadow.tint = spooky
    end
    if b.circuit_connector_sprites.led_blue_off then 
      data.raw["accumulator"][a].circuit_connector_sprites.led_blue_off.tint = spooky
    end
  end
  if b.integration_patch then 
--     data.raw["accumulator"][a].integration_patch
--     oh god what do i do about sprite4way... maybe best to just ignore for now
  end
end

for a,b in pairs(data.raw["artillery-turret"]) do
  if b.base_picture then
    if b.base_picture.north then
      data.raw["artillery-turret"][a].base_picture.north.tint = spooky
      if b.base_picture.east then
        data.raw["artillery-turret"][a].base_picture.east.tint = spooky
      end
      if b.base_picture.south then
        data.raw["artillery-turret"][a].base_picture.south.tint = spooky
      end
      if b.base_picture.west then
        data.raw["artillery-turret"][a].base_picture.west.tint = spooky
      end
    else
      data.raw["artillery-turret"][a].base_picture.tint = spooky
    end
  end
  if b.cannon_base_pictures then 
    data.raw["artillery-turret"][a].cannon_base_pictures.tint = spooky
  end
  if b.cannon_barrel_pictures then 
    data.raw["artillery-turret"][a].cannon_barrel_pictures.tint = spooky
  end
end

