local name = "GuiContainer";

local super = GuiObject;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get [key] end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set [key] end });

local private  = setmetatable({}, { __index = function(tbl, key) return super.private [key] end });
local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });



local function new(obj)
    super.new(obj);
    
    obj.clipsDescendants = true;
end



function func.update_containerGui(obj)
    obj.containerGui = obj.rootGui and (
           obj.clipsDescendants        and obj
        or (obj.parent == obj.rootGui) and obj.parent
        or                                 obj.parent.containerGui
    ) or nil;
    
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "GuiContainer") then
            func.update_containerGui(child);
        end
    end
end

function func.update_containerTransformPivot(obj)
    
end

function func.update_containerTransformPerspective(obj)
    
end

function func.update_container(obj)
    if isElement(obj.container) then destroyElement(obj.container) end
    
    obj.container = obj.rootGui and obj.visible and dxCreateRenderTarget(
        obj.containerGui.absSize.x,
        obj.containerGui.absSize.y,
        
        true
    ) or nil;
    
    
    for i = 1, #obj.children do
        local child = obj.children[i];
        
        if Instance.func.isA(child, "Frame") then
            func.update_container(child);
        end
    end
end



function set.parent(obj, parent, prev, k)
    local success, result = pcall(super.set.parent, obj, parent, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_containerGui(obj);
    func.update_container(obj);
    
    
    GuiObject.func.update(obj);
    
    obj.draw(true);
end


function set.size(obj, size, prev, k)
    local success, result = pcall(super.set.size, obj, size, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_container(obj);
    
    
    GuiObject.func.update(obj);
    
    obj.draw(true);
end


function set.visible(obj, visible, prev, k)
    local success, result = pcall(super.set.visible, obj, visible, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update_container(obj);
    
    
    if (visible) then
        GuiObject.func.update(obj);
    end
    
    obj.draw(true);
end


function set.clipsDescendants(obj, clipsDescendants)
    local clipsDescendants_t = type(clipsDescendants);
    
    if (clipsDescendants_t ~= "boolean") then
        error("bad argument #1 to 'clipsDescendants' (boolean expected, got " ..clipsDescendants_t.. ")", 2);
    end
    
    
    obj.clipsDescendants = clipsDescendants;
    
    
    func.update_containerGui(obj);
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
    
    private  = private,
    readOnly = readOnly,
    
    new = new,
}
