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
					
                    if Instance.func.isA(child, "GuiObject") then
                        dxDrawImageSection(
                            absX, absY, absWidth, absHeight,
                            absX, absY, absWidth, absHeight,
                            
                            child.shader
                        );
                    end
				end
			else
				for i = 1, #obj.children do
					local child = obj.children[i];
                    
                    if Instance.func.isA(child, "GuiObject") then
                        dxDrawImage(0, 0, child.rtSize.x, child.rtSize.y, child.shader);
                    end
				end
			end
			
			dxSetRenderTarget();
            
            dxSetBlendMode("blend");
            
            
            dxSetShaderValue(obj.shader, "image", obj.rt); -- dxSetShaderTransform(obj.shader, 0, 0, 30);
		end
		
        local parent = obj.parent;
        
        if (parent) and Instance.func.isA(parent, "GuiBase2D") then
            parent.draw();
        end
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

fr1.rot = Vector3.new(0, 0, 45);

fr1.clipsDescendants = true;

fr2 = Instance.new("Frame", fr1);
fr2.name = "fr2";
fr2.pos = UDim2.new(0, -50, 0, -50);
fr2.bgColor3 = Color3.new(223, 196, 125);
fr2.borderColor3 = Color3.new();
fr2.borderSize = 40;
fr2.borderOffset = 0;
fr2.rot = Vector3.new(0, 0, -30);

print(fr1.absRot);
print(fr2.absRot);



-- local v = 0;
-- addEventHandler("onClientRender", root, function()
    -- if (v < 300) then
        -- fr1.pos = UDim2.new(0, v, 0, v);
        
        -- v = v+0.5;
    -- end
-- end);





-- [ ================= [ Masking test ] ================= ]

-- local shader = dxCreateShader("shaders/mask.fx");

-- local ico = decode_ico("decoders/ico/chrome-png.ico");
-- ico = ico[1];

-- local shd = dxCreateShader("shaders/nothing.fx");
-- dxSetShaderValue(shd, "image", ico.image);
-- dxSetShaderTransform(shd, 0, 0, -30);

-- local rt1 = dxCreateRenderTarget(256, 256, true);
-- dxSetRenderTarget(rt1);
-- dxDrawImage(0, 0, 256, 256, shd);
-- dxSetRenderTarget();

-- dxSetShaderValue(shader, "image", rt1);

-- local rt = dxCreateRenderTarget(256, 256, true);

-- dxSetRenderTarget(rt);
-- dxDrawRectangle(0, 0, 128, 128);
-- dxSetRenderTarget();

-- dxSetShaderValue(shader, "mask", rt);

-- addEventHandler("onClientRender", root, function()
    -- dxDrawImage(400, 400, 256, 256, shader);
-- end);

-- [ ================= [ 3D Rotation test ] ================= ]

-- local s1 = guiCreateScrollBar(400, 20,  200, 20, true, false);
-- local s2 = guiCreateScrollBar(400, 40,  200, 20, true, false);
-- local s3 = guiCreateScrollBar(400, 60,  200, 20, true, false);
-- local s4 = guiCreateScrollBar(400, 80,  200, 20, true, false);
-- local s5 = guiCreateScrollBar(400, 100, 200, 20, true, false);
-- local s6 = guiCreateScrollBar(400, 120, 200, 20, true, false);

-- -- local s7 = guiCreateScrollBar(400, 160, 200, 20, true, false);
-- -- local s8 = guiCreateScrollBar(400, 180, 200, 20, true, false);

-- guiScrollBarSetScrollPosition(s4, 50);
-- guiScrollBarSetScrollPosition(s5, 50);
-- guiScrollBarSetScrollPosition(s6, 50);

-- -- guiScrollBarSetScrollPosition(s7, 50);
-- -- guiScrollBarSetScrollPosition(s8, 50);

-- local ico = decode_ico("decoders/ico/chrome-png.ico");
-- ico = ico[1];

-- local shader = dxCreateShader("shaders/nothing.fx");
-- dxSetShaderValue(shader, "image", ico.image);

-- addEventHandler("onClientRender", root, function()
    -- dxSetShaderTransform(
        -- shader,
        
        -- guiScrollBarGetScrollPosition(s1)/100*360,
        -- guiScrollBarGetScrollPosition(s2)/100*360,
        -- guiScrollBarGetScrollPosition(s3)/100*360,
        
        -- ((guiScrollBarGetScrollPosition(s4)/100-0.5)*2*ico.width)/SCREEN_WIDTH,
        -- ((guiScrollBarGetScrollPosition(s5)/100-0.5)*2*ico.height)/SCREEN_HEIGHT,
        -- ((guiScrollBarGetScrollPosition(s6)/100-0.5)*2) --,
        
        -- -- true,
        
        -- -- (guiScrollBarGetScrollPosition(s7)/100-0.5)*2,
        -- -- (guiScrollBarGetScrollPosition(s8)/100-0.5)*2
    -- );
    
    -- dxDrawImage(400, 400, ico.width, ico.height, shader);
    
    -- dxDrawLine(
        -- SCREEN_WIDTH/2,
        -- SCREEN_HEIGHT/2,
        
        -- 400+guiScrollBarGetScrollPosition(s4)/100*ico.width,
        -- 400+guiScrollBarGetScrollPosition(s5)/100*ico.height,
        
        -- tocolor(0, 255, 0)
    -- );
    
    -- print("offX", ((guiScrollBarGetScrollPosition(s4)/100-0.5)*2*ico.width)/SCREEN_WIDTH);
    -- print("offY", ((guiScrollBarGetScrollPosition(s5)/100-0.5)*2*ico.height)/SCREEN_HEIGHT);
    -- print("offZ", ((guiScrollBarGetScrollPosition(s6)/100-0.5)*2));
    -- print("\n");
    
    -- -- dxDrawLine(
        -- -- SCREEN_WIDTH/2,
        -- -- SCREEN_HEIGHT/2,
        
        -- -- 400+guiScrollBarGetScrollPosition(s7)/100*ico.width,
        -- -- 400+guiScrollBarGetScrollPosition(s8)/100*ico.height,
        
        -- -- tocolor(0, 0, 255)
    -- -- );
-- end);
