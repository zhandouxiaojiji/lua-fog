local fog = require "fog"

local rect = {
    x = 0,
    y = 0,
    w = 5,
    h = 5,
}

local map = fog.create(rect.w, rect.h)

fog.dispel_fog(map, 1, 1, 2, 2)

print("test ok")
