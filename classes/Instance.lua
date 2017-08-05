local super = Object;

local class = inherit({
    name = "Instance",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = false,
}, super);

classes[class.name] = class;



function class.isCircularReference(obj, parent)
    if (obj.childrenByKey[parent]) then
        return true;
    end
    
    for i = 1, #obj.children do
        if (class.isCircularReference(obj.children[i], parent)) then
            return true;
        end
    end
    
    return false;
end



function class.new(...)
    local success, obj = pcall(super.new, ...);
    if (not success) then error(obj, 2) end
    
    
    obj.index = nil; -- index in children array of parent
    
    obj.children       = {}
    obj.childrenByKey  = {}
    obj.childrenByName = {}
    
    obj.depth = nil; -- depth in Instance tree
    
    
    class.set.name(obj, obj.class.name);
    class.set.parent(obj, nil);
    
    
    return obj;
end

class.meta = extend({
    __metatable = class.name,
    
    --[[
    TODO: add this code to a proxy_meta table to extend from when creating proxy classes in end.lua
          instead of extending from meta
    -- __index = function(proxy, key)
        -- local obj = PROXY__OBJ[proxy];
        
        -- local child = obj.childrenByName[key];
        
        -- if (obj.class.private[key]) then
            -- if (child) then -- if key is private but a child with key name exists
                -- return OBJ__PROXY[child];
            -- end
            
            -- return;
        -- end
        
        -- if (child) then
            -- return OBJ__PROXY[child];
        -- end
    -- end,
    ]]
    
    __tostring = function(obj)
        return obj.class.name.. " " ..obj.name;
    end,
}, super.meta);







function class.func.update_depth(obj, descend)
    local depth = obj.parent and obj.parent.depth+1 or 1;
    
    if (depth ~= obj.depth) then
        obj.depth = depth;
        
        
        if (descend) then
            for i = 1, #obj.children do
                class.func.update_depth(obj.children[i], true);
            end
        end
    end
end


function class.func.isA(obj, className)
    local className_t = type(className);
    
    if (className_t ~= "string") then
        error("bad argument #1 to 'isA' (string expected, got " ..className_t.. ")", 2);
    end
    
    
    local class = obj.class;
    while (class) do
        if (class.name == className) then
            return true;
        end
        
        class = class.super;
    end
    
    return false;
end



function class.set.name(obj, name, prev)
    local name_t = type(name);
    
    if (name_t ~= "string") then
        error("bad argument #1 to 'name' (string expected, got " ..name_t.. ")", 2);
    end
    
    
    if (obj.parent) then
        local parent = obj.parent;
        
        -- if obj is occupying the place in childrenByName then try to find another child with same prevName to replace it
        if (parent.childrenByName[prev] == obj) then
            local child;
            
            -- start search from after obj because childrenByName place is occupied by object with smallest index
            for i = obj.index+1, #parent.children do
                child = parent.children[i];
                
                if (child.name == prev) then
                    break;
                end
            end
            
            parent.childrenByName[prev] = child; -- if other child not found it will be set to nil
        end
        
        if (not parent.childrenByName[name]) then
            parent.childrenByName[name] = obj;
        end
    end
    
    obj.name = name;
end


function class.set.parent(obj, parent, prev)
    if (parent ~= nil) then -- might be false so check against nil for assertion
        local parent_t = type(parent);
        
        if (parent_t ~= "Instance") then
            error("bad argument #1 to 'parent' (Instance expected, got " ..parent_t.. ")", 2);
        end
        
        
        -- if trying to make circular references
        -- e.g. obj1.parent = obj2; obj2.parent = obj3; obj3.parent = obj1;
        
        while (class.isCircularReference(obj, parent)) do
            error("bad argument #1 to 'parent' (circular reference)", 2);
        end
        
        -- if trying to set an object as its own parent
        -- e.g. obj.parent = obj;
        
        if (parent == obj) then
            error("bad argument #1 to 'parent' (self parenting)", 2);
        end
    end
    
    
    if (prev) then
        local childrenCount = #prev.children;
        
        for i = obj.index+1, childrenCount do
            local child = prev.children[i];
            
            child.index = child.index-1;
            prev.children[i-1] = child;
        end
        
        prev.children[childrenCount] = nil; -- remove last redundant element (using childrenCount from before operating on array)
        
        -- remove child from childrenByKey table
        prev.childrenByKey[obj] = nil;
        
        -- remove child from childrenByName table and, if possible, replace with another child with same name
        if (prev.childrenByName[obj.name] == obj) then
            local child;
            
            for i = obj.index, #prev.children do
                child = prev.children[i];
                
                if (child.name == obj.name) then
                    break;
                end
            end
            
            prev.childrenByName[obj.name] = child; -- if other child not found it will be set to nil
        end
        
        obj.index = nil;
    end
    
    
    if (parent) then
        obj.index = #parent.children+1;
        parent.children[obj.index] = obj;
        
        parent.childrenByKey[obj] = true;
        
        if (not parent.childrenByName[obj.name]) then -- if there is no existing child with same name
            parent.childrenByName[obj.name] = obj;
        end
    end
    
    
    obj.parent = parent;
    
    
    class.func.update_depth(obj, true);
end
