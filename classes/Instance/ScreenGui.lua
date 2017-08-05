local name = "ScreenGui";

local class;
local super = RootGui;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local new, meta;

local concrete = true;



function new()
    local success, obj = pcall(super.new, class, meta);
    if (not success) then error(obj, 2) end
    
    
    function obj.draw_wrapper()
        func.draw(obj);
    end
    
    addEventHandler("onClientRender", root, obj.draw_wrapper, false);
    
    
    return obj;
end

meta = extend({}, super.meta);



function func.draw(obj)
    if (obj.container) then
        dxDrawImageSection(
            obj.containerPos.x, obj.containerPos.y, obj.containerSize.x, obj.containerSize.y,
            0, 0, obj.containerSize.x, obj.containerSize.y,
            
            obj.container,
            
            nil, nil, nil, GuiBase2D.DRAW_POST_GUI -- somehow its the 13th argument instead of 14th when leaving rotation nil
        );
    end
end



class = {
    name = name,
    
    super = super,
    
    func = func, get = get, set = set,
    
    new = new, meta = meta,
    
    concrete = concrete,
}

_G[name] = class;
classes[#classes+1] = class;
