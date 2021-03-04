local classes = classes;

local classes = classes;

local super = classes.Object;

local class = inherit({
    name = "UDim2",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = true,
}, super);

classes[class.name] = class;



local cache = setmetatable({}, { __mode = "v" });

function class.new_UDim(x, y)
    if (x ~= nil) then
        local x_t = type(x);
        if (x_t ~= "UDim") then
            error("bad argument #1 to '" ..__func__.. "' (UDim expected, got " ..x_t.. ")", 2);
        end
    else
        x = classes.UDim.new();
    end
    
    if (y ~= nil) then
        local y_t = type(y);
        if (y_t ~= "UDim") then
            error("bad argument #2 to '" ..__func__.. "' (UDim expected, got " ..y_t.. ")", 2);
        end
    else
        y = classes.UDim.new();
    end
    
    
    local cacheId = tostring(x).. ":" ..tostring(y);
    
    local obj = cache[cacheId];
    if (not obj) then
        local success;
        
        success, obj = pcall(super.new, class);
        if (not success) then error(obj, 2) end
        
        obj.x = x;
        obj.y = y;
        
        cache[cacheId] = obj;
    end
    
    return obj;
end

function class.new(scaleX, offsetX, scaleY, offsetY)
    local success, x = pcall(classes.UDim.new, scaleX, offsetX);
    if (not success) then error(x, 2) end
    
    local success, y = pcall(classes.UDim.new, scaleY, offsetY);
    if (not success) then error(y, 2) end
    
    return class.new_UDim(x, y);
end

class.meta = extend({
    __metatable = super.name.. ":" ..class.name,
    
    
    __add = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "UDim2" and obj1_t ~= "number") then
            error("bad operand #1 to '+' (UDim2/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "UDim2" and obj2_t ~= "number") then
            error("bad operand #2 to '+' (UDim2/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and class.new_UDim(obj1+obj2.x, obj1+obj2.y)
        or (obj2_t == "number") and class.new_UDim(obj1.x+obj2, obj1.y+obj2)
        or class.new_UDim(obj1.x+obj2.x, obj1.y+obj2.y);
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
        
        
        return (obj1_t == "number") and class.new_UDim(obj1-obj2.x, obj1-obj2.y)
        or (obj2_t == "number") and class.new_UDim(obj1.x-obj2, obj1.y-obj2)
        or class.new_UDim(obj1.x-obj2.x, obj1.y-obj2.y);
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
        
        
        return (obj1_t == "number") and class.new_UDim(obj1*obj2.x, obj1*obj2.y)
        or (obj2_t == "number") and class.new_UDim(obj1.x*obj2, obj1.y*obj2)
        or class.new_UDim(obj1.x*obj2.x, obj1.y*obj2.y);
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
        
        
        return (obj1_t == "number") and class.new_UDim(obj1/obj2.x, obj1/obj2.y)
        or (obj2_t == "number") and class.new_UDim(obj1.x/obj2, obj1.y/obj2)
        or class.new_UDim(obj1.x/obj2.x, obj1.y/obj2.y);
    end,
    
    
    __unm = function(obj)
        return class.new_UDim(-obj.x, -obj.y);
    end,
    
    
    __tostring = function(obj)
        return "{" ..tostring(obj.x).. "}, {" ..tostring(obj.y).. "}";
    end,
}, super.meta);



function class.func.unpack(obj)
    return obj.x.scale, obj.x.offset, obj.y.scale, obj.y.offset;
end
