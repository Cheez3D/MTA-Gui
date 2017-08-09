local name = "Color3";

local class;
local super = classes.Object;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local new, meta;

local concrete = true;



local cache = setmetatable({}, { __mode = "v" });

function new(r, g, b)
    if (r ~= nil) then
        local r_t = type(r);
        if (r_t ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..r_t.. ")", 2);
        elseif (r < 0) or (r > 255) then
            error("bad argument #1 to '" ..__func__.. "' (value out of bounds)", 2);
        end
    else
        r = 0;
    end
    
    if (g ~= nil) then
        local g_t = type(g);
        if (g_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..g_t.. ")", 2);
        elseif (g < 0) or (g > 255) then
            error("bad argument #2 to '" ..__func__.. "' (value out of bounds)", 2);
        end
    else
        g = 0;
    end
    
    if (b ~= nil) then
        local b_t = type(b);
        if (b_t ~= "number") then
            error("bad argument #3 to '" ..__func__.. "' (number expected, got " ..b_t.. ")", 2);
        elseif (b < 0) or (b > 255) then
            error("bad argument #3 to '" ..__func__.. "' (value out of bounds)", 2);
        end
    else
        b = 0;
    end
    
    
    local cacheId = r.. ":" ..g.. ":" ..b;
    
    local obj = cache[cacheId];
    if (not obj) then
        local success;
        
        success, obj = pcall(super.new, class, meta);
        if (not success) then error(obj, 2) end
        
        obj.r = r;
        obj.g = g;
        obj.b = b;
        
        cache[cacheId] = obj;
    end
    
    return obj;
end

meta = extend({
    __metatable = name,
    
    
    __tostring = function(obj)
        return obj.r.. ", " ..obj.g.. ", " ..obj.b;
    end,
}, super.meta);



function func.unpack(obj)
    return obj.r, obj.g, obj.b;
end



function get.hex(obj)
    if (not obj.hex) then
        obj.hex = 0x10000 * obj.b
                + 0x100   * obj.g
                +           obj.r;
    end

    return obj.hex;
end



class = {
    name = name,
    func = func, get = get, set = set,
    
    new = new, meta = meta,
    
    concrete = concrete,
}

_G[name] = class;
classes[#classes+1] = class;
