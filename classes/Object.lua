local name = "Object";

local class;
local super = nil;

local func = {}
local get  = {}
local set  = {}



local new, meta;



function new(class, meta)
    local obj = {
        class = class,
        
        func = class.func,
        get  = class.get,
        set  = class.set,
    }
    
    return setmetatable(obj, meta);
end

meta = {
    __metatable = name,
    
    
    __tostring = function(obj)
        return obj.class.name;
    end,
}



class = {
    name = name,
    
    super = super,
    
    func = func, get = get, set = set,
    
    new = new, meta = meta,
}

_G[name] = class;
