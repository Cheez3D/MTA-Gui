local name = "ScreenGui";

local super = RootGui;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local event = inherit({}, super.event);

local private  = inherit({}, super.private);
local readOnly = inherit({}, super.readOnly);



local function new(obj)
    local success, result = pcall(super.new, obj);
    if (not success) then error(result, 2) end
    
    
    function obj.draw_wrapper()
        func.draw(obj);
    end
    
    
    addEventHandler("onClientPreRender", root, obj.draw_wrapper);
end



function func.draw(obj)
    if (obj.container) then
        dxDrawImageSection(
            obj.containerPos.x, obj.containerPos.y, obj.containerSize.x, obj.containerSize.y,
            0, 0, obj.containerSize.x, obj.containerSize.y,
            
            obj.container
        );
    end
end



ScreenGui = inherit({
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    event = event,
    
    private  = private,
    readOnly = readOnly,
    
    new = new,
}, super);

Instance.initializable.ScreenGui = ScreenGui;
