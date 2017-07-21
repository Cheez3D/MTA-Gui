local name = "ScreenGui";

local super = RootGui;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get[key]  end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set[key]  end });

local event = setmetatable({}, { __index = function(tbl, key) return super.event[key] end });

local private  = setmetatable({}, { __index = function(tbl, key) return super.private[key]  end });
local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });



local function new(obj)
    super.new(obj);
    
    
    function obj.drawContainer_wrapper()
        func.drawContainer(obj);
    end
    
    addEventHandler("onClientPreRender", root, obj.drawContainer_wrapper);
end



function func.draw(obj, descend)
    local success, result = pcall(super.func.draw, obj, descend);
    if (not success) then error(result, 2) end
    
    
    dxSetBlendMode("add");
    
    dxSetRenderTarget(obj.container);
    
    for i = 1, #obj.guiChildren do
        local child = obj.guiChildren[i];
        
        if (child.rt) then
            if (child.isRotated) then
                dxSetShaderTransform(
                    GuiObject.SHADER,
                    
                    child.rot.y, child.rot.x, child.rot.z,
                    
                    child.rtRotPivot.x, child.rtRotPivot.y, child.rtRotPivot.z, false,
                    
                    child.isRotated3D and child.rtRotPerspective.x or 0,
                    child.isRotated3D and child.rtRotPerspective.y or 0,
                    not child.isRotated3D
                );
                
                dxSetShaderValue(GuiObject.SHADER, "image", child.rt);
            end
            
            dxDrawImage(
                child.rtPos.x-obj.containerPos.x, child.rtPos.y-obj.containerPos.y,
                    
                child.rtSize.x, child.rtSize.y,
                
                child.isRotated and GuiObject.SHADER or child.rt
            );
        end
        
        if (child.container) then
            if (child.isRotated) then
                dxSetShaderTransform(
                    GuiObject.SHADER,
                    
                    child.rot.y, child.rot.x, child.rot.z,
                    
                    child.containerRotPivot.x, child.containerRotPivot.y, child.containerRotPivot.z, false,
                    
                    child.isRotated3D and child.containerRotPerspective.x or 0,
                    child.isRotated3D and child.containerRotPerspective.y or 0,
                    not child.isRotated3D
                );
                
                dxSetShaderValue(GuiObject.SHADER, "image", child.container);
            end
            
            dxDrawImage(
                child.containerPos.x-obj.containerPos.x, child.containerPos.y-obj.containerPos.y,
                
                child.containerSize.x, child.containerSize.y,
                
                child.isRotated and GuiObject.SHADER or child.container
            );
        end
    end
    
    dxSetRenderTarget();
    
    dxSetBlendMode("blend");
end

function func.drawContainer(obj)
    if (obj.container) then
        dxDrawImage(obj.containerPos.x, obj.containerPos.y, obj.containerSize.x, obj.containerSize.y, obj.container);
    end
end



Instance.initializable.ScreenGui = {
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
