
local spidertronTrailsColor = {
  type = "bool-setting",
  name = "robot-trails-color",
  setting_type = "runtime-global",
  order = "a",
  default_value = true
}

local spidertronTrailsGlow = {
  type = "bool-setting",
  name = "robot-trails-glow",
  setting_type = "runtime-global",
  order = "b",
  default_value = true
}

local spidertronTrailsTiptoeMode = {
  type = "bool-setting",
  name = "robot-trails-tiptoe-mode",
  setting_type = "runtime-global",
  order = "c",
  default_value = true
}

local spidertronTrailsPassengersOnly = {
  type = "bool-setting",
  name = "robot-trails-passengers-only",
  setting_type = "runtime-global",
  order = "d",
  default_value = false
}


local spidertronTrailsScale = {
  type = "string-setting",
  name = "robot-trails-scale",
  setting_type = "runtime-global",
  order = "e",
  default_value = "5",
  allowed_values = {
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "8",
    "11",
    "20",
  }
}

local spidertronTrailsLength = {
  type = "string-setting",
  name = "robot-trails-length",
  setting_type = "runtime-global",
  order = "f",
  default_value = "120",
  allowed_values = {
    "15",
    "30",
    "60",
    "90",
    "120",
    "180",
    "210",
    "300",
    "600"
  }
}

local spidertronTrailsColorSync = {
  type = "string-setting",
  name = "robot-trails-color-type",
  setting_type = "runtime-global",
  order = "g",
  default_value = "spidertron",
  allowed_values = {
    "spidertron",
    "rainbow",
  }
}

local spidertronTrailsPalette = {
  type = "string-setting",
  name = "robot-trails-palette",
  setting_type = "runtime-global",
  order = "h",
  default_value = "default",
  allowed_values = {
    "light",
    "pastel",
    "default",
    "vibrant",
    "deep"
  }
}

local spidertronTrailsSpeed = {
  type = "string-setting",
  name = "robot-trails-speed",
  setting_type = "runtime-global",
  order = "i",
  default_value = "default",
  allowed_values = {
    "veryslow",
    "slow",
    "default",
    "fast",
    "veryfast"
  }
}

local spidertronTrailsBalance = {
  type = "string-setting",
  name = "robot-trails-balance",
  setting_type = "runtime-global",
  order = "j",
  default_value = "pretty",
  allowed_values = {
    -- "super-performance",
    "performance",
    "balanced",
    "pretty",
    "super-pretty"
  }
}

data:extend({
  spidertronTrailsColor,
  spidertronTrailsGlow,
  spidertronTrailsScale,
  spidertronTrailsLength,
  spidertronTrailsColorSync,
  spidertronTrailsPalette,
  spidertronTrailsSpeed,
  spidertronTrailsBalance,
  spidertronTrailsPassengersOnly,
  spidertronTrailsTiptoeMode
})
