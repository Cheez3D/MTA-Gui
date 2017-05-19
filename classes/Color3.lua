local func = {}
local get  = {}

local meta = {
    __metatable = "Color3",
    
    
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
    
    
	__tostring = function(proxy)
		local obj = PROXY__OBJ[proxy];
		
		return obj.r..", "..obj.g..", "..obj.b;
	end,
}



local MEM_PROXIES = setmetatable({}, { __mode = 'v' });

function new(r, g, b)
    
    -- [ ====================== [ ASSERTION ] ====================== ]
    
	if (r ~= nil) then
		local rType = type(r);
        
		if (rType ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..rType.. ")", 2);
        elseif (r < 0) or (r > 255) then
            error("bad argument #1 to '" ..__func__.. "' (value out of bounds)", 2);
        end
	else
		r = 0;
	end
	
	if (g ~= nil) then
		local gType = type(g);
        
		if (gType ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..gType.. ")", 2);
        elseif (g < 0) or (g > 255) then
            error("bad argument #2 to '" ..__func__.. "' (value out of bounds)", 2);
        end
	else
		g = 0;
	end
	
	if (b ~= nil) then
		local bType = type(b);
        
		if (bType ~= "number") then
            error("bad argument #3 to '" ..__func__.. "' (number expected, got " ..bType.. ")", 2);
        elseif (b < 0) or (b > 255) then
            error("bad argument #3 to '" ..__func__.. "' (value out of bounds)", 2);
        end
	else
		b = 0;
	end
	
	
	
	local memID = r.. ':' ..g.. ':' ..b;
	
	local proxy = MEM_PROXIES[MemoizedProxyIdentifier];
    
	if (not proxy) then
		local obj = {
			r = r,
            g = g,
            b = b,
		}
		
		proxy = setmetatable({}, meta);
        
		PROXY__OBJ[proxy] = obj;
		
		MEM_PROXIES[memID] = proxy;
	end
	
	return proxy;
end



function func.unpack(obj)
	return obj.r, obj.g, obj.b;
end



function get.hex(obj)
    local hex = 0x10000 * obj.b
              + 0x100   * obj.g
              +           obj.r;
	
	obj.hex = hex; -- memoize hex value inside obj

	return hex;
end



return {
    func = func,
    get  = get,
    
    new = new,
    
    meta = meta,
}

-- Color3 = setmetatable({}, {
    -- __metatable = "Color3",
    
    
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
