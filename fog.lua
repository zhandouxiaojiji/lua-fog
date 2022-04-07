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
    encode_node(node.left, arr)
    encode_node(node.right, arr)
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

local function set_tag(map, pos, tag)
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
    local function find_and_insert(node)
        if node.tag == tag then
            return
        end
        if node.min == node.max then
            node.tag = tag
            revert_parent(node.parent)
            return
        end
        local center = node.min + (node.max - node.min) // 2
        if not node.left then
            node.left = create_node(node, node.tag, node.min, center)
            node.right = create_node(node, node.tag, center + 1 < node.max and center + 1 or node.max, node.max)
            node.tag = MIX
        end

        if pos <= center then
            find_and_insert(node.left)
        else
            find_and_insert(node.right)
        end
    end
    find_and_insert(map.root)
end

function M.dispel(map, pos)
    set_tag(map, pos, DISPEL)
end

function M.fog(map, pos)
    set_tag(map, pos, FOG)
end

function M.is_fog(map, pos)
    local function find(node)
        if pos <= node.max and pos >= node.min and node.tag ~= MIX then
            return node.tag
        end
        local center = node.min + (node.max - node.min) // 2
        if pos <= center then
            return find(node.left)
        else
            return find(node.right)
        end
    end
    return find(map.root) == FOG
end

return M
