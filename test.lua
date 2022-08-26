local fog = require "fog"

local function test1(map_size, hole_size, hole_count)
    local map = fog.create(map_size.w, map_size.h)
    for _ = 1, hole_count do
        local x = math.random(0, map_size.w - 1)
        local y = math.random(0, map_size.h - 1)
        fog.dispel_fog(map, x, y, hole_size.w, hole_size.h)
        assert(fog.is_dispel(map, x, y))
    end
    local str = fog.encode(map)
    local size = string.len(str)/1024
    print(string.format("map:%dx%d, hole:%dx%d count:%d, size:%.2fkb",
        map_size.w, map_size.h, hole_size.w, hole_size.h, hole_count, size))
end

for i = 1, 10 do
    test1({w = 2500, h = 2500}, {w = 30, h = 30}, 100)
end

local function test2(map_size)
    local map = fog.create(map_size.w, map_size.h)
    fog.dispel_fog(map, 2, 2, 2, 2)
    fog.dispel_fog(map, 3, 3, 2, 2)
    fog.dispel_fog(map, 0, 16, 100, 100)
    fog.dispel_fog(map, 10, 3, 10, 100)
    fog.dump(map)
    local str = fog.encode(map)
    print(str)
    local map2 = fog.decode(str, map_size.w, map_size.h)
    fog.dump(map2)
end
test2({w = 20, h = 20})

print("test ok")
