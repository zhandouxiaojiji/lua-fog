
local fog = require "fog"

local map = fog.create(10000)

local str = fog.encode(map)
print(str)