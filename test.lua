local fog = require "fog"

local function test1(map_size, hole_size, hole_count)
    local map = fog.create(map_size.w, map_size.h)
    -- print(fog.encode_base64(map))

    -- local hole_count = 0
    -- for x = 0, map_size.w - 1, 50 do
    --     for y = 0, map_size.h - 1, 50 do
    --         hole_count = hole_count + 1
    --         fog.dispel_fog(map, x, y, hole_size.w, hole_size.h)
    --         assert(fog.is_dispel(map, x, y))
    --         -- print(fog.encode_base64(map))
    --     end
    -- end
    for _ = 1, hole_count do
        local x = math.random(0, map_size.w - 1)
        local y = math.random(0, map_size.h - 1)
        fog.dispel_fog(map, x, y, hole_size.w, hole_size.h)
        assert(fog.is_dispel(map, x, y))
    end
    local str = fog.encode_base64(map)
    -- print(str)
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
    fog.dispel_fog(map, 33, 33, 100, 100)
    fog.dispel_fog(map, 10, 3, 10, 100)
    fog.dump(map)
end
test2({w = 50, h = 50})

print("test ok")
