local DEFAULT_SCHEME = {
    ["arrow"]       = "decoders/ani/windows-4bpp.ani",
    ["beam"]        = "cursors/PulseGlass/beam.cur",
    ["busy"]        = "cursors/PulseGlass/busy.ani",
    ["help"]        = "cursors/PulseGlass/help.cur",
    ["link"]        = "cursors/PulseGlass/link.ani",
    ["move"]        = "cursors/PulseGlass/move.cur",
    ["precision"]   = "cursors/PulseGlass/precision.cur",
    ["size-ew"]     = "cursors/PulseGlass/size-ew.cur",
    ["size-ns"]     = "cursors/PulseGlass/size-ns.cur",
    ["size-nesw"]   = "cursors/PulseGlass/size-nesw.cur",
    ["size-nwse"]   = "cursors/PulseGlass/size-nwse.cur",
    ["unavailable"] = "cursors/PulseGlass/unavailable.cur",
}


local DECODERS = {decode_ico, decode_ani, decode_gif}

local function decode_cursor(path)
    for i = 1, #DECODERS do
        local decoder = DECODERS[i];
        
        local success, result = pcall(decoder, path);
        
        if (success) then return result end
    end
end



local func = {}
local set  = {}

local private = {
    cursorContainer = true,
    
    cursorFrame = true,
    cursorData = true,
}

local readonly = {
    Move = true,
    
    viewWidth  = true,
    viewHeight = true,
    
    x = true,
    y = true,
}

local function new(obj)
    obj.viewWidth  = SCREEN_WIDTH;
    obj.viewHeight = SCREEN_HEIGHT;
    
    obj.x = obj.viewWidth/2;
    obj.y = obj.viewHeight/2;
    
    setCursorPosition(obj.x, obj.y);
    
    
    obj.cursorContainer = {}
    
    for cursor, path in pairs(DEFAULT_SCHEME) do
       local data = decode_cursor(path);
        
        if (not data) then
            error("could not decode " ..path); -- TODO: handle this in Instance
        end
        
        obj.cursorContainer[cursor] = data;
    end
    
    obj.cursor = "arrow";
    obj.cursorSize = 1;
    
    obj.cursorFrameController = 1; -- used for animations (e.g. for ani cursors)
    obj.cursorFrame = 1;
    
    obj.cursorData = obj.cursorContainer[obj.cursor];
    
    
    
    function obj.render(dt)
        if (isMainMenuActive()) then
            if (not isMainMenuAlphaSet) then
                setCursorAlpha(255);
                
                isMainMenuAlphaSet = true;
            end
            
            return;
        end
        
        
        local isAnimation = false;
        
        local hotspotX, hotspotY;
        local width, height;
        
        local image;
        
        local delay, frameCount; -- used if isAnimation == true
        
        if (obj.cursorData.type == "ico") or (obj.cursorData.type == "cur") then
        
            local data = obj.cursorData[obj.cursorSize];
            
            hotspotX = data.hotspotX or 0;
            hotspotY = data.hotspotY or 0;
            
            width  = data.width;
            height = data.height;
            
            image = data.image;
            
        elseif (obj.cursorData.type == "ani") then
        
            local data = obj.cursorData[obj.cursorSize][obj.cursorFrame];
            
            isAnimation = true;
            
            hotspotX = data.hotspotX;
            hotspotY = data.hotspotY;
            
            width  = data.width;
            height = data.height;
            
            image = data.image;
            
            delay = 60/data.rate;
            frameCount = #obj.cursorData[obj.cursorSize];
            
        elseif (obj.cursorData.type == "gif") then
            
            local data = obj.cursorData;
            
            isAnimation = data.isAnimation;
            
            hotspotX = 0;
            hotspotY = 0;
            
            width  = data.width;
            height = data.height;
            
            image = data[obj.cursorFrame].image;
            
            delay = isAnimation and data[obj.cursorFrame].delay;
            frameCount = isAnimation and #data;
            
        end
        
        
        dxDrawImage(
            obj.x - hotspotX, obj.y - hotspotY,
            
            width, height,
            
            image,
            
            nil, nil, nil, true -- draw over gui elements
        );
        
        if (isAnimation) then
            
            if (obj.cursorFrameController > frameCount) then
                obj.cursorFrameController = 1;
            end
            
            obj.cursorFrameController = obj.cursorFrameController+(dt/1000)*delay;
            obj.cursorFrame = math.floor(obj.cursorFrameController);
            
        end
    end
    
    addEventHandler("onClientPreRender", root, obj.render, nil, "high");
    
    addEventHandler("onClientCursorMove", root, function(relativeX, relativeY, absX, absY)
        obj.x = absX;
        obj.y = absY;
    end, nil, "high");
end

