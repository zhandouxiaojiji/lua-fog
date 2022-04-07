
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
