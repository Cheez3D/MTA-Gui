-- local Vector2 = require("Vector2");



local name = "ScreenGui";

local super = GuiBase2D;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get [key] end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set [key] end });

local private  = setmetatable({
        render = true,
    },
    
    { __index = function(tbl, key) return super.private [key] end }
);
local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });



local function new(obj)
    super.new(obj);
    
    obj.absSize = Vector2.new(SCREEN_WIDTH, SCREEN_HEIGHT);
    
    obj.absPos = Vector2.new(0, 0);
    
    obj.absRot      = Vector3.new(0, 0, 0);
    obj.absRotPivot = Vector2.new(0, 0);
    
    function obj.draw()
        dxSetBlendMode("add");
        
        dxSetRenderTarget(obj.rt, true);
        
        for i = 1, #obj.children do
            local child = obj.children[i];
            
            if Instance.func.isA(child, "GuiObject") and (child.rt) then
                if (child.isRotated) then
                    dxSetShaderTransform(
                        GuiObject.SHADER,
                        
                        child.rot.y, child.rot.x, child.rot.z,
                        
                        child.rtTransformPivot.x, child.rtTransformPivot.y, child.rtTransformPivot.z, false,
                        
                        child.isRotated3D and child.rtTransformPerspective.x or 0,
                        child.isRotated3D and child.rtTransformPerspective.y or 0,
                        not child.isRotated3D
                    );
                    
                    dxSetShaderValue(GuiObject.SHADER, "image", child.rt);
                end
                
                dxDrawImage(
                    child.rtAbsPos.x-obj.absPos.x, child.rtAbsPos.y-obj.absPos.y,
                        
                    child.rtAbsSize.x, child.rtAbsSize.y,
                    
                    child.isRotated and GuiObject.SHADER or child.rt
                );
                
                if Instance.func.isA(child, "GuiContainer") and (child.container) then
                    if (child.isRotated) then
                        dxSetShaderTransform(
                            GuiObject.SHADER,
                            
                            child.rot.y, child.rot.x, child.rot.z,
                            
                            2*(-child.containerGui.absSize.x/2 + child.absRotPivot.x-child.containerGui.absPos.x)/obj.absSize.x,
                            2*(-child.containerGui.absSize.y/2 + child.absRotPivot.y-child.containerGui.absPos.y)/obj.absSize.y,
                            2*(child.absRotPivot.z/GuiObject.ROT_PIVOT_DEPTH_UNIT),
                            false,
                            
                            child.isRotated3D and 2*(-child.containerGui.absSize.x/2 + child.absRotPerspective.x-child.containerGui.absPos.x)/obj.absSize.x or 0,
                            child.isRotated3D and 2*(-child.containerGui.absSize.y/2 + child.absRotPerspective.y-child.containerGui.absPos.y)/obj.absSize.y or 0,
                            not child.isRotated3D
                        );
                        
                        dxSetShaderValue(GuiObject.SHADER, "image", child.container);
                    end
                    
                    dxDrawImage(
                        child.containerGui.absPos.x-obj.absPos.x, child.containerGui.absPos.y-obj.absPos.y,
                        
                        child.containerGui.absSize.x, child.containerGui.absSize.y,
                        
                        child.isRotated and GuiObject.SHADER or child.container
                    );
                end
            end
        end
        
        dxSetRenderTarget();
        
        dxSetBlendMode("blend");
    end
    
    obj.rt = dxCreateRenderTarget(obj.absSize.x, obj.absSize.y, true); -- TODO: add check for successful creation (dxSetTestMode)
    
    
    
    function obj.render()
        dxSetBlendMode("modulate_add");
        
        dxDrawImage(obj.absPos.x, obj.absPos.y, obj.absSize.x, obj.absSize.y, obj.rt);
        
        dxSetBlendMode("blend");
    end
    
    addEventHandler("onClientPreRender", root, obj.render);
end



Instance.initializable.ScreenGui = {
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    private  = private,
    readOnly = readOnly,
    
    new = new,
}
