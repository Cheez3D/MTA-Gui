local name = "GuiBase2D";

local super = Instance;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get[key]  end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set[key]  end });

local event = setmetatable({}, { __index = function(tbl, key) return super.event[key] end });

local private  = setmetatable({}, { __index = function(tbl, key) return super.private[key]  end });
local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });



local function new(obj)
    obj.guiChildren = {}
    
    func.update_rootGui(obj);
    func.update_clipperGui(obj);
    
    func.update_absSize(obj);
    func.update_absPos(obj);
    
    func.update_containerPos(obj, true);
    func.update_container(obj, true);
end



function func.update_rootGui(obj, descend)
    if (Instance.func.isA(obj, "RootGui")) then
        obj.rootGui = obj;
    elseif (obj.parent and Instance.func.isA(obj.parent, "GuiBase2D")) then
        obj.rootGui = obj.parent.rootGui;
    else
        obj.rootGui = nil;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_rootGui(obj.guiChildren[i], true);
        end
    end
end

function func.update_clipperGui(obj, descend)
    if (Instance.func.isA(obj, "RootGui")) then
        obj.clipperGui = obj;
    elseif (obj.rootGui) then
        if (obj.clipsDescendants) then
            obj.clipperGui = obj;
        else
            obj.clipperGui = obj.parent.clipperGui;
        end
    else
        obj.clipperGui = nil;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_clipperGui(obj.guiChildren[i], true);
        end
    end
end


function func.update_absSize(obj, descend)
    if (Instance.func.isA(obj, "RootGui")) then
        if (Instance.func.isA(obj, "ScreenGui")) then
            obj.absSize = Vector2.new(SCREEN_WIDTH, SCREEN_HEIGHT);
        else
            obj.absSize = Vector2.new();
        end
    elseif (obj.rootGui) then
        obj.absSize = Vector2.new(
            math.floor(obj.size.x.offset + obj.parent.absSize.x*obj.size.x.scale),
            math.floor(obj.size.y.offset + obj.parent.absSize.y*obj.size.y.scale)
        );
    else
        obj.absSize = nil;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_absSize(obj.guiChildren[i], true);
        end
    end
end

function func.update_absPos(obj, descend)
    if (Instance.func.isA(obj, "RootGui")) then
        obj.absPos = Vector2.new();
    elseif (obj.rootGui) then
        obj.absPos = Vector2.new(
            math.floor(
                obj.parent.absPos.x + (obj.pos.x.offset + obj.parent.absSize.x*obj.pos.x.scale)
              - (obj.posOrigin.x.offset + obj.absSize.x*obj.posOrigin.x.scale)
            ),
            math.floor(
                obj.parent.absPos.y + (obj.pos.y.offset + obj.parent.absSize.y*obj.pos.y.scale)
              - (obj.posOrigin.y.offset + obj.absSize.y*obj.posOrigin.y.scale)
            )
        );
    else
        obj.absPos = nil;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_absPos(obj.guiChildren[i], true);
        end
    end
end


function func.update_containerPos(obj, descend)
    if (obj.rootGui and #obj.guiChildren > 0) then
        obj.containerPos = obj.clipperGui.absPos;
    else
        obj.containerPos = nil;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_containerPos(obj.guiChildren[i], true);
        end
    end
end

function func.update_container(obj, descend)
    if (obj.rootGui and #obj.guiChildren > 0) then
        local containerSize = obj.clipperGui.absSize;
        
        if (containerSize ~= obj.containerSize) then
            if (obj.container and isElement(obj.container)) then
                destroyElement(obj.container);
            end
            
            obj.containerSize = containerSize;
            obj.container = dxCreateRenderTarget(containerSize.x, containerSize.y, true);
        end
    else
        if (obj.container and isElement(obj.container)) then
            destroyElement(obj.container);
        end
        
        obj.containerSize = nil;
        obj.container = nil;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_container(obj.guiChildren[i], true);
        end
    end
end


function func.draw(obj, descend)
    if (descend) then
        for i = 1, #obj.guiChildren do
            local child = obj.guiChildren[i];
            
            child.class.func.draw(child, true);
        end
    end
    
    
    if (obj.rootGui) then
        dxSetRenderTarget(obj.container, true);
        
        if (obj.debug) then
            dxSetBlendMode("add");
            
            dxDrawRectangle(0, 0, obj.containerSize.x, obj.containerSize.y, tocolor(0, 255, 0, 127.5));
        
            dxSetBlendMode("blend");
        end
        
        dxSetRenderTarget();
    end
end

function func.propagate(obj)
    if (not func.isA(obj, "RootGui") and obj.rootGui) then
        obj.parent.class.func.draw(obj.parent);

        func.propagate(obj.parent);
    end
end



function set.debug(obj, debug)
    local debug_t = type(debug);
    
    if (debug_t ~= "boolean") then
        error("bad argument #1 to 'debug' (boolean expected, got " ..debug_t.. ")", 2);
    end
    
    
    obj.debug = debug;
    
    
    obj.class.func.draw(obj);
    func.propagate(obj);
end



GuiBase2D = {
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    event = event,
    
    private  = private,
    readOnly = readOnly,
    
    new = new,
}






addEventHandler("onClientRestore", root, function(clearedRts)
    if (clearedRts) then
        print("Render Targets were cleared!");
    end
end);
