local name = "Matrix3x3";

local func = {}
local get  = {}

local new;

local meta = {
    __metatable = name,
    
    
    __index = function(proxy, key)
        local obj = PROXY__OBJ[proxy];
        
        local val = obj[key];
        if (val ~= nil) then -- val might be false so compare against nil
            return val;
        end
    
        local func_f = func[key];
        if (func_f) then
            return (function(...) return func_f(obj, ...) end); -- might be able to do memoization here
        end
        
        local get_f = get[key];
        if (get_f) then
            return get_f(obj, key);
        end
    end,
    
    __newindex = function(proxy, key)
        error("attempt to modify a read-only key (" ..tostring(key).. ")", 2);
    end,
    
    
    __add = function(proxy1, proxy2)
        local proxy1_t = type(proxy1);
        
        if (proxy1_t ~= "Matrix3x3") then
            error("bad operand #1 to '__add' (Matrix3x3 expected, got " ..proxy1_t.. ")", 2);
        end
        
        local proxy2_t = type(proxy2);
        
        if (proxy2_t ~= "Matrix3x3") then
            error("bad operand #2 to '__add' (Matrix3x3 expected, got " ..proxy2_t.. ")", 2);
        end
        
        
        
        local obj1 = PROXY__OBJ[proxy1];
        local obj2 = PROXY__OBJ[proxy2];
        
        return new(
            obj1.m00 + obj2.m00, obj1.m01 + obj2.m01, obj1.m02 + obj2.m02,
            obj1.m10 + obj2.m10, obj1.m11 + obj2.m11, obj1.m12 + obj2.m12,
            obj1.m20 + obj2.m20, obj1.m21 + obj2.m21, obj1.m22 + obj2.m22
        );
    end,
    
    __sub = function(proxy1, proxy2)
        local proxy1_t = type(proxy1);
        
        if (proxy1_t ~= "Matrix3x3") then
            error("bad operand #1 to '__sub' (Matrix3x3 expected, got " ..proxy1_t.. ")", 2);
        end
        
        local proxy2_t = type(proxy2);
        
        if (proxy2_t ~= "Matrix3x3") then
            error("bad operand #2 to '__sub' (Matrix3x3 expected, got " ..proxy2_t.. ")", 2);
        end
        
        
        
        local obj1 = PROXY__OBJ[proxy1];
        local obj2 = PROXY__OBJ[proxy2];
        
        return new(
            obj1.m00 - obj2.m00, obj1.m01 - obj2.m01, obj1.m02 - obj2.m02,
            obj1.m10 - obj2.m10, obj1.m11 - obj2.m11, obj1.m12 - obj2.m12,
            obj1.m20 - obj2.m20, obj1.m21 - obj2.m21, obj1.m22 - obj2.m22
        );
    end,
    
    __mul = function(proxy1, proxy2)
        local proxy1_t = type(proxy1);
        
        if (proxy1_t ~= "Matrix3x3") then
            error("bad operand #1 to '__mul' (Matrix3x3 expected, got " ..proxy1_t.. ")", 2);
        end
        
        local proxy2_t = type(proxy2);
        
        if (proxy2_t ~= "Matrix3x3" and proxy2_t ~= "Vector3") then
            error("bad operand #2 to '__mul' (Matrix3x3/Vector3 expected, got " ..proxy2_t.. ")", 2);
        end
        
        
        
        local obj1 = PROXY__OBJ[proxy1];
        local obj2 = PROXY__OBJ[proxy2];
        
        if (proxy2_t == "Vector3") then
            return Vector3.new(
                obj1.m00*obj2.x + obj1.m01*obj2.y + obj1.m02*obj2.z,
                obj1.m10*obj2.x + obj1.m11*obj2.y + obj1.m12*obj2.z,
                obj1.m20*obj2.x + obj1.m21*obj2.y + obj1.m22*obj2.z
            );
        end
        
        return new(
            obj1.m00*obj2.m00 + obj1.m01*obj2.m10 + obj1.m02*obj2.m20,
            obj1.m00*obj2.m01 + obj1.m01*obj2.m11 + obj1.m02*obj2.m21,
            obj1.m00*obj2.m02 + obj1.m01*obj2.m12 + obj1.m02*obj2.m22,
            
            obj1.m10*obj2.m00 + obj1.m11*obj2.m10 + obj1.m12*obj2.m20,
            obj1.m10*obj2.m01 + obj1.m11*obj2.m11 + obj1.m12*obj2.m21,
            obj1.m10*obj2.m02 + obj1.m11*obj2.m12 + obj1.m12*obj2.m22,
            
            obj1.m20*obj2.m00 + obj1.m21*obj2.m10 + obj1.m22*obj2.m20,
            obj1.m20*obj2.m01 + obj1.m21*obj2.m11 + obj1.m22*obj2.m21,
            obj1.m20*obj2.m02 + obj1.m21*obj2.m12 + obj1.m22*obj2.m22
        );
    end,
    
    
    __unm = function(proxy)
        local obj = PROXY__OBJ[proxy];
        
        return new(
            -obj.m00, -obj.m01, -obj.m02,
            -obj.m10, -obj.m11, -obj.m12,
            -obj.m20, -obj.m21, -obj.m22
        );
    end,
    
    
    -- __eq, -- memoization takes care of it
    
    
    __tostring = function(proxy)
        local obj = PROXY__OBJ[proxy];
        
        return obj.m00.. ", " ..obj.m01.. ", " ..obj.m02.. "\n"
             ..obj.m10.. ", " ..obj.m11.. ", " ..obj.m12.. "\n"
             ..obj.m20.. ", " ..obj.m21.. ", " ..obj.m22;
    end,
}



