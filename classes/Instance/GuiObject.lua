local name = "GuiObject";

local super = GuiBase2D;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local event = inherit({}, super.event);

local private  = inherit({}, super.private);
local readOnly = inherit({}, super.readOnly);



local CANVAS_ADDITIONAL_MARGIN = 1; -- added so that canvas can be properly anti-aliased when rotated

local MAX_BORDER_SIZE = 100;

local ROT_NEAR_Z_PLANE        = -1000;
local ROT_ACTUAL_NEAR_Z_PLANE = -900;
local ROT_FAR_Z_PLANE         =  9000;

local ROT_PIVOT_DEPTH_UNIT = 1000;

local SHADER = dxCreateShader("shaders/nothing.fx"); -- TODO: add check for successful creation (dxSetTestMode)

local DEBUG_CANVAS_COLOR = tocolor(255, 0, 255, 127.5);

local DEBUG_ROT_LINE_COLOR = tocolor(255, 0, 0, 200);
local DEBUG_ROT_LINE_THICKNESS = 2;



local function new(obj)
    local success, result = pcall(super.new, obj);
    if (not success) then error(result, 2) end
    
    
    obj.guiIndex = nil; -- index in guiChildren array of parent
    
    set.clipsDescendants(obj, true);
    
    set.bgColor(obj, Color3.new(255, 255, 255));
    set.bgTransparency(obj, 0);
    
    set.borderColor(obj, Color3.new(27, 42, 53));
    set.borderSize(obj, 1);
    set.borderTransparency(obj, 0);
    
    obj.size = nil;
    obj.pos = nil;
    set.posOrigin(obj, UDim2.new());
    
    set.rot(obj, Vector3.new());
    set.rotPivot(obj, UDim2.new(0.5, 0, 0.5, 0));
    set.rotPivotDepth(obj, 0);
    set.rotPerspective(obj, obj.rotPivot);
    
    set.visible(obj, true);
end



function func.update_rootGui(obj, descend)
    local rootGui = obj.parent and func.isA(obj.parent, "GuiBase2D") and (
        func.isA(obj.parent, "RootGui") and obj.parent
        or func.isA(obj.parent, "GuiObject") and obj.parent.rootGui
    )
    or nil;
    
    if (rootGui ~= obj.rootGui) then
        obj.rootGui = rootGui;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_rootGui(obj.guiChildren[i], true);
            end
        end
    end
end


function func.update_clipperGui(obj, descend)
    local clipperGui = obj.rootGui and (
        obj.clipsDescendants and obj
        or func.isA(obj.parent, "RootGui") and obj.parent
        or obj.parent.clipperGui
    )
    or nil;
    
    if (clipperGui ~= obj.clipperGui) then
        obj.clipperGui = clipperGui;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_clipperGui(obj.guiChildren[i], true);
            end
        end
    end
end


function func.update_isRotated(obj)
    if (obj.rot.x%180 == 0 and (obj.rot.x == obj.rot.y and obj.rot.y == obj.rot.z)) then
        obj.isRotated = false;
    elseif (obj.rot.x%360 == 0 and obj.rot.y%360 == 0 and obj.rot.z%360 == 0) then
        obj.isRotated = false;
    else
        obj.isRotated = true;
    end
end

function func.update_isRotated3D(obj)
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


function func.update_absRotPivot(obj, descend)
    local absRotPivot = obj.rootGui and Vector3.new(
        math.floor(obj.absPos.x + (obj.rotPivot.x.offset + obj.absSize.x*obj.rotPivot.x.scale)),
        math.floor(obj.absPos.y + (obj.rotPivot.y.offset + obj.absSize.y*obj.rotPivot.y.scale)),
        
        math.floor(obj.rotPivotDepth)
    )
    or nil;
    
    if (absRotPivot ~= obj.absRotPivot) then
        obj.absRotPivot = absRotPivot;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_absRotPivot(obj.guiChildren[i], true);
            end
        end
    end
end

function func.update_absRotPerspective(obj, descend)
    local absRotPerspective = obj.rootGui and Vector2.new(
        math.floor(obj.absPos.x + (obj.rotPerspective.x.offset + obj.absSize.x*obj.rotPerspective.x.scale)),
        math.floor(obj.absPos.y + (obj.rotPerspective.y.offset + obj.absSize.y*obj.rotPerspective.y.scale))
    )
    or nil;
    
    if (absRotPerspective ~= obj.absRotPerspective) then
        obj.absRotPerspective = absRotPerspective;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_absRotPerspective(obj.guiChildren[i], true);
            end
        end
    end
