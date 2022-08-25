local fog = require "fog"

local rect = {
    x = 0,
    y = 0,
    w = 2,
    h = 2,
}

local map = fog.create(rect.w, rect.h)

fog.dispel_fog(map, 0, 0, 1, 1)

print("test ok")
