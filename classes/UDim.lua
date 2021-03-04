local classes = classes;

local super = classes.Object;

local class = inherit({
    name = "UDim",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = true,
}, super);

classes[class.name] = class;



local cache = setmetatable({}, { __mode = "v" });

function class.new(scale, offset)
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
        
        success, obj = pcall(super.new, class);
        if (not success) then error(obj, 2) end
        
        obj.scale  = scale;
        obj.offset = offset;
        
        cache[cacheId] = obj;
    end
    
    return obj;
end

class.meta = extend({
    __metatable = super.name.. ":" ..class.name,
    
    
    __add = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim" and obj1_t ~= "number") then
            error("bad operand #1 to '+' (UDim/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim" and obj2_t ~= "number") then
            error("bad operand #2 to '+' (UDim/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and class.new(obj1+obj2.scale, obj1+obj2.offset)
        or (obj2_t == "number") and class.new(obj1.scale+obj2, obj1.offset+obj2)
        or class.new(obj1.scale+obj2.scale, obj1.offset+obj2.offset);
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
        
        
        return (obj1_t == "number") and class.new(obj1-obj2.scale, obj1-obj2.offset)
        or (obj2_t == "number") and class.new(obj1.scale-obj2, obj1.offset-obj2)
        or class.new(obj1.scale-obj2.scale, obj1.offset-obj2.offset);
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
        
        
        return (obj1_t == "number") and class.new(obj1*obj2.scale, obj1*obj2.offset)
        or (obj2_t == "number") and class.new(obj1.scale*obj2, obj1.offset*obj2)
        or class.new(obj1.scale*obj2.scale, obj1.offset*obj2.offset);
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
        
        
        return (obj1_t == "number") and class.new(obj1/obj2.scale, obj1/obj2.offset)
        or (obj2_t == "number") and class.new(obj1.scale/obj2, obj1.offset/obj2)
        or class.new(obj1.scale/obj2.scale, obj1.offset/obj2.offset);
    end,
    
    
    __unm = function(obj)
        return class.new(-obj.scale, -obj.offset);
    end,
    
    
    __tostring = function(obj)
        return obj.scale.. ", " ..obj.offset;
    end,
}, super.meta);



function class.func.unpack(obj)
    return obj.scale, obj.offset;
end
