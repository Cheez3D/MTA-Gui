local name = "Vector2";

local func = {}
local get  = {}

local new;

local meta = {
    __metatable = name,
    
    
    __index = function(proxy, key)
        local obj = PROXY__OBJ[proxy];
        
        local val = obj[key];
        if (val ~= nil) then -- val might be false so compare against nil
            return val;
        end
    
        local func_f = func[key];
        if (func_f) then
            return (function(...) return func_f(obj, ...) end); -- might be able to do memoization here
        end
        
        local get_f = get[key];
        if (get_f) then
            return get_f(obj, key);
        end
    end,
    
    __newindex = function(proxy, key)
        error("attempt to modify a read-only key (" ..tostring(key).. ")", 2);
    end,
    
    
    __add = function(proxy1, proxy2)
        local proxy1_t = type(proxy1);
        
        if (proxy1_t ~= "Vector2" and proxy1_t ~= "number") then
            error("bad operand #1 to '__add' (Vector2/number expected, got " ..proxy1_t.. ")", 2);
        end
        
        local proxy2_t = type(proxy2);
        
        if (proxy2_t ~= "Vector2" and proxy2_t ~= "number") then
            error("bad operand #2 to '__add' (Vector2/number expected, got " ..proxy2_t.. ")", 2);
        end
        
        
        if (proxy1_t == "number") then
            local obj2 = PROXY__OBJ[proxy2];
            
            return new(proxy1+obj2.x, proxy1+obj2.y);
        end
        
        local obj1 = PROXY__OBJ[proxy1];
        
        if (proxy2_t == "number") then
            return new(obj1.x+proxy2, obj1.y+proxy2);
        end
        
        local obj2 = PROXY__OBJ[proxy2];
        
        return new(obj1.x+obj2.x, obj1.y+obj2.y);
    end,
    
    __sub = function(proxy1, proxy2)
        local proxy1_t = type(proxy1);
        
        if (proxy1_t ~= "Vector2" and proxy1_t ~= "number") then
            error("bad operand #1 to '__sub' (Vector2/number expected, got " ..proxy1_t.. ")", 2);
        end
        
        local proxy2_t = type(proxy2);
        
        if (proxy2_t ~= "Vector2" and proxy2_t ~= "number") then
            error("bad operand #2 to '__sub' (Vector2/number expected, got " ..proxy2_t.. ")", 2);
        end
        
        
        if (proxy1_t == "number") then
            local obj2 = PROXY__OBJ[proxy2];
            
            return new(proxy1-obj2.x, proxy1-obj2.y);
        end
        
        local obj1 = PROXY__OBJ[proxy1];
        
        if (proxy2_t == "number") then
            return new(obj1.x-proxy2, obj1.y-proxy2);
        end
        
        local obj2 = PROXY__OBJ[proxy2];
        
        if (proxy2_t == "Vector3") then
            return Vector3.new(obj1.x-obj2.x, obj1.y-obj2.y, obj2.z);
        end
        
        return new(obj1.x-obj2.x, obj1.y-obj2.y);
    end,
    
    __mul = function(proxy1, proxy2)
        local proxy1_t = type(proxy1);
        
        if (proxy1_t ~= "Vector2" and proxy1_t ~= "number") then
            error("bad operand #1 to '__mul' (Vector2/number expected, got " ..proxy1_t.. ")", 2);
        end
        
        local proxy2_t = type(proxy2);
        
        if (proxy2_t ~= "Vector2" and proxy2_t ~= "number") then
            error("bad operand #2 to '__mul' (Vector2/number expected, got " ..proxy2_t.. ")", 2);
        end
        
        
        if (proxy1_t == "number") then
            local obj2 = PROXY__OBJ[proxy2];
            
            return new(proxy1*obj2.x, proxy1*obj2.y);
        end
        
        local obj1 = PROXY__OBJ[proxy1];
        
        if (proxy2_t == "number") then
            return new(obj1.x*proxy2, obj1.y*proxy2);
        end
        
        local obj2 = PROXY__OBJ[proxy2];
        
        return new(obj1.x*obj2.x, obj1.y*obj2.y);
    end,
    
    __div = function(proxy1, proxy2)
        local proxy1_t = type(proxy1);
        
        if (proxy1_t ~= "Vector2" and proxy1_t ~= "number") then
            error("bad operand #1 to '__div' (Vector2/number expected, got " ..proxy1_t.. ")", 2);
        end
        
        local proxy2_t = type(proxy2);
        
        if (proxy2_t ~= "Vector2" and proxy2_t ~= "number") then
            error("bad operand #2 to '__div' (Vector2/number expected, got " ..proxy2_t.. ")", 2);
        end
        
        
        if (proxy1_t == "number") then
            local obj2 = PROXY__OBJ[proxy2];
            
            return new(proxy1/obj2.x, proxy1/obj2.y);
        end
        
        local obj1 = PROXY__OBJ[proxy1];
        
        if (proxy2_t == "number") then
            return new(obj1.x/proxy2, obj1.y/proxy2);
        end
        
        local obj2 = PROXY__OBJ[proxy2];
        
        return new(obj1.x/obj2.x, obj1.y/obj2.y);
    end,
    
    
    __unm = function(proxy)
        local obj = PROXY__OBJ[proxy];
        
        return new(-obj.x, -obj.y);
    end,
    
    
    -- __eq, -- memoization takes care of it
    
    
    __tostring = function(proxy)
        local obj = PROXY__OBJ[proxy];
        
        return obj.x.. ", " ..obj.y;
    end,
}



local MEM_PROXIES = setmetatable({}, { __mode = "v" });



function new(x, y)
    if (x ~= nil) then
        local x_t = type(x);
        
        if (x_t ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..x_t.. ")", 2);
        end
    else
        x = 0;
    end
    
    if (y ~= nil) then
        local y_t = type(y);
        
        if (y_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..y_t.. ")", 2);
        end
    else
        y = 0;
    end
    
    
    local memId = x.. ":" ..y;
    
    local proxy = MEM_PROXIES[memId];
    
    if (not proxy) then
        local obj = {
            type = name,
            
            
            x = x,
            y = y,
        }
        
        proxy = setmetatable({}, meta);
        
        MEM_PROXIES[memId] = proxy;
        
        OBJ__PROXY[obj] = proxy;
        PROXY__OBJ[proxy] = obj;
    end
    
    return proxy;
end



function func.unpack(obj)
    return obj.x, obj.y;
end



function get.mag(obj)
    if (not obj.mag) then
        obj.mag = math.sqrt(obj.x^2+obj.y^2);
    end
    
    return obj.mag;
end

function get.unit(obj)
    if (not obj.unit) then
        local mag = get.mag(obj);
        
        if (mag == 0) then
            error("attempt to get unit of 0 length vector", 2);
        end
        
        obj.unit = new(obj.x/mag, obj.y/mag);
    end
    
    return obj.unit;
end

function get.vec30(obj) -- for addition/substraction
    if (not obj.vec30) then
        obj.vec30 = Vector3.new(obj.x, obj.y, 0);
    end
    
    return obj.vec30;
end

function get.vec31(obj) -- for multiplication/division
    if (not obj.vec31) then
        obj.vec31 = Vector3.new(obj.x, obj.y, 1);
    end
    
    return obj.vec31;
end



Vector2 = {
    name = name,
    
    func = func,
    get  = get,
    
    meta = meta,
    
    new = new,
    
    ZERO = new(),
}
