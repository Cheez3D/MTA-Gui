local classes = classes;

local super = classes.Object;

local class = inherit({
    name = "Stream",

    super = super,
    
    func = inherit({}, super.func),
    get  = inherit({}, super.get),
    set  = inherit({}, super.set),
    
    concrete = true,
}, super);

classes[class.name] = class;



class.CHAR_MASK  = 2^7;
class.SHORT_MASK = 2^15;
class.INT_MASK   = 2^31;



function class.new(bytes)
    local bytes_t = type(bytes);
    if (bytes_t ~= "string") then
        error("bad argument #1 to '" ..__func__.. "' (string expected, got " ..bytes_t.. ")", 2);
    end
    
    
    local success, obj = pcall(super.new, class);
    if (not success) then error(obj, 2) end
    
    
    if (fileExists(bytes)) then
        -- outputDebugString("creating stream from file found at " ..bytes);
        
        local f = fileOpen(bytes);
        obj.bytes = fileRead(f, fileGetSize(f));
        fileClose(f);
    else
        -- outputDebugString("file not found at " ..bytes.. "; creating stream from string instead");
        
        obj.bytes = bytes;
    end
    
    obj.size = #obj.bytes;
    obj.pos  = 0;
    
    
    return obj;
end

class.meta = extend({
    __metatable = super.name.. ":" ..class.name,
    
    
    __tostring = function(obj)
        return tostring(obj.isOpen).. ", " ..obj.pos.. "/" ..obj.size;
    end,
}, super.meta);



function class.func.read(obj, count)
    if (count ~= nil) then
        local count_t = type(count);
        
        if (count_t ~= "number") then
            error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..count_t.. ")", 2);
        elseif (count < 0) then
            error("bad argument #1 to '" ..__func__.. "' (value out of bounds)", 2);
        end
        
        count = math.floor(count);
    else
        count = 1;
    end
    
    
    local newPos = obj.pos+count;
    if (newPos > obj.size) then
        newPos = obj.size;
    end
    
    local ret = obj.bytes:sub(obj.pos+1, newPos);
    
    obj.pos = newPos;
    
    return ret;
end

function class.func.read_uchar(obj)
    return obj:read():byte();
end

function class.func.read_ushort(obj, bigEndian)
    if (bigEndian ~= nil) then
        local bigEndian_t = type(bigEndian);
        
        if (bigEndian_t ~= "boolean") then
            error("bad argument #1 to '" ..__func__.. "' (boolean expected, got " ..bigEndian_t.. ")", 2);
        end
    else
        bigEndian = false;
    end
    
    
    local uchar1 = obj:read_uchar();
    local uchar2 = obj:read_uchar();
    
    return (bigEndian) and 0x100 * uchar1
                         +         uchar2
                         
                        or         uchar1
                         + 0x100 * uchar2;
end

function class.func.read_uint(obj, bigEndian)
    if (bigEndian ~= nil) then
        local bigEndian_t = type(bigEndian);
        
        if (bigEndian_t ~= "boolean") then
            error("bad argument #1 to '" ..__func__.. "' (boolean expected, got " ..bigEndian_t.. ")", 2);
        end
    else
        bigEndian = false;
    end
    
    
    local ushort1 = obj:read_ushort(bigEndian);
    local ushort2 = obj:read_ushort(bigEndian);
    

    return (bigEndian) and 0x10000 * ushort1
                         +           ushort2
                         
                        or           ushort1
                         + 0x10000 * ushort2;
end


-- convert unsigned to signed
-- using masks to determine if MSB is 1 or 0
function class.func.read_char(obj)
    local uchar = obj:read_uchar();
    
    return uchar-2*bitAnd(uchar, class.CHAR_MASK);
end

function class.func.read_short(obj, bigEndian)
    local ushort = obj:read_ushort(bigEndian);
    
    return ushort-2*bitAnd(ushort, class.SHORT_MASK);
end

function class.func.read_int(obj, bigEndian)
    local uint = obj:read_uint(bigEndian);
    
    return uint-2*bitAnd(uint, class.INT_MASK);
end



function class.get.BOF(obj)
    return (obj.pos == 0);
end

function class.get.EOF(obj)
    return (obj.pos >= obj.size);
end



function class.set.pos(obj, pos)
    local pos_t = type(pos);
    if (pos_t ~= "number") then
        error("bad argument #1 to 'pos' (number expected, got " ..pos_t.. ")", 2);
    end
    
    pos = math.floor(pos);
    
    if (pos < 0) or (pos > obj.size) then
        error("bad argument #1 to 'pos' (value out of bounds)", 2);
    end
    
    
    obj.pos = pos;
end
