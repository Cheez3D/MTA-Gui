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
	
    obj.size = PROXY__OBJ[UDim2.new(0, 100, 0, 100)];
    
	obj.pos  = PROXY__OBJ[UDim2.new(0, 0)];
	
	function obj.draw(propagate)
		if (obj.rootGui) then -- if drawable
            if (obj.visible) then -- TODO: fix visible param not working properly
                dxSetBlendMode("add");
                
                dxSetRenderTarget(obj.isRotated and obj.parent.rt or obj.rt, true);
                
                if (obj.debug) then
                    dxDrawRectangle(0, 0, obj.clipperGui.absSize.x, obj.clipperGui.absSize.y, tocolor(255, 0, 0, 200));
                end
                
                
                -- [ ===================== [ BORDER ] ===================== ]
                
                dxDrawRectangle(
                    (obj.isRotated and obj.rotDrawOffset.x or 0) + obj.absPos.x-obj.clipperGui.absPos.x - obj.borderSize,
                    (obj.isRotated and obj.rotDrawOffset.y or 0) + obj.absPos.y-obj.clipperGui.absPos.y - obj.borderSize,
                    
                    obj.absSize.x + 2*obj.borderSize,
                    obj.absSize.y + 2*obj.borderSize,
                    
                    tocolor(obj.borderColor3.r, obj.borderColor3.g, obj.borderColor3.b, 255*(1-obj.borderTransparency))
                );
                
                -- [ ===================== [ BACKGROUND ] ===================== ]
                
                dxSetBlendMode("overwrite");
                
                dxDrawRectangle(
                    (obj.isRotated and obj.rotDrawOffset.x or 0) + obj.absPos.x-obj.clipperGui.absPos.x,
                    (obj.isRotated and obj.rotDrawOffset.y or 0) + obj.absPos.y-obj.clipperGui.absPos.y,
                    
                    obj.absSize.x, obj.absSize.y,
                    
                    tocolor(obj.bgColor3.r, obj.bgColor3.g, obj.bgColor3.b, 255*(1-obj.bgTransparency))
                );
                
                -- [ ===================== [ CHILDREN ] ===================== ]
                
                dxSetBlendMode("add");
                
                for i = 1, #obj.children do
                    local child = obj.children[i];
                    
                    if Instance.func.isA(child, "GuiObject") then
                        dxDrawImage(
                            (obj.isRotated and obj.rotDrawOffset.x or 0) + child.clipperGui.absPos.x-obj.clipperGui.absPos.x,
                            (obj.isRotated and obj.rotDrawOffset.y or 0) + child.clipperGui.absPos.y-obj.clipperGui.absPos.y,
                            
                            child.clipperGui.absSize.x, child.clipperGui.absSize.y,
                            
                            child.rt
                        );
                    end
                end
                
                -- [ ===================== [ ROTATION ] ===================== ]
                
                if (obj.isRotated) then
                    
                    -- apply rotation through shader transform
                    dxSetShaderTransform(
                        GuiObject.SHADER,
                        
                        obj.rot.x, obj.rot.y, obj.rot.z,
                        
                        ((obj.absRotPivot.x-obj.clipperGui.absPos.x - obj.clipperGui.absSize.x/2)/obj.clipperGui.absSize.x)*2,
                        ((obj.absRotPivot.y-obj.clipperGui.absPos.y - obj.clipperGui.absSize.y/2)/obj.clipperGui.absSize.y)*2,
                        0,
                        
                        false,
                        
                        ((obj.absPos.x-obj.clipperGui.absPos.x + obj.absSize.x/2 - obj.clipperGui.absSize.x/2)/obj.clipperGui.absSize.x)*2,
                        ((obj.absPos.y-obj.clipperGui.absPos.y + obj.absSize.y/2 - obj.clipperGui.absSize.y/2)/obj.clipperGui.absSize.y)*2,
                        
                        false
                    );
                    
                    dxSetShaderValue(GuiObject.SHADER, "image", obj.parent.rt);
                    
                    dxSetRenderTarget(obj.rt, true); -- draw rotated result on object rt
                    
                    dxDrawImage(-obj.rotDrawOffset.x, -obj.rotDrawOffset.y, obj.rotDrawSize.x, obj.rotDrawSize.y, GuiObject.SHADER);
                end
                
                dxSetRenderTarget();
                
                dxSetBlendMode("blend");
            end
            
            if (propagate) then
                obj.parent.draw(true);
            end
		end
	end
    
    function obj.propagate()
        obj.draw();
        
        obj.parent.propagate();
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






