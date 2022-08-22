local DISPEL = 0 -- 全驱散
local MIX = 1 -- 混合
local FOG = 2 -- 全迷雾

local slen = string.len
local ssub = string.sub
local type = type

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local n2c = {}
local c2n = {}

for i = 1, 64 do
    local c = ssub(b64chars, i, i)
    local n = i - 1
    n2c[n] = c
    c2n[c] = n
end

local function create_node(parent, x, y, h, w, tag)
    return {
        tag = tag,
        parent = parent,
        x = x,
        y = y,
        w = w,
        h = h,
    }
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
    map.root = create_node(nil, 0, 0, w, h, tag or FOG)
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

function M.dispel_fog(map, x, y, w, h)
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
