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
	
    obj.size = UDim2.new(0, 100, 0, 100);
    
	obj.pos  = UDim2.new(0, 0);
	
	function obj.draw(propagate)
		if (obj.rootGui) then
            if (obj.rt) then
                dxSetBlendMode("modulate_add");
                
                if (obj.isRotated) then
                    dxSetRenderTarget(obj.rootGui.rt, true);
                    
                    if (obj.debug) then
                        dxDrawRectangle(obj.rotRtOffset.x, obj.rotRtOffset.y, obj.clipperGui.absSize.x, obj.clipperGui.absSize.y, tocolor(255, 0, 0, 127.5));
                    end
                    
                    -- border
                    dxDrawRectangle(
                        obj.rotRtOffset.x + obj.absPos.x-obj.clipperGui.absPos.x - obj.borderSize,
                        obj.rotRtOffset.y + obj.absPos.y-obj.clipperGui.absPos.y - obj.borderSize,
                        
                        obj.absSize.x + 2*obj.borderSize,
                        obj.absSize.y + 2*obj.borderSize,
                        
                        tocolor(obj.borderColor3.r, obj.borderColor3.g, obj.borderColor3.b, 255*(1-obj.borderTransparency))
                    );
                    
                    -- background
                    dxSetBlendMode("overwrite");
                    
                    dxDrawRectangle(
                        obj.rotRtOffset.x + obj.absPos.x-obj.clipperGui.absPos.x,
                        obj.rotRtOffset.y + obj.absPos.y-obj.clipperGui.absPos.y,
                        
                        obj.absSize.x, obj.absSize.y,
                        
                        tocolor(obj.bgColor3.r, obj.bgColor3.g, obj.bgColor3.b, 255*(1-obj.bgTransparency))
                    );
                    
                    -- children
                    dxSetBlendMode("modulate_add");
                    
                    for i = 1, #obj.children do
                        local child = obj.children[i];
                        
                        if Instance.func.isA(child, "GuiObject") and (child.rt) then
                            dxDrawImage(
                                obj.rotRtOffset.x + child.clipperGui.absPos.x-obj.clipperGui.absPos.x,
                                obj.rotRtOffset.y + child.clipperGui.absPos.y-obj.clipperGui.absPos.y,
                                
                                child.clipperGui.absSize.x, child.clipperGui.absSize.y,
                                
                                child.rt
                            );
                        end
                    end
                    
                    -- rotation
                    dxSetRenderTarget(obj.rt, true);
                    
                    if (obj.isRotated3D) then
                        dxSetShaderTransform(
                            GuiObject.SHADER,
                            
                            obj.rot.y, obj.rot.x, obj.rot.z,
                            
                            obj.rotTransformPivot.x, obj.rotTransformPivot.y, obj.rotTransformPivot.z, false,
                            
                            obj.rotTransformPerspective.x, obj.rotTransformPerspective.y, false
                        );
                    else
                        dxSetShaderTransform(
                            GuiObject.SHADER,
                            
                            obj.rot.y, obj.rot.x, obj.rot.z,
                            
                            obj.rotTransformPivot.x, obj.rotTransformPivot.y, obj.rotTransformPivot.z, false
                            
                            -- if object is not rotated 3d (i.e. rotation on x and y flips the object or object is only rotated on z axis)
                            -- then do not use rotTransformPerspective to avoid blurring
                        );
                    end
                    
                    dxSetShaderValue(GuiObject.SHADER, "image", obj.rootGui.rt);
                    
                    dxDrawImage(-obj.rotRtOffset.x, -obj.rotRtOffset.y, obj.rootGui.absSize.x, obj.rootGui.absSize.y, GuiObject.SHADER);
                else
                    dxSetRenderTarget(obj.rt, true);
                    
                    if (obj.debug) then
                        dxDrawRectangle(0, 0, obj.clipperGui.absSize.x, obj.clipperGui.absSize.y, tocolor(255, 0, 0, 127.5));
                    end
                    
                    -- border
                    dxDrawRectangle(
                        obj.absPos.x-obj.clipperGui.absPos.x - obj.borderSize,
                        obj.absPos.y-obj.clipperGui.absPos.y - obj.borderSize,
                        
                        obj.absSize.x + 2*obj.borderSize,
                        obj.absSize.y + 2*obj.borderSize,
                        
                        tocolor(obj.borderColor3.r, obj.borderColor3.g, obj.borderColor3.b, 255*(1-obj.borderTransparency))
                    );
                    
                    -- background
                    dxSetBlendMode("overwrite");
                    
                    dxDrawRectangle(
                        obj.absPos.x-obj.clipperGui.absPos.x,
                        obj.absPos.y-obj.clipperGui.absPos.y,
                        
                        obj.absSize.x, obj.absSize.y,
                        
                        tocolor(obj.bgColor3.r, obj.bgColor3.g, obj.bgColor3.b, 255*(1-obj.bgTransparency))
                    );
                    
                    -- children
                    dxSetBlendMode("modulate_add");
                    
                    for i = 1, #obj.children do
                        local child = obj.children[i];
                        
                        if Instance.func.isA(child, "GuiObject") and (child.rt) then
                            dxDrawImage(
                                child.clipperGui.absPos.x-obj.clipperGui.absPos.x,
                                child.clipperGui.absPos.y-obj.clipperGui.absPos.y,
                                
                                child.clipperGui.absSize.x, child.clipperGui.absSize.y,
                                
                                child.rt
                            );
                        end
                    end
                end
                
                dxSetRenderTarget();
                
                dxSetBlendMode("blend");
            end
            
            if (propagate) then
                obj.parent.draw(true);
            end
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






