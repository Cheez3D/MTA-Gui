local name = "GuiBase2D";

local super = Instance;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local event = inherit({}, super.event);

local private  = inherit({}, super.private);
local readOnly = inherit({}, super.readOnly);



local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize();



local function new(obj)
    obj.guiChildren = {}
end



function func.update_absSize(obj, descend)
    local absSize = (
        func.isA(obj, "RootGui") and (
            func.isA(obj, "ScreenGui") and Vector2.new(SCREEN_WIDTH, SCREEN_HEIGHT)
            or Vector2.new()
        )
        or func.isA(obj, "GuiObject") and obj.rootGui and Vector2.new(
            math.floor(obj.size.x.offset + obj.parent.absSize.x*obj.size.x.scale),
            math.floor(obj.size.y.offset + obj.parent.absSize.y*obj.size.y.scale)
        )
    )
    or nil;
    
    if (absSize ~= obj.absSize) then
        obj.absSize = absSize;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_absSize(obj.guiChildren[i], true);
            end
        end
    end
end

function func.update_absPos(obj, descend)
    local absPos = (
        func.isA(obj, "RootGui") and (
            func.isA(obj, "ScreenGui") and Vector2.new()
            or Vector2.new()
        )
        or func.isA(obj, "GuiObject") and obj.rootGui and Vector2.new(
            math.floor(
                obj.parent.absPos.x + (obj.pos.x.offset + obj.parent.absSize.x*obj.pos.x.scale)
                - (obj.posOrigin.x.offset + obj.absSize.x*obj.posOrigin.x.scale)
            ),
            math.floor(
                obj.parent.absPos.y + (obj.pos.y.offset + obj.parent.absSize.y*obj.pos.y.scale)
                - (obj.posOrigin.y.offset + obj.absSize.y*obj.posOrigin.y.scale)
            )
        )
    )
    or nil;
    
    if (absPos ~= obj.absPos) then
        obj.absPos = absPos;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_absPos(obj.guiChildren[i], true);
        end
    end
end


function func.update_containerPos(obj, descend)
    local containerPos = #obj.guiChildren > 0 and (
        func.isA(obj, "RootGui") and obj.absPos
        or func.isA(obj, "GuiObject") and obj.rootGui and obj.clipperGui.absPos
    )
    or nil;
    
    if (containerPos ~= obj.containerPos) then
        obj.containerPos = containerPos;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_containerPos(obj.guiChildren[i], true);
        end
    end
end

function func.update_containerSize(obj, descend)
    local containerSize = #obj.guiChildren > 0 and (
        func.isA(obj, "RootGui") and obj.absSize
        or func.isA(obj, "GuiObject") and obj.rootGui and obj.clipperGui.absSize
    )
    or nil;
    
    if (containerSize ~= obj.containerSize) then
        if (obj.container and isElement(obj.container)) then
            destroyElement(obj.container);
        end
        
        obj.containerSize = containerSize;
        obj.container = containerSize and dxCreateRenderTarget(containerSize.x, containerSize.y, true);
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_containerSize(obj.guiChildren[i], true);
            end
        end
    end
end


