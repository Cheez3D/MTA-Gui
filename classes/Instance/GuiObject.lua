-- local Color3  = require("Color3");
-- local Vector2 = require("Vector2");



local name = "GuiObject";

local super = GuiBase2D;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get [key] end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set [key] end });

local private = setmetatable({
        update_rootGui = true,
        
        update_clipperGui = true,
        update_rt         = true,
        
        update_absSize = true,
        
        update_absPosOrigin = true,
        update_absPos       = true,
        
        update_absRot      = true,
        update_absRotPivot = true,
        
        update = true,
    },
    
    { __index = function(tbl, key) return super.private[key] end }
);

local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });


local MAX_BORDER_SIZE = 64;

local SHADER = dxCreateShader("shaders/nothing.fx"); -- TODO: add check for successful creation (dxSetTestMode)



local function new(obj)
	super.new(obj);
	
	obj.bgColor3       = PROXY__OBJ[Color3.new(255, 255, 255)];
	obj.bgTransparency = 0;
	
	obj.borderColor3       = PROXY__OBJ[Color3.new(27, 42, 53)];
	obj.borderSize         = 1;
	obj.borderTransparency = 0;
	
	obj.clipsDescendants = true;
	
    
    obj.size = nil;
    
    obj.posOrigin = PROXY__OBJ[UDim2.new(0, 0, 0, 0)];
	obj.pos       = nil;
    
    obj.rot      = PROXY__OBJ[Vector3.new(0, 0, 0)];
    obj.rotPivot = PROXY__OBJ[UDim2.new(0.5, 0, 0.5, 0)];
    func.update_isRotated(obj);
    
    
	obj.visible = true;
end


-- TODO: add onClientRestore rt recreation when rts were cleared

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


function func.update_clipperGui(obj)
    obj.clipperGui = obj.rootGui and (
           (obj.parent == obj.rootGui)   and obj.rootGui
        or (obj.parent.clipsDescendants) and obj.parent
        or                                   obj.parent.clipperGui
    ) or nil;
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_clipperGui(child);
        end
    end
end

function func.update_rt(obj)
    if isElement(obj.rt) then destroyElement(obj.rt) end -- destroy previous rt to free video memory
    
    obj.rt = obj.clipperGui and dxCreateRenderTarget(obj.clipperGui.absSize.x, obj.clipperGui.absSize.y, true) or nil;
    
    -- recursively update all children rts
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_rt(child);
        end
    end
end


function func.update_absSize(obj)
    obj.absSize = obj.rootGui and PROXY__OBJ[Vector2.new(
        obj.size.x.offset + obj.parent.absSize.x*obj.size.x.scale,
        obj.size.y.offset + obj.parent.absSize.y*obj.size.y.scale
    )] or nil;
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_absSize(child);
        end
    end
end


function func.update_absPosOrigin(obj)
    obj.absPosOrigin = obj.absSize and PROXY__OBJ[Vector2.new(
        obj.posOrigin.x.offset + obj.absSize.x*obj.posOrigin.x.scale,
        obj.posOrigin.y.offset + obj.absSize.y*obj.posOrigin.y.scale
    )] or nil;
end

function func.update_absPos(obj)
    obj.absPos = obj.rootGui and PROXY__OBJ[Vector2.new(
        obj.parent.absPos.x + (obj.pos.x.offset + obj.parent.absSize.x*obj.pos.x.scale - obj.absPosOrigin.x),
        obj.parent.absPos.y + (obj.pos.y.offset + obj.parent.absSize.y*obj.pos.y.scale - obj.absPosOrigin.y)
    )] or nil;
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_absPos(child);
        end
    end
end


function func.update_isRotated(obj)
    obj.isRotated = (obj.rot.x%360 ~= 0) or (obj.rot.y%360 ~= 0) or (obj.rot.z%360 ~= 0);
end

