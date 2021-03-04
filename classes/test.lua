-- this file is for testing implemented functionality
scrGui = ScreenGui.new();
scrGui.name = "scrGui";

fr1 = Frame.new();
fr1.name = "fr1";
fr1.posOrigin = UDim2.new(0.5, 0, 0.5, 0);
fr1.pos = UDim2.new(0.6, 0, 0.6, 0);
fr1.size = UDim2.new(0.2, 0, 0.3, 0);
fr1.borderSize = 5;
fr1.borderColor = Color3.new(0, 0, 255);

fr2 = Frame.new();
fr2.name = "fr2";
fr2.pos = UDim2.new(0.5, 0, 0, 10);
fr2.posOrigin = UDim2.new(0.25, 0, 0, -10)
fr2.bgColor = Color3.new(223, 196, 125);
fr2.borderColor = Color3.new(0, 0, 0);
fr2.parent = fr1;

fr3 = Frame.new();
fr3.name = "fr3";
fr3.bgColor = Color3.new(0, 196, 0);
fr3.pos = UDim2.new(0.5, 0, 0.5, 0);
fr3.parent = fr2;

fr4 = Frame.new();
fr4.name = "fr4";
fr4.bgColor = Color3.new(255, 255, 0);
fr4.pos = UDim2.new(0.05, 0, 0.05, 0);
fr4.size = UDim2.new(0.25, 0, 0.3, 0);
fr4.parent = fr1;

fr5 = Frame.new();
fr5.name = "fr5";
fr5.bgColor = Color3.new(255, 0, 200);
fr5.pos = UDim2.new(0, -50, 0.5, 0);
fr5.parent = fr1;

fr1.parent = scrGui;


fr6 = Frame.new();
fr6.name = "fr6";
fr6.size = UDim2.new(0, 200, 0, 200);
fr6.pos = UDim2.new(0.07, 0, 0.4);
fr6.parent = scrGui;

fr7 = Frame.new();
fr7.name = "fr7";
fr7.bgColor = Color3.new(0, 255, 0);
fr7.pos = UDim2.new(0.5, 0, 0.5);
fr7.parent = fr6;



selFr = fr1;

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



-- local v1 = selFr.size.x.scale;
-- local v2 = selFr.size.y.scale;
-- local v3 = 0;

-- local function render()
    -- if (v1 > 0.66) then
        -- print("Done");
        
        -- removeEventHandler("onClientRender", root, render)
        
        -- return
    -- end
    
    -- v1 = v1+0.0005;
    -- v2 = v2+0.0005;
    -- v3 = v3+0.0025;
    
    -- selFr.size = UDim2.new(v1, 0, v2, 0);
    
    -- -- selFr.borderSize = v1*60;
    -- -- selFr.borderColor = Color3.new(v3*255, 0, (1-v3)*255);
-- end

-- addEventHandler("onClientRender", root, render);
