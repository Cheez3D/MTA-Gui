-- local Color3  = require("Color3");
-- local Vector2 = require("Vector2");

local floor = math.floor;



local name = "GuiObject";

local super = GuiBase2D;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get [key] end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set [key] end });

local private = setmetatable({
        
    },
    
    { __index = function(tbl, key) return super.private[key] end }
);

local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });



local RT_ADDITIONAL_MARGIN = 1; -- added so that rt can be properly anti-aliased when rotated

local MAX_BORDER_SIZE = 100;

local ROT_NEAR_Z_PLANE        = -1000;
local ROT_ACTUAL_NEAR_Z_PLANE = -900;
local ROT_FAR_Z_PLANE         =  9000;

local ROT_PIVOT_DEPTH_UNIT = 1000;


local SHADER = dxCreateShader("shaders/nothing.fx"); -- TODO: add check for successful creation (dxSetTestMode)



local function new(obj)
    super.new(obj);
    
    obj.bgColor3       = Color3.new(255, 255, 255);
    obj.bgTransparency = 0;
    
    obj.borderColor3       = Color3.new(27, 42, 53);
    obj.borderSize         = 1;
    obj.borderTransparency = 0;
    
    obj.size      = nil;
    obj.posOrigin = UDim2.new(0, 0, 0, 0);
    obj.pos       = nil;
    
    obj.rot            = Vector3.new(0, 0, 0);
    obj.rotPivot       = UDim2.new(0.5, 0, 0.5, 0);
    obj.rotPerspective = UDim2.new(0.5, 0, 0.5, 0);
    obj.rotPivotDepth  = 0;
    
    obj.visible = true;
    
    
    
    obj.isRotated   = false;
    obj.isRotated3D = false;
    
    
    -- function obj.draw() end
end



function func.update_rootGui(obj)
    obj.rootGui = obj.parent and (
           Instance.func.isA(obj.parent, "ScreenGui") and obj.parent
        or Instance.func.isA(obj.parent, "GuiObject") and obj.parent.rootGui
    ) or nil;
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_rootGui(child);
        end
    end
end


function func.update_absSize(obj)
    obj.absSize = obj.rootGui and Vector2.new(
        floor(obj.size.x.offset + obj.parent.absSize.x*obj.size.x.scale),
        floor(obj.size.y.offset + obj.parent.absSize.y*obj.size.y.scale)
    ) or nil;
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_absSize(child);
        end
    end
end

function func.update_absPos(obj)
    obj.absPos = obj.rootGui and Vector2.new(
        floor(obj.parent.absPos.x + (obj.pos.x.offset + obj.parent.absSize.x*obj.pos.x.scale) - (obj.posOrigin.x.offset + obj.absSize.x*obj.posOrigin.x.scale)),
        floor(obj.parent.absPos.y + (obj.pos.y.offset + obj.parent.absSize.y*obj.pos.y.scale) - (obj.posOrigin.y.offset + obj.absSize.y*obj.posOrigin.y.scale))
    ) or nil;
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_absPos(child);
        end
    end
end


function func.update_absRotPivot(obj)
    obj.absRotPivot = obj.rootGui and Vector3.new(
        floor(obj.absPos.x + (obj.rotPivot.x.offset + obj.absSize.x*obj.rotPivot.x.scale)),
        floor(obj.absPos.y + (obj.rotPivot.y.offset + obj.absSize.y*obj.rotPivot.y.scale)),
        
        obj.rotPivotDepth
    ) or nil;
    
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_absRotPivot(child);
        end
    end
end

function func.update_absRotPerspective(obj)
    obj.absRotPerspective = obj.rootGui and Vector2.new(
        floor(obj.absPos.x + (obj.rotPerspective.x.offset + obj.absSize.x*obj.rotPerspective.x.scale)),
        floor(obj.absPos.y + (obj.rotPerspective.y.offset + obj.absSize.y*obj.rotPerspective.y.scale))
    ) or nil;
    
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_absRotPerspective(child);
        end
    end
end

function func.update_isRotated(obj)
    if     (obj.rot.x == obj.rot.y and obj.rot.y == obj.rot.z) and (obj.rot.x%180 == 0) then obj.isRotated = false;
    elseif (obj.rot.x%360 == 0 and obj.rot.y%360 == 0 and obj.rot.z%360 == 0)           then obj.isRotated = false;
    else                                                                                     obj.isRotated = true;
    end
