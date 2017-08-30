local UDim = UDim;



local name = "UDim2";

local class;
local super = classes.Object;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local new, new2, meta;

local concrete = true;



local cache = setmetatable({}, { __mode = "v" });

function new(x, y)
    if (x ~= nil) then
        local x_t = type(x);
        if (x_t ~= "UDim") then
            error("bad argument #1 to '" ..__func__.. "' (UDim expected, got " ..x_t.. ")", 2);
        end
    else
        x = UDim.new();
    end
    
    if (y ~= nil) then
        local y_t = type(y);
        if (y_t ~= "UDim") then
            error("bad argument #2 to '" ..__func__.. "' (UDim expected, got " ..y_t.. ")", 2);
        end
    else
        y = UDim.new();
    end
    
    
    local cacheId = tostring(x).. ":" ..tostring(y);
    
    local obj = cache[cacheId];
    if (not obj) then
        local success;
        
        success, obj = pcall(super.new, class, meta);
        if (not success) then error(obj, 2) end
        
        obj.x = x;
        obj.y = y;
        
        cache[cacheId] = obj;
    end
    
    return obj;
end

function new2(scaleX, offsetX, scaleY, offsetY)
    local success, x = pcall(UDim.new, scaleX, offsetX);
    if (not success) then error(x, 2) end
    
    local success, y = pcall(UDim.new, scaleY, offsetY);
    if (not success) then error(y, 2) end
    
    return new(x, y);
end

meta = extend({
    __metatable = name,
    
    
    __add = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim2" and obj1_t ~= "number") then
            error("bad operand #1 to '+' (UDim2/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim2" and obj2_t ~= "number") then
            error("bad operand #2 to '+' (UDim2/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and new(obj1+obj2.x, obj1+obj2.y)
        or (obj2_t == "number") and new(obj1.x+obj2, obj1.y+obj2)
        or new(obj1.x+obj2.x, obj1.y+obj2.y);
    end,
    
    __sub = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim2" and obj1_t ~= "number") then
            error("bad operand #1 to '-' (UDim2/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim2" and obj2_t ~= "number") then
            error("bad operand #2 to '-' (UDim2/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and new(obj1-obj2.x, obj1-obj2.y)
        or (obj2_t == "number") and new(obj1.x-obj2, obj1.y-obj2)
        or new(obj1.x-obj2.x, obj1.y-obj2.y);
    end,
    
    __mul = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim2" and obj1_t ~= "number") then
            error("bad operand #1 to '*' (UDim2/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim2" and obj2_t ~= "number") then
            error("bad operand #2 to '*' (UDim2/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and new(obj1*obj2.x, obj1*obj2.y)
        or (obj2_t == "number") and new(obj1.x*obj2, obj1.y*obj2)
        or new(obj1.x*obj2.x, obj1.y*obj2.y);
    end,
    
    __div = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim2" and obj1_t ~= "number") then
            error("bad operand #1 to '/' (UDim2/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim2" and obj2_t ~= "number") then
            error("bad operand #2 to '/' (UDim2/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and new(obj1/obj2.x, obj1/obj2.y)
        or (obj2_t == "number") and new(obj1.x/obj2, obj1.y/obj2)
        or new(obj1.x/obj2.x, obj1.y/obj2.y);
    end,
    
    
    __unm = function(obj)
        return new(-obj.x, -obj.y);
    end,
    
    
    __tostring = function(obj)
        return "{" ..tostring(obj.x).. "}, {" ..tostring(obj.y).. "}";
    end,
}, super.meta);



function func.unpack(obj)
    return obj.x.scale, obj.x.offset, obj.y.scale, obj.y.offset;
end



class = {
    name = name,
    func = func, get = get, set = set,
    
    new = new2, meta = meta,
}

_G[name] = class;
classes[#classes+1] = class;
