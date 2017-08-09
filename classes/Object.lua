local class = {
    name = "Object",
    
    func = {},
    get  = {},
    set  = {},
    
    concrete = false,
}

classes[class.name] = class;



function class.new(class, meta)
    local obj = {
        class = class,
        
        func = class.func,
        get  = class.get,
        set  = class.set,
    }
    
    return setmetatable(obj, meta);
end

class.meta = {
    __metatable = name,
    
    
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
