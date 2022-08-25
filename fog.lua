local DISPEL = 0 -- 全驱散
local MIX = 1 -- 混合
local FOG = 2 -- 全迷雾

local slen = string.len
local ssub = string.sub
local type = type

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local n2c = {}
local c2n = {}

local LT = 1 -- 左上
local RT = 2 -- 右上
local LB = 3 -- 左下
local RB = 4 -- 右下

local DIRECTS = {
    LT, RT, LB, RB,
}

for i = 1, 64 do
    local c = ssub(b64chars, i, i)
    local n = i - 1
    n2c[n] = c
    c2n[c] = n
end

local function create_node(parent, left, right, buttom, top, tag)
    if left > right or buttom > top then
        return
    end
    return {
        left = left,
        right = right,
        top = top,
        buttom = buttom,
        tag = tag,
        parent = parent,
        children = {},
    }
end

local function init_children(parent, tag)
    if next(parent.children) then
        return
    end
    local w = parent.right - parent.left
    local h = parent.top - parent.buttom
    local mx = parent.left + w // 2
    local my = parent.buttom + h // 2
    if w <= 1 and h <= 1 then
        return
    end
    parent.children[LT] = create_node(parent, parent.left, mx, my, parent.top, tag)
    parent.children[RT] = create_node(parent, mx + 1, parent.right, my, parent.top, tag)
    parent.children[LB] = create_node(parent, parent.left, mx, parent.buttom, my - 1, tag)
    parent.children[RB] = create_node(parent, mx + 1, parent.right, parent.buttom, my - 1, tag)
end

local M = {
    DISPEL = DISPEL,
    FOG = FOG,
    MIX = MIX,
}
function M.create(w, h, tag)
    local map = {
        w = w,
        h = h,
    }
    map.root = create_node(nil, 0, w - 1, 0, h - 1, tag or FOG)
    return map
end

function M.encode_base64(map)
end

function M.decode_base64(str, w, h)
end

function M.encode_binary(map)
end

function M.decode_binary(str, w, h)
end

local function dispel_node(node, left, right, buttom, top, tag)
    if left < node.left then
        left = node.left
    end
    if right > node.right then
        right = node.right
    end
    if buttom < node.buttom then
        buttom = node.buttom
    end
    if top > node.top then
        top = node.top
    end

    if left > right or buttom > top then
        return
    end

    init_children(node)
    for _, child in pairs(node.children) do
        dispel_node(child, left, right, buttom, top, tag)
    end
end

function M.dispel_fog(map, x, y, w, h)
    dispel_node(map.root, x, x + w - 1, y, y + h - 1, DISPEL)
end

function M.cover_fog(map, x, y, w, h)
end

function M.is_fog(map, pos)
end
function M.is_dispel(map, pos)
end

function M.union(map1, map2)
end

function M.cmp(old_map, new_map)
end

return M
