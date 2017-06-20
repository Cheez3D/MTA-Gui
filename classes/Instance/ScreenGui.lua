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
	
	obj.absPos  = PROXY__OBJ[Vector2.new(0, 0)];
	obj.absSize = PROXY__OBJ[Vector2.new(SCREEN_WIDTH, SCREEN_HEIGHT)];
	
	obj.rootGui = obj;
	
	function obj.draw()
        dxSetBlendMode("modulate_add");
        
		dxSetRenderTarget(obj.rt, true);
		
		for i = 1, #obj.children do
            local child = obj.children[i];
            
            if Instance.func.isA(child, "GuiObject") then
                dxDrawImage(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, child.shader);
            end
		end
		
		dxSetRenderTarget();
        
        dxSetBlendMode("blend");
	end
	
	obj.rt     = dxCreateRenderTarget(SCREEN_WIDTH, SCREEN_HEIGHT, true);
	obj.rtSize = PROXY__OBJ[Vector2.new(SCREEN_WIDTH, SCREEN_HEIGHT)];
	
    
    
	function obj.render()
		dxSetBlendMode("add");
		
		dxDrawImage(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, obj.rt);
		
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