end


function func.update_vertices(obj, descend)
    -- REFERENCES:
    -- http://www.scratchapixel.com/lessons/mathematics-physics-for-computer-graphics/geometry/how-does-matrix-work-part-1
    -- https://www.siggraph.org/education/materials/HyperGraph/modeling/mod_tran/3drota.htm
    -- http://www.petesqbsite.com/sections/tutorials/tuts/perspective.html
    
    if (obj.rootGui) then
        -- get positions of all 4 vertices
        local v1 = obj.absPos;
        local v2 = obj.absPos+Vector2.new(obj.absSize.x, 0);
        local v3 = obj.absPos+obj.absSize;
        local v4 = obj.absPos+Vector2.new(0, obj.absSize.y);
        
        if (obj.isRotated) then
            -- we will be working in 3D so convert to Vector3
            v1 = v1.vector3_0;
            v2 = v2.vector3_0;
            v3 = v3.vector3_0;
            v4 = v4.vector3_0;
            
            -- calculate rotation matrices for each plane
            local ax = math.rad(obj.rot.x);
            local sx, cx = math.sin(ax), math.cos(ax);
            local rx = Matrix3x3.new(
                1, 0,  0,
                0, cx, -sx,
                0, sx, cx
            );
            
            local ay = math.rad(obj.rot.y);
            local sy, cy = math.sin(ay), math.cos(ay);
            local ry = Matrix3x3.new(
                cy,  0, sy,
                0,   1, 0,
                -sy, 0, cy
            );
            
            local az = math.rad(obj.rot.z);
            local sz, cz = math.sin(az), math.cos(az);
            local rz = Matrix3x3.new(
                cz, -sz, 0,
                sz, cz,  0,
                0,  0,   1
            );
            
            local r = ry*rx*rz; -- get the final rotation transformation matrix
                                -- (order is y, x, z because in dxSetShaderTransform x and y rotations are interchanged)
            
            -- translate by -absRotPivot so that absRotPivot is center of rotation, apply rotation through matrix, then translate back by +absRotPivot
            v1 = v1-obj.absRotPivot;
            v2 = v2-obj.absRotPivot;
            v3 = v3-obj.absRotPivot;
            v4 = v4-obj.absRotPivot;
            
            v1 = r*v1;
            v2 = r*v2;
            v3 = r*v3;
            v4 = r*v4;
            
            local m1 = (1/(v1.z+1000))*Matrix3x3.new(
                (1000), 0, (obj.absRotPerspective.x-obj.absRotPivot.x),
                0, (1000), (obj.absRotPerspective.y-obj.absRotPivot.y),
                0, 0, 0
            );
            
            v1 = m1*v1+obj.absRotPivot;
            v2 = v2+obj.absRotPivot;
            v3 = v3+obj.absRotPivot;
            v4 = v4+obj.absRotPivot;
            
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
            -- |                                                    (cx, cy, -1000)                                         |
            -- |                                                                                                            |
            -- +------------------------------------------------------------------------------------------------------------+
            -- |                                                                                                            |
            -- | (E) -> eye (empirically found out that for dxSetShaderTransform eye is 1000 pixels in front of the screen) |
            -- |        (actually, stuff starts to disappear from sight at values >= 900 px,                                |
            -- |         but I've noticed that the position is the most accurate when 1000 is used)                         |
            -- |                                                                                                            |
            -- | (C) -> perspective point that is used in dxSetShaderTransform (located at absRotPerspective)               |
            -- |                                                                                                            |
            -- | (P) -> point obtained by applying rotation to rectangle vertex                                             |
            -- |                                                                                                            |
            -- | (S) -> point that will be visible on screen after dxSetShaderTransform is applied                          |
            -- |        (this is the point whose sx and sy coordinates we need to find)                                     |
            -- |                                                                                                            |
            -- +------------------------------------------------------------------------------------------------------------+
            -- |                                                                                                            |
            -- | Using the fact that the triangles (EPC') and (ESC) are similar we can calculate the coordinates of (S):    |
            -- |                                                                                                            |
            -- |                                   CS/C'P = CE/C'E =>                                                       |
            -- |                                => (sx-cx)/(px-cx) = (0-(-1000))/(pz-(-1000)) =>                            |
            -- |                                => (sx-cx)/(px-cx) = 1000/(pz+1000) =>                                      |
            -- |                                => sx-cx = (1000/(pz+1000))*(px-cx) =>                                      |
            -- |                                                                                                            |
            -- |                                => sx = cx + (1000/(pz+1000))*(px-cx)                                       |
            -- |                                                                                                            |
            -- +------------------------------------------------------------------------------------------------------------+
            
            -- before we can use the vertex positions on screen we need to project them onto the screen using perspective projection
            -- (this is the projection used by dxSetShaderTransform)
            
            local m1 = (1/(v1.z+1000))*Matrix3x3.new(
                (1000), 0, (obj.absRotPerspective.x),
                0, (1000), (obj.absRotPerspective.y),
                0, 0, 0
            );
            
            
            -- v1 = Vector2.new(
                -- (1000/(v1.z+1000))*v1.x+(obj.absRotPerspective.x/(v1.z+1000))*v1.z,
                -- (1000/(v1.z+1000))*v1.y+(obj.absRotPerspective.y/(v1.z+1000))*v1.z
            -- );
            v1 = v1.vector2-- (m1*v1).vector2; -- obj.absRotPerspective+(-ROT_NEAR_Z_PLANE/(v1.z-ROT_NEAR_Z_PLANE))*(v1.vector2-obj.absRotPerspective);
            v2 = obj.absRotPerspective+(-ROT_NEAR_Z_PLANE/(v2.z-ROT_NEAR_Z_PLANE))*(v2.vector2-obj.absRotPerspective);
            v3 = obj.absRotPerspective+(-ROT_NEAR_Z_PLANE/(v3.z-ROT_NEAR_Z_PLANE))*(v3.vector2-obj.absRotPerspective);
            v4 = obj.absRotPerspective+(-ROT_NEAR_Z_PLANE/(v4.z-ROT_NEAR_Z_PLANE))*(v4.vector2-obj.absRotPerspective);
        end
        
        obj.vertex1 = v1;
        obj.vertex2 = v2;
        obj.vertex3 = v3;
        obj.vertex4 = v4;
    else
        obj.vertex1 = nil;
        obj.vertex2 = nil;
        obj.vertex3 = nil;
        obj.vertex4 = nil;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_vertices(obj.guiChildren[i], true);
        end
    end
end


function func.update_containerRotPivot(obj, descend)
    local containerRotPivot = #obj.guiChildren > 0 and (
        obj.rootGui and obj.isRotated and Vector3.new(
            2*(-obj.containerSize.x/2 + obj.absRotPivot.x-obj.containerPos.x), -- use containerSize and not containerActualSize
            2*(-obj.containerSize.y/2 + obj.absRotPivot.y-obj.containerPos.y), -- because we draw container using dxDrawImageSection in GuiBase2D
            
            2*(obj.absRotPivot.z/ROT_PIVOT_DEPTH_UNIT)
        )/obj.parent.containerActualSize.vector3_1
    )
    or nil;
    
    if (containerRotPivot ~= obj.containerRotPivot) then
        obj.containerRotPivot = containerRotPivot;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_containerRotPivot(obj.guiChildren[i], true);
            end
        end
    end
end

function func.update_containerRotPerspective(obj, descend)
    local containerRotPerspective = #obj.guiChildren > 0 and (
        obj.rootGui and obj.isRotated3D and Vector2.new(
            2*(-obj.containerSize.x/2 + obj.absRotPerspective.x-obj.containerPos.x),
            2*(-obj.containerSize.y/2 + obj.absRotPerspective.y-obj.containerPos.y)
        )/obj.parent.containerActualSize
    )
    or nil;
    
    if (containerRotPerspective ~= obj.containerRotPerspective) then
        obj.containerRotPerspective = containerRotPerspective;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_containerRotPerspective(obj.guiChildren[i], true);
            end
        end
    end