-- function Mouse.New(Object)
    -- Object.ViewSizeX = SCREEN_WIDTH;
    -- Object.ViewSizeY = SCREEN_HEIGHT;
    
    -- Object.X = SCREEN_WIDTH/2;
    -- Object.Y = SCREEN_HEIGHT/2;
    
    -- Object.Pointer = Enum.Pointer.Arrow;
    -- Object.PointersData = {
        -- [Enum.Pointer.Arrow] = decode_ani("cursors/PulseGlass/arrow.ani")[1],
        -- [Enum.Pointer.Busy]  = decode_ani("cursors/PulseGlass/busy.ani")[1]
    -- }
    -- Object.PointerData = Object.PointersData[Object.Pointer];
    
    -- setCursorPosition(Object.X,Object.Y);
    
    
    -- local PointerAnimationController = 1;
    -- local IsConsoleCursorAlphaSet = false;    local IsMainMenuCursorAlphaSet = false;
    -- function Object.Render(Delta)
        -- if (isMainMenuActive() == false) then
            -- local IsConsoleActive = isConsoleActive();
            
            -- if (isChatBoxInputActive() == true) or (IsConsoleActive == true) or (isCursorShowing() == true) then
                -- local PointerData = Object.PointerData;
                
                -- local PointerAnimationFramesNumber = #PointerData;
                -- if (PointerAnimationFramesNumber ~= 0) then
                    -- if (PointerAnimationController >= PointerAnimationFramesNumber+1) then PointerAnimationController = 1 end
                    
                    -- PointerData = PointerData[math.floor(PointerAnimationController)];
                    
                    -- PointerAnimationController = PointerAnimationController+(Delta/1000)*(60/PointerData.rate);
                -- end
                
                -- -- SHADOW
                -- dxDrawImage(
                    -- Object.X-PointerData.hotspotX+2,Object.Y-PointerData.hotspotY+2,
                    -- PointerData.width,PointerData.height,
                    -- PointerData.image,
                    -- nil,nil,tocolor(0,0,0,125),true
                -- );
                
                -- dxDrawImage(
                    -- Object.X-PointerData.hotspotX,Object.Y-PointerData.hotspotY,
                    -- PointerData.width,PointerData.height,
                    -- PointerData.image,
                    -- nil,nil,nil,true
                -- );
            -- end
            
            -- if (IsConsoleActive == true) then
                -- if (IsConsoleCursorAlphaSet == false) then
                    -- setCursorAlpha(--[[0]] 255);
                    
                    -- IsConsoleCursorAlphaSet = true;
                -- end
            -- elseif (IsConsoleCursorAlphaSet == true) then IsConsoleCursorAlphaSet = false end
            
            -- if (IsMainMenuCursorAlphaSet == true) then
                -- setCursorAlpha(--[[0]] 255);
                
                -- IsMainMenuCursorAlphaSet = false;
            -- end
        -- elseif (IsMainMenuCursorAlphaSet == false) then
            -- setCursorAlpha(255);
            
            -- IsMainMenuCursorAlphaSet = true;
        -- end
    -- end
    -- addEventHandler("onClientPreRender",root,Object.Render);
    
    
    -- do
        -- -- local MoveConnections,MoveTrigger;
        -- -- Object.Move,MoveConnections,MoveTrigger = Signal.New();
        
        -- addEventHandler("onClientCursorMove",root,function(_RelativeCursorX,_RelativeCursorY,AbsoluteCursorX,AbsoluteCursorY)
            -- Object.X = AbsoluteCursorX;
            -- Object.Y = AbsoluteCursorY;
            
            -- -- MoveTrigger(AbsoluteCursorX,AbsoluteCursorY);
        -- end);
    -- end
-- end

-- do
    -- for k,v in pairs(Enum.Pointer) do
        -- Mouse.NewIndexFunctions[k.."Icon"] = function(Object,Key,Icon)
            -- local IconType = type(Icon);
            -- if (IconType ~= "string") then error("bad argument #1 to '"..Key.."' (string expected, got "..IconType..")",3) end
            
            -- if (fileExists(Icon) == false) then error("bad argument #1 to '"..Key.."' (nonexistent file)",3) end
            
            -- local File = fileOpen(Icon);
            -- if (File == false) then error("bad argument #1 to '"..Key.."' (invalid file)",3) end
            
            -- local IconBytes = fileRead(File,fileGetSize(File));
            
            -- local Success,Result = pcall(decode_ani,IconBytes);
            -- if (Success == false) then
                -- Success,Result = pcall(decode_ico,IconBytes);
                -- if (Success == false) then error(format_pcall_error(Result):gsub("?",Key,1),3) end
                
                -- Result = Result[1];
                -- if (Result.HotspotX == nil) or (Result.HotspotY == nil) then error("bad argument #1 to '"..Key.."' (invalid file)") end -- make sure file is not ICO
            -- else Result = Result[1] end
            
            -- Object.PointersData[v] = Result;
            -- if (Object.Pointer == v) then Object.PointerData = Result end
            
            -- Object[Key] = Icon;
        -- end
    -- end
    
    -- function Mouse.NewIndexFunctions.Pointer(Object,Key,Pointer)
        -- local PointerType = type(Pointer);
        -- if (PointerType ~= "number") then error("bad argument #1 to '"..Key.."' (number expected, got "..PointerType..")",3) end
        
        -- if (EnumValidity.Pointer[Pointer] ~= true) then error("bad argument #1 to '"..Key.."' (invalid value)",3) end
        
        -- Object.PointerData = Object.PointersData[Pointer];
        
        -- Object.Pointer = Pointer;
    -- end
-- end

Instance.Inherited.Mouse = {
    Base = Instance,
    
    Name = "Mouse",
    
    Functions = get,
    NewIndexFunctions = set,
    
    PrivateKeys = private,
    
    ReadOnlyKeys = readonly,
    
    New = new,
}



local Mouse = Instance.New("Mouse");
-- Mouse.ArrowIcon = "Testers/aliendance.ani";