scrGui = Instance.new("ScreenGui"); scrGui.name = "scrGui";

fr1 = Instance.new("Frame", scrGui); fr1.name = "fr1";

fr1.pos = UDim2.new(0.5, 0, 0.5, 0);
fr1.size = UDim2.new(0, 300, 0, 300);
fr1.borderSize = 5;

fr2 = Instance.new("Frame", fr1); fr2.name = "fr2";

fr2.pos = UDim2.new(0.5, 0, 0, 10);
fr2.bgColor3 = Color3.new(223, 196, 125);
fr2.borderColor3 = Color3.new(0, 0, 0);


fr3 = Instance.new("Frame", fr2); fr3.name = "fr3";
fr3.bgColor3 = Color3.new(0, 196, 0);
fr3.pos = UDim2.new(0.5, 0, 0.5, 0);



local srx = guiCreateScrollBar(400, 20,  200, 20, true, false);
local sry = guiCreateScrollBar(400, 40,  200, 20, true, false);
local srz = guiCreateScrollBar(400, 60,  200, 20, true, false);

local spx = guiCreateScrollBar(400, 100,  200, 20, true, false); guiScrollBarSetScrollPosition(spx, 50);
local spy = guiCreateScrollBar(400, 120,  200, 20, true, false); guiScrollBarSetScrollPosition(spy, 50);
local spz = guiCreateScrollBar(400, 140,  200, 20, true, false); guiScrollBarSetScrollPosition(spz, 10);

local fr = fr2;

local x, y, z = fr.absPos.x, fr.absPos.y, 0;

local v1 = Vector3.new(fr.absPos.x, fr.absPos.y, 0);

addEventHandler("onClientRender", root, function()
    fr.rotPivot = UDim2.new(guiScrollBarGetScrollPosition(spx)/100, 0, guiScrollBarGetScrollPosition(spy)/100, 0);
    
    fr.rotPivotDepth = (guiScrollBarGetScrollPosition(spz)/100)*10000-1000;
    
    dxDrawLine(
        SCREEN_WIDTH/2,
        SCREEN_HEIGHT/2,
        
        fr.absRotPivot.x,
        fr.absRotPivot.y,
        
        tocolor(255, 0, 0), 3
    );
    
    fr.rot = Vector3.new(guiScrollBarGetScrollPosition(srx)/100*360, guiScrollBarGetScrollPosition(sry)/100*360, guiScrollBarGetScrollPosition(srz)/100*360);
    
    
    local ang = guiScrollBarGetScrollPosition(srx)/100*2*math.pi;
    
    local s = math.sin(ang);
    local c = math.cos(ang);
    
    -- local offset = Vector3.new(fr.absRotPivot.x, fr.absRotPivot.y --[[, fr.absRotPivotDepth]]);
    
    -- local v1_1 = Vector3.new(
        -- v1.x-fr.absRotPivot.x,
        -- v1.y-fr.absRotPivot.y,
        -- v1.z--[[-fr.absRotPivotDepth]]
    -- );
    
    -- local v1_2 = Vector3.new(
        -- v1_1.x,
        -- v1_1.y*c-v1_1.z*s,
        -- v1_1.y*s+v1_1.z*c
    -- );
    
    -- local v1_3 = Vector3.new(
        -- v1_2.x+fr.absRotPivot.x,
        -- v1_2.y+fr.absRotPivot.y,
        -- v1_2.z--[[+fr.absRotPivotDepth]]
    -- );
    
    local cx = fr.absPos.x+fr.absSize.x/2;
    local cy = fr.absPos.y+fr.absSize.y/2;
    
    -- dxDrawLine(
        -- fr.absRotPivot.x,
        -- fr.absRotPivot.y,
        
        -- cx+(1000/(v1_3.z+1000))*(v1_3.x-cx),
        -- cy+(1000/(v1_3.z+1000))*(v1_3.y-cy),
        
        -- tocolor(0, 255, 0), 3
    -- );
    
    -- print(fr.rot);
end);

