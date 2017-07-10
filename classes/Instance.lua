local name = "Instance";

local func = {}
local get  = {}
local set  = {}

local private = {
    children       = true,
    childrenByKey  = true,
    childrenByName = true,
    
    index = true,
}

local readOnly = {
    className = true,
}

local initializable = {}
local privateClass  = {}

local new;

local meta = {
    __metatable = name,
    
    
	__index = function(proxy, key)
		local obj = PROXY__OBJ[proxy];
		
        
        local class = initializable[obj.className];
        
        local child = obj.childrenByName[key];
        
        if (class.private[key]) then
            if (child) then -- if key is private but a child with key name exists
                return OBJ__PROXY[child];
            else
                return;
            end
        end
		
		local val = obj[key];
        if (val ~= nil) then -- val might be false so compare against nil
            if (OBJ__PROXY[val] and type(val) == "Instance") then -- convert object to proxy before returning (only for Instance objects)
                val = OBJ__PROXY[val];
            end
            
            return val;
        end
		
        local func_f = class.func[key];
        if (func_f) then
            return (function(...)
                local success, result = pcall(func_f, obj, ...);
                if (not success) then error(result, 2) end
                
                return result;
            end);
        end
        
        local get_f = class.get[key];
        if (get_f) then
            return get_f(obj);
        end
		
        if (child) then
            return OBJ__PROXY[child];
        end
	end,
    
	__newindex = function(proxy, key, val)
		local obj = PROXY__OBJ[proxy];
		
        -- convert proxy to object before continuing (only for Instance objects)
        if (PROXY__OBJ[val] and type(val) == "Instance") then
            val = PROXY__OBJ[val];
        end
        
		local prev = obj[key];
		if (val == prev) then return end -- if trying to set same val then return
		
        
		local class = initializable[obj.className];
        
        local set_f = class.set[key];
        if (set_f) then
            local success, result = pcall(set_f, obj, val, prev);
            if (not success) then error(result, 2) end
            
            return;
        end
        
		error("attempt to modify an invalid key (" ..tostring(key).. ")", 2);
	end,
    
    
	__tostring = function(proxy)
		local obj = PROXY__OBJ[proxy];
		
		return obj.className.. " " ..obj.name;
	end,
}



function new(className, parentProxy)
	local className_t = type(className);
    
	if (className_t ~= "string") then
        error("bad argument #1 to '" ..__func__.. "' (string expected, got " ..className_t.. ")", 2);
    end
	
	if (parentProxy ~= nil) then
		local parentProxy_t = type(parentProxy);
        
		if (parentProxy_t ~= "Instance") then
            error("bad argument #2 to '" ..__func__.. "' (Instance expected, got " ..parentProxy_t.. ")", 2);
        end
	end
	
    
    
	local class = (not privateClass[className]) and initializable[className];
    
	if (not class) then
        error("bad argument #1 to '" ..__func__.. "' (invalid class name)", 2);
	end
    
    local obj = {
        type = name,
        
        
        className = className,
        
        name = className,
        
        children       = {},
        childrenByKey  = {},
        childrenByName = {},
    }
    
    class.new(obj);
    
    local proxy = setmetatable({}, meta);
    
    OBJ__PROXY[obj] = proxy;
    PROXY__OBJ[proxy] = obj;
    
    
    proxy.parent = parentProxy; -- shortcut for eliminating the need to set parent after object creation
    
    return proxy;
end



function func.isA(obj, className)
    local className_t = type(className);
    
    if (className_t ~= "string") then
        error("bad argument #1 to 'isA' (string expected, got " ..className_t.. ")", 2);
    end
    
    
    local class = initializable[obj.className];
    
    while (class) do
        if (class.name == className) then
            return true;
        end
        
        class = class.super;
    end
    
    return false;
end



function set.name(obj, name, prevName)
    local name_t = type(name);
    
    if (name_t ~= "string") then
        error("bad argument #1 to 'name' (string expected, got " ..name_t.. ")", 2);
    end
    
    
    if (obj.parent) then
        local parent = obj.parent;
        
        -- if obj is occupying the place in childrenByName then try to find another child with same prevName to replace it
        if (parent.childrenByName[prevName] == obj) then
            local child;
            
            -- start search from after obj because childrenByName place is occupied by object with smallest index
            for i = obj.index+1, #parent.children do
                child = parent.children[i];
                
                if (child.name == prevName) then
                    break;
                end
            end
            
            parent.childrenByName[prevName] = child; -- if other child not found it will be set to nil
        end
        
        if (not parent.childrenByName[name]) then
            parent.childrenByName[name] = obj;
        end
    end
    
    obj.name = name;
end

function set.parent(obj, parent, prevParent)
    
    if (parent ~= nil) then -- might be false so check against nil for assertion
        local parent_t = type(parent);
        
        if (parent_t ~= "Instance") then
            error("bad argument #1 to 'parent' (Instance expected, got " ..parent_t.. ")", 2);
        end
        
        
        -- if trying to set a child to be the parent of its parent
        -- e.g. obj1.parent = obj2; obj2.parent = obj1;
        
        if (obj.childrenByKey[parent]) then
            error("bad argument #1 to 'parent' (circular reference)", 2);
        end
        
        -- if trying to set an object as its own parent
        -- e.g. obj.parent = obj;
        
        if (parent == obj) then
            error("bad argument #1 to 'parent' (self parenting)", 2);
        end
    end
    
    
    if (prevParent) then
        -- -- remove child from children table (NOT NEEDED, taken care of by loop)
        -- prevParent.children[obj.index] = nil;
        
        local childrenCount = #prevParent.children;
        
        for i = obj.index+1, childrenCount do
            local child = prevParent.children[i];
            
            child.index = child.index-1;
            prevParent.children[i-1] = child;
        end
        
        prevParent.children[childrenCount] = nil; -- remove last redundant element (using childrenCount from before operating on array)
        
        -- remove child from childrenByKey table
        prevParent.childrenByKey[obj] = nil;
        
        -- remove child from childrenByName table and, if possible, replace with another child with same name
        if (prevParent.childrenByName[obj.name] == obj) then
            local child;
            
            for i = obj.index, #prevParent.children do
                child = prevParent.children[i];
                
                if (child.name == obj.name) then
                    break;
                end
            end
            
            prevParent.childrenByName[obj.name] = child; -- if other child not found it will be set to nil
        end
        
        obj.index = nil;
    end
    
    
    if (parent) then
        obj.index = #parent.children+1;
        parent.children[obj.index] = obj;
        
        parent.childrenByKey[obj] = true;
        
        if (not parent.childrenByName[obj.name]) then -- if there is no existing child with same name
            parent.childrenByName[obj.name] = obj;
        end
    end
    
    
    obj.parent = parent;
end



Instance = {
    name = name,
	
	func = func,
    get  = get,
	set  = set,
	
	private  = private,
	readOnly = readOnly,
    
    initializable = initializable,
    privateClass  = privateClass,
    
    meta = meta,
    
    new = new,
}

-- Instance = setmetatable({}, {
	-- __call = function(_Proxy,...)
		-- local Success,Result = pcall(Class.New,...);
		-- if (Success == false) then error(fromat_pcall_error(Result),2) end
		
		-- return Result;
	-- end,
	-- __index = Class,
	-- __metatable = "Instance",
	-- __newindex = function(_Proxy,Key)
		-- error("attempt to modify a read-only key ("..tostring(Key)..")",2);
	-- end
-- });
