
local fog = require "fog"

local map = fog.create(3)

local str = fog.encode(map)
print(str)

fog.dispel(map, 1)
-- fog.dispel(map, 101)
-- fog.dispel(map, 102)

print(fog.encode(map))

fog.fog(map, 1)
-- fog.fog(map, 101)
-- fog.fog(map, 102)

print(fog.encode(map))
