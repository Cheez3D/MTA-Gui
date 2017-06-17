-- local UDim = require("UDim");

local name = "UDim2";

local func = {}

local new;

local meta = {
    __metatable = name,
    
    
    __index = function(proxy, key)
        local obj = PROXY__OBJ[proxy];
        
        local val = obj[key];
        if (val ~= nil) then -- val might be false so compare against nil
            
            -- convert object to proxy before returning
            if (OBJ__PROXY[val]) then
                val = OBJ__PROXY[val];
            end
            
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
        
        if (proxy1Type ~= "UDim2") then
            error("bad operand #1 to '__add' (UDim2 expected, got " ..proxy1Type.. ")", 2);
        end
        
        local proxy2Type = type(proxy2);
        
        if (proxy2Type ~= "UDim2") then
            error("bad operand #2 to '__add' (UDim2 expected, got " ..proxy2Type.. ")", 2);
        end
        
        
        
        local obj1 = PROXY__OBJ[proxy1];
        local obj2 = PROXY__OBJ[proxy2];
        
        local obj1ScaleX, obj1OffsetX, obj1ScaleY, obj1OffsetY = func.unpack(obj1);
        local obj2ScaleX, obj2OffsetX, obj2ScaleY, obj2OffsetY = func.unpack(obj2);
        
        return new(
            obj1ScaleX  + obj2ScaleX,
            obj1OffsetX + obj2OffsetX,
            obj1ScaleY  + obj2ScaleY,
            obj1OffsetY + obj2OffsetY
        );
    end,
    
    
    __tostring = function(proxy)
        local obj = PROXY__OBJ[proxy];
        
        return "{" ..tostring(obj.x).. "}, {" ..tostring(obj.y).. "}";
    end,
}


local MEM_PROXIES = setmetatable({}, { __mode = 'v' });

function new(scaleX, offsetX, scaleY, offsetY)
    if (scaleX ~= nil) then
        local scaleXType = type(scaleX);
        
        if (scaleXType ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..scaleXType.. ")", 2);
        end
    else
        scaleX = 0;
    end
    
    if (offsetX ~= nil) then
        local offsetXType = type(offsetX);
        
        if (offsetXType ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..offsetXType.. ")", 2);
        end
    else
        offsetX = 0;
    end
    
    if (scaleY ~= nil) then
        local scaleYType = type(scaleY);
        
        if (scaleYType ~= "number") then
            error("bad argument #3 to '" ..__func__.. "' (number expected, got " ..scaleYType.. ")", 2);
        end
    else
        scaleY = 0;
    end
    
    if (offsetY ~= nil) then
        local offsetYType = type(offsetY);
        
        if (offsetYType ~= "number") then
            error("bad argument #4 to '" ..__func__.. "' (number expected, got " ..offsetYType.. ")", 2);
        end
    else
        offsetY = 0;
    end
    
    
    local memID = scaleX.. ":" ..offsetX.. ":" ..scaleY.. ":" ..offsetY;
    
    local proxy = MEM_PROXIES[memID];
    
    if (not proxy) then
        local obj = {
            x = PROXY__OBJ[UDim.new(scaleX, offsetX)],
            y = PROXY__OBJ[UDim.new(scaleY, offsetY)],
        }
        
        proxy = setmetatable({}, meta);
        
        PROXY__OBJ[proxy] = obj;
        
        MEM_PROXIES[memID] = proxy;
    end
    
    return proxy;
end



function func.unpack(obj)
    local scaleX, offsetX = UDim.func.unpack(PROXY__OBJ[obj.x]);
    local scaleY, offsetY = UDim.func.unpack(PROXY__OBJ[obj.y]);
    
    return scaleX, offsetX, scaleY, offsetY;
end



UDim2 = {
    func = func,
    
    new = new,
    
    meta = meta,
}


-- return setmetatable({}, {
    -- __metatable = "UDim2",
    
    
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
