local classes = classes;

local class = {
    name = "Object",
    
    func = {},
    get  = {},
    set  = {},
    
    concrete = false,
}

classes[class.name] = class;



function class.new(class)
    local obj = {
        class = class,
        
        func = class.func,
        get  = class.get,
        set  = class.set,
    }
    
    return setmetatable(obj, class.meta);
end

class.meta = {
    __metatable = name,
    
    
    -- regex for replacing with colon call
    -- find what: ([A-Za-z0-9_]+\.)?func\.([A-Za-z0-9_]+)\(([A-Za-z0-9_]*),?\ ?
    -- replace with: \3:\2\(
    -- e.g. func.update_var(obj, 73) becomes obj:update_var(73)
    --      child.func.update_var(child, 73) becomes child:update_var(73)
    
    -- also getters and setters can be called by appending get_ or set_ before the variable name
    
    -- for colon function call support
    __index = function(obj, key)
        return obj.func[key]
        or obj.get[string.match(key, "^get_([%w_]-)$")]
        or obj.set[string.match(key, "^set_([%w_]-)$")]
        or nil;
    end,
    
    
    __tostring = function(obj)
        return obj.class.name;
    end,
}



function class.func.isA(obj, className)
    local className_t = type(className);
    
    if (className_t ~= "string") then
        error("bad argument #1 to 'isA' (string expected, got " ..className_t.. ")", 2);
    end
    
    
    local class = obj.class;
    while (class) do
        if (class.name == className) then
            return true;
        end
        
        class = class.super;
    end
    
    return false;
end
