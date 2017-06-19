local DEFAULT_CURSORS = {
    ["arrow"]       = "cursors/PulseGlass/arrow.ani",
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


local DECODERS = { decode_ico, decode_ani, decode_gif, decode_jpg, decode_png }

local function decode_cursor(path)
    for i = 1, #DECODERS do
        local decoder = DECODERS[i];
        
        local success, data = pcall(decoder, path);
        
        if (success) then
            -- adapt returned table to render function
            
            if (decoder == decode_ico) then
                
                local type = data.type;
                
                data = data[1];
                
                data.isAnimation = false;
            
                if (type == "ico") then
                    data.hotspotX = 0;
                    data.hotspotY = 0;
                end

            elseif (decoder == decode_ani) then
            
                data = data[1];
                
                data.isAnimation = true;
                
                data.frameCount = #data;
                
                for i = 1, #data do
                    data[i].fpms = 0.06/data[i].rate;
                end
                
            elseif (decoder == decode_gif) then
                
                if (data.isAnimation) then
                    data.frameCount = #data;
                    
                    for i = 1, #data do
                        data[i].width  = data.width;
                        data[i].height = data.height;
                        
                        data[i].hotspotX = 0;
                        data[i].hotspotY = 0;
                        
                        data[i].fpms = (data[i].delay ~= 0) and 1/data[i].delay or REFERENCE_FPMS;
                    end
                else
                    data.hotspotX = 0;
                    data.hotspotY = 0;
                    
                    data.image = data[1].image;
                end
            
            elseif (decoder == decode_jpg) or (decoder == decode_png) then
                data.hotspotX = 0;
                data.hotspotY = 0;
            end
            
            return data;
        end
    end
end



setCursorAlpha(0);



local name = "Mouse";

local super = Instance;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get [key] end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set [key] end });

local private = setmetatable({
        cursorContainer = true,
        
        cursorFrame = true,
        cursorData = true,
    },
    
    { __index = function(tbl, key) return super.private[key] end }
);

local readOnly = setmetatable({
        Move = true,
        
        viewWidth  = true,
        viewHeight = true,
        
        x = true,
        y = true,
    },
    
    { __index = function(tbl, key) return super.readOnly[key] end }
);



local function new(obj)
    obj.viewWidth  = SCREEN_WIDTH;
    obj.viewHeight = SCREEN_HEIGHT;
    
    obj.x = obj.viewWidth/2;
    obj.y = obj.viewHeight/2;
    
    setCursorPosition(obj.x, obj.y);
    
    
    obj.cursorContainer = {}
    
    for cursor, path in pairs(DEFAULT_CURSORS) do
       local data = decode_cursor(path);
        
        if (not data) then
            error("could not decode " ..path); -- TODO: handle this in Instance
        end
        
        obj.cursorContainer[cursor] = data;
    end
    
    obj.cursor = "arrow";
    
    obj.cursorFrameController = 1; -- used for animations (e.g. for ani cursors)
    obj.cursorFrame           = 1;
    
    obj.cursorData = obj.cursorContainer[obj.cursor];
    
    obj.shadow = true;
    obj.shadowOffsetX = 2;
    obj.shadowOffsetY = 2;
    
    
    
    local isScenario1Fixed = false; -- scenario 1: when cursor alpha is 0 and console is opened it is set back to 255
    
    local isScenario2Fixed = false; -- scenario 2: when cursor alpha is 0, main menu is open
                                    -- and we open and close console, cursor alpha in main menu is set to 0
    
    function obj.render(dt)
        local isConsoleActive  = isConsoleActive();
        local isMainMenuActive = isMainMenuActive();
        
        if (isConsoleActive) then
            if (isMainMenuActive) and (isScenario2Fixed) then isScenario2Fixed = false end
            
            if (not isMainMenuActive) and (not isScenario1Fixed) then
                setCursorAlpha(0);
                
                isScenario1Fixed = true;
            end
        elseif (not isConsoleActive) then
            if (isScenario1Fixed) then isScenario1Fixed = false end -- resetting scenario 1 fix for the next time it will happen
            
            if (isMainMenuActive) and (not isScenario2Fixed) then
                setCursorAlpha(255);
                
                isScenario2Fixed = true;
            end
        end
        
        if (not isMainMenuActive) and (isCursorShowing() or isChatBoxInputActive() or isConsoleActive) then
            
            local data = obj.cursorData;
            
            local isAnimation = data.isAnimation;
            local frameCount, fpms;
            
            if (isAnimation) then
                frameCount = data.frameCount;
                
                data = data[obj.cursorFrame];
                
                fpms = data.fpms;
            end
            
            local hotspotX = data.hotspotX;
            local hotspotY = data.hotspotY;
            
            local width  = data.width;
            local height = data.height;
            
            local image = data.image;
            
            if (obj.shadow) then
                dxDrawImage(
                    (obj.x - hotspotX) + obj.shadowOffsetX, (obj.y - hotspotY) + obj.shadowOffsetY, width, height, image,
                    nil, nil, tocolor(0, 0, 0, 127.5), true -- draw over gui elements
                );
            end
            
            dxDrawImage(
                obj.x - hotspotX, obj.y - hotspotY, width, height, image,
                nil, nil, nil, true
            );
            
            if (isAnimation) then
                obj.cursorFrameController = obj.cursorFrameController + fpms*dt; -- for increment that is independent of framerate
                obj.cursorFrame           = math.floor(obj.cursorFrameController);
                
                if (obj.cursorFrameController > frameCount) then
                    obj.cursorFrameController = 1;
                    obj.cursorFrame           = 1;
                end
            end
            
        end
    end
    
    addEventHandler("onClientPreRender", root, obj.render, nil, "high");
    
    addEventHandler("onClientCursorMove", root, function(relativeX, relativeY, absX, absY)
        obj.x = absX;
        obj.y = absY;
    end, nil, "high");
end



Instance.initializable.Mouse = {
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    private  = private,
    readOnly = readOnly,
    
    new = new,
}

local mouse = Instance.new("Mouse");

Instance.privateClass.Mouse = true;
