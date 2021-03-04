local super = classes.GuiObject;

local class = inherit({
    name = "Frame",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = true,
}, super);

classes[class.name] = class;



function class.new()
    local success, obj = pcall(super.new, class);
    if (not success) then error(obj, 2) end
    
    
    return obj;
end

class.meta = extend({}, super.meta);
