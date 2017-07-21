local name = "GuiContainer";

local super = GuiObject;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get[key]  end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set[key]  end });

local event = setmetatable({}, { __index = function(tbl, key) return super.event[key] end });

local private  = setmetatable({}, { __index = function(tbl, key) return super.private[key]  end });
local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });



local function new(obj)
    super.new(obj);
    
    obj.clipsDescendants = true;
end



function func.update_clippingGui(obj)
    if (obj.rootGui) then
        if     (obj.clipsDescendants)      then obj.clippingGui = obj;
        elseif (obj.parent == obj.rootGui) then obj.clippingGui = obj.parent;
        else                                    obj.clippingGui = obj.parent.clippingGui;
        end
    else
        obj.clippingGui = nil;
    end
    
    
    for i = 1, #obj.guiChildren do
        local child = obj.guiChildren[i];
        
        if Instance.func.isA(child, "GuiContainer") then
            func.update_clippingGui(child);
        end
    end
end


function func.update_containerSize(obj)
    if (obj.rootGui) then
        obj.containerSize = obj.clippingGui.absSize;
    else
        obj.containerSize = nil;
    end
end

function func.update_containerPos(obj)
    if (obj.rootGui) then
        obj.containerPos = obj.clippingGui.absPos;
    else
        obj.containerPos = nil;
    end
end

function func.update_containerRotPivot(obj)
    if (obj.rootGui and obj.isRotated) then
        obj.containerRotPivot = Vector3.new(
            2*(-obj.containerSize.x/2 + obj.absRotPivot.x-obj.containerPos.x),
            2*(-obj.containerSize.y/2 + obj.absRotPivot.y-obj.containerPos.y),
            
            2*(obj.absRotPivot.z/GuiObject.ROT_PIVOT_DEPTH_UNIT)
        )
        
        obj.containerRotPivot = obj.containerRotPivot/(obj.parent == obj.rootGui and obj.parent.absSize or obj.parent.containerSize);
    else
        obj.containerRotPivot = nil;
    end
    
    
    for i = 1, #obj.guiChildren do
        local child = obj.guiChildren[i];
        
        if Instance.func.isA(child, "GuiContainer") then
            func.update_containerRotPivot(child);
        end
    end
end

function func.update_containerRotPerspective(obj)
    if (obj.rootGui and obj.isRotated3D) then
        obj.containerRotPerspective = Vector2.new(
            2*(-obj.containerSize.x/2 + obj.absRotPerspective.x-obj.containerPos.x),
            2*(-obj.containerSize.y/2 + obj.absRotPerspective.y-obj.containerPos.y)
        );
        
        obj.containerRotPerspective = obj.containerRotPerspective/(obj.parent == obj.rootGui and obj.parent.absSize or obj.parent.containerSize);
    else
        obj.containerRotPerspective = nil;
    end
    
    
    for i = 1, #obj.guiChildren do
        local child = obj.guiChildren[i];
        
        if Instance.func.isA(child, "GuiContainer") then
            func.update_containerRotPerspective(child);
        end
    end
end





function set.parent(obj, parent, prev, k)
    local success, result = pcall(super.set.parent, obj, parent, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_clippingGui(obj);
    
    func.update_containerSize(obj);
    func.update_containerPos(obj);
    func.update_containerRotPivot(obj);
    func.update_containerRotPerspective(obj);
    func.update_container(obj);
    
    
    GuiObject.func.update(obj);
    
    obj.draw(true);
end


function set.size(obj, size, prev, k)
    local success, result = pcall(super.set.size, obj, size, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_containerSize(obj);
    func.update_containerPos(obj);
    func.update_containerRotPivot(obj);
    func.update_containerRotPerspective(obj);
    func.update_container(obj);
    
    
    GuiObject.func.update(obj);
    
    obj.draw(true);
end


function set.rot(obj, rot, prev, k)
    local success, result = pcall(super.set.rot, obj, rot, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_containerRotPivot(obj);
    func.update_containerRotPerspective(obj);
    
    
    obj.draw(true);
end

function set.rotPivot(obj, rotPivot, prev, k)
    local success, result = pcall(super.set.rotPivot, obj, rotPivot, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_containerRotPivot(obj);
    
    
    obj.draw(true);
end

function set.rotPivotDepth(obj, rotPivotDepth, prev, k)
    local success, result = pcall(super.set.rotPivotDepth, obj, rotPivotDepth, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_containerRotPivot(obj);
    
    
    obj.draw(true);
end

function set.rotPerspective(obj, rotPerspective, prev, k)
    local success, result = pcall(super.set.rotPerspective, obj, rotPerspective, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_containerRotPerspective(obj);
    
    
    obj.draw(true);
end


function set.visible(obj, visible, prev, k)
    local success, result = pcall(super.set.visible, obj, visible, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_container(obj);
    
    
    GuiObject.func.update(obj);
    
    obj.draw(true);
end


function set.clipsDescendants(obj, clipsDescendants)
    local clipsDescendants_t = type(clipsDescendants);
    
    if (clipsDescendants_t ~= "boolean") then
        error("bad argument #1 to 'clipsDescendants' (boolean expected, got " ..clipsDescendants_t.. ")", 2);
    end
    
    
    obj.clipsDescendants = clipsDescendants;
    
    
    func.update_clippingGui(obj);
    
    func.update_containerSize(obj);
    func.update_containerPos(obj);
    
    GuiObject.func.update_rtRotPivot(obj);
    GuiObject.func.update_rtRotPerspective(obj);
    
    func.update_containerRotPivot(obj);
    func.update_containerRotPerspective(obj);
    func.update_container(obj);
    
    
    GuiObject.func.update(obj);
    
    obj.draw(true);
end



GuiContainer = {
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    event = event,
    
    private  = private,
    readOnly = readOnly,
    
    new = new,
}
