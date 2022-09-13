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
    map.root = create_node(nil, 0, w - 1, 0, h - 1, tag)
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

local function fix_border(node, left, right, buttom, top)
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
    return left, right, buttom, top
end

local function fix_node_tag(node)
    local last_tag, mix
    for _, child in pairs(node.children) do
        last_tag = last_tag or child.tag
        if last_tag == MIX or last_tag ~= child.tag then
            mix = true
            break
        end
    end
    if mix or last_tag == MIX then
        node.tag = MIX
    else
        node.tag = assert(last_tag)
        node.children = {}
    end
end

local function set_node_tag(node, left, right, buttom, top, tag)
    if node.tag == tag then
        return
    end

    left, right, buttom, top = fix_border(node, left, right, buttom, top)

    if left > right or buttom > top then
        return
    end

    if left == node.left and right == node.right and buttom == node.buttom and top == node.top then
        node.tag = tag
        node.children = {}
        return
    end

    init_children(node, node.tag)
    for _, child in pairs(node.children) do
        set_node_tag(child, left, right, buttom, top, tag)
    end
    fix_node_tag(node)
end

function M.dispel_fog(map, x, y, w, h)
    set_node_tag(map.root, x, x + w - 1, y, y + h - 1, DISPEL)
end

function M.cover_fog(map, x, y, w, h)
    set_node_tag(map.root, x, x + w - 1, y, y + h - 1, FOG)
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

local function clone_node(node, parent)
    if not node then
        return
    end
    local new = {
        left = node.left,
        right = node.right,
        buttom = node.buttom,
        top = node.top,
        tag = node.tag,
        parent = parent,
        children = {},
    }
    for _, dir in ipairs(DIRECTS) do
        new.children[dir] = clone_node(node.children[dir], new)
    end
    return new
end

function M.union(map1, map2)
    assert(map1.w == map2.w and map1.h == map2.h)
    local map = {
        w = map1.w,
        h = map2.h,
    }
    local function union(node1, node2, parent)
        if node1.tag == MIX and node2.tag == MIX then
            local node = {
                left = node1.left,
                right = node1.right,
                buttom = node1.buttom,
                top = node1.top,
                parent = parent,
                tag = MIX,
                children = {},
            }
            for _, dir in ipairs(DIRECTS) do
                node.children[dir] = union(node1.children[dir], node2.children[dir], node)
            end
            local mix, last_tag
            for _, child in pairs(node.children) do
                last_tag = last_tag or child.tag
                if child.tag ~= last_tag then
                    mix = true
                    break
                end
            end
            if not mix then
                node.tag = last_tag
                node.children = {}
            end
            return node
        elseif node1.tag == node2.tag or node1.tag < node2.tag then
            return clone_node(node1, parent)
        elseif node2.tag < node1.tag then
            return clone_node(node2, parent)
        end
    end
    map.root = union(map1.root, map2.root)
    return map
end

function M.cmp(old_map, new_map)
    assert(old_map.w == new_map.w and old_map.h == new_map.h)
    local new_fog_list, new_dispel_list = {}, {}
    local function cmp(old, new)
        if not old or not new then
            return
        end
        local old_tag = type(old) == "number" and old or old.tag
        local new_tag = type(new) == "number" and new or new.tag

        local function add_to_list()
            local node = type(old) == "table" and old or new
            for x = node.left, node.right do
                for y = node.buttom, node.top do
                    if new_tag == FOG then
                        new_fog_list[#new_fog_list+1] = {x, y}
                    else
                        new_dispel_list[#new_dispel_list+1] = {x, y}
                    end
                end
            end
        end

        local function cmp_dir(func)
            for _, dir in pairs(DIRECTS) do
                func(dir)
            end
        end

        if old_tag == new_tag then
            if old_tag == MIX then
                cmp_dir(function (dir)
                    cmp(old.children[dir], new.children[dir])
                end)
            else
                return
            end
        elseif old_tag == MIX then
            cmp_dir(function (dir)
                cmp(old.children[dir], new_tag)
            end)
        elseif new_tag == MIX then
            cmp_dir(function (dir)
                cmp(old_tag, new.children[dir])
            end)
        else
            add_to_list()
        end
    end
    cmp(old_map.root, new_map.root)
    return new_fog_list, new_dispel_list
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