end

function func.update_isRotated3D(obj)
    if (obj.isRotated) then
        if     (obj.rotPivotDepth == 0) and (obj.rot.x%180 == 0 and obj.rot.y%180 == 0) then obj.isRotated3D = false;
        elseif (obj.rot.x == obj.rot.y) and (obj.rot.x%180 == 0)                        then obj.isRotated3D = false;
        else                                                                                 obj.isRotated3D = true;
        end
    else
        obj.isRotated3D = false;
    end
end


function func.update_rtSpacing(obj)
    obj.rtLeftSpacing  = obj.rootGui and RT_ADDITIONAL_MARGIN or nil;
    obj.rtRightSpacing = obj.rootGui and RT_ADDITIONAL_MARGIN or nil;
    
    obj.rtTopSpacing    = obj.rootGui and RT_ADDITIONAL_MARGIN or nil;
    obj.rtBottomSpacing = obj.rootGui and RT_ADDITIONAL_MARGIN or nil;
end

function func.update_rtAbsSize(obj)
    obj.rtAbsSize = obj.rootGui and Vector2.new(
        obj.rtLeftSpacing + obj.borderSize + obj.absSize.x + obj.borderSize + obj.rtRightSpacing,
        obj.rtTopSpacing  + obj.borderSize + obj.absSize.y + obj.borderSize + obj.rtBottomSpacing
    ) or nil;
    
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_rtAbsSize(child);
        end
    end
end

function func.update_rtAbsPos(obj)
    obj.rtAbsPos = obj.rootGui and Vector2.new(
        obj.absPos.x - (obj.borderSize + obj.rtLeftSpacing),
        obj.absPos.y - (obj.borderSize + obj.rtTopSpacing)
    ) or nil;
    
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_rtAbsPos(child);
        end
    end
end

function func.update_rtTransformPivot(obj)
    obj.rtTransformPivot = obj.rootGui and obj.isRotated and Vector3.new(
        2*(-obj.rtAbsSize.x/2 + obj.absRotPivot.x-obj.rtAbsPos.x)/(obj.parent == obj.rootGui and obj.parent.absSize.x or obj.parent.containerGui.absSize.x),
        2*(-obj.rtAbsSize.y/2 + obj.absRotPivot.y-obj.rtAbsPos.y)/(obj.parent == obj.rootGui and obj.parent.absSize.y or obj.parent.containerGui.absSize.y),
        
        2*(obj.absRotPivot.z/ROT_PIVOT_DEPTH_UNIT)
    ) or nil;
    
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_rtTransformPivot(child);
        end
    end
end

function func.update_rtTransformPerspective(obj)
    obj.rtTransformPerspective = obj.rootGui and obj.isRotated3D and Vector2.new(
        2*(-obj.rtAbsSize.x/2 + obj.absRotPerspective.x-obj.rtAbsPos.x)/(obj.parent == obj.rootGui and obj.parent.absSize.x or obj.parent.containerGui.absSize.x),
        2*(-obj.rtAbsSize.y/2 + obj.absRotPerspective.y-obj.rtAbsPos.y)/(obj.parent == obj.rootGui and obj.parent.absSize.y or obj.parent.containerGui.absSize.y)
    ) or nil;
    
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_rtTransformPerspective(child);
        end
    end
end

function func.update_rt(obj)
    if isElement(obj.rt) then destroyElement(obj.rt) end
    
    obj.rt = obj.rootGui and obj.visible and dxCreateRenderTarget(obj.rtAbsSize.x, obj.rtAbsSize.y, true) or nil;
    
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_rt(child);
        end
    end
end


function func.update(obj)
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update(child);
        end
    end
    
    
    obj.draw(false);
end



