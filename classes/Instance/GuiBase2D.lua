local name = "GuiBase2D";

local class;
local super = classes.Instance;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local new, meta;



local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize();

local RT_SIZE_STEP = 25;

local DEBUG_CONTAINER_COLOR = tocolor(0, 255, 0, 127.5);

local DRAW_POST_GUI = false;



function new(class, meta)
    local success, obj = pcall(super.new, class, meta);
    if (not success) then error(obj, 2) end
    
    obj.guiChildren = {}
    
    set.debug(obj, false);
    
    return obj;
end

meta = extend({}, super.meta);



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
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_absSize(obj.guiChildren[i], true);
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
        obj.containerSize = containerSize;
        
        local containerActualSize = containerSize and (
            func.isA(obj, "RootGui") and containerSize
            or func.isA(obj, "GuiObject") and Vector2.new(
                math.ceil(containerSize.x/RT_SIZE_STEP)*RT_SIZE_STEP,
                math.ceil(containerSize.y/RT_SIZE_STEP)*RT_SIZE_STEP
            )
        )
        or nil;
        
        if (containerActualSize ~= obj.containerActualSize) then
            obj.containerActualSize = containerActualSize;
            
            
            if (obj.container and isElement(obj.container)) then
                destroyElement(obj.container);
            end
            
            obj.container = containerActualSize and dxCreateRenderTarget(containerActualSize.x, containerActualSize.y, true);
        end
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_containerSize(obj.guiChildren[i], true);
        end
    end
end


function func.update(obj, descend)
    if (obj.container) then
        if (descend) then
            for i = 1, #obj.guiChildren do
                local child = obj.guiChildren[i];
                
                child.class.func.update(child, true); -- TODO: investigate if class is necessary
            end
        end
        
        
        dxSetRenderTarget(obj.container, true);
        
        dxSetBlendMode("add");
        
        if (obj.debug) then
            dxDrawRectangle(0, 0, obj.containerSize.x, obj.containerSize.y, DEBUG_CONTAINER_COLOR);
        end
        
        -- children
        for i = 1, #obj.guiChildren do
            local child = obj.guiChildren[i];
            
            if (child.visible) then
                if (func.isA(child, "GuiObject") and child.canvas) then
                    if (child.isRotated) then
                        if (child.isRotated3D) then
                            dxSetShaderTransform(
                                GuiObject.SHADER,
                                
                                child.rot.y, child.rot.x, child.rot.z,
                                child.canvasRotPivot.x, child.canvasRotPivot.y, child.canvasRotPivot.z, false,
                                child.canvasRotPerspective.x, child.canvasRotPerspective.y, false
                            );
                        else
                            dxSetShaderTransform(
                                GuiObject.SHADER,
                                
                                child.rot.y, child.rot.x, child.rot.z,
                                child.canvasRotPivot.x, child.canvasRotPivot.y, child.canvasRotPivot.z, false,
                                0, 0, true -- if rotated 2D-ly do not change perspective to avoid unnecessary blurring
                            );
                        end
                        
                        dxSetShaderValue(GuiObject.SHADER, "image", child.canvas);
                    end
                    
                    dxDrawImage(
                        child.canvasPos.x-obj.containerPos.x, child.canvasPos.y-obj.containerPos.y,
                        child.canvasActualSize.x, child.canvasActualSize.y,
                        
                        child.isRotated and GuiObject.SHADER or child.canvas
                    );
                end
                
                if (child.container) then
                    if (func.isA(child, "GuiObject")) then
                        if (child.isRotated) then
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
                        end
                    
                        dxDrawImageSection(
                            child.containerPos.x-obj.containerPos.x, child.containerPos.y-obj.containerPos.y,
                            child.containerSize.x, child.containerSize.y,
                            
                            0, 0, child.containerSize.x, child.containerSize.y,
                            
                            child.isRotated and GuiObject.SHADER or child.container
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



function set.debug(obj, debug, prev)
    local debug_t = type(debug);
    
    if (debug_t ~= "boolean") then
        error("bad argument #1 to 'debug' (boolean expected, got " ..debug_t.. ")", 2);
    end
    
    
    obj.debug = debug;
    
    
    func.update(obj);
    
    func.propagate(obj);
end



class = {
    name = name,
    
    super = super,
    
    func = func, get = get, set = set,
    
    new = new, meta = meta,
    
    
    SCREEN_WIDTH, SCREEN_HEIGHT = SCREEN_WIDTH, SCREEN_HEIGHT,
    
    RT_SIZE_STEP = RT_SIZE_STEP,
    
    DRAW_POST_GUI = DRAW_POST_GUI,
}

_G[name] = class;



addEventHandler("onClientRestore", root, function(clearedRts)
    if (clearedRts) then
        print("RTs were cleared!");
    end
end);