function func.update(obj, descend)
    if (obj.container) then
        if (descend) then
            for i = 1, #obj.guiChildren do
                local child = obj.guiChildren[i];
                
                child.class.func.update(child, true);
            end
        end
        
        
        dxSetRenderTarget(obj.container, true);
        
        dxSetBlendMode("add");
        
        if (obj.debug) then
            dxDrawRectangle(0, 0, obj.containerSize.x, obj.containerSize.y, tocolor(0, 255, 0, 127.5));
        end
        
        -- children
        for i = 1, #obj.guiChildren do
            local child = obj.children[i];
            
            if (child.visible) then
                if (func.isA(child, "GuiObject") and child.rt) then
                    if (child.isRotated) then
                        if (child.isRotated3D) then
                            dxSetShaderTransform(
                                GuiObject.SHADER,
                                
                                child.rot.y, child.rot.x, child.rot.z,
                                child.rtRotPivot.x, child.rtRotPivot.y, child.rtRotPivot.z, false,
                                child.rtRotPerspective.x, child.rtRotPerspective.y, false
                            );
                        else
                            dxSetShaderTransform(
                                GuiObject.SHADER,
                                
                                child.rot.y, child.rot.x, child.rot.z,
                                child.rtRotPivot.x, child.rtRotPivot.y, child.rtRotPivot.z, false,
                                0, 0, true -- if rotated 2D-ly do not change perspective to avoid unnecessary blurring
                            );
                        end
                        
                        dxSetShaderValue(GuiObject.SHADER, "image", child.rt);
                        
                        dxDrawImage(
                            child.rtPos.x-obj.containerPos.x, child.rtPos.y-obj.containerPos.y,
                            child.rtSize.x, child.rtSize.y,
                            
                            GuiObject.SHADER
                        );
                    else
                        dxDrawImage(
                            child.rtPos.x-obj.containerPos.x, child.rtPos.y-obj.containerPos.y,
                            child.rtSize.x, child.rtSize.y,
                            
                            child.rt
                        );
                    end
                end
                
                if (child.container) then
                    if (func.isA(child, "GuiObject") and child.isRotated) then
                        if (child.isRotated3D) then
                            dxSetShaderTransform(
                                GuiObject.SHADER,
                                
                                child.rot.y, child.rot.x, child.rot.z,
                                child.containerRotPivot.x, child.containerRotPivot.y, child.containerRotPivot.z, false,
                                child.containerRotPerspective.x, child.containerRotPerspective.y, false
                            );
                        else
                            dxSetShaderTransform(
                                GuiObject.SHADER,
                                
                                child.rot.y, child.rot.x, child.rot.z,
                                child.containerRotPivot.x, child.containerRotPivot.y, child.containerRotPivot.z, false,
                                0, 0, true -- if rotated 2D-ly do not change perspective to avoid unnecessary blurring
                            );
                        end
                        
                        dxSetShaderValue(GuiObject.SHADER, "image", child.container);
                        
                        dxDrawImage(
                            child.containerPos.x-obj.containerPos.x, child.containerPos.y-obj.containerPos.y,
                            child.containerSize.x, child.containerSize.y,
                            
                            GuiObject.SHADER
                        );
                    else
                        dxDrawImage(
                            child.containerPos.x-obj.containerPos.x, child.containerPos.y-obj.containerPos.y,
                            child.containerSize.x, child.containerSize.y,
                            
                            child.container
                        );
                    end
                end
            end
        end
        
        dxSetRenderTarget();
        
        dxSetBlendMode("blend");
    end
end


function func.propagate(obj)
    if (func.isA(obj, "RootGui")) then
        -- do nothing
    elseif (func.isA(obj, "GuiObject") and obj.rootGui) then
        obj.parent.class.func.update(obj.parent);
        
        obj.parent.class.func.propagate(obj.parent);
    end
end



function set.debug(obj, debug, prev, k)
    local debug_t = type(debug);
    
    if (debug_t ~= "boolean") then
        error("bad argument #1 to 'debug' (boolean expected, got " ..debug_t.. ")", 2);
    end
    
    
    obj.debug = debug;
    
    
    if (k == 1) then -- used because GuiObject has its own set.debug function
        func.update(obj);
        
        func.propagate(obj);
    end
end



GuiBase2D = inherit({
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    event = event,
    
    private  = private,
    readOnly = readOnly,
    
    SCREEN_WIDTH  = SCREEN_WIDTH,
    SCREEN_HEIGHT = SCREEN_HEIGHT,
    
    new = new,
}, super);






addEventHandler("onClientRestore", root, function(clearedRts)
    if (clearedRts) then
        print("RTs were cleared!");
    end
end);
