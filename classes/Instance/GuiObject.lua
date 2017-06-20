-- local Color3  = require("Color3");
-- local Vector2 = require("Vector2");



local name = "GuiObject";

local super = GuiBase2D;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get [key] end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set [key] end });

local private = setmetatable({
        updateDescendatsRt = true,
    },
    
    { __index = function(tbl, key) return super.private[key] end }
);

local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });



local function new(obj)
	super.new(obj);
	
	obj.bgColor3       = PROXY__OBJ[Color3.new(255, 255, 255)];
	obj.bgTransparency = 0;
	
	obj.borderColor3       = PROXY__OBJ[Color3.new(27, 42, 53)];
	obj.borderOffset       = 1;
	obj.borderSize         = 1;
	obj.borderTransparency = 0;
	
	obj.clipsDescendants = false;
	
	obj.pos  = nil;
	obj.size = nil;
    
	obj.visible = true;
    
    
    obj.absRot      = PROXY__OBJ[Vector3.new(0, 0, 0)];
    obj.absRotPivot = PROXY__OBJ[Vector2.new(0, 0)];
    
    obj.rot      = PROXY__OBJ[Vector3.new(0, 0, 0)];
    obj.rotPivot = PROXY__OBJ[UDim2.new(0, 0, 0, 0)];
	
    obj.shader = dxCreateShader("shaders/nothing.fx");
end



function func.updateDescendatsRt(obj, rtSize)
	if isElement(obj.rt) then
        destroyElement(obj.rt);
    end
	
	obj.rt     = dxCreateRenderTarget(rtSize.x, rtSize.y, true);
	obj.rtSize = rtSize;
	
	for i = 1, #obj.children do
        func.updateDescendatsRt(obj.children[i], rtSize);
    end
end



function set.parent(obj, parent, prevParent)
    local success, result = pcall(super.set.parent, obj, parent, prevParent);
    if (not success) then error(result, 2) end
    
    
	if (prevParent) and Instance.func.isA(prevParent, "GuiBase2D") then
        prevParent.draw();
	end
	
	if (parent) and Instance.func.isA(parent, "GuiBase2D") then
        
        -- for example if switching from a ScreenGui to a SurfaceGui which has different rt size
        -- this also includes the scenario in which obj was just created and has a nil rtSize
		if (parent.rtSize ~= obj.rtSize) then
            func.updateDescendatsRt(obj, parent.rtSize);
        end
        
        -- update size and pos (because of relative pos / size)
        set.pos (obj, obj.pos);
		set.size(obj, obj.size);
        
        -- update rot (for absRot)
        if Instance.func.isA(parent, "GuiObject") then
            set.rot(obj, obj.rot);
        end
        
        obj.draw();
    else
        if isElement(obj.rt) then
            destroyElement(obj.rt);
        end
        
        obj.rt     = nil;
        obj.rtSize = nil;
	end
end


function set.bgColor3(obj, bgColor3)
	local bgColor3Type = type(bgColor3);
    
	if (bgColor3Type ~= "Color3") then
        error("bad argument #1 to 'bgColor3' (Color3 expected, got " ..bgColor3Type.. ")", 2);
    end
	
    
	obj.bgColor3 = bgColor3;
	
	obj.draw();
end

function set.bgTransparency(obj, bgTransparency)
	local bgTransparencyType = type(bgTransparency);
    
	if (BackgroundTransparencyType ~= "number") then
        error("bad argument #1 to 'bgTransparency' (number expected, got " ..bgTransparencyType.. ")", 2);
	elseif (bgTransparency < 0) or (bgTransparency > 1) then
        error("bad argument #1 to 'bgTransparency' (value out of bounds)", 2);
    end
	
    
	obj.bgTransparency = bgTransparency;
	
	obj.draw();
end


function set.borderColor3(obj, borderColor3)
	local borderColor3Type = type(borderColor3);
    
	if (borderColor3Type ~= "Color3") then
        error("bad argument #1 to 'borderColor3' (Color3 expected, got " ..borderColor3Type.. ")", 2);
    end
	
    
	obj.borderColor3 = borderColor3;
	
	obj.draw();
end

function set.borderOffset(obj, borderOffset)
	local borderOffsetType = type(borderOffset);
    
	if (borderOffsetType ~= "number") then
        error("bad argument #1 to 'borderOffset' (number expected, got " ..borderOffsetType.. ")", 2);
	elseif (borderOffset%1 ~= 0) then
        error("bad argument #1 to 'borderOffset' (number has no integer representation)", 2);
	elseif (borderOffset < 0) or (borderOffset > obj.borderSize) then
        error("bad argument #1 to 'borderOffset' (invalid value)", 2);
    end
	
    
	obj.borderOffset = borderOffset;
	
	obj.draw();
