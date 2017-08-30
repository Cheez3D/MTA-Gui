local name = "RootGui";

local class;
local super = classes.GuiBase2D;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local new, meta;



function new(class, meta)
    local success, obj = pcall(super.new, class, meta);
    if (not success) then error(obj, 2) end
    
    
    func.update_absSize(obj);
    func.update_absPos(obj);
    
    func.update_containerSize(obj);
    func.update_containerPos(obj);
    
    
    return obj;
end

meta = extend({}, super.meta);



class = inherit({
    name = name,
    
    super = super,
    
    func = func, get = get, set = set,
    
    new = new, meta = meta,
}, super);

_G[name] = class;