scrGui = Instance.new("ScreenGui"); scrGui.name = "scrGui";

fr1 = Instance.new("Frame", scrGui); fr1.name = "fr1";

fr1.pos = UDim2.new(0.6, 0, 0.25, 0);
fr1.size = UDim2.new(0, 300, 0, 300)
fr1.borderSize = 5;

fr1.rotPivot = UDim2.new(1, 0, 1, 0);
-- fr1.posOrigin = UDim2.new(0.5, 0, 0.5, 0);

fr2 = Instance.new("Frame", fr1); fr2.name = "fr2";

fr2.pos = UDim2.new(0.5, -25, 0, 10);
fr2.bgColor3 = Color3.new(223, 196, 125);
fr2.borderColor3 = Color3.new(0, 0, 0);


fr3 = Instance.new("Frame", fr2); fr3.name = "fr3";
fr3.bgColor3 = Color3.new(0, 196, 0);
fr3.pos = UDim2.new(0.5, 0, 0.5, 0);

fr3.posOrigin = fr1.posOrigin;

fr2.size = UDim2.new(0, 124, 0, 124);



local srx = guiCreateScrollBar(400, 20,  200, 20, true, false);
local sry = guiCreateScrollBar(400, 40,  200, 20, true, false);
local srz = guiCreateScrollBar(400, 60,  200, 20, true, false);

local spx = guiCreateScrollBar(400, 100,  200, 20, true, false); guiScrollBarSetScrollPosition(spx, 50);
local spy = guiCreateScrollBar(400, 120,  200, 20, true, false); guiScrollBarSetScrollPosition(spy, 50);

local fr = fr2;

addEventHandler("onClientRender", root, function()
    fr.rotPivot = UDim2.new(guiScrollBarGetScrollPosition(spx)/100, 0, guiScrollBarGetScrollPosition(spy)/100, 0);
    
    dxDrawLine(
        SCREEN_WIDTH/2,
        SCREEN_HEIGHT/2,
        
        fr.absRotPivot.x,
        fr.absRotPivot.y,
        
        tocolor(255, 0, 0), 3
    );
    
    fr.rot = Vector3.new(guiScrollBarGetScrollPosition(srx)/100*360, guiScrollBarGetScrollPosition(sry)/100*360, guiScrollBarGetScrollPosition(srz)/100*360);
end);


-- local u = 360;
-- local v = 0;
-- addEventHandler("onClientRender", root, function()
    -- if (v < 720) and (u > 0) then
        -- fr2.rot = Vector3.new(-v, 0, 0);
        -- fr3.rot = Vector3.new(v, u, 0);
        
        -- fr1.rot = Vector3.new(0, 0, v);
        
        -- -- u = u-1;
        -- v = v+1;
    -- end
-- end);







-- local rt1 = dxCreateRenderTarget(400, 400, true);
-- local rt2 = dxCreateRenderTarget(800, 800, true);

-- dxSetRenderTarget()


-- [ ================= [ Masking test ] ================= ]

-- local shader = dxCreateShader("shaders/mask.fx");

-- local ico = decode_ico("decoders/ico/chrome-png.ico");
-- ico = ico[1];

-- local shd = dxCreateShader("shaders/nothing.fx");
-- dxSetShaderValue(shd, "image", ico.image);
-- dxSetShaderTransform(shd, 30, 30, -30);

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
