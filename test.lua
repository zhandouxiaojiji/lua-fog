local fog = require "fog"

local function test()
    local w, h = 10000, 5000
    local map1 = fog.create(w, h)
    print(fog.encode(map1)) -- ouput: C
    fog.dispel_fog(map1, 100, 100, 10, 10)
    local str = fog.encode(map1)
    print(str) -- ouput: ppppplaZapmkCZiJUKhGhEqVmImQmYCFhIhGhEaZioBqWEiqqqqqC
    local map2 = fog.decode(str, w, h)
    fog.dispel_fog(map2, 0, 0, 10000, 10000)
    print(fog.encode(map2)) -- ouput: A
    fog.cover_fog(map2, 0, 0, 5000, 10000)
    print(fog.encode(map2)) -- ouput: JC
    local map3 = fog.union(map1, map2)
    print(fog.encode(map3)) -- ouput: JpppplaZapmkCZiJUKhGhEqVmImQmYCFhIhGhEaZioBqWEiqqqqqA
end
print("=========================================")
test()

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
print("=========================================")
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
    fog.cover_fog(map2, 18, 18, 100, 100)
    fog.dump(map2)
end
print("=========================================")
test2({w = 20, h = 20})


local function test3()
    local w, h = 20, 20
    local map1 = fog.create(w, h)
    fog.dispel_fog(map1, 10, 10, 10, 10)
    fog.dump(map1)
    local map2 = fog.create(w, h)
    fog.dispel_fog(map2, 5, 5, 10, 10)
    fog.dump(map2)
    local map3 = fog.union(map1, map2)
    fog.dump(map3)
end
print("=========================================")
test3()


print("test ok")
