local OBJ__PROXY = setmetatable({}, { __mode = "v" });
local PROXY__OBJ = setmetatable({}, { __mode = "k" });

local function getProxy(obj)
    local proxy = OBJ__PROXY[obj];
    
    if (not proxy) then
        local proxy = {}
        
        OBJ__PROXY[obj] = proxy;
        PROXY__OBJ[proxy] = obj;
        
        setmetatable(proxy, obj.class.proxy_meta);
    end
    
    return proxy;
end

-- TODO: add private and readOnly support !!!

for className, class in pairs(classes) do
    if (class.concrete) then
        function class.proxy_new(...)
            local success, obj = pcall(class.new, ...);
            if (not success) then error(obj, 2) end
            
            return getProxy(obj);
        end
        
        -- TODO: add support for children access for Instance
        class.proxy_meta = extend({
            __index = function(proxy, key)
                local obj = PROXY__OBJ[proxy];
                
                local val = obj[key];
                if (val ~= nil) then -- val might be false so compare against nil
                    return type(val):find("Object") and getProxy(val) or val; -- if val that is to be returned is obj then convert to proxy before returning
                end
                
                local func = obj.func[key];
                if (func) then print("is func")
                    return (function(...) print("called")
                        local ret = { pcall(func, obj, ...) }
                        if (not ret[1]) then error(ret[2], 2) end
                        
                        for i = 2, #ret do
                            -- if val that is to be returned is obj then convert to proxy before returning
                            if (obj__proxy[ret[i]]) then
                                ret[i] = obj__proxy[ret[i]];
                            end
                        end
                        
                        return select(2, unpack(ret));
                    end);
                end
                
                local get = obj.get[key];
                if (get) then
                    local ret = get(obj);
                    
                    return obj__proxy[ret] or ret; -- if val that is to be returned is obj then convert to proxy before returning
                end
                
                return nil;
            end,
            
            __newindex = function(proxy, key, val)
                local obj = PROXY__OBJ[proxy];
                
                if (PROXY__OBJ[val]) then -- if val is proxy convert it to obj
                    val = PROXY__OBJ[val];
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
        
        
        local classProxy = {
            new = newProxy,
        }
        
        setmetatable(classProxy, {
            __metatable = class.name,
            
            
            __call = function(classProxy, ...)
                local success, proxy = pcall(classProxy.new, ...);
                if (not success) then error(proxy, 2) end
                
                return proxy;
            end,
        });
        
        _G[class.name] = classProxy;
    end
end