function func.update_rotDrawParams(obj)
    -- if object is rotated then calculate offset for drawing object exactly in the middle of the parent rt
    -- so that when rotating the chance of something to be percieved as cut off is very small
    -- (something will be seen as cut off only when it is drawn outside of the parent rt boundaries and the object is rotated
    --  so that it can be visible inside the parent)
    
    local ascendantGui = obj.rootGui and (obj.parent.clipperGui or obj.rootGui); -- because rootGui does not have a clipperGui member
    
    obj.rotDrawOffset = ascendantGui and obj.isRotated and PROXY__OBJ[Vector2.new(
        (ascendantGui.absSize.x-obj.clipperGui.absSize.x)/2,
        (ascendantGui.absSize.y-obj.clipperGui.absSize.y)/2
    )] or nil;
    
    obj.rotDrawSize = ascendantGui and obj.isRotated and PROXY__OBJ[Vector2.new(ascendantGui.absSize.x, ascendantGui.absSize.y)] or nil;
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_rotDrawParams(child);
        end
    end
end

function func.update_absRot(obj)
    obj.absRot = obj.rootGui and PROXY__OBJ[Vector3.new(
        obj.parent.absRot.x + obj.rot.x,
        obj.parent.absRot.y + obj.rot.y,
        obj.parent.absRot.z + obj.rot.z
    )] or nil;
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_absRot(child);
        end
    end
end

function func.update_absRotPivot(obj)
    obj.absRotPivot = obj.rootGui and PROXY__OBJ[Vector2.new(
        obj.absPos.x + (obj.rotPivot.x.offset + obj.absSize.x*obj.rotPivot.x.scale),
        obj.absPos.y + (obj.rotPivot.y.offset + obj.absSize.y*obj.rotPivot.y.scale)
    )] or nil;
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        -- TODO
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



function set.parent(obj, parent, prevParent)
    local success, result = pcall(super.set.parent, obj, parent, prevParent);
    if (not success) then error(result, 2) end
    
    
	if (prevParent) and Instance.func.isA(prevParent, "GuiBase2D") then
        prevParent.draw(true);
	end
	
    
    func.update_rootGui(obj);
    
    func.update_clipperGui(obj);
    func.update_rt(obj);
    
    
    func.update_absSize(obj);
    
    func.update_absPosOrigin(obj);
    func.update_absPos(obj);
    
    
    func.update_rotDrawParams(obj);
    
    func.update_absRot(obj);
    func.update_absRotPivot(obj);
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update(child);
        end
    end
        
    obj.draw(true);
end


function set.bgColor3(obj, bgColor3)
	local bgColor3Type = type(bgColor3);
    
	if (bgColor3Type ~= "Color3") then
        error("bad argument #1 to 'bgColor3' (Color3 expected, got " ..bgColor3Type.. ")", 2);
    end
	
    
	obj.bgColor3 = bgColor3;
	
	obj.draw(true);
end

function set.bgTransparency(obj, bgTransparency)
	local bgTransparencyType = type(bgTransparency);
    
	if (bgTransparencyType ~= "number") then
        error("bad argument #1 to 'bgTransparency' (number expected, got " ..bgTransparencyType.. ")", 2);
	elseif (bgTransparency < 0) or (bgTransparency > 1) then
        error("bad argument #1 to 'bgTransparency' (value out of bounds)", 2);
    end
	
    
	obj.bgTransparency = bgTransparency;
	
	obj.draw(true);
end


function set.borderColor3(obj, borderColor3)
	local borderColor3Type = type(borderColor3);
    
	if (borderColor3Type ~= "Color3") then
        error("bad argument #1 to 'borderColor3' (Color3 expected, got " ..borderColor3Type.. ")", 2);
    end
	
    
	obj.borderColor3 = borderColor3;
	
	obj.draw(true);
end

function set.borderSize(obj, borderSize)
	local borderSizeType = type(borderSize);
    
	if (borderSizeType ~= "number") then
        error("bad argument #1 to 'borderSize' (number expected, got " ..borderSizeType.. ")", 2);
	elseif (borderSize%1 ~= 0) then
        error ("bad argument #1 to 'borderSize' (number has no integer representation)", 2);
	elseif (borderSize < 0) or (borderSize > MAX_BORDER_SIZE) then
        error("bad argument #1 to 'borderSize' (value out of bounds)", 2);
    end
	
    
	obj.borderSize = borderSize;
	
	obj.draw(true);
