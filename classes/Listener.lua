local name = "Listener";

local func = {}

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
            return (function(...)
                local success, result = pcall(func_f, obj, ...);
                if (not success) then error(result, 2) end
                
                return result;
            end);
        end
    end,
    
    __newindex = function(proxy, key)
        error("attempt to modify a read-only key (" ..tostring(key).. ")", 2);
    end,
    
    
    __tostring = function(proxy)
        local obj = PROXY__OBJ[proxy];
        
        return name;
    end,
}



local function new(signal, func)
    local obj = {
        signal = signal,
        
        index = #signal.listeners
        
        func = func,
    }
    
    local proxy = setmetatable({}, meta);
    
    OBJ__PROXY[obj] = proxy;
    PROXY__OBJ[proxy] = obj;
    
    return proxy;
end



function func.disconnect(obj, listener)
    local listener_t = type(listener);
    
    if (listener_t ~= "function") then
        error("bad argument #1 to '" ..__func__.. "' (function expected, got " ..listener_t.. ")", 2);
    elseif (not obj.listenersByKey[listener]) then
        error("bad argument #1 to '" ..__func__.. "' (attempt do disconnect unconnected listener)", 2);
    end
    
    
    obj.listenersByKey[listener] = nil;
end


function func.trigger(obj, ...)
    for listener in pairs(obj.listenersByKey) do
        listener(...);
    end
end



Listener = {
    name = name,
    
    func = func,
    
    meta = meta,
    
    new = new,
}
