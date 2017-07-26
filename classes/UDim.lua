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
        local proxy1_t = type(proxy1);
        
        if (proxy1_t ~= "UDim") then
            error("bad operand #1 to '__add' (UDim expected, got " ..proxy1_t.. ")", 2);
        end
        
        local proxy2_t = type(proxy2);
        
        if (proxy2_t ~= "UDim") then
            error("bad operand #2 to '__add' (UDim expected, got " ..proxy2_t.. ")", 2);
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



local MEM_PROXIES = setmetatable({}, { __mode = "v" });



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
    
    
    local memId = scale.. ":" ..offset;
    
    local proxy = MEM_PROXIES[memId];
    
    if (not proxy) then
        local obj = {
            type = name,
            
            
            scale  = scale,
            offset = offset,
        }
        
        proxy = setmetatable({}, meta);
        
        MEM_PROXIES[memId] = proxy;
        
        OBJ__PROXY[obj] = proxy;
        PROXY__OBJ[proxy] = obj;
    end
    
    return proxy;
end



function func.unpack(obj)
    return obj.scale, obj.offset;
end



UDim = {
    name = name,
    
    func = func,
    
    meta = meta,
    
    new = new,
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
