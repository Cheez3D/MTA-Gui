local classes = classes;

local super = classes.Object;

local class = inherit({
    name = "Signal",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = true,
}, super);

classes[class.name] = class;



function class.new()
    local success, obj = pcall(super.new, class);
    if (not success) then error(obj, 2) end
    
    obj.listenersByKey = {}
    
    return obj;
end

class.meta = extend({
    __metatable = super.name.. ":" ..class.name;
}, super.meta);



function class.func.connect(obj, listener)
    local listener_t = type(listener);
    
    if (listener_t ~= "function") then
        error("bad argument #1 to '" ..__func__.. "' (function expected, got " ..listener_t.. ")", 2);
    elseif (obj.listenersByKey[listener]) then
        error("bad argument #1 to '" ..__func__.. "' (listener already connected)", 2);
    end
    
    
    obj.listenersByKey[listener] = true;
end

function class.func.disconnect(obj, listener)
    local listener_t = type(listener);
    
    if (listener_t ~= "function") then
        error("bad argument #1 to '" ..__func__.. "' (function expected, got " ..listener_t.. ")", 2);
    elseif (not obj.listenersByKey[listener]) then
        error("bad argument #1 to '" ..__func__.. "' (attempt do disconnect unconnected listener)", 2);
    end
    
    
    obj.listenersByKey[listener] = nil;
end


function class.func.trigger(obj, ...)
    for listener in pairs(obj.listenersByKey) do
        listener(...);
    end
end
