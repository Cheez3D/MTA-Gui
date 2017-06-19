-- local Vector2 = require("Vector2");
-- local UDim2   = require("UDim2");



local name = "Frame";

local super = GuiObject;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get [key] end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set [key] end });

local private  = setmetatable({}, { __index = function(tbl, key) return super.private [key] end });
local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });


-- TODO: 2D rotation mouse collision detection
-- https://www.siggraph.org/education/materials/HyperGraph/modeling/mod_tran/2drota.htm

local function new(obj)
	super.new(obj);
	
	obj.absPos  = PROXY__OBJ[Vector2.new()];
	obj.absSize = PROXY__OBJ[Vector2.new(100, 100)];
	
	obj.pos  = PROXY__OBJ[UDim2.new()];
	obj.size = PROXY__OBJ[UDim2.new(0, 100, 0, 100)];
	
    
    
	function obj.draw()
		if (obj.visible) then
            dxSetBlendMode("modulate_add");
            
			dxSetRenderTarget(obj.rt, true);
            
            local absX,     absY      = Vector2.func.unpack(obj.absPos);
            local absWidth, absHeight = Vector2.func.unpack(obj.absSize);
			
			local borderOffset = obj.borderOffset;
			local borderSize   = obj.borderSize;
			
			-- draw border
			dxDrawRectangle(
				absX-borderOffset,
                absY-borderOffset,
                
				absWidth  + 2*borderOffset,
                absHeight + 2*borderOffset,
                
				tocolor(obj.borderColor3.r, obj.borderColor3.g, obj.borderColor3.b, 255*(1-obj.borderTransparency))
			);
			
			-- draw background
			dxSetBlendMode("overwrite");
            
			dxDrawRectangle(
				absX+(borderSize-borderOffset),
                absY+(borderSize-borderOffset),
                
				absWidth -2*borderSize+2*borderOffset,
                absHeight-2*borderSize+2*borderOffset,
                
				tocolor(obj.bgColor3.r, obj.bgColor3.g, obj.bgColor3.b, 255*(1-obj.bgTransparency))
			);
            
            -- draw children
			dxSetBlendMode("modulate_add");
			
			if (obj.clipsDescendants) then
				for i = 1, #obj.children do
					local child = obj.children[i];
					
					dxDrawImageSection(
						absX, absY, absWidth, absHeight,
						absX, absY, absWidth, absHeight,
                        
						child.rt
					);
				end
			else
				for i = 1, #obj.children do
					local child = obj.children[i];
                    
					dxDrawImage(0, 0, child.rtSize.x, child.rtSize.y, child.rt);
				end
			end
			
			dxSetRenderTarget();
            
            dxSetBlendMode("blend");
		end
		
		obj.parent.draw();
	end
end



Instance.initializable.Frame = {
	name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    private  = private,
    readOnly = readOnly,
	
	new = new,
}






local scrGui = Instance.new("ScreenGui");

local fr1 = Instance.new("Frame", scrGui);
fr1.pos = UDim2.new(0.5, -50, 0.5, -50);


fr2 = Instance.new("Frame", fr1);
fr2.name = "fr2";
fr2.pos = UDim2.new(0, -50, 0, -50);
fr2.bgColor3 = Color3.new(223, 196, 125);
fr2.borderColor3 = Color3.new();
fr2.borderSize = 40;
fr2.borderOffset = 0;


-- local v = 0;
-- addEventHandler("onClientRender", root, function()
    -- if (v < 300) then
        -- fr1.pos = UDim2.new(0, v, 0, v);
        
        -- v = v+0.5;
    -- end
-- end);
