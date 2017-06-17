local name = "Instance";

local func = {}
local set  = {}

local setAll = {}

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
		
        
        -- check if key is private
		local class = initializable[obj.className];
        
		while (class) do
			if (class.private) and (class.private[key]) then -- if key is private but a child with its name exists
				local child = obj.childrenByName[key];
                
				if (child) then
                    return OBJ__PROXY[child];
                end
                
                return;
			end
			
			class = class.super;
		end
		
        
		local val = obj[key];
        if (val ~= nil) then -- val might be false so compare against nil
        
            -- convert object to proxy before returning
            if (OBJ__PROXY[val]) then
                val = OBJ__PROXY[val];
            end
            
            return val;
        end
		
        
		local class = initializable[obj.className];
        
		while (class) do
			local func_f = class.func and class.func[key];
			if (func_f) then
                return (function(...) return func_f(obj, ...) end);
            end
			
			local get_f = class.get and class.get[key];
			if (get_f) then
                return get_f(obj, key);
            end
			
			class = class.super;
		end
		
		local child = obj.childrenByName[key];
        
		if (child) then
            return OBJ__PROXY[child];
        end
	end,
    
	__newindex = function(proxy, key, val)
		local obj = PROXY__OBJ[proxy];
		
		local prev = obj[key];
		if (val == prev) then return end -- if trying to set same val then return
		
        
		local set_fs = {} -- stack of set functions to call
		
		local class = initializable[obj.className];
        
		while (class) do
			if (class.readOnly) and (class.readOnly[key]) then
                error("attempt to modify a read-only key (" ..tostring(key).. ")", 2);
            end
			
			local set_f = class.set and class.set[key];
            
			if (set_f) then
                set_fs[#set_fs+1] = set_f;
            end
			
			class = class.super;
		end
        
        
        if (#set_fs > 0) then
            for i = #set_fs, 1, -1 do
                set_fs[i](obj, val, prev, key);
            end
		else
            error("attempt to modify an invalid key (" ..tostring(key).. ")", 2);
        end
	end,
    
    
	__tostring = function(proxy)
		local obj = PROXY__OBJ[proxy];
		
		return obj.className.. " " ..obj.name;
	end
}

function new(className, parentProxy)
	local classNameType = type(className);
    
	if (classNameType ~= "string") then
        error("bad argument #1 to '" ..__func__.. "' (string expected, got " ..classNameType.. ")", 2);
    end
	
	if (parentProxy ~= nil) then
		local parentProxyType = type(parentProxy);
        
		if (parentProxyType ~= "Instance") then
            error("bad argument #2 to '" ..__func__.. "' (Instance expected, got " ..parentProxyType.. ")", 2);
        end
	end
	
    
    
	local class = (not privateClass[className]) and initializable[className];
    
	if (not class) then
        error("bad argument #1 to '" ..__func__.. "' (invalid class)",2);
	end
    
    local obj = {
        className = className,
        
        name = className,
        
        children       = {},
        childrenByKey  = {},
        childrenByName = {},
    }
    
    class.new(obj);
    
    local proxy = setmetatable({}, meta);
    
    PROXY__OBJ[proxy] = obj;
    OBJ__PROXY[obj]   = proxy;
    
    proxy.parent = parentProxy;
    
    return proxy;
end



function func.isA(obj, className)
    local classNameType = type(className);
    
    if (classNameType ~= "string") then
        error("bad argument #2 to '" ..__func__.. "' (string expected, got " ..classNameType.. ")", 2);
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



function set.name(obj, name, prevName, key)
    local nameType = type(name);
    
    if (nameType ~= "string") then
        error("bad argument #1 to '" ..key.. "' (string expected, got " ..nameType.. ")", 3);
    end
    
    
    if (obj.parent) then
        local parent = obj.parent;
        
        -- if obj is occupying the place in childrenByName then try to find another child with same prevName to replace it
        if (parent.childrenByName[prevName] == obj) then
            
            -- start search from after obj because childrenByName place is occupied by object with smallest index
            for i = obj.index+1, #parent.children do
                local child = parent.children[i];
                
                if (child.name == prevName) then
                    parent.childrenByName[prevName] = child;
                    
                    break;
                end
            end
        end
        
        if (not parent.childrenByName[name]) then
            parent.childrenByName[name] = obj;
        end
    end
    
    obj.name = name;
end

function set.parent(obj, parentProxy, prevParentProxy, key)
    
    local parent;
    
    if (parentProxy ~= nil) then
        local parentProxyType = type(parentProxy);
        
        if (parentProxyType ~= "Instance") then
            error("bad argument #1 to '" ..key.. "' (Instance expected, got " ..parentProxyType.. ")", 3);
        end
        
        
        parent = PROXY__OBJ[parentProxy];
        
        -- if trying to set a child to be the parent of its parent
        -- e.g. obj1.parent = obj2; obj2.parent = obj1;
        
        if (obj.childrenByKey[parent]) then
            error("bad argument #1 to '" ..key.. "' (circular reference)", 3);
        end
        
        -- if trying to set an object as its own parent
        -- e.g. obj.parent = obj;
        
        if (parent == obj) then
            error("bad argument #1 to '" ..key.. "' (self parenting)", 3);
        end
    end
    
    
    if (prevParentProxy) then
        
        local prevParent = PROXY__OBJ[prevParentProxy];
        
        -- remove child from children table
        prevParent.children[obj.index] = nil;
        
        for i = obj.index+1, #prevParent.children do
            local child = prevParent.children[i];
            
            child.index = child.index-1;
            prevParent.children[i-1] = child;
        end
        
        prevParent.children[#prevParent.children] = nil; -- remove last redundant element
        
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
    initializable = initializable,
    privateClass  = privateClass,
	
	func = func,
	set  = set,
	
	name = name,
	
	private  = private,
	readOnly = readOnly,
    
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
