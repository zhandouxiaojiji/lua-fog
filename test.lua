
local fog = require "fog"

local rect = {
    x = 0,
    y = 0,
    w = 1000,
    h = 1000,
}

local map = fog.create(rect.w, rect.h)
