local name = "Frame";

local super = GuiObject;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local event = inherit({}, super.event);

local private  = inherit({}, super.private);
local readOnly = inherit({}, super.readOnly);



local function new(obj)
    local success, result = pcall(super.new, obj);
    if (not success) then error(result, 2) end
    
    
    set.size(obj, UDim2.new(0, 100, 0, 100));
    set.pos(obj, UDim2.new());
end



Frame = inherit({
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

Instance.initializable.Frame = Frame;






scrGui = Instance.new("ScreenGui");
scrGui.name = "scrGui";

fr1 = Instance.new("Frame");
fr1.name = "fr1";
fr1.posOrigin = UDim2.new(0.5, 0, 0.5, 0);
fr1.pos = UDim2.new(0.6, 0, 0.6, 0);
fr1.size = UDim2.new(0.2, 0, 0.3, 0);
fr1.borderSize = 5;
fr1.borderColor3 = Color3.new(0, 0, 255);

fr2 = Instance.new("Frame");
fr2.name = "fr2";
fr2.pos = UDim2.new(0.5, 0, 0, 10);
fr2.posOrigin = UDim2.new(0.25, 0, 0, -10)
fr2.bgColor3 = Color3.new(223, 196, 125);
fr2.borderColor3 = Color3.new(0, 0, 0);
fr2.parent = fr1;

fr3 = Instance.new("Frame");
fr3.name = "fr3";
fr3.bgColor3 = Color3.new(0, 196, 0);
fr3.pos = UDim2.new(0.5, 0, 0.5, 0);
fr3.parent = fr2;

fr4 = Instance.new("Frame");
fr4.name = "fr4";
fr4.bgColor3 = Color3.new(255, 255, 0);
fr4.pos = UDim2.new(0.05, 0, 0.05, 0);
fr4.size = UDim2.new(0.25, 0, 0.3, 0);
fr4.parent = fr1;

fr5 = Instance.new("Frame");
fr5.name = "fr5";
fr5.bgColor3 = Color3.new(255, 0, 200);
fr5.pos = UDim2.new(0, -50, 0.5, 0);
fr5.parent = fr1;

fr1.parent = scrGui;

fr6 = Instance.new("Frame");
fr6.name = "fr6";
fr6.size = UDim2.new(0, 200, 0, 200);
fr6.pos = UDim2.new(0.07, 0, 0.4);
fr6.parent = scrGui;

fr7 = Instance.new("Frame");
fr7.name = "fr7";
fr7.bgColor3 = Color3.new(0, 255, 0);
fr7.pos = UDim2.new(0.5, 0, 0.5);
fr7.parent = fr6;



selFr = fr6;

local srx = guiCreateScrollBar(400, 20,  200, 20, true, false);
local sry = guiCreateScrollBar(400, 40,  200, 20, true, false);
local srz = guiCreateScrollBar(400, 60,  200, 20, true, false);

local spx = guiCreateScrollBar(400, 100,  200, 20, true, false); guiScrollBarSetScrollPosition(spx, 50);
local spy = guiCreateScrollBar(400, 120,  200, 20, true, false); guiScrollBarSetScrollPosition(spy, 50);
local spz = guiCreateScrollBar(400, 140,  200, 20, true, false); guiScrollBarSetScrollPosition(spz, 10);


addEventHandler("onClientGUIScroll", root, function()
    selFr.rotPivot = UDim2.new(guiScrollBarGetScrollPosition(spx)/100, 0, guiScrollBarGetScrollPosition(spy)/100, 0);
    
    selFr.rotPivotDepth = ((guiScrollBarGetScrollPosition(spz)/100)*10000-1000)/2;
    
    selFr.rot = Vector3.new(guiScrollBarGetScrollPosition(srx)/100*360, guiScrollBarGetScrollPosition(sry)/100*360, guiScrollBarGetScrollPosition(srz)/100*360);
end);



-- selFr.clipsDescendants = false;
selFr.debug = true
local v1 = selFr.size.x.scale;
local v2 = selFr.size.y.scale;
local v3 = 0;

local function render()
    if (v1 > 0.66) then
        -- selFr.clipsDescendants = true;
        
        print("Done");
        
        removeEventHandler("onClientRender", root, render)
        
        return
    end
    
    v1 = v1+0.001;
    v2 = v2+0.001;
    v3 = v3+0.0025;
    
    selFr.size = UDim2.new(v1, 0, v2, 0);
    -- selFr.borderSize = v1*60;
    -- selFr.borderColor3 = Color3.new(v3*255, 0, (1-v3)*255);
end

setTimer(function()
    addEventHandler("onClientRender", root, render);
end, 2500, 1);



-- local v1 = Vector3.new(selFr.absPos.x, selFr.absPos.y, 0);

addEventHandler("onClientPreRender", root, function()
    if (selFr.absRotPivot) then
        local x = selFr.absRotPerspective.x+(1000/(selFr.absRotPivot.z+1000))*(selFr.absRotPivot.x-selFr.absRotPerspective.x);
        local y = selFr.absRotPerspective.y+(1000/(selFr.absRotPivot.z+1000))*(selFr.absRotPivot.y-selFr.absRotPerspective.y);
        
        dxDrawLine(0, super.SCREEN_HEIGHT, x, y, tocolor(255, 0, 0), 3);
    end
    
    if (selFr.containerPos) then
        dxDrawLine(
            0, super.SCREEN_HEIGHT,
            
            selFr.containerPos.x,
            selFr.containerPos.y,
            
            tocolor(selFr.borderColor3.r, selFr.borderColor3.g, selFr.borderColor3.b), 3
        );
    end
    
    
    -- local angx = guiScrollBarGetScrollPosition(srx)/100*2*math.pi;
    -- local angy = guiScrollBarGetScrollPosition(sry)/100*2*math.pi;
    -- local angz = guiScrollBarGetScrollPosition(srz)/100*2*math.pi;
    
    -- local sinx = math.sin(angx);
    -- local cosx = math.cos(angx);
    
    -- local siny = math.sin(angy);
    -- local cosy = math.cos(angy);
    
    -- local sinz = math.sin(angz);
    -- local cosz = math.cos(angz);
    
    -- local rotx = Matrix3x3.new(
        -- 1, 0,     0,
        -- 0, cosx, -sinx,
        -- 0, sinx,  cosx
    -- );
    
    -- local roty = Matrix3x3.new(
         -- cosy, 0, siny,
         -- 0,    1, 0,
        -- -siny, 0, cosy
    -- );
    
    -- local rotz = Matrix3x3.new(
        -- cosz, -sinz, 0,
        -- sinz,  cosz, 0,
        -- 0,     0,    1
    -- );
    
    
    -- local v1_1 = v1-selFr.absRotPivot;
    
    -- local v1_2 = roty*rotx*rotz*v1_1;
    
    -- local v1_3 = v1_2+selFr.absRotPivot;
    
    
    -- dxDrawLine(
        -- selFr.absRotPivot.x,
        -- selFr.absRotPivot.y,
        
        -- selFr.absRotPerspective.x+(1000/(v1_3.z+1000))*(v1_3.x-selFr.absRotPerspective.x),
        -- selFr.absRotPerspective.y+(1000/(v1_3.z+1000))*(v1_3.y-selFr.absRotPerspective.y),
        
        -- tocolor(0, 255, 0), 3
    -- );
end);


-- local c = coroutine.wrap(function(arg)
    -- print(arg, "1");
    
    -- local res = coroutine.yield();
    
    -- print(res, "2");
-- end);

-- c(5);
-- c(2);
-- c(7);
-- c(4);

-- function thread_main ()
  -- while true do
    -- coroutine.yield();
  -- end
-- end

-- local x = coroutine.create(thread_main);

-- for i = 1, 5 do
    -- coroutine.resume(x);
    -- print(coroutine.status(x));
-- end




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
-- | (C) -> perspective point that is used in dxSetShaderTransform (located at absRotPerspective)               |
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
