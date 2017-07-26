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



function func.draw(obj) -- TODO: move update from GuiBase2D to GuiObject, move container;
    -- if (obj.container) then
        -- dxDrawImage(obj.containerPos.x, obj.containerPos.y, obj.containerSizeStep.x, obj.containerSizeStep.y, obj.container);
    -- end
    
    if (obj.debug) then
        dxDrawRectangle(0, 0, math.floor(obj.containerSizeStep.x), math.floor(obj.containerSizeStep.y), tocolor(0, 255, 0, 127.5));
    end
    
    -- children
    for i = 1, #obj.guiChildren do
        local child = obj.guiChildren[i];
        
        if (child.visible) then
            if (child.canvas) then
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
                    
                    dxDrawImage(
                        math.floor(child.canvasPos.x-obj.containerPos.x),
                        math.floor(child.canvasPos.y-obj.containerPos.y),
                        
                        math.floor(child.canvasSizeStep.x),
                        math.floor(child.canvasSizeStep.y),
                        
                        GuiObject.SHADER
                    );
                else
                    dxDrawImage(
                        math.floor(child.canvasPos.x-obj.containerPos.x),
                        math.floor(child.canvasPos.y-obj.containerPos.y),
                        
                        math.floor(child.canvasSizeStep.x),
                        math.floor(child.canvasSizeStep.y),
                        
                        child.canvas
                    );
                end
            end
            
            if (child.container) then
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
                    
                    dxDrawImage(
                        math.floor(child.containerPos.x-obj.containerPos.x),
                        math.floor(child.containerPos.y-obj.containerPos.y),
                        
                        math.floor(child.containerSizeStep.x),
                        math.floor(child.containerSizeStep.y),
                        
                        GuiObject.SHADER
                    );
                else
                    dxDrawImage(
                        math.floor(child.containerPos.x-obj.containerPos.x),
                        math.floor(child.containerPos.y-obj.containerPos.y),
                        
                        math.floor(child.containerSizeStep.x),
                        math.floor(child.containerSizeStep.y),
                        
                        child.container
                    );
                end
            end
        end
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
