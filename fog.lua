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

local function create_node(parent, tag, min, max)
    return {
        tag = tag,
        parent = parent,
        min = min,
        max = max,
    }
end

local M = {}
function M.create(size, tag)
    local map = {
        size = size,
    }
    map.root = create_node(nil, tag or FOG, 0, size - 1)
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

local function set_tag(map, dst_pos, tag)
    local function revert_parent(node)
        if not node then
            return
        end
        if node.left.tag == node.right.tag then
            node.tag = node.left.tag
            node.left = nil
            node.right = nil
            revert_parent(node.parent)
        end
    end
    local function find(node)
        if node.tag == tag then
            return
        end
        if node.min == node.max then
            node.tag = tag
            revert_parent(node.parent)
            return
        end
        local center = node.min + (node.max - node.min) // 2
        if node.max - node.min == 1 then
            node.left = create_node(node, node.tag, node.min, node.min)
            node.right = create_node(node, node.tag, node.max, node.max)
        else
            node.left = create_node(node, node.tag, node.min, center - 1 > node.min and center - 1 or node.min)
            node.right = create_node(node, node.tag, center < node.max and center or node.max, node.max)
        end
        node.tag = MIX
        print("split", node.left.min, node.left.max, "=", node.right.min, node.right.max)
        if dst_pos < center then
            print("left", node.left.min, node.left.max)
            find(node.left)
        else
            print("right", node.right.min, node.right.max)
            find(node.right)
        end
    end
    find(map.root)
end

function M.dispel(map, dst_pos)
    set_tag(map, dst_pos, DISPEL)
end

function M.fog(map, dst_pos)
    set_tag(map, dst_pos, FOG)
end

function M.is_fog(pos)
end

return M