end

function set.borderSize(obj, borderSize)
	local borderSizeType = type(borderSize);
    
	if (borderSizeType ~= "number") then
        error("bad argument #1 to 'borderSize' (number expected, got " ..borderSizeType.. ")", 2);
	elseif (borderSize%1 ~= 0) then
        error ("bad argument #1 to 'borderSize' (number has no integer representation)", 2);
	elseif (borderSize < 0) then
        error("bad argument #1 to 'borderSize' (invalid value)", 2);
    end
	
    
	if (obj.borderOffset > borderSize) then
        obj.borderOffset = borderSize;
    end
    
	obj.borderSize = borderSize;
	
	obj.draw();
end

function set.borderTransparency(obj, borderTransparency)
	local borderTransparencyType = type(borderTransparency);
    
	if (borderTransparencyType ~= "number") then
        error("bad argument #1 to 'borderTransparency' (number expected, got " ..borderTransparencyType.. ")", 2);
	elseif (borderTransparency < 0) or (borderTransparency > 1) then
        error("bad argument #1 to 'borderTransparency' (invalid value)", 2);
    end
	
    
	obj.borderTransparency = borderTransparency;
	
	obj.draw();
end


function set.clipsDescendants(obj, clipsDescendants)
	local clipsDescendantsType = type(clipsDescendants);
    
	if (clipsDescendantsType ~= "boolean") then
        error("bad argument #1 to 'clipsDescendants' (boolean expected, got " ..clipsDescendantsType.. ")", 2);
    end
	
    
	obj.clipsDescendants = clipsDescendants;
	
	for i = 1, #obj.children do
		obj.children[i].draw();
	end
end


function set.pos(obj, pos)
	local posType = type(pos);
    
	if (posType ~= "UDim2") then
        error("bad argument #1 to 'pos' (UDim2 expected, got " ..posType.. ")", 2);
    end
	
    
	obj.pos = pos;
	
    local parent = obj.parent;
    
	if (parent) and Instance.func.isA(parent, "GuiBase2D") then
        obj.absPos = PROXY__OBJ[Vector2.new(
			parent.absPos.x+pos.x.offset + parent.absSize.x*pos.x.scale,
			parent.absPos.y+pos.y.offset + parent.absSize.y*pos.y.scale
		)];
	end
    
    obj.draw();
end

function set.size(obj, size)
	local sizeType = type(size);
    
	if (sizeType ~= "UDim2") then
        error("bad argument #1 to 'size' (UDim2 expected, got " ..sizeType.. ")", 2);
    end
	
	
	obj.size = size;
	
    local parent = obj.parent;
    
	if (parent) and Instance.func.isA(parent, "GuiBase2D") then
		obj.absSize = PROXY__OBJ[Vector2.new(
			size.x.offset + parent.absSize.x*size.x.scale,
			size.y.offset + parent.absSize.y*size.y.scale
		)];
		
        for i = 1, #obj.children do
            local child = obj.children[i];
            
            set.pos (obj, child.pos);
            set.size(obj, child.size); -- TODO: check if updates recursively with more than 2 objects
        end
	end
    
    obj.draw();
end


function set.visible(obj, visible)
	local visibleType = type(visible);
    
	if (visibleType ~= "boolean") then
        error("bad argument #1 to 'visible' (boolean expected, got " ..visibleType.. ")", 2);
    end
	
	
	obj.visible = visible;
	
	obj.draw();
end


function set.rot(obj, rot)
    local rotType = type(rot);
    
    if (rotType ~= "Vector3") then
        error("bad argument #1 to 'rot' (Vector3 expected, got " ..rotType.. ")", 2);
    end
    
    
    obj.rot = rot;
    
    local parent = obj.parent;
    
    if (parent) and Instance.func.isA(parent, "GuiObject") then
        obj.absRot = PROXY__OBJ[Vector3.new(
            parent.absRot.x + rot.x,
            parent.absRot.y + rot.y,
            parent.absRot.z + rot.z
        )];
    else
        obj.absRot = rot;
    end
    
    dxSetShaderTransform(obj.shader, rot.x, rot.y, rot.z);
    
    obj.draw();
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
}
