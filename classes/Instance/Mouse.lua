local name = "Mouse";

local super = Instance;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local event = inherit({}, super.event);

local private  = inherit({}, super.private);
local readOnly = inherit({}, super.readOnly);



local DEFAULT_CURSORS = {
    ["arrow"]       = "cursors/arrow.png", -- "cursors/PulseGlass/arrow.ani",
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


local function decodeCursor(path)
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
            elseif (decoder == decode_jpg or decoder == decode_png) then
                data.hotspotX = 0;
                data.hotspotY = 0;
            end
            
            return data;
        end
    end
end



local function new(obj)
    local prevCursorAlpha = getCursorAlpha();

    addEventHandler("onClientResourceStop", resourceRoot, function()
        setCursorAlpha(prevCursorAlpha);
    end);
    
    if (not isMainMenuActive()) then
        setCursorAlpha(0);
    end -- otherwise cursor alpha is set to 0 by scenario 3 fix as soon as main menu is exited
    
    
    
    obj.viewSize = Vector2.new(GuiBase2D.SCREEN_WIDTH, GuiBase2D.SCREEN_HEIGHT);
    obj.viewPos  = Vector2.new();
    obj.viewRect = { obj.viewPos, obj.viewPos+obj.viewSize }
    
    local x, y = getCursorPosition();
    
    if (x and y) then
        obj.x = math.floor(x*GuiBase2D.SCREEN_WIDTH);
        obj.y = math.floor(y*GuiBase2D.SCREEN_HEIGHT);
    else
        obj.x = math.floor(obj.viewSize.x/2);
        obj.y = math.floor(obj.viewSize.y/2);
    end
    
    obj.cursorContainer = {}
    
    for cursor, path in pairs(DEFAULT_CURSORS) do
       local data = decodeCursor(path);
        
        if (not data) then
            error("could not decode " ..path, 2); -- TODO: handle this in Instance.new
        end
        
        obj.cursorContainer[cursor] = data;
    end
    
    obj.cursorFrameController = 1; -- used for animations (e.g. for ani cursors)
    obj.cursorFrame = 1;
    
    obj.isScenario1Fixed = false; -- when cursor alpha is 0 and console is opened it is set back to 255
    obj.isScenario2Fixed = false; -- while in the main menu and console is opened and then closed,
                                  -- cursor alpha will be set to 0 (probably because MTA's cursor showing code
                                  -- mistakenly thinks that we are no longer in the main menu and reverts
                                  -- back to script-set alpha value, which for us is 0, because we want to
                                  -- display a custom cursor)
    obj.isScenario3Fixed = false; -- while in the main menu and the console and any other window(s) (e.g. server browser)
                                  -- is opened and then Esc is pressed repeatedly to return to the game, cursor alpha
                                  -- will remain at 255 (probably because MTA's cursor showing code mistakenly thinks
                                  -- we are still inside the main menu)
    
    obj.move = Signal.new();
    
    
    set.cursor(obj, "arrow");
    
    set.shadow(obj, false);
    set.shadowOffset(obj, Vector2.new(2, 2));
    
    
    function obj.draw_wrapper(dt)
        func.draw(obj, dt);
    end
    
    function obj.move_wrapper(relX, relY, absX, absY)
        func.move(obj, absX, absY);
    end
    
    
    addEventHandler("onClientRender", root, obj.draw_wrapper, false, "low-1");
    
    addEventHandler("onClientCursorMove", root, obj.move_wrapper, false, "high");
end



function func.update_cursorData(obj)
    obj.cursorData = obj.cursorContainer[obj.cursor];
end


function func.move(obj, x, y)
    local isOutOfView = x < obj.viewRect[1].x or x > obj.viewRect[2].x or y < obj.viewRect[1].y or y > obj.viewRect[2].y;
    
    if (isOutOfView) then
        if (x < obj.viewRect[1].x) then
            x = obj.viewRect[1].x;
        elseif (x > obj.viewRect[2].x) then
            x = obj.viewRect[2].x;
        end
        
        if (y < obj.viewRect[1].y) then
            y = obj.viewRect[1].y;
        elseif (y > obj.viewRect[2].y) then
            y = obj.viewRect[2].y;
        end
        
        setCursorPosition(x, y); -- stop cursor from escaping viewRect
    end
    
    local hasMoved = x ~= obj.x or y ~= obj.y;
    
    obj.x = x;
    obj.y = y;
    
    if (hasMoved) then
        Signal.func.trigger(PROXY__OBJ[obj.move], x, y);
    end
end


function func.draw(obj, dt)
    local isConsoleActive  = isConsoleActive();
    local isMainMenuActive = isMainMenuActive();
    
    -- fix scenario 1
    if (isConsoleActive) then
        if (not isMainMenuActive and not obj.isScenario1Fixed) then
            setCursorAlpha(0);
            
            obj.isScenario1Fixed = true;
        end
    else
        if (obj.isScenario1Fixed) then
            obj.isScenario1Fixed = false;
        end
    end
    
    -- fix scenarios 2 and 3
    if (isMainMenuActive) then
        if (isConsoleActive) then
            if (obj.isScenario2Fixed) then
                obj.isScenario2Fixed = false;
            end
        else
            if (not obj.isScenario2Fixed) then
                setCursorAlpha(255);
                
                obj.isScenario2Fixed = true;
            end
        end
        
        if (obj.isScenario3Fixed) then
            obj.isScenario3Fixed = false;
        end
    else
        if (not obj.isScenario3Fixed) then
            setCursorAlpha(0);
            
            obj.isScenario3Fixed = true;
        end
    end
    
    -- draw cursor
    if (not isMainMenuActive and (isCursorShowing() or isChatBoxInputActive() or isConsoleActive)) then
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
                (obj.x - hotspotX) + obj.shadowOffset.x, (obj.y - hotspotY) + obj.shadowOffset.y, width, height, image,
                nil, nil, tocolor(0, 0, 0, 127.5), true
            );
        end
        
        dxDrawImage(
            obj.x - hotspotX, obj.y - hotspotY, width, height, image,
            nil, nil, nil, true -- draw over gui elements
        );
        
        if (isAnimation) then
            obj.cursorFrameController = obj.cursorFrameController + fpms*dt; -- for increment does not depend on framerate
            obj.cursorFrame = math.floor(obj.cursorFrameController);
            
            if (obj.cursorFrameController > frameCount) then
                obj.cursorFrameController = 1;
                obj.cursorFrame = 1;
            end
        end
    end
end


function set.cursor(obj, cursor)
    local cursor_t = type(cursor);
    
    if (cursor_t ~= "string") then
        error("bad argument #1 to 'cursor' (string expected, got " ..cursor_t.. ")", 2);
    elseif (not obj.cursorContainer[cursor]) then
        error("bad argument #1 to 'cursor' (invalid type)", 2);
    end
    
    
    obj.cursor = cursor;
    
    
    func.update_cursorData(obj);
end


function set.shadow(obj, shadow)
    local shadow_t = type(shadow);
    
    if (shadow_t ~= "boolean") then
        error("bad argument #1 to 'shadow' (boolean expected, got " ..shadow_t.. ")", 2);
    end
    
    
    obj.shadow = shadow;
end

function set.shadowOffset(obj, shadowOffset)
    local shadowOffset_t = type(shadowOffset);
    
    if (shadowOffset_t ~= "Vector2") then
        error("bad argument #1 to 'shadowOffset' (Vector2 expected, got " ..shadowOffset_t.. ")", 2);
    end
    
    
    obj.shadowOffset = shadowOffset;
end



Mouse = inherit({
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

Instance.initializable.Mouse = Mouse;

mouse = Instance.new("Mouse");

Instance.privateClass.Mouse = true;
