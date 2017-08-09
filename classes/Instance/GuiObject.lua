local super = classes.GuiBase2D;

local class = inherit({
    name = "GuiObject",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = false,
}, super);

classes[class.name] = class;

local func = class.func;
local get  = class.get;
local set  = class.set;



class.DEBUG_CANVAS_COLOR = tocolor(255, 0, 255, 127.5);

class.DEBUG_VERTEX_LINE_COLOR = tocolor(255, 0, 0, 200);
class.DEBUG_VERTEX_LINE_THICKNESS = 2;

class.CANVAS_ADDITIONAL_MARGIN = 1; -- added so that canvas can be properly anti-aliased when rotated

class.MAX_BORDER_SIZE = 100;

class.ROT_NEAR_Z_PLANE        = -1000;
class.ROT_ACTUAL_NEAR_Z_PLANE = -900;
class.ROT_FAR_Z_PLANE         =  9000;

class.ROT_PIVOT_DEPTH_UNIT = 1000;

class.SHADER = dxCreateShader("shaders/nothing.fx"); -- TODO: add check for successful creation (dxSetTestMode)



function class.new(...)
    local success, obj = pcall(super.new, ...);
    if (not success) then error(obj, 2) end
    
    
    obj.guiIndex = nil; -- index in guiChildren array of parent
    
    obj.quad = {}
    
    
    class.set.debug(obj, false);
    
    
    class.set.clipsDescendants(obj, true);
    
    class.set.bgColor(obj, Color3.new(255, 255, 255));
    class.set.bgTransparency(obj, 0);
    
    class.set.borderColor(obj, Color3.new(27, 42, 53));
    class.set.borderSize(obj, 1);
    class.set.borderTransparency(obj, 0);
    
    class.set.size(obj, UDim2.new(0, 100, 0, 100));
    class.set.pos(obj, UDim2.new());
    class.set.posOrigin(obj, UDim2.new());
    
    class.set.rot(obj, Vector3.new());
    class.set.rotPivot(obj, UDim2.new(0.5, 0, 0.5, 0));
    class.set.rotPivotDepth(obj, 0);
    class.set.rotPerspective(obj, obj.rotPivot);
    
    class.set.visible(obj, true);
    
    
    return obj;
end

meta = extend({}, super.meta);



function class.func.update_rootGui(obj, descend)
    local rootGui = obj.parent and obj.parent:isA("GuiBase2D") and (
        obj.parent:isA("RootGui") and obj.parent
        or obj.parent:isA("GuiObject") and obj.parent.rootGui
    )
    or nil;
    
    if (rootGui ~= obj.rootGui) then
        obj.rootGui = rootGui;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                obj.guiChildren[i]:update_rootGui(true);
            end
        end
    end
end


function class.func.update_clipperGui(obj, descend)
    local clipperGui = obj.rootGui and (
        obj.clipsDescendants and obj
        or obj.parent:isA("RootGui") and obj.parent
        or obj.parent.clipperGui
    )
    or nil;
    
    if (clipperGui ~= obj.clipperGui) then
        obj.clipperGui = clipperGui;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_clipperGui(true);
        end
    end
end


function class.func.update_isRotated(obj)
    if (obj.rot.x%180 == 0 and (obj.rot.x == obj.rot.y and obj.rot.y == obj.rot.z)) then
        obj.isRotated = false;
    elseif (obj.rot.x%360 == 0 and obj.rot.y%360 == 0 and obj.rot.z%360 == 0) then
        obj.isRotated = false;
    else
        obj.isRotated = true;
    end
end

function class.func.update_isRotated3D(obj)
    if (not obj.isRotated) then
        obj.isRotated3D = false;
    elseif ((obj.rot.x%180 == 0 and obj.rot.y%180 == 0) and obj.rotPivotDepth == 0) then
        obj.isRotated3D = false;
    elseif (obj.rot.x%180 == 0 and (obj.rot.x == obj.rot.y)) then
        obj.isRotated3D = false;
    else
        obj.isRotated3D = true;
    end
end

