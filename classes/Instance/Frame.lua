local name = "Frame";

local class;
local super = GuiObject;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local new, meta;

local concrete = true;



function new()
    local success, obj = pcall(super.new, class, meta);
    if (not success) then error(obj, 2) end
    
    
    return obj;
end

meta = extend({}, super.meta);



class = {
    name = name,
    
    super = super,
    
    func = func, get = get, set = set,
    
    new = new, meta = meta,
    
    concrete = concrete,
}

_G[name] = class;
classes[#classes+1] = class;
