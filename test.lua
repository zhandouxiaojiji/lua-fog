local fog = require "fog"

local rect = {
    x = 0,
    y = 0,
    w = 5,
    h = 5,
}

local map = fog.create(rect.w, rect.h)

for x = 0, rect.w - 1 do
    for y = 0, rect.h - 1 do
        fog.dispel_fog(map, x, y, 2, 2)
        assert(fog.is_dispel(map, x, y))
    end
end

print("test ok")