end


function func.update_canvasPos(obj, descend)
    local canvasPos = obj.rootGui and Vector2.new(
        obj.absPos.x - (CANVAS_ADDITIONAL_MARGIN + obj.borderSize),
        obj.absPos.y - (CANVAS_ADDITIONAL_MARGIN + obj.borderSize)
    )
    or nil;
    
    if (canvasPos ~= obj.canvasPos) then
        obj.canvasPos = canvasPos;
    end
    
    
    if (descend) then
        for i = 1, #obj.guiChildren do
            func.update_canvasPos(obj.guiChildren[i], true);
        end
    end
end

function func.update_canvasSize(obj, descend)
    local canvasSize = obj.rootGui and Vector2.new(
        CANVAS_ADDITIONAL_MARGIN + obj.borderSize + obj.absSize.x + obj.borderSize + CANVAS_ADDITIONAL_MARGIN,
        CANVAS_ADDITIONAL_MARGIN + obj.borderSize + obj.absSize.y + obj.borderSize + CANVAS_ADDITIONAL_MARGIN
    )
    or nil;
    
    if (canvasSize ~= obj.canvasSize) then
        obj.canvasSize = canvasSize;
        
        local canvasActualSize = canvasSize and Vector2.new(
            math.ceil(canvasSize.x/GuiBase2D.RT_SIZE_STEP)*GuiBase2D.RT_SIZE_STEP,
            math.ceil(canvasSize.y/GuiBase2D.RT_SIZE_STEP)*GuiBase2D.RT_SIZE_STEP
        )
        or nil;
        
        if (canvasActualSize ~= obj.canvasActualSize) then
            obj.canvasActualSize = canvasActualSize;
            
            
            if (obj.canvas and isElement(obj.canvas)) then
                destroyElement(obj.canvas);
            end
            
            obj.canvas = canvasActualSize and dxCreateRenderTarget(canvasActualSize.x, canvasActualSize.y, true);
        end
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_canvasSize(obj.guiChildren[i], true);
            end
        end
    end
