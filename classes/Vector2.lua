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
        local proxy1Type = type(proxy1);
        
        if (proxy1Type ~= "Vector2") then
            error("bad operand #1 to '__add' (Vector2 expected, got " ..proxy1Type.. ")", 2);
        end
        
        local proxy2Type = type(proxy2);
        
        if (proxy2Type ~= "Vector2") then
            error("bad operand #2 to '__add' (Vector2 expected, got " ..proxy2Type.. ")", 2);
        end
        
        
        
        local obj1 = PROXY__OBJ[proxy1];
        local obj2 = PROXY__OBJ[proxy2];
        
        return new(obj1.x + obj2.x, obj1.y + obj2.y);
    end,
    
    __sub = function(proxy1, proxy2)
        local proxy1Type = type(proxy1);
        
        if (proxy1Type ~= "Vector2") then
            error("bad operand #1 to '__sub' (Vector2 expected, got " ..proxy1Type.. ")", 2);
        end
        
        local proxy2Type = type(proxy2);
        
        if (proxy2Type ~= "Vector2") then
            error("bad operand #2 to '__sub' (Vector2 expected, got " ..proxy2Type.. ")", 2);
        end
        
        
        
        local obj1 = PROXY__OBJ[proxy1];
        local obj2 = PROXY__OBJ[proxy2];
        
        return new(obj1.x - obj2.x, obj1.y - obj2.y);
    end,
    
    __mul = function(proxy1, proxy2)
        local proxy1Type = type(proxy1);
        
        if (proxy1Type ~= "Vector2") then
            error("bad operand #1 to '__mul' (Vector2 expected, got " ..proxy1Type.. ")", 2);
        end
        
        local proxy2Type = type(proxy2);
        
        if (proxy2Type ~= "Vector2") then
            error("bad operand #2 to '__mul' (Vector2 expected, got " ..proxy2Type.. ")", 2);
        end
        
        
        
        local obj1 = PROXY__OBJ[proxy1];
        local obj2 = PROXY__OBJ[proxy2];
        
        return new(obj1.x*obj2.x, obj1.y*obj2.y);
    end,
    
    __div = function(proxy1, proxy2)
        local proxy1Type = type(proxy1);
        
        if (proxy1Type ~= "Vector2") then
            error("bad operand #1 to '__div' (Vector2 expected, got " ..proxy1Type.. ")", 2);
        end
        
        local proxy2Type = type(proxy2);
        
        if (proxy2Type ~= "Vector2") then
            error("bad operand #2 to '__div' (Vector2 expected, got " ..proxy2Type.. ")", 2);
        end
        
        
        
        local obj1 = PROXY__OBJ[proxy1];
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



local MEM_PROXIES = setmetatable({}, { __mode = 'v' });

function new(x, y)
    if (x ~= nil) then
        local xType = type(x);
        
        if (xType ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..xType.. ")", 2);
        end
    else
        x = 0;
    end
    
    if (y ~= nil) then
        local yType = type(y);
        
        if (yType ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..yType.. ")", 2);
        end
    else
        y = 0;
    end
    
    
    
    local memID = x.. ":" ..y;
    
    local proxy = MEM_PROXIES[memID];
    
    if (not proxy) then
        
        local obj = {
            x = x,
            y = y,
        }
        
        proxy = setmetatable({}, meta);
        
        PROXY__OBJ[proxy] = obj;
        
        MEM_PROXIES[memID] = proxy;
    end
    
    return proxy;
end



function func.unpack(obj)
    return obj.x, obj.y;
end



function get.magnitude(obj)
    local mag = math.sqrt(obj.x^2+obj.y^2);
    
    obj.magnitude = mag; -- memoize magnitude inside obj
    
    return mag;
end

function get.unit(obj)
    -- check if magnitude was already computed and memoized inside obj
    local mag = obj.magnitude or get.magnitude(obj);
    
    local unit = new(obj.x/mag, obj.y/mag);
    
    obj.unit = unit; -- memoize unit vector inside obj
    
    return unit;
end



Vector2 = {
    func = func,
    get  = get,
    
    new = new,
    
    meta = meta,
}

-- Vector2 = setmetatable({}, {
    -- __metatable = "Vector2",
    
    
    -- __index = function(proxy, key)
        -- return (key == "new") and new or nil;
    -- end,
    
    -- __newindex = function(proxy, key)
        -- error("attempt to modify a read-only key (" ..tostring(key).. ")", 2);
    -- end,
    
    
    -- __call = function(proxy, ...)
        -- local success, result = pcall(new, ...);
        
        -- if (not success) then
            -- error("call error", 2);
        -- end
        
        -- return result;
    -- end,
-- });






-- do
    -- local PROXY__OBJ = {}

    -- local func = {}

    -- local mem = {}

    -- local meta = {
        -- __index = function(proxy, key)
            -- local func = func[key];
            -- if (func) then
                -- -- local obj = PROXY__OBJ[proxy];
                
                -- -- -- if (not mem[func]) then mem[func] = {} end
                
                -- -- local f -- = mem[func][obj];
                -- -- -- if (not f) then
                    -- -- f = function() return func(obj) end
                    
                    -- -- -- mem[func][obj] = f;
                -- -- -- end
                
                -- return func;
            -- end
        -- end,
    -- }

    -- local function new(x, y)
        -- local obj = {
            -- x = x,
            -- y = y,
        -- }
        
        -- local proxy = setmetatable({}, meta);

        -- PROXY__OBJ[proxy] = obj;
        
        -- return proxy;
    -- end


    -- function func.print(obj)
        -- -- print(obj.x, obj.y);
        
        -- return true;
    -- end



    -- local v = new(3, 4);

    -- local start = getTickCount();

    -- for i = 1, 10000000 do
        -- v.print();
    -- end

    -- print(getTickCount()-start);
-- end
