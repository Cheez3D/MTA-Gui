local name = "UDim";

local class;
local super = classes.Object;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local new, meta;

local concrete = true;



local cache = setmetatable({}, { __mode = "v" });

function new(scale, offset)
    if (scale ~= nil) then
        local scale_t = type(scale);
        if (scale_t ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..scale_t.. ")", 2);
        end
    else
        scale = 0;
    end
    
    if (offset ~= nil) then
        local offset_t = type(offset);
        if (offset_t ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..offset_t.. ")", 2);
        end
    else
        offset = 0;
    end
    
    
    local cacheId = scale.. ":" ..offset;
    
    local obj = cache[cacheId];
    if (not obj) then
        local success;
        
        success, obj = pcall(super.new, class, meta);
        if (not success) then error(obj, 2) end
        
        obj.scale  = scale;
        obj.offset = offset;
        
        cache[cacheId] = obj;
    end
    
    return obj;
end

meta = extend({
    __metatable = name,
    
    
    __add = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim" and obj1_t ~= "number") then
            error("bad operand #1 to '+' (UDim/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim" and obj2_t ~= "number") then
            error("bad operand #2 to '+' (UDim/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and new(obj1+obj2.scale, obj1+obj2.offset)
        or (obj2_t == "number") and new(obj1.scale+obj2, obj1.offset+obj2)
        or new(obj1.scale+obj2.scale, obj1.offset+obj2.offset);
    end,
    
    __sub = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim" and obj1_t ~= "number") then
            error("bad operand #1 to '-' (UDim/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim" and obj2_t ~= "number") then
            error("bad operand #2 to '-' (UDim/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and new(obj1-obj2.scale, obj1-obj2.offset)
        or (obj2_t == "number") and new(obj1.scale-obj2, obj1.offset-obj2)
        or new(obj1.scale-obj2.scale, obj1.offset-obj2.offset);
    end,
    
    __mul = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim" and obj1_t ~= "number") then
            error("bad operand #1 to '*' (UDim/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim" and obj2_t ~= "number") then
            error("bad operand #2 to '*' (UDim/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and new(obj1*obj2.scale, obj1*obj2.offset)
        or (obj2_t == "number") and new(obj1.scale*obj2, obj1.offset*obj2)
        or new(obj1.scale*obj2.scale, obj1.offset*obj2.offset);
    end,
    
    __div = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim" and obj1_t ~= "number") then
            error("bad operand #1 to '/' (UDim/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim" and obj2_t ~= "number") then
            error("bad operand #2 to '/' (UDim/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and new(obj1/obj2.scale, obj1/obj2.offset)
        or (obj2_t == "number") and new(obj1.scale/obj2, obj1.offset/obj2)
        or new(obj1.scale/obj2.scale, obj1.offset/obj2.offset);
    end,
    
    
    __unm = function(obj)
        return new(-obj.scale, -obj.offset);
    end,
    
    
    __tostring = function(obj)
        return obj.scale.. ", " ..obj.offset;
    end,
}, super.meta);



function func.unpack(obj)
    return obj.scale, obj.offset;
end



class = {
    name = name,
    func = func, get = get, set = set,
    
    new = new, meta = meta,
    
    concrete = concrete,
}

_G[name] = class;
classes[#classes+1] = class;