function set.parent(obj, parent, prev, k)
    local success, result = pcall(super.set.parent, obj, parent, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    if (prev and Instance.func.isA(prev, "GuiBase2D")) then
        prev.draw(true);
    end
    
    
    func.update_rootGui(obj);
    
    func.update_absSize(obj);
    func.update_absPos(obj);
    
    func.update_absRotPivot(obj);
    func.update_absRotPerspective(obj);
    
    func.update_rtSpacing(obj);
    func.update_rtAbsSize(obj);
    func.update_rtAbsPos(obj);
    func.update_rtTransformPivot(obj);
    func.update_rtTransformPerspective(obj);
    func.update_rt(obj);
    
    
    if (k == 1) then
        func.update(obj);
        
        obj.draw(true);
    end
end


function set.bgColor3(obj, bgColor3)
    local bgColor3_t = type(bgColor3);
    
    if (bgColor3_t ~= "Color3") then
        error("bad argument #1 to 'bgColor3' (Color3 expected, got " ..bgColor3_t.. ")", 2);
    end
    
    
    obj.bgColor3 = bgColor3;
    
    
    obj.draw(true);
end

function set.bgTransparency(obj, bgTransparency)
    local bgTransparency_t = type(bgTransparency);
    
    if (bgTransparency_t ~= "number") then
        error("bad argument #1 to 'bgTransparency' (number expected, got " ..bgTransparency_t.. ")", 2);
    elseif (bgTransparency < 0) or (bgTransparency > 1) then
        error("bad argument #1 to 'bgTransparency' (value out of bounds)", 2);
    end
    
    
    obj.bgTransparency = bgTransparency;
    
    
    obj.draw(true);
end


function set.borderColor3(obj, borderColor3)
    local borderColor3_t = type(borderColor3);
    
    if (borderColor3_t ~= "Color3") then
        error("bad argument #1 to 'borderColor3' (Color3 expected, got " ..borderColor3_t.. ")", 2);
    end
    
    
    obj.borderColor3 = borderColor3;
    
    
    obj.draw(true);
end

function set.borderSize(obj, borderSize)
    local borderSize_t = type(borderSize);
    
    if (borderSize_t ~= "number") then
        error("bad argument #1 to 'borderSize' (number expected, got " ..borderSize_t.. ")", 2);
    elseif (borderSize < 0) or (borderSize > MAX_BORDER_SIZE) then
        error("bad argument #1 to 'borderSize' (value out of bounds)", 2);
    end
    
    
    obj.borderSize = floor(borderSize);
    
    
    func.update_rtAbsSize(obj);
    func.update_rtAbsPos(obj);
    func.update_rtTransformPivot(obj);
    func.update_rtTransformPerspective(obj);
    func.update_rt(obj);
    
    
    func.update(obj);
    
    obj.draw(true);
end

function set.borderTransparency(obj, borderTransparency)
    local borderTransparency_t = type(borderTransparency);
    
    if (borderTransparency_t ~= "number") then
        error("bad argument #1 to 'borderTransparency' (number expected, got " ..borderTransparency_t.. ")", 2);
    elseif (borderTransparency < 0) or (borderTransparency > 1) then
        error("bad argument #1 to 'borderTransparency' (invalid value)", 2);
    end
    
    
    obj.borderTransparency = borderTransparency;
    
    
    obj.draw(true);
end


function set.size(obj, size, prev, k)
    local size_t = type(size);
    
    if (size_t ~= "UDim2") then
        error("bad argument #1 to 'size' (UDim2 expected, got " ..size_t.. ")", 2);
    end
    
    
    obj.size = size;
    
    
    func.update_absSize(obj);
    func.update_absPos(obj);
    
    func.update_absRotPivot(obj);
    func.update_absRotPerspective(obj);
    
    func.update_rtAbsSize(obj);
    func.update_rtAbsPos(obj);
    func.update_rtTransformPivot(obj);
    func.update_rtTransformPerspective(obj);
    func.update_rt(obj);
    
    
    if (k == 1) then
        func.update(obj);
        
        obj.draw(true);
    end
end


function set.pos(obj, pos)
    local pos_t = type(pos);
    
    if (pos_t ~= "UDim2") then
        error("bad argument #1 to 'pos' (UDim2 expected, got " ..pos_t.. ")", 2);
    end
    
    
    obj.pos = pos;
    
    
    func.update_absPos(obj);
    
    func.update_absRotPivot(obj);
    func.update_absRotPerspective(obj);
    
    func.update_rtAbsPos(obj);
    func.update_rtTransformPivot(obj);
    func.update_rtTransformPerspective(obj);
    
    
    func.update(obj);
    
    obj.draw(true);
end

function set.posOrigin(obj, posOrigin)
    local posOrigin_t = type(posOrigin);
    
    if (posOrigin_t ~= "UDim2") then
        error("bad argument #1 to 'pos' (UDim2 expected, got " ..posOrigin_t.. ")", 2);
    end
    
    
    obj.posOrigin = posOrigin;
    
    
    func.update_absPos(obj);
    
    func.update_absRotPivot(obj);
    func.update_absRotPerspective(obj);
    
    func.update_rtAbsPos(obj);
    func.update_rtTransformPivot(obj);
    func.update_rtTransformPerspective(obj);
    
    
    func.update(obj);
    
    obj.draw(true);
end


function set.rot(obj, rot)
    local rot_t = type(rot);
    
    if (rot_t ~= "Vector3") then
        error("bad argument #1 to 'rot' (Vector3 expected, got " ..rot_t.. ")", 2);
    end
    
    
    obj.rot = rot;
    
    
    func.update_isRotated(obj);
    func.update_isRotated3D(obj);
    
    func.update_rtTransformPivot(obj);
    func.update_rtTransformPerspective(obj);
    
    
    obj.draw(true);
end

function set.rotPivot(obj, rotPivot)
    local rotPivot_t = type(rotPivot);
    
    if (rotPivot_t ~= "UDim2") then
        error("bad argument #1 to 'rotPivot' (UDim2 expected, got " ..rotPivot_t.. ")", 2);
    end
    
    obj.rotPivot = rotPivot;
    
    
    func.update_absRotPivot(obj);
    
    func.update_rtTransformPivot(obj);
    
    
    obj.draw(true);
end

function set.rotPivotDepth(obj, rotPivotDepth)
    local rotPivotDepth_t = type(rotPivotDepth);
    
    if (rotPivotDepth_t ~= "number") then
        error("bad argument #1 to 'rotPivotDepth' (number expected, got " ..rotPivotDepth_t.. ")", 2);
    elseif (rotPivotDepth <= ROT_ACTUAL_NEAR_Z_PLANE/2 or rotPivotDepth > ROT_FAR_Z_PLANE/2) then
        error("bad argument #1 to 'rotPivotDepth' (value out of bounds)", 2);
    end
    
    obj.rotPivotDepth = rotPivotDepth;
    
    
    func.update_absRotPivot(obj);
    func.update_isRotated3D(obj);
    
    func.update_rtTransformPivot(obj);
    
    
    obj.draw(true);
end

function set.rotPerspective(obj, rotPerspective)
    local rotPerspective_t = type(rotPerspective);
    
    if (rotPerspective_t ~= "UDim2") then
        error("bad argument #1 to 'rotPerspective' (UDim2 expected, got " ..rotPerspective_t.. ")", 2);
    end
    
    
    obj.rotPerspective = rotPerspective;
    
    
    func.update_absRotPerspective(obj);
    
    func.update_rtTransformPerspective(obj);
    
    
    obj.draw(true);
end


function set.visible(obj, visible, prev, k)
    local visible_t = type(visible);
    
    if (visible_t ~= "boolean") then
        error("bad argument #1 to 'visible' (boolean expected, got " ..visible_t.. ")", 2);
    end
    
    
    obj.visible = visible;
    
    
    func.update_rt(obj);
    
    
    if (k == 1) then
        if (visible) then
            func.update(obj);
        end
        
        obj.draw(true);
    end
end


function set.debug(obj, debug)
    local debug_t = type(debug);
    
    if (debug_t ~= "boolean") then
        error("bad argument #1 to 'debug' (boolean expected, got " ..debug_t.. ")", 2);
    end
    
    
    obj.debug = debug;
    
    
    obj.draw(true);
end



GuiObject = {
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    private  = private,
    readOnly = readOnly,
    
    new = new,
    
    
    RT_ADDITIONAL_MARGIN = RT_ADDITIONAL_MARGIN,
    
    MAX_BORDER_SIZE = MAX_BORDER_SIZE,

    ROT_NEAR_Z_PLANE        = ROT_NEAR_Z_PLANE,
    ROT_ACTUAL_NEAR_Z_PLANE = ROT_ACTUAL_NEAR_Z_PLANE,
    ROT_FAR_Z_PLANE         = ROT_FAR_Z_PLANE,

    ROT_PIVOT_DEPTH_UNIT = ROT_PIVOT_DEPTH_UNIT,
    
    SHADER = SHADER,
}
