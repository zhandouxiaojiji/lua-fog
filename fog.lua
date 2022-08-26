local DISPEL = 0 -- 全驱散
local MIX = 1 -- 混合
local FOG = 2 -- 全迷雾

local slen = string.len
local ssub = string.sub

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
        tag = tag or FOG,
        parent = parent,
        children = {},
    }
end

local function get_node_size(node)
    local w = node.right - node.left + 1
    local h = node.top - node.buttom + 1
    return w, h
end

local function get_node_center(node)
    local w, h = get_node_size(node)
    local mx = node.left + w // 2
    local my = node.buttom + h // 2
    return mx, my, w, h
end

local function init_children(parent, tag)
    if next(parent.children) then
        return
    end
    local mx, my, w, h = get_node_center(parent)
    if w <= 0 and h <= 0 then
        return
    end
    parent.children[LT] = create_node(parent, parent.left, mx - 1, my, parent.top, tag)
    parent.children[RT] = create_node(parent, mx, parent.right, my, parent.top, tag)
    parent.children[LB] = create_node(parent, parent.left, mx - 1, parent.buttom, my - 1, tag)
    parent.children[RB] = create_node(parent, mx , parent.right, parent.buttom, my - 1, tag)
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
    map.root = create_node(nil, 0, w - 1, 0, h - 1)
    return map
end

local function encode_node(node, arr)
    if not node then
        return arr
    end
    arr[#arr+1] = node.tag
    if node.tag == MIX then
        for _, dir in ipairs(DIRECTS) do
            encode_node(node.children[dir], arr)
        end
    end
    return arr
end

function M.encode(map)
    local arr = encode_node(map.root, {})
    local num = 0
    local str = ""
    for i = 0, #arr - 1 do
        local mod = i % 3
        if mod == 0 and i > 0 then
            str = str .. n2c[num]
            num = 0
        end
        local n = arr[i+1]
        n = n << 2 * mod
        num = num | n
    end
    str = str .. n2c[num]
    return str
end

function M.decode(str, w, h)
    local len = slen(str)
    local chars = {}
    for i = 1, len do
        local c = ssub(str, i, i)
        chars[i - 1] = c
    end
    local idx = 0
    local function pop_tag()
        local c = chars[idx//3]
        local mod = idx % 3
        local tag = c2n[c] >> 2 * mod & 3
        assert(tag <= FOG, tag)
        idx = idx + 1
        return tag
    end
    local function pop_create_node(parent, left, right, buttom, top)
        if left > right or buttom > top then
            return
        end
        local tag = pop_tag()
        local node = {
            left = left,
            right = right,
            buttom = buttom,
            top = top,
            tag = tag,
            parent = parent,
            children = {},
        }
        if tag == MIX then
            local mx, my, nw, nh = get_node_center(node)
            if nw <= 0 and nh <= 0 then
                return
            end
            node.children[LT] = pop_create_node(node, node.left, mx - 1, my, node.top)
            node.children[RT] = pop_create_node(node, mx, node.right, my, node.top)
            node.children[LB] = pop_create_node(node, node.left, mx - 1, node.buttom, my - 1)
            node.children[RB] = pop_create_node(node, mx , node.right, node.buttom, my - 1)
        end
        return node
    end
    local map = {
        w = w,
        h = h,
    }
    map.root = pop_create_node(nil, 0, w - 1, 0, h - 1)
    return map
end

local function dispel_node(node, left, right, buttom, top)
    if node.tag == DISPEL then
        return node.tag
    end
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
        return node.tag
    end

    if left == node.left and right == node.right and buttom == node.buttom and top == node.top then
        node.tag = DISPEL
        node.children = {}
        return node.tag
    end

    init_children(node)
    local mix = false
    for _, child in pairs(node.children) do
        local tag = dispel_node(child, left, right, buttom, top)
        if tag ~= DISPEL then
            mix = true
        end
    end
    if mix then
        node.tag = MIX
    else
        node.tag = DISPEL
        node.children = {}
    end
    return node.tag
end

function M.dispel_fog(map, x, y, w, h)
    dispel_node(map.root, x, x + w - 1, y, y + h - 1)
end

function M.cover_fog(map, x, y, w, h)
end

local function find_tag(node, x, y)
    for _, child in pairs(node.children) do
        if x >= child.left and x <= child.right and y >= child.buttom and y <= child.top then
            return find_tag(child, x, y)
        end
    end
    return node.tag
end

function M.is_fog(map, x, y)
    local tag = find_tag(map.root, x, y)
    return tag == FOG
end
function M.is_dispel(map, x, y)
    local tag = find_tag(map.root, x, y)
    return tag == DISPEL
end

function M.union(map1, map2)
end

function M.cmp(old_map, new_map)
end

function M.dump(map)
    local str = ""
    for y = map.h - 1, 0, -1 do
        for x = 0, map.w - 1 do
            if M.is_fog(map, x, y) then
                str = str .. "@ "
            else
                str = str .. "+ "
            end
        end
        str = str .. "\n"
    end
    print(str)
end

return M
