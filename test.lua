
local fog = require "fog"

local size = 100000
local map = fog.create(size)

local str = fog.encode(map)
print(str)

print("dispel 100 - 102")
fog.dispel(map, 100)
fog.dispel(map, 101)
fog.dispel(map, 102)

assert(not fog.is_fog(map, 100))
assert(not fog.is_fog(map, 101))
assert(not fog.is_fog(map, 102))

str = fog.encode(map)
print(str)
local new_map = fog.decode(str, size)
assert(not fog.is_fog(new_map, 100))
assert(not fog.is_fog(new_map, 101))
assert(not fog.is_fog(new_map, 102))

fog.fog(map, 100)
fog.fog(map, 101)
fog.fog(map, 102)

print(fog.encode(map))

print("========= test union ==========")
size = 10000
local map1 = fog.create(size)
fog.dispel(map1, 0)
fog.dispel(map1, 2)

local map2 = fog.create(size)
fog.dispel(map2, 1)

local map3 = fog.union(map1, map2)
print(fog.encode(map1))
print(fog.encode(map2))
print(fog.encode(map3))

assert(fog.is_dispel(map3, 0))
assert(fog.is_dispel(map3, 1))
assert(fog.is_dispel(map3, 2))

print("========= test create ==========")
local map4 = fog.create(size, fog.DISPEL)
print(fog.encode(map4))

print("========= test cmp ==========")
-- size = 3
local map5 = fog.create(size)
fog.dispel(map5, 0)
fog.dispel(map5, 2)
fog.dispel(map5, 3)

local map6 = fog.create(size)
fog.dispel(map6, 4)
fog.dispel(map6, 2)
fog.dispel(map6, 3)
local new_fog_list, new_dispel_list = fog.cmp(map5, map6)
print("new_fog_list", table.concat(new_fog_list, ","))
print("new_dispel_list", table.concat(new_dispel_list, ","))