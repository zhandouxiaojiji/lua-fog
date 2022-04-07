# 地图迷雾压缩算法
使用二叉树将庞大的地图迷雾数据压缩为较小的base64字符串，以便传输和存储。

# 区域迷雾状态
|状态|标识|
|---|---|
|全驱散|0|
|全迷雾|1|
|二者混合|2|

# API
+ fog.create(size) 创建指定大小的地图
+ fog.encode(map) 序列化
+ fog.decoce(str, size) 反序列化(返回新的map)
+ fog.dispel(map, pos) 驱散迷雾
+ fog.fog(map, pos) 设置迷雾
+ fog.is_fog(map, pos) 检查迷雾

# Usage
```lua
local fog = require "fog"

local size = 100000
local map = fog.create(size)

local str = fog.encode(map)
print(str) -- ouput: B

print("dispel 100 - 102")
fog.dispel(map, 100)
fog.dispel(map, 101)
fog.dispel(map, 102)

assert(not fog.is_fog(map, 100))
assert(not fog.is_fog(map, 101))
assert(not fog.is_fog(map, 102))

str = fog.encode(map)
print(str) -- ouput: qqqmqaoUVVVVB

local new_map = fog.decode(str, size)
assert(not fog.is_fog(new_map, 100))
assert(not fog.is_fog(new_map, 101))
assert(not fog.is_fog(new_map, 102))

fog.fog(map, 100)
fog.fog(map, 101)
fog.fog(map, 102)

print(fog.encode(map))  -- ouput: B
```