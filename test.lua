local fog = require "fog"

local function test(map_size, hole_size, hole_count)
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
    end
    local str = fog.encode_base64(map)
    -- print(str)
    local size = string.len(str)/1024
    print(string.format("map:%dx%d, hole:%dx%d count:%d, size:%.2fkb",
        map_size.w, map_size.h, hole_size.w, hole_size.h, hole_count, size))
end
for i = 1, 10 do
    test({w = 1000, h = 1000}, {w = 10, h = 10}, 100)
end
-- test({w = 1000, h = 1000}, {w = 30, h = 30}, 1000)

print("test ok")
