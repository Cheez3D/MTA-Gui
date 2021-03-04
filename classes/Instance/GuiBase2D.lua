local classes = classes;

local super = classes.Instance;

local class = inherit({
    name = "GuiBase2D",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = false,
}, super);

classes[class.name] = class;



class.SCREEN_WIDTH, class.SCREEN_HEIGHT = guiGetScreenSize();

class.RT_SIZE_STEP = 25;

class.DEBUG_CONTAINER_COLOR = tocolor(0, 255, 0, 127.5);

class.DRAW_POST_GUI = false;



function class.new(...)
    local success, obj = pcall(super.new, ...);
    if (not success) then error(obj, 2) end
    
    obj.guiChildren = {}
    
    class.set.debug(obj, false);
    
    return obj;
end

class.meta = super.meta;



function class.func.update_absSize(obj, descend)
    local absSize = (
        obj:isA("RootGui") and (
            obj:isA("ScreenGui") and classes.Vector2.new(class.SCREEN_WIDTH, class.SCREEN_HEIGHT)
            or classes.Vector2.new()
        )
        or obj:isA("GuiObject") and obj.rootGui and classes.Vector2.new(
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
            local child = obj.guiChildren[i];
            child:update_absSize(true);
        end
    end
end

function class.func.update_absPos(obj, descend)
    local absPos = (
        obj:isA("RootGui") and (
            obj:isA("ScreenGui") and classes.Vector2.new()
            or classes.Vector2.new()
        )
        or obj:isA("GuiObject") and obj.rootGui and classes.Vector2.new(
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
            local child = obj.guiChildren[i];
            child:update_absPos(true);
        end
    end
end


function class.func.update_containerSize(obj, descend)
    local containerSize = (#obj.guiChildren > 0) and (
        obj:isA("RootGui") and obj.absSize
        or obj:isA("GuiObject") and obj.rootGui and obj.clipperGui.absSize
    )
    or nil;
    
    if (containerSize ~= obj.containerSize) then
        obj.containerSize = containerSize;
        
        local containerActualSize = containerSize and (
            obj:isA("RootGui") and containerSize
            or obj:isA("GuiObject") and classes.Vector2.new(
                math.ceil(containerSize.x/class.RT_SIZE_STEP)*class.RT_SIZE_STEP,
                math.ceil(containerSize.y/class.RT_SIZE_STEP)*class.RT_SIZE_STEP
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
            local child = obj.guiChildren[i];
            child:update_containerSize(true);
        end
    end
end

function class.func.update_containerPos(obj, descend)
    local containerPos = (#obj.guiChildren > 0) and (
        obj:isA("RootGui") and obj.absPos
        or obj:isA("GuiObject") and obj.rootGui and obj.clipperGui.absPos
    )
    or nil;
    
    if (containerPos ~= obj.containerPos) then
        obj.containerPos = containerPos;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            local child = obj.guiChildren[i];
            child:update_containerPos(true);
        end
    end
end


function class.func.update(obj, descend)
    if (obj.container) then
        if (descend) then
            for i = 1, #obj.guiChildren do
                local child = obj.guiChildren[i];
                child:update(true);
            end
        end
        
        
        dxSetRenderTarget(obj.container, true);
        
        dxSetBlendMode("add");
        
        if (obj.debug) then
            dxDrawRectangle(0, 0, obj.containerSize.x, obj.containerSize.y, class.DEBUG_CONTAINER_COLOR);
        end
        
        -- children
        for i = 1, #obj.guiChildren do
            local child = obj.guiChildren[i];
            
            if (child.visible) then
                if (child:isA("GuiObject") and child.canvas) then
                    if (child.isRotated) then
                        if (child.isRotated3D) then
                            dxSetShaderTransform(
                                child.class.SHADER,
                                
                                child.rot.y, child.rot.x, child.rot.z,
                                child.canvasRotPivot.x, child.canvasRotPivot.y, child.canvasRotPivot.z, false,
                                child.canvasRotPerspective.x, child.canvasRotPerspective.y, false
                            );
                        else
                            dxSetShaderTransform(
                                child.class.SHADER,
                                
                                child.rot.y, child.rot.x, child.rot.z,
                                child.canvasRotPivot.x, child.canvasRotPivot.y, child.canvasRotPivot.z, false,
                                0, 0, true -- if rotated 2D-ly do not change perspective to avoid unnecessary blurring
                            );
                        end
                        
                        dxSetShaderValue(child.class.SHADER, "image", child.canvas);
                    end
                    
                    dxDrawImage(
                        child.canvasPos.x-obj.containerPos.x, child.canvasPos.y-obj.containerPos.y,
                        child.canvasActualSize.x, child.canvasActualSize.y,
                        
                        child.isRotated and child.class.SHADER or child.canvas
                    );
                end
                
                if (child.container) then
                    if (child:isA("GuiObject")) then
                        if (child.isRotated) then
                            if (child.isRotated3D) then
                                dxSetShaderTransform(
                                    child.class.SHADER,
                                    
                                    child.rot.y, child.rot.x, child.rot.z,
                                    child.containerRotPivot.x, child.containerRotPivot.y, child.containerRotPivot.z, false,
                                    child.containerRotPerspective.x, child.containerRotPerspective.y, false
                                );
                            else
                                dxSetShaderTransform(
                                    child.class.SHADER,
                                    
                                    child.rot.y, child.rot.x, child.rot.z,
                                    child.containerRotPivot.x, child.containerRotPivot.y, child.containerRotPivot.z, false,
                                    0, 0, true -- if rotated 2D-ly do not change perspective to avoid unnecessary blurring
                                );
                            end
                            
                            dxSetShaderValue(child.class.SHADER, "image", child.container);
                        end
                    
                        dxDrawImageSection(
                            child.containerPos.x-obj.containerPos.x, child.containerPos.y-obj.containerPos.y,
                            child.containerSize.x, child.containerSize.y,
                            
                            0, 0, child.containerSize.x, child.containerSize.y,
                            
                            child.isRotated and child.class.SHADER or child.container
                        );
                    end
                end
            end
        end
        
        dxSetRenderTarget();
        
        dxSetBlendMode("blend");
    end
end


function class.func.propagate(obj)
    if (obj:isA("RootGui")) then
        -- do nothing
    elseif (obj:isA("GuiObject") and obj.rootGui) then
        local parent = obj.parent;
        
        parent:update();
        
        parent:propagate();
    end
end



function class.set.debug(obj, debug, prev)
    local debug_t = type(debug);
    
    if (debug_t ~= "boolean") then
        error("bad argument #1 to 'debug' (boolean expected, got " ..debug_t.. ")", 2);
    end
    
    
    obj.debug = debug;
    
    
    obj:update();
    
    obj:propagate();
end






addEventHandler("onClientRestore", root, function(clearedRts)
    if (clearedRts) then
        print("RTs were cleared!");
    end
end);