function class.func.update_rotMatrix(obj)
    local rotMatrix;
    
    if (obj.isRotated) then
        -- calculate rotation matrices for each plane
        local ax = math.rad(obj.rot.x);
        local ay = math.rad(obj.rot.y);
        local az = math.rad(obj.rot.z);
        
        local sx, cx = math.sin(ax), math.cos(ax);
        local sy, cy = math.sin(ay), math.cos(ay);
        local sz, cz = math.sin(az), math.cos(az);
        
        local rx = Matrix3x3.new(
            1, 0,  0,
            0, cx, -sx,
            0, sx, cx
        );
        
        local ry = Matrix3x3.new(
            cy,  0, sy,
            0,   1, 0,
            -sy, 0, cy
        );
        
        local rz = Matrix3x3.new(
            cz, -sz, 0,
            sz, cz,  0,
            0,  0,   1
        );
        
        rotMatrix = ry*rx*rz; -- get final rotation matrix
    end
    
    obj.rotMatrix = rotMatrix;
end


function class.func.update_absRotPivot(obj, descend)
    local absRotPivot = obj.rootGui and Vector3.new(
        math.floor(obj.absPos.x + (obj.rotPivot.x.offset + obj.absSize.x*obj.rotPivot.x.scale)),
        math.floor(obj.absPos.y + (obj.rotPivot.y.offset + obj.absSize.y*obj.rotPivot.y.scale)),
        
        math.floor(obj.rotPivotDepth)
    )
    or nil;
    
    if (absRotPivot ~= obj.absRotPivot) then
        obj.absRotPivot = absRotPivot;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_absRotPivot(true);
        end
    end
end

function class.func.update_absRotPerspective(obj, descend)
    local absRotPerspective = obj.rootGui and Vector2.new(
        math.floor(obj.absPos.x + (obj.rotPerspective.x.offset + obj.absSize.x*obj.rotPerspective.x.scale)),
        math.floor(obj.absPos.y + (obj.rotPerspective.y.offset + obj.absSize.y*obj.rotPerspective.y.scale))
    )
    or nil;
    
    if (absRotPerspective ~= obj.absRotPerspective) then
        obj.absRotPerspective = absRotPerspective;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_absRotPerspective(true);
        end
    end
end



