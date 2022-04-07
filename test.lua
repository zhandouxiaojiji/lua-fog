
local fog = require "fog"

local map = fog.create(10000)

local str = fog.encode(map)
print(str)

fog.dispel(map, 100)
fog.dispel(map, 101)
fog.dispel(map, 102)