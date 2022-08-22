# 地图迷雾压缩算法
使用四叉树将庞大的地图迷雾数据压缩为较小的base64或者二进制字符串，以便传输和存储。

# 区域迷雾状态
|状态|标识|
|---|---|
|全驱散|0|
|二者混合|1|
|全迷雾|2|

# API
+ fog.create(w, h, tag) 创建指定大小的地图
+ fog.encode_base64(map) 序列化base64
+ fog.decode_base64(str, w, h) 反序列化base64(返回新的map)
+ fog.encode_binary(map) 序列化二进制字符串
+ fog.decode_binary(str, w, h) 序列化二进制字符串(返回新的map)
+ fog.dispel_fog(map, x, y, w, h) 驱散迷雾
+ fog.cover_fog(map, x, y, w, h) 覆盖迷雾
+ fog.is_fog(map, x, y) 检查迷雾
+ fog.union(map1, map2) 求并集

# Usage
```lua
```