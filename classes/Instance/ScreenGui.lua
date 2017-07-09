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
        dxSetBlendMode("modulate_add");
        
		dxSetRenderTarget(obj.rt, true);
		
		for i = 1, #obj.children do
            local child = obj.children[i];
            
            if Instance.func.isA(child, "GuiObject") and (child.rt) then
                dxDrawImage(
                    child.clipperGui.absPos.x, child.clipperGui.absPos.y,
                        
                    child.clipperGui.absSize.x, child.clipperGui.absSize.y,
                    
                    child.rt
                );
            end
		end
		
		dxSetRenderTarget();
        
        dxSetBlendMode("blend");
	end
	
	obj.rt = dxCreateRenderTarget(obj.absSize.x, obj.absSize.y, true); -- TODO: add check for successful creation (dxSetTestMode)
	
    
    
	function obj.render()
		dxSetBlendMode("modulate_add");
		
		dxDrawImage(0, 0, obj.absSize.x, obj.absSize.y, obj.rt);
		
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