end

function func.update_canvasRotPivot(obj, descend)
    local canvasRotPivot = obj.rootGui and obj.isRotated and Vector3.new(
        2*(-obj.canvasActualSize.x/2 + obj.absRotPivot.x-obj.canvasPos.x), -- use canvasActualSize and not canvasSize
        2*(-obj.canvasActualSize.y/2 + obj.absRotPivot.y-obj.canvasPos.y), -- because we draw canvas using dxDrawImage in GuiBase2D
        
        2*(obj.absRotPivot.z/ROT_PIVOT_DEPTH_UNIT)
    )/obj.parent.containerActualSize.vector3_1
    or nil;
    
    if (canvasRotPivot ~= obj.canvasRotPivot) then
        obj.canvasRotPivot = canvasRotPivot;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_canvasRotPivot(obj.guiChildren[i], true);
            end
        end
    end
end

function func.update_canvasRotPerspective(obj, descend)
    local canvasRotPerspective = obj.rootGui and obj.isRotated3D and Vector2.new(
        2*(-obj.canvasActualSize.x/2 + obj.absRotPerspective.x-obj.canvasPos.x),
        2*(-obj.canvasActualSize.y/2 + obj.absRotPerspective.y-obj.canvasPos.y)
    )/obj.parent.containerActualSize
    or nil;
    
    if (canvasRotPerspective ~= obj.canvasRotPerspective) then
        obj.canvasRotPerspective = canvasRotPerspective;
        
        
        if (descend) then
            for i = 1, #obj.guiChildren do
                func.update_canvasRotPerspective(obj.guiChildren[i], true);
            end
        end
    end
end


function func.update(obj, descend)
    local success, result = pcall(super.func.update, obj, descend);
    if (not success) then error(result, 2) end
    
    
    if (obj.canvas) then
        dxSetRenderTarget(obj.canvas, true);
        
        dxSetBlendMode("add");
        
        if (obj.debug) then
            dxDrawRectangle(0, 0, obj.canvasActualSize.x, obj.canvasActualSize.y, DEBUG_CANVAS_COLOR);
        end
        
        -- border
        dxDrawRectangle(
            CANVAS_ADDITIONAL_MARGIN, CANVAS_ADDITIONAL_MARGIN,
            
            obj.absSize.x+2*obj.borderSize,
            obj.absSize.y+2*obj.borderSize,
            
            tocolor(obj.borderColor.r, obj.borderColor.g, obj.borderColor.b, 255*(1-obj.borderTransparency))
        );
        
        -- background
        dxSetBlendMode("overwrite");
        
        dxDrawRectangle(
            CANVAS_ADDITIONAL_MARGIN+obj.borderSize,
            CANVAS_ADDITIONAL_MARGIN+obj.borderSize,
            
            obj.absSize.x, obj.absSize.y,
            
            tocolor(obj.bgColor.r, obj.bgColor.g, obj.bgColor.b, 255*(1-obj.bgTransparency))
        );
        
        dxSetRenderTarget();
        
        dxSetBlendMode("blend");
    end
end



