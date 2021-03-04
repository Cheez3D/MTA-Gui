local classes = classes;

local super = classes.Object;

local class = inherit({
    name = "Matrix3x3",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = true,
}, super);

classes[class.name] = class;



local cache = setmetatable({}, { __mode = "v" });

function class.new(...)
    local arg = { ... }
    
    for i = 1, 9 do
        if (arg[i] ~= nil) then
            local arg_t = type(arg[i]);
            if (arg_t ~= "number") then
                error("bad argument #" ..i.. " to '" ..__func__.. "' (number expected, got " ..arg_t.. ")", 2);
            end
        else
            arg[i] = 0;
        end
    end
    
    
    local cacheId = table.concat(arg, ":");
    
    local obj = cache[cacheId];
    if (not obj) then
        local success;
        
        success, obj = pcall(super.new, class);
        if (not success) then error(obj, 2) end
        
        obj[00] = arg[1]; obj[01] = arg[2]; obj[02] = arg[3];
        obj[10] = arg[4]; obj[11] = arg[5]; obj[12] = arg[6];
        obj[20] = arg[7]; obj[21] = arg[8]; obj[22] = arg[9];
        
        cache[cacheId] = obj;
    end
    
    return obj;
end



class.meta = extend({
    __metatable = super.name.. ":" ..class.name,
    
    
    __add = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "Matrix3x3" and obj1_t ~= "number") then
            error("bad operand #1 to '+' (Matrix3x3/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "Matrix3x3" and obj2_t ~= "number") then
            error("bad operand #2 to '+' (Matrix3x3/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and class.new(
            obj1+obj2[00], obj1+obj2[01], obj1+obj2[02],
            obj1+obj2[10], obj1+obj2[11], obj1+obj2[12],
            obj1+obj2[20], obj1+obj2[21], obj1+obj2[22]
        )
        or (obj2_t == "number") and class.new(
            obj1[00]+obj2, obj1[01]+obj2, obj1[02]+obj2,
            obj1[10]+obj2, obj1[11]+obj2, obj1[12]+obj2,
            obj1[20]+obj2, obj1[21]+obj2, obj1[22]+obj2
        )
        or new(
            obj1[00]+obj2[00], obj1[01]+obj2[01], obj1[02]+obj2[02],
            obj1[10]+obj2[10], obj1[11]+obj2[11], obj1[12]+obj2[12],
            obj1[20]+obj2[20], obj1[21]+obj2[21], obj1[22]+obj2[22]
        );
    end,
    
    __sub = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "Matrix3x3" and obj1_t ~= "number") then
            error("bad operand #1 to '-' (Matrix3x3/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "Matrix3x3" and obj2_t ~= "number") then
            error("bad operand #2 to '-' (Matrix3x3/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and class.new(
            obj1-obj2[00], obj1-obj2[01], obj1-obj2[02],
            obj1-obj2[10], obj1-obj2[11], obj1-obj2[12],
            obj1-obj2[20], obj1-obj2[21], obj1-obj2[22]
        )
        or (obj2_t == "number") and class.new(
            obj1[00]-obj2, obj1[01]-obj2, obj1[02]-obj2,
            obj1[10]-obj2, obj1[11]-obj2, obj1[12]-obj2,
            obj1[20]-obj2, obj1[21]-obj2, obj1[22]-obj2
        )
        or class.new(
            obj1[00]-obj2[00], obj1[01]-obj2[01], obj1[02]-obj2[02],
            obj1[10]-obj2[10], obj1[11]-obj2[11], obj1[12]-obj2[12],
            obj1[20]-obj2[20], obj1[21]-obj2[21], obj1[22]-obj2[22]
        );
    end,
    
    __mul = function(obj1, obj2)
        local obj1_t = type(obj1);
        if (obj1_t ~= "Matrix3x3" and obj1_t ~= "number") then
            error("bad operand #1 to '*' (Matrix3x3/number expected, got " ..obj1_t.. ")", 2);
        end
        
        local obj2_t = type(obj2);
        if (obj2_t ~= "Matrix3x3" and obj2_t ~= "Vector3" and obj2_t ~= "number") then
            error("bad operand #2 to '*' (Matrix3x3/Vector3/number expected, got " ..obj2_t.. ")", 2);
        end
        
        
        return (obj1_t == "number") and class.new(
            obj1*obj2[00], obj1*obj2[01], obj1*obj2[02],
            obj1*obj2[10], obj1*obj2[11], obj1*obj2[12],
            obj1*obj2[20], obj1*obj2[21], obj1*obj2[22]
        )
        or (obj2_t == "Vector3") and classes.Vector3.new(
            obj1[00]*obj2.x + obj1[01]*obj2.y + obj1[02]*obj2.z,
            obj1[10]*obj2.x + obj1[11]*obj2.y + obj1[12]*obj2.z,
            obj1[20]*obj2.x + obj1[21]*obj2.y + obj1[22]*obj2.z
        )
        or (obj2_t == "number") and class.new(
            obj1[00]*obj2, obj1[01]*obj2, obj1[02]*obj2,
            obj1[10]*obj2, obj1[11]*obj2, obj1[12]*obj2,
            obj1[20]*obj2, obj1[21]*obj2, obj1[22]*obj2
        )
        or class.new(
            obj1[00]*obj2[00] + obj1[01]*obj2[10] + obj1[02]*obj2[20],
            obj1[00]*obj2[01] + obj1[01]*obj2[11] + obj1[02]*obj2[21],
            obj1[00]*obj2[02] + obj1[01]*obj2[12] + obj1[02]*obj2[22],
            
            obj1[10]*obj2[00] + obj1[11]*obj2[10] + obj1[12]*obj2[20],
            obj1[10]*obj2[01] + obj1[11]*obj2[11] + obj1[12]*obj2[21],
            obj1[10]*obj2[02] + obj1[11]*obj2[12] + obj1[12]*obj2[22],
            
            obj1[20]*obj2[00] + obj1[21]*obj2[10] + obj1[22]*obj2[20],
            obj1[20]*obj2[01] + obj1[21]*obj2[11] + obj1[22]*obj2[21],
            obj1[20]*obj2[02] + obj1[21]*obj2[12] + obj1[22]*obj2[22]
        );
    end,
    
    
    __unm = function(obj)
        return class.new(
            -obj[00], -obj[01], -obj[02],
            -obj[10], -obj[11], -obj[12],
            -obj[20], -obj[21], -obj[22]
        );
    end,
    
    
    __tostring = function(obj)
        return obj[00].. ", " ..obj[01].. ", " ..obj[02].. "\n"
             ..obj[10].. ", " ..obj[11].. ", " ..obj[12].. "\n"
             ..obj[20].. ", " ..obj[21].. ", " ..obj[22];
    end,
}, super.meta);



function class.func.unpack(obj)
    return obj[00], obj[01], obj[02],
           obj[10], obj[11], obj[12],
           obj[20], obj[21], obj[22];
end



function class.get.det(obj)
    if (not obj.det) then
        obj.det = obj[00]*obj[11]*obj[22] + obj[02]*obj[10]*obj[21] + obj[01]*obj[12]*obj[20]
                - obj[02]*obj[11]*obj[20] - obj[00]*obj[12]*obj[21] - obj[01]*obj[10]*obj[22];
    end
    
    return obj.det;
end

function class.get.transpose(obj)
    if (not obj.transpose) then
        obj.transpose = class.new(
            obj[00], obj[10], obj[20],
            obj[01], obj[11], obj[21],
            obj[02], obj[12], obj[22]
        );
    end
    
    return obj.transpose;
end