end

function set.borderTransparency(obj, borderTransparency)
	local borderTransparencyType = type(borderTransparency);
    
	if (borderTransparencyType ~= "number") then
        error("bad argument #1 to 'borderTransparency' (number expected, got " ..borderTransparencyType.. ")", 2);
	elseif (borderTransparency < 0) or (borderTransparency > 1) then
        error("bad argument #1 to 'borderTransparency' (invalid value)", 2);
    end
	
    
	obj.borderTransparency = borderTransparency;
	
	obj.draw(true);
end


function set.clipsDescendants(obj, clipsDescendants)
	local clipsDescendantsType = type(clipsDescendants);
    
	if (clipsDescendantsType ~= "boolean") then
        error("bad argument #1 to 'clipsDescendants' (boolean expected, got " ..clipsDescendantsType.. ")", 2);
    end
	
    
	obj.clipsDescendants = clipsDescendants;
	
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_clipperGui(child);
            func.update_rt(child);
            
            func.update_rotDrawParams(child);
            
            func.update(child);
        end
	end
    
    obj.draw(true);
end


function set.pos(obj, pos)
	local posType = type(pos);
    
	if (posType ~= "UDim2") then
        error("bad argument #1 to 'pos' (UDim2 expected, got " ..posType.. ")", 2);
    end
	
    
	obj.pos = pos;
	
    func.update_absPos(obj);
    
    func.update_absRotPivot(obj);
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update(child);
        end
    end
    
    obj.draw(true);
end

function set.size(obj, size)
	local sizeType = type(size);
    
	if (sizeType ~= "UDim2") then
        error("bad argument #1 to 'size' (UDim2 expected, got " ..sizeType.. ")", 2);
    end
	
	
	obj.size = size;
	
    func.update_absSize(obj);
    
    func.update_absPosOrigin(obj);
    func.update_absPos(obj);
    
    func.update_absRotPivot(obj);
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update_rt(child);
            
            func.update(child);
        end
    end
    
    obj.draw(true);
end

function set.posOrigin(obj, posOrigin)
    local posOriginType = type(posOrigin);
    
	if (posOriginType ~= "UDim2") then
        error("bad argument #1 to 'pos' (UDim2 expected, got " ..posOriginType.. ")", 2);
    end
    
    
    obj.posOrigin = posOrigin;
    
    func.update_absPosOrigin(obj);
    func.update_absPos(obj);
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiObject") then
            func.update(child);
        end
    end
    
    obj.draw(true);
end


function set.rot(obj, rot)
    local rotType = type(rot);
    
    if (rotType ~= "Vector3") then
        error("bad argument #1 to 'rot' (Vector3 expected, got " ..rotType.. ")", 2);
    end
    
    
    obj.rot = rot;
    
    func.update_isRotated(obj);
    func.update_rotDrawParams(obj);
    
    func.update_absRot(obj);
    
    obj.draw(true);
end

function set.rotPivot(obj, rotPivot)
    local rotPivotType = type(rotPivot);
    
	if (rotPivotType ~= "UDim2") then
        error("bad argument #1 to 'pos' (UDim2 expected, got " ..rotPivotType.. ")", 2);
    end
    
    obj.rotPivot = rotPivot;
    
    func.update_absRotPivot(obj);
    
    obj.draw(true);
end


function set.visible(obj, visible)
	local visibleType = type(visible);
    
	if (visibleType ~= "boolean") then
        error("bad argument #1 to 'visible' (boolean expected, got " ..visibleType.. ")", 2);
    end
	
	
	obj.visible = visible;
	
	obj.draw(true);
end


function set.debug(obj, debug)
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
    
    
    SHADER = SHADER,
}
