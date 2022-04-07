local DISPEL = 0 -- 全驱散
local FOG = 1 -- 全迷雾
local MIX = 2 -- 混合

local slen = string.len
local ssub = string.sub

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local n2c = {}
local c2n = {}

for i = 1, 60 do
    local c = ssub(b64chars, i, i)
    local n = i - 1
    n2c[n] = c
    c2n[c] = n
end

local function create_node(parent, tag)
    return {
        tag = tag,
        parent = parent
    }
end

local M = {}
function M.create(size, tag)
    local map = {
        size = size,
    }
    map.root = create_node(nil, tag or FOG)
    return map
end

local function encode_node(node, arr)
    if not node then
        return
    end
    arr[#arr+1] = node.tag
    encode_node(node.left)
    encode_node(node.right)
end

function M.encode(map)
    local arr = {}
    encode_node(map.root, arr)
    local num = 0
    local str = ""
    for i = 0, #arr - 1 do
        local mod = i % 3
        if mod == 0 and i > 0 then
            str = str .. n2c[num]
            num = 0
        end
        local n = arr[i+1]
        n = n << (2 * (2 - mod))
        num = num | n
    end
    if num > 0 then
        str = str .. n2c[num]
    end
    return str
end

function M.decode(str)
    local len = slen(str)
    for i = 1, len do
        local c = ssub(str, i, i)
        print(c, c2n[c])
    end
end

function M.is_fog(pos)
end

return M