local MEM_PROXIES = setmetatable({}, { __mode = "v" });



function new(m00, m01, m02, m10, m11, m12, m20, m21, m22)
    
    if (m00 ~= nil) then
        local m00_t = type(m00);
        
        if (m00_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..m00_t.. ")", 2);
        end
    else
        m00 = 0;
    end
    
    if (m01 ~= nil) then
        local m01_t = type(m01);
        
        if (m01_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..m01_t.. ")", 2);
        end
    else
        m01 = 0;
    end
    
    if (m02 ~= nil) then
        local m02_t = type(m02);
        
        if (m02_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..m02_t.. ")", 2);
        end
    else
        m02 = 0;
    end
    
    if (m10 ~= nil) then
        local m10_t = type(m10);
        
        if (m10_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..m10_t.. ")", 2);
        end
    else
        m10 = 0;
    end
    
    if (m11 ~= nil) then
        local m11_t = type(m11);
        
        if (m11_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..m11_t.. ")", 2);
        end
    else
        m11 = 0;
    end
    
    if (m12 ~= nil) then
        local m12_t = type(m12);
        
        if (m12_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..m12_t.. ")", 2);
        end
    else
        m12 = 0;
    end
    
    if (m20 ~= nil) then
        local m20_t = type(m20);
        
        if (m20_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..m20_t.. ")", 2);
        end
    else
        m20 = 0;
    end
    
    if (m21 ~= nil) then
        local m21_t = type(m21);
        
        if (m21_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..m21_t.. ")", 2);
        end
    else
        m21 = 0;
    end
    
    if (m22 ~= nil) then
        local m22_t = type(m22);
        
        if (m22_t ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..m22_t.. ")", 2);
        end
    else
        m22 = 0;
    end
    
    
    local memId = m00.. ":" ..m01.. ":" ..m02.. ":"
                ..m10.. ":" ..m11.. ":" ..m12.. ":"
                ..m20.. ":" ..m21.. ":" ..m22;
    
    local proxy = MEM_PROXIES[memId];
    
    if (not proxy) then
        local obj = {
            type = name,
            
            
            m00 = m00, m01 = m01, m02 = m02,
            m10 = m10, m11 = m11, m12 = m12,
            m20 = m20, m21 = m21, m22 = m22,
        }
        
        proxy = setmetatable({}, meta);
        
        MEM_PROXIES[memId] = proxy;
        
        OBJ__PROXY[obj] = proxy;
        PROXY__OBJ[proxy] = obj;
    end
    
    return proxy;
end



function func.unpack(obj)
    return obj.m00, obj.m01, obj.m02,
           obj.m10, obj.m11, obj.m12,
           obj.m20, obj.m21, obj.m22;
end



function get.det(obj)
    obj.det = obj.m00*obj.m11*obj.m22 + obj.m02*obj.m10*obj.m21 + obj.m01*obj.m12*obj.m20
            - obj.m02*obj.m11*obj.m20 - obj.m00*obj.m12*obj.m21 - obj.m01*obj.m10*obj.m22;
    
    return obj.det;
end

function get.transpose(obj)
    obj.transpose = new(
        obj.m00, obj.m10, obj.m20,
        obj.m01, obj.m11, obj.m21,
        obj.m02, obj.m12, obj.m22
    );
    
    return obj.transpose;
end



Matrix3x3 = {
    name = name,
    
    func = func,
    get  = get,
    
    meta = meta,
    
    new = new,
}
