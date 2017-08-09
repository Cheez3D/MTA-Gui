local obj__proxy = {} -- TODO: add __mode meta
local proxy__obj = {}



for className, class in pairs(classes) do
    if (class.concrete) then
        local proxy_new, proxy_meta;
        
        function proxy_new(...)
            local success, obj = pcall(class.new, ...);
            if (not success) then error(obj, 2) end
            
            local proxy = obj__proxy[obj];
            if (not proxy) then
                proxy = {}
                
                obj__proxy[obj] = proxy;
                proxy__obj[proxy] = obj;
                
                setmetatable(proxy, proxy_meta);
            end
            
            return proxy;
        end
        
        -- TODO: add support for children access for Instance
        proxy_meta = extend({
            __index = function(proxy, key)
                local obj = proxy__obj[proxy];
                
                -- TODO: if val that is to be returned is obj then convert to proxy before returning
                
                local val = obj[key];
                if (val ~= nil) then -- val might be false so compare against nil
                    return val;
                end
                
                local func = obj.func[key];
                if (func) then
                    return (function(...)
                        local ret = { pcall(func, obj, ...) }
                        if (not ret[1]) then error(ret[2], 2) end
                        
                        return select(2, unpack(ret));
                    end);
                end
                
                local get = obj.get[key];
                if (get) then
                    return get(obj);
                end
                
                return nil;
            end,
            
            __newindex = function(proxy, key, val)
                local obj = proxy__obj[proxy];
                
                if (proxy__obj[val]) then -- if val is proxy convert it to obj
                    val = proxy__obj[val];
                end
                
                local prev = obj[key];
                if (val == prev) then
                    return;
                end
                
                local set = obj.set[key];
                if (set) then
                    local success, result = pcall(set, obj, val, prev, 1);
                    if (not success) then error(result, 2) end
                    
                    return;
                end
                
                error("attempt to modify an invalid key (" ..tostring(key).. ")", 2);
            end,
        }, class.meta);
        
        
        local proxy_class = {
            new = proxy_new,
        }
        
        setmetatable(proxy_class, {
            __metatable = class.name,
            
            
            __call = function(proxy_class, ...)
                local success, proxy = pcall(proxy_class.new, ...);
                if (not success) then error(proxy, 2) end
                
                return proxy;
            end,
        });
        
        _G[class.name] = proxy_class;
    else
        -- TODO: leave this uncommented to identify where to add local variables for required classes
        -- _G[class.name] = nil;
    end
end

classes = nil;