function class.func.update_vertices(obj, descend)
    -- REFERENCES:
    -- http://www.scratchapixel.com/lessons/mathematics-physics-for-computer-graphics/geometry/how-does-matrix-work-part-1
    -- https://www.siggraph.org/education/materials/HyperGraph/modeling/mod_tran/3drota.htm
    -- http://www.petesqbsite.com/sections/tutorials/tuts/perspective.html
    
    if (obj.rootGui) then
        obj.quad[1] = Vector3.new(obj.absPos.x, obj.absPos.y, 0);
        obj.quad[2] = Vector3.new(obj.absPos.x+obj.absSize.x, obj.absPos.y, 0);
        obj.quad[3] = Vector3.new(obj.absPos.x+obj.absSize.x, obj.absPos.y+obj.absSize.y, 0);
        obj.quad[4] = Vector3.new(obj.absPos.x, obj.absPos.y+obj.absSize.y, 0);
        
        local asc = obj;
        while (asc ~= obj.rootGui) do
            if (asc.isRotated) then
                for i = 1, #obj.quad do
                    local v = obj.quad[i];
                    
                    v = v-asc.absRotPivot; -- translate by -absRotPivot so that absRotPivot becomes center of rotation
                    v = asc.rotMatrix*v; -- apply rotation through rotMatrix
                    v = v+asc.absRotPivot; -- translate back by +absRotPivot
                    
                    local projMatrix = 1/(v.z-class.ROT_NEAR_Z_PLANE) * Matrix3x3.new(
                        -class.ROT_NEAR_Z_PLANE, 0,                       asc.absRotPerspective.x,
                        0,                       -class.ROT_NEAR_Z_PLANE, asc.absRotPerspective.y,
                        0,                       0,                       0
                    );
                    
                    v = projMatrix*v;
                    
                    obj.quad[i] = v;
                end
            end
            
            asc = asc.parent;
        end
        
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
        -- |                                                    (cx, cy, nearz)                                         |
        -- |                                                                                                            |
        -- +------------------------------------------------------------------------------------------------------------+
        -- | (E) -> eye (empirically found out that for dxSetShaderTransform near z-plane is 1000 px behind the screen) |
        -- |        (actually, stuff starts to disappear from sight at values >= 900 px,                                |
        -- |         but I've noticed that the position is accurate when 1000 is used)                                  |
        -- |                                                                                                            |
        -- | (C) -> perspective point that is used in dxSetShaderTransform (located at absRotPerspective)               |
        -- |                                                                                                            |
        -- | (P) -> point obtained by applying rotation to rectangle vertex                                             |
        -- |                                                                                                            |
        -- | (S) -> point that will be visible on screen after dxSetShaderTransform is applied                          |
        -- |        (this is the point whose sx and sy coordinates we need to find)                                     |
        -- +------------------------------------------------------------------------------------------------------------+
        -- | Using the fact that the triangles (EPC') and (ESC) are similar we can calculate the coordinates of (S):    |
        -- |                                                                                                            |
        -- |                                   CS/C'P = CE/C'E =>                                                       |
        -- |                                => (sx-cx)/(px-cx) = (0-nearz)/(pz-nearz) =>                                |
        -- |                                => (sx-cx)/(px-cx) = -nearz/(pz-nearz) =>                                   |
        -- |                                => sx-cx = (-nearz/(pz-nearz))*(px-cx) =>                                   |
        -- |                                => sx = cx + (-nearz/(pz-nearz))*(px-cx)                                    |
        -- |                                        ^                                                                   |
        -- |                                        Now we amplify cx by (pz-nearz) =>                                  |
        -- |                                                                                                            |
        -- |                       => sx = (pz*cx - cx*nearz - px*nearz + cx*nearz)/(pz-nearz) =>                       |
        -- |                       => sx = 1/(pz-nearz) * (-nearz*px + cx*pz)                                           |
        -- |                                                                                                            |
        -- |                       This can now be written in matrix form, as seen in projMatrix                        |
        -- +------------------------------------------------------------------------------------------------------------+
    else
        for i = 1, #obj.quad do
            obj.quad[i] = nil;
        end
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_vertices(true);
        end
    end
end


function class.func.update_containerRotPivot(obj, descend)
    local containerRotPivot = (#obj.guiChildren > 0) and (
        obj.rootGui and obj.isRotated and Vector3.new(
            2*(-obj.containerSize.x/2 + obj.absRotPivot.x-obj.containerPos.x), -- use containerSize and not containerActualSize
            2*(-obj.containerSize.y/2 + obj.absRotPivot.y-obj.containerPos.y), -- because we draw container using dxDrawImageSection in GuiBase2D
            
            2*(obj.absRotPivot.z/class.ROT_PIVOT_DEPTH_UNIT)
        )/obj.parent.containerActualSize:get_vec31()
    )
    or nil;
    
    if (containerRotPivot ~= obj.containerRotPivot) then
        obj.containerRotPivot = containerRotPivot;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_containerRotPivot(true);
        end
    end
end

function class.func.update_containerRotPerspective(obj, descend)
    local containerRotPerspective = #obj.guiChildren > 0 and (
        obj.rootGui and obj.isRotated3D and Vector2.new(
            2*(-obj.containerSize.x/2 + obj.absRotPerspective.x-obj.containerPos.x),
            2*(-obj.containerSize.y/2 + obj.absRotPerspective.y-obj.containerPos.y)
        )/obj.parent.containerActualSize
    )
    or nil;
    
    if (containerRotPerspective ~= obj.containerRotPerspective) then
        obj.containerRotPerspective = containerRotPerspective;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_containerRotPerspective(true);
        end
    end
end


function class.func.update_canvasSize(obj, descend)
    local canvasSize = obj.rootGui and Vector2.new(
        class.CANVAS_ADDITIONAL_MARGIN+obj.borderSize + obj.absSize.x + obj.borderSize+class.CANVAS_ADDITIONAL_MARGIN,
        class.CANVAS_ADDITIONAL_MARGIN+obj.borderSize + obj.absSize.y + obj.borderSize+class.CANVAS_ADDITIONAL_MARGIN
    )
    or nil;
    
    if (canvasSize ~= obj.canvasSize) then
        obj.canvasSize = canvasSize;
        
        local canvasActualSize = canvasSize and Vector2.new(
            math.ceil(canvasSize.x/class.RT_SIZE_STEP)*class.RT_SIZE_STEP,
            math.ceil(canvasSize.y/class.RT_SIZE_STEP)*class.RT_SIZE_STEP
        )
        or nil;
        
        if (canvasActualSize ~= obj.canvasActualSize) then
            obj.canvasActualSize = canvasActualSize;
            
            
            if (obj.canvas and isElement(obj.canvas)) then
                destroyElement(obj.canvas);
            end
            
            obj.canvas = canvasActualSize and dxCreateRenderTarget(canvasActualSize.x, canvasActualSize.y, true);
        end
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_canvasSize(true);
        end
    end
end

function class.func.update_canvasPos(obj, descend)
    local canvasPos = obj.rootGui and Vector2.new(
        obj.absPos.x - (class.CANVAS_ADDITIONAL_MARGIN+obj.borderSize),
        obj.absPos.y - (class.CANVAS_ADDITIONAL_MARGIN+obj.borderSize)
    )
    or nil;
    
    if (canvasPos ~= obj.canvasPos) then
        obj.canvasPos = canvasPos;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_canvasPos(true);
        end
    end
end

function class.func.update_canvasRotPivot(obj, descend)
    local canvasRotPivot = obj.rootGui and obj.isRotated and Vector3.new(
        2*(-obj.canvasActualSize.x/2 + obj.absRotPivot.x-obj.canvasPos.x), -- use canvasActualSize and not canvasSize
        2*(-obj.canvasActualSize.y/2 + obj.absRotPivot.y-obj.canvasPos.y), -- because we draw canvas using dxDrawImage in GuiBase2D
        
        2*(obj.absRotPivot.z/class.ROT_PIVOT_DEPTH_UNIT)
    )/obj.parent.containerActualSize:get_vec31()
    or nil;
    
    if (canvasRotPivot ~= obj.canvasRotPivot) then
        obj.canvasRotPivot = canvasRotPivot;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_canvasRotPivot(true);
        end
    end
end

function class.func.update_canvasRotPerspective(obj, descend)
    local canvasRotPerspective = obj.rootGui and obj.isRotated3D and Vector2.new(
        2*(-obj.canvasActualSize.x/2 + obj.absRotPerspective.x-obj.canvasPos.x),
        2*(-obj.canvasActualSize.y/2 + obj.absRotPerspective.y-obj.canvasPos.y)
    )/obj.parent.containerActualSize
    or nil;
    
    if (canvasRotPerspective ~= obj.canvasRotPerspective) then
        obj.canvasRotPerspective = canvasRotPerspective;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            obj.guiChildren[i]:update_canvasRotPerspective(true);
        end
    end
end


function class.func.update(obj, descend)
    local success, result = pcall(super.func.update, obj, descend);
    if (not success) then error(result, 2) end
    
    
    if (obj.canvas) then
        dxSetRenderTarget(obj.canvas, true);
        
        dxSetBlendMode("add");
        
        if (obj.debug) then
            dxDrawRectangle(0, 0, obj.canvasActualSize.x, obj.canvasActualSize.y, class.DEBUG_CANVAS_COLOR);
        end
        
        -- border
        dxDrawRectangle(
            class.CANVAS_ADDITIONAL_MARGIN, class.CANVAS_ADDITIONAL_MARGIN,
            
            obj.absSize.x+2*obj.borderSize,
            obj.absSize.y+2*obj.borderSize,
            
            tocolor(obj.borderColor.r, obj.borderColor.g, obj.borderColor.b, 255*(1-obj.borderTransparency))
        );
        
        -- background
        dxSetBlendMode("overwrite");
        
        dxDrawRectangle(
            class.CANVAS_ADDITIONAL_MARGIN+obj.borderSize,
            class.CANVAS_ADDITIONAL_MARGIN+obj.borderSize,
            
            obj.absSize.x, obj.absSize.y,
            
            tocolor(obj.bgColor.r, obj.bgColor.g, obj.bgColor.b, 255*(1-obj.bgTransparency))
        );
        
        dxSetRenderTarget();
        
        dxSetBlendMode("blend");
    end
end


function class.func.drawVertices(obj)
    for i = 1, #obj.quad do
        dxDrawLine(
            obj.absRotPivot.x, obj.absRotPivot.y,
            obj.quad[i].x, obj.quad[i].y,
            
            class.DEBUG_VERTEX_LINE_COLOR, class.DEBUG_VERTEX_LINE_THICKNESS,
            
            class.DRAW_POST_GUI
        );
    end
end



function class.set.parent(obj, parent, prev)
    local success, result = pcall(super.set.parent, obj, parent, prev);
    if (not success) then error(result, 2) end
    
    
    if (prev and prev:isA("GuiBase2D")) then
        local childrenCount = #prev.guiChildren;
        
        for i = obj.guiIndex+1, childrenCount do
            local child = prev.guiChildren[i];
            
            child.guiIndex = child.guiIndex-1;
            prev.guiChildren[i-1] = child;
        end
        
        prev.guiChildren[childrenCount] = nil;
        
        obj.guiIndex = nil;
        
        
        prev:update_containerSize();
        prev:update_containerPos();
        
        prev:update();
        
        prev:propagate();
    end
    
    
    if (parent and parent:isA("GuiBase2D")) then
        obj.guiIndex = #parent.guiChildren+1;
        parent.guiChildren[obj.guiIndex] = obj;
        
        
        parent:update_containerSize();
        parent:update_containerPos();
    end
    
    -- "func\.([A-Za-z_]+)\(([A-Za-z_]*),?\ ? -> obj:\1\(""
    obj:update_rootGui(true);
    
    obj:update_clipperGui(true);
    
    obj:update_absSize(true);
    obj:update_absPos(true);
    
    obj:update_absRotPivot(true);
    obj:update_absRotPerspective(true);
    
    obj:update_vertices(true);
    
    obj:update_containerPos(true);
    obj:update_containerSize(true);
    obj:update_containerRotPivot(true);
    obj:update_containerRotPerspective(true);
    
    obj:update_canvasPos(true);
    obj:update_canvasSize(true);
    obj:update_canvasRotPivot(true);
    obj:update_canvasRotPerspective(true);
    
    obj:update(true);
    
    obj:propagate();
end


function class.set.debug(obj, debug, prev)
    local success, result = pcall(super.set.debug, obj, debug, prev);
    if (not success) then error(result, 2) end
    
    
    obj:update();
    
    obj:propagate();
    
    
    if (obj.rootGui) then
        if (debug) then
            function obj.drawVertices_wrapper()
                obj:drawVertices();
            end
            
            addEventHandler("onClientRender", root, obj.drawVertices_wrapper, false, "low");
        else
            removeEventHandler("onClientRender", root, obj.drawVertices_wrapper);
            
            obj.drawVertices_wrapper = nil;
        end
    end
end


function class.set.clipsDescendants(obj, clipsDescendants)
    local clipsDescendants_t = type(clipsDescendants);
    
    if (clipsDescendants_t ~= "boolean") then
        error("bad argument #1 to 'clipsDescendants' (boolean expected, got " ..clipsDescendants_t.. ")", 2);
    end
    
    
    obj.clipsDescendants = clipsDescendants;
    
    
    func.update_clipperGui(obj, true);
    
    func.update_containerPos(obj, true);
    func.update_containerSize(obj, true);
    func.update_containerRotPivot(obj, true);
    func.update_containerRotPerspective(obj, true);
    
    for i = 1, #obj.guiChildren do
        local child = obj.guiChildren[i];
        
        -- because of updating obj's containerActualSize through update_containerSize
        func.update_canvasRotPivot(child, true);
        func.update_canvasRotPerspective(child, true);
    end
    
    func.update(obj, true);
    
    func.propagate(obj);
end


function class.set.bgColor(obj, bgColor)
    local bgColor_t = type(bgColor);
    
    if (bgColor_t ~= "Color3") then
        error("bad argument #1 to 'bgColor3' (Color3 expected, got " ..bgColor_t.. ")", 2);
    end
    
    
    obj.bgColor = bgColor;
    
    
    func.update(obj);
    
    func.propagate(obj);
end

function class.set.bgTransparency(obj, bgTransparency)
    local bgTransparency_t = type(bgTransparency);
    
    if (bgTransparency_t ~= "number") then
        error("bad argument #1 to 'bgTransparency' (number expected, got " ..bgTransparency_t.. ")", 2);
    elseif (bgTransparency < 0) or (bgTransparency > 1) then
        error("bad argument #1 to 'bgTransparency' (value out of bounds)", 2);
    end
    
    
    obj.bgTransparency = bgTransparency;
    
    
    func.update(obj);
    
    func.propagate(obj);
end


function class.set.borderColor(obj, borderColor)
    local borderColor_t = type(borderColor);
    
    if (borderColor_t ~= "Color3") then
        error("bad argument #1 to 'borderColor3' (Color3 expected, got " ..borderColor_t.. ")", 2);
    end
    
    
    obj.borderColor = borderColor;
    
    
    func.update(obj);
    
    func.propagate(obj);
end

function class.set.borderSize(obj, borderSize)
    local borderSize_t = type(borderSize);
    
    if (borderSize_t ~= "number") then
        error("bad argument #1 to 'borderSize' (number expected, got " ..borderSize_t.. ")", 2);
    elseif (borderSize < 0) or (borderSize > class.MAX_BORDER_SIZE) then
        error("bad argument #1 to 'borderSize' (value out of bounds)", 2);
    end
    
    
    obj.borderSize = math.floor(borderSize);
    
    
    func.update_canvasPos(obj);
    func.update_canvasSize(obj);
    func.update_canvasRotPivot(obj);
    func.update_canvasRotPerspective(obj);
    
    func.update(obj);
    
    func.propagate(obj);
end

function class.set.borderTransparency(obj, borderTransparency)
    local borderTransparency_t = type(borderTransparency);
    
    if (borderTransparency_t ~= "number") then
        error("bad argument #1 to 'borderTransparency' (number expected, got " ..borderTransparency_t.. ")", 2);
    elseif (borderTransparency < 0) or (borderTransparency > 1) then
        error("bad argument #1 to 'borderTransparency' (invalid value)", 2);
    end
    
    
    obj.borderTransparency = borderTransparency;
    
    
    func.update(obj);
    
    func.propagate(obj);
end


function class.set.size(obj, size)
    local size_t = type(size);
    
    if (size_t ~= "UDim2") then
        error("bad argument #1 to 'size' (UDim2 expected, got " ..size_t.. ")", 2);
    end
    
    
    obj.size = size;
    
    
    func.update_absSize(obj, true);
    func.update_absPos(obj, true); -- update because of posOrigin
    
    func.update_absRotPivot(obj, true);
    func.update_absRotPerspective(obj, true);
    
    func.update_vertices(obj, true);
    
    func.update_containerPos(obj, true);
    func.update_containerSize(obj, true);
    func.update_containerRotPivot(obj, true);
    func.update_containerRotPerspective(obj, true);
    
    func.update_canvasPos(obj, true);
    func.update_canvasSize(obj, true);
    func.update_canvasRotPivot(obj, true);
    func.update_canvasRotPerspective(obj, true);
    
    func.update(obj, true);
    
    func.propagate(obj);
end


function class.set.pos(obj, pos)
    local pos_t = type(pos);
    
    if (pos_t ~= "UDim2") then
        error("bad argument #1 to 'pos' (UDim2 expected, got " ..pos_t.. ")", 2);
    end
    
    
    obj.pos = pos;
    
    
    func.update_absPos(obj, true); -- descend because all relative positions of obj's children must be updated
    
    func.update_absRotPivot(obj, true);
    func.update_absRotPerspective(obj, true);
    
    func.update_vertices(obj, true);
    
    func.update_containerPos(obj, true);
    func.update_containerRotPivot(obj, true);
    func.update_containerRotPerspective(obj, true);
    
    func.update_canvasPos(obj, true);
    func.update_canvasRotPivot(obj, true);
    func.update_canvasRotPerspective(obj, true);
    
    func.update(obj, true);
    
    func.propagate(obj);
end

function class.set.posOrigin(obj, posOrigin)
    local posOrigin_t = type(posOrigin);
    
    if (posOrigin_t ~= "UDim2") then
        error("bad argument #1 to 'pos' (UDim2 expected, got " ..posOrigin_t.. ")", 2);
    end
    
    
    obj.posOrigin = posOrigin;
    
    
    func.update_absPos(obj, true);
    
    func.update_absRotPivot(obj, true);
    func.update_absRotPerspective(obj, true);
    
    func.update_vertices(obj, true);
    
    func.update_containerPos(obj, true);
    func.update_containerRotPivot(obj, true);
    func.update_containerRotPerspective(obj, true);
    
    func.update_canvasPos(obj, true);
    func.update_canvasRotPivot(obj, true);
    func.update_canvasRotPerspective(obj, true);
    
    func.update(obj, true);
    
    func.propagate(obj);
end


function class.set.rot(obj, rot)
    local rot_t = type(rot);
    
    if (rot_t ~= "Vector3") then
        error("bad argument #1 to 'rot' (Vector3 expected, got " ..rot_t.. ")", 2);
    end
    
    
    obj.rot = rot;
    
    
    func.update_isRotated(obj);
    func.update_isRotated3D(obj);
    func.update_rotMatrix(obj);
    
    func.update_vertices(obj, true);
    
    func.update_containerRotPivot(obj);
    func.update_containerRotPerspective(obj);
    
    func.update_canvasRotPivot(obj);
    func.update_canvasRotPerspective(obj);
    
    func.update(obj);
    
    func.propagate(obj);
end

function class.set.rotPivot(obj, rotPivot)
    local rotPivot_t = type(rotPivot);
    
    if (rotPivot_t ~= "UDim2") then
        error("bad argument #1 to 'rotPivot' (UDim2 expected, got " ..rotPivot_t.. ")", 2);
    end
    
    obj.rotPivot = rotPivot;
    
    
    func.update_absRotPivot(obj);
    
    func.update_vertices(obj, true);
    
    func.update_containerRotPivot(obj);
    
    func.update_canvasRotPivot(obj);
    
    func.update(obj);
    
    func.propagate(obj);
end

function class.set.rotPivotDepth(obj, rotPivotDepth)
    local rotPivotDepth_t = type(rotPivotDepth);
    
    if (rotPivotDepth_t ~= "number") then
        error("bad argument #1 to 'rotPivotDepth' (number expected, got " ..rotPivotDepth_t.. ")", 2);
    elseif (rotPivotDepth <= class.ROT_ACTUAL_NEAR_Z_PLANE/2 or rotPivotDepth > class.ROT_FAR_Z_PLANE/2) then
        error("bad argument #1 to 'rotPivotDepth' (value out of bounds)", 2);
    end
    
    obj.rotPivotDepth = rotPivotDepth;
    
    
    func.update_isRotated3D(obj);
    
    func.update_absRotPivot(obj);
    
    func.update_vertices(obj, true);
    
    func.update_containerRotPivot(obj);
    
    func.update_canvasRotPivot(obj);
    
    func.update(obj);
    
    func.propagate(obj);
end

function class.set.rotPerspective(obj, rotPerspective)
    local rotPerspective_t = type(rotPerspective);
    
    if (rotPerspective_t ~= "UDim2") then
        error("bad argument #1 to 'rotPerspective' (UDim2 expected, got " ..rotPerspective_t.. ")", 2);
    end
    
    
    obj.rotPerspective = rotPerspective;
    
    
    func.update_absRotPerspective(obj);
    
    func.update_vertices(obj, true);
    
    func.update_containerRotPerspective(obj);
    
    func.update_canvasRotPerspective(obj);
    
    func.update(obj);
    
    func.propagate(obj);
end


function class.set.visible(obj, visible)
    local visible_t = type(visible);
    
    if (visible_t ~= "boolean") then
        error("bad argument #1 to 'visible' (boolean expected, got " ..visible_t.. ")", 2);
    end
    
    
    obj.visible = visible;
    
    func.propagate(obj);
end