-- REFERENCES:
-- http://www.scratchapixel.com/lessons/mathematics-physics-for-computer-graphics/geometry/how-does-matrix-work-part-1
-- https://www.siggraph.org/education/materials/HyperGraph/modeling/mod_tran/3drota.htm
-- http://www.petesqbsite.com/sections/tutorials/tuts/perspective.html

-- +------------------------------------------------------------------------------------------------------------+
-- | PERSPECTIVE PROJECTION                                                                                     |
-- +------------------------------------------------------------------------------------------------------------+
-- | TOP-DOWN VIEW OF SCREEN SLICED AT AN ARBITRARY Y VALUE                                                     |
-- +------------------------------------------------------------------------------------------------------------+
-- |                                                                                                            |
-- |                                   (cx, cy, pz)                      (px, py, pz)                           |
-- |                                                (C')-------------(P)                                        |
-- |                                                 |               /                                          |
-- |                                                 |              /                                           |
-- |                                                 |             /                                            |
-- |                                                 |            /                                             |
-- |        (SCREEN) [============================= (C)---------(S) =====================]                      |
-- |                                    (cx, cy, 0)  |          /   (sx, sy, 0)                                 |
-- |                                                 |         /                                                |
-- |                                                 |        /                                                 |
-- |                                                 |       /                                                  |
-- |                                                 |      /                                                   |
-- |                         (z)                     |     /                                                    |
-- |                          ^                      |    /                                                     |
-- |                          |                      |   /                                                      |
-- |                          +---> (x)              |  /                                                       |
-- |                                                 | /                                                        |
-- |                                                 |/                                                         |
-- |                                                (E)                                                         |
-- |                                                    (cx, cy, -1000)                                         |
-- |                                                                                                            |
-- +------------------------------------------------------------------------------------------------------------+
-- |                                                                                                            |
-- | (E) -> eye (empirically found out that for dxSetShaderTransform eye is 1000 pixels in front of the screen) |
-- |        (actually, stuff starts to disappear from sight at values >= 900 px,                                |
-- |         but I've noticed that the position is the most accurate when 1000 is used)                         |
-- |                                                                                                            |
-- | (C) -> center of the rectangle that is used as the perspective point in dxSetShaderTransform               |
-- |        (located at (absPos.x+absSize.x/2, absPos.y+absSize.y/2))                                           |
-- |                                                                                                            |
-- | (P) -> point obtained by applying rotation to rectangle vertex                                             |
-- |                                                                                                            |
-- | (S) -> point that will be visible on screen after dxSetShaderTransform is applied                          |
-- |        (this is the point whose sx and sy coordinates we need to find)                                     |
-- |                                                                                                            |
-- +------------------------------------------------------------------------------------------------------------+
-- |                                                                                                            |
-- | Using the fact that the triangles (EPC') and (ESC) are similar we can calculate the coordinates of (S):    |
-- |                                                                                                            |
-- |                                   CS/C'P = CE/C'E =>                                                       |
-- |                                => (sx-cx)/(px-cx) = (0-(-1000))/(pz-(-1000)) =>                            |
-- |                                => (sx-cx)/(px-cx) = 1000/(pz+1000) =>                                      |
-- |                                => sx-cx = (1000/(pz+1000))*(px-cx) =>                                      |
-- |                                                                                                            |
-- |                                => sx = cx + (1000/(pz+1000))*(px-cx)                                       |
-- |                                                                                                            |
-- +------------------------------------------------------------------------------------------------------------+

-- local v = 100;

-- addEventHandler("onClientRender", root, function()
    -- if (v <= 500) then
        -- fr1.size = UDim2.new(0, v, 0, v);
        
        -- v = v+1;
    -- else
        -- v = 100;
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

-- [ ================= [ Rotation test ] ================= ]

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

-- local ico = decode_ico("decoders/ico/256x256-1bpp.ico");
-- ico = ico[1];

-- addEventHandler("onClientRender", root, function()
    -- dxDrawImage(400, 400, ico.width, ico.height, ico.image, guiScrollBarGetScrollPosition(s3)/100*360, -ico.width/2, -ico.height/2);
    
    -- dxDrawLine(
        -- SCREEN_WIDTH/2,
        -- SCREEN_HEIGHT/2,
        
        -- 400+guiScrollBarGetScrollPosition(s4)/100*ico.width,
        -- 400+guiScrollBarGetScrollPosition(s5)/100*ico.height,
        
        -- tocolor(0, 255, 0)
    -- );
-- end);
