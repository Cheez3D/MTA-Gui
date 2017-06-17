local name = "UDim";

local func = {}

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
    end,
    
    __newindex = function(proxy, key)
        error("attempt to modify a read-only key (" ..tostring(key).. ")", 2);
    end,
    
    
    __add = function(proxy1, proxy2)
        local proxy1Type = type(proxy1);
        
        if (proxy1Type ~= "UDim") then
            error("bad operand #1 to '__add' (UDim expected, got " ..proxy1Type.. ")", 2);
        end
        
        local proxy2Type = type(proxy2);
        
        if (proxy2Type ~= "UDim") then
            error("bad operand #2 to '__add' (UDim expected, got " ..proxy2Type.. ")", 2);
        end
        
        
        local obj1 = PROXY__OBJ[proxy1];
        local obj2 = PROXY__OBJ[proxy2];
        
        return new(obj1.scale + obj2.scale, obj1.offset + obj2.offset);
    end,
    
    
    __tostring = function(proxy)
        local obj = PROXY__OBJ[proxy];
        
        return obj.scale.. ", " ..obj.offset;
    end,
}


local MEM_PROXIES = setmetatable({}, { __mode = 'v' });

function new(scale, offset)
    
    -- [ ====================== [ ASSERTION ] ====================== ]
    
    if (scale ~= nil) then
        local scaleType = type(scale);
        
        if (scaleType ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..scaleType.. ")", 2);
        end
    else
        scale = 0;
    end
    
    if (offset ~= nil) then
        local offsetType = type(offset);
        
        if (offsetType ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..offsetType.. ")", 2);
        end
    else
        offset = 0;
    end
    
    
    
    local memID = scale.. ":" ..offset;
    
    local proxy = MEM_PROXIES[memID];
    
    if (not proxy) then
        
        local obj = {
            scale = scale,
            offset = offset,
        }
        
        proxy = setmetatable({}, meta);
        
        PROXY__OBJ[proxy] = obj;
        OBJ__PROXY[obj] = proxy;
        
        MEM_PROXIES[memID] = proxy;
    end
    
    return proxy;
end



function func.unpack(obj)
    return obj.scale, obj.offset;
end



UDim = {
    func = func,
    
    new = new,
    
    meta = meta,
}

-- UDim = setmetatable({}, {
    -- __metatable = "UDim",
    
    
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
