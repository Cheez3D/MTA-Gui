local super = classes.RootGui;

local class = inherit({
    name = "ScreenGui",

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
    
    
    function obj.draw_wrapper()
        obj:draw();
    end
    
    addEventHandler("onClientRender", root, obj.draw_wrapper, false);
    
    
    return obj;
end

class.meta = super.meta;



function class.func.draw(obj)
    if (obj.container) then
        dxDrawImageSection(
            obj.containerPos.x, obj.containerPos.y, obj.containerSize.x, obj.containerSize.y,
            0, 0, obj.containerSize.x, obj.containerSize.y,
            
            obj.container,
            
            nil, nil, nil, class.DRAW_POST_GUI -- somehow its the 13th argument instead of 14th when leaving rotation nil
        );
    end
end
