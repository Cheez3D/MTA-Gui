local super = classes.GuiBase2D;

local class = inherit({
    name = "RootGui",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = false,
}, super);

classes[class.name] = class;



function class.new(...)
    local success, obj = pcall(super.new, ...);
    if (not success) then error(obj, 2) end
    
    
    class.func.update_absSize(obj);
    class.func.update_absPos(obj);
    
    class.func.update_containerSize(obj);
    class.func.update_containerPos(obj);
    
    
    return obj;
end

class.meta = super.meta;