function set.parent(obj, parent, prev, k)
    local success, result = pcall(super.set.parent, obj, parent, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    if (prev and func.isA(prev, "GuiBase2D")) then
        local childrenCount = #prev.guiChildren;
        
        for i = obj.guiIndex+1, childrenCount do
            local child = prev.guiChildren[i];
            
            child.guiIndex = child.guiIndex-1;
            prev.guiChildren[i-1] = child;
        end
        
        prev.guiChildren[childrenCount] = nil;
        
        obj.guiIndex = nil;
        
        
        prev.class.func.update_containerPos(prev);
        prev.class.func.update_containerSize(prev);
        
        
        prev.class.func.update(prev);
        prev.class.func.propagate(prev);
    end
    
    
    if (parent and func.isA(parent, "GuiBase2D")) then
        obj.guiIndex = #parent.guiChildren+1;
        parent.guiChildren[obj.guiIndex] = obj;
        
        
        parent.class.func.update_containerPos(parent);
        parent.class.func.update_containerSize(parent);
    end
    
    
    func.update_rootGui(obj, true);
    
    func.update_clipperGui(obj, true);
    
    func.update_absSize(obj, true);
    func.update_absPos(obj, true);
    
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


function set.debug(obj, debug, prev, k)
    local success, result = pcall(super.set.debug, obj, debug, prev, k+1);
    if (not success) then error(result, 2) end
    
    
    func.update(obj);
    
    func.propagate(obj);
end


function set.clipsDescendants(obj, clipsDescendants)
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


function set.bgColor(obj, bgColor)
    local bgColor_t = type(bgColor);
    
    if (bgColor_t ~= "Color3") then
        error("bad argument #1 to 'bgColor3' (Color3 expected, got " ..bgColor_t.. ")", 2);
    end
    
    
    obj.bgColor = bgColor;
    
    
    func.update(obj);
    
    func.propagate(obj);
end

function set.bgTransparency(obj, bgTransparency)
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


function set.borderColor(obj, borderColor)
    local borderColor_t = type(borderColor);
    
    if (borderColor_t ~= "Color3") then
        error("bad argument #1 to 'borderColor3' (Color3 expected, got " ..borderColor_t.. ")", 2);
    end
    
    
    obj.borderColor = borderColor;
    
    
    func.update(obj);
    
    func.propagate(obj);
end

function set.borderSize(obj, borderSize)
    local borderSize_t = type(borderSize);
    
    if (borderSize_t ~= "number") then
        error("bad argument #1 to 'borderSize' (number expected, got " ..borderSize_t.. ")", 2);
    elseif (borderSize < 0) or (borderSize > MAX_BORDER_SIZE) then
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

function set.borderTransparency(obj, borderTransparency)
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


function set.size(obj, size)
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


function set.pos(obj, pos)
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

function set.posOrigin(obj, posOrigin)
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


function set.rot(obj, rot)
    local rot_t = type(rot);
    
    if (rot_t ~= "Vector3") then
        error("bad argument #1 to 'rot' (Vector3 expected, got " ..rot_t.. ")", 2);
    end
    
    
    obj.rot = rot;
    
    
    func.update_isRotated(obj);
    func.update_isRotated3D(obj);
    
    func.update_vertices(obj, true);
    
    func.update_containerRotPivot(obj);
    func.update_containerRotPerspective(obj);
    
    func.update_canvasRotPivot(obj);
    func.update_canvasRotPerspective(obj);
    
    func.update(obj);
    
    func.propagate(obj);
end

function set.rotPivot(obj, rotPivot)
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

function set.rotPivotDepth(obj, rotPivotDepth)
    local rotPivotDepth_t = type(rotPivotDepth);
    
    if (rotPivotDepth_t ~= "number") then
        error("bad argument #1 to 'rotPivotDepth' (number expected, got " ..rotPivotDepth_t.. ")", 2);
    elseif (rotPivotDepth <= ROT_ACTUAL_NEAR_Z_PLANE/2 or rotPivotDepth > ROT_FAR_Z_PLANE/2) then
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

function set.rotPerspective(obj, rotPerspective)
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


function set.visible(obj, visible)
    local visible_t = type(visible);
    
    if (visible_t ~= "boolean") then
        error("bad argument #1 to 'visible' (boolean expected, got " ..visible_t.. ")", 2);
    end
    
    
    obj.visible = visible;
    
    func.propagate(obj);
end



GuiObject = inherit({
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    event = event,
    
    private  = private,
    readOnly = readOnly,
    
    SHADER = SHADER,
    
    DEBUG_ROT_LINE_COLOR     = DEBUG_ROT_LINE_COLOR,
    DEBUG_ROT_LINE_THICKNESS = DEBUG_ROT_LINE_THICKNESS,
    
    new = new,
}, super);
