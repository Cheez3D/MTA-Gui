local name = "Stream";

local class;
local super = Object;

local func = inherit({}, super.func);
local get  = inherit({}, super.get);
local set  = inherit({}, super.set);

local new, meta;

local concrete = true;



local CHAR_MASK  = 2^7;
local SHORT_MASK = 2^15;
local INT_MASK   = 2^31;



function new(bytes)
    local bytes_t = type(bytes);
    if (bytes_t ~= "string") then
        error("bad argument #1 to '" ..__func__.. "' (string expected, got " ..bytes_t.. ")", 2);
    end
    
    
    local success, obj = pcall(super.new, class, meta);
    if (not success) then error(obj, 2) end
    
    
    obj.isFile = fileExists(bytes);
    
    if (obj.isFile) then
        obj.fileName = bytes;
    else
        obj.bytes = bytes;
    end
    
    
    obj.func.open(obj);
    
    
    return obj;
end

meta = extend({
    __metatable = name,
    
    
    __tostring = function(obj)
        return tostring(obj.isOpen).. ", " ..obj.pos.. "/" ..obj.size;
    end,
}, super.meta);



function func.open(obj)
    if (obj.isOpen) then
        error("stream is already open", 2);
    end
    
    
    obj.isOpen = true;
    
    if (obj.isFile) then
        obj.file = fileOpen(obj.fileName, true); -- TODO: add write support in the future
        
        obj.size = fileGetSize(obj.file);
    else
        obj.size = #obj.bytes;
    end
    
    obj.pos = 0;
end

function func.close(obj)
    if (not obj.isOpen) then
        error("stream is already closed", 2);
    end
    
    
    obj.isOpen = false;
    
    if (obj.isFile) then
        fileClose(obj.file);
        obj.file = nil;
    end
    
    obj.size = nil;
    obj.pos  = nil;
end


function func.read(obj, count)
    if (not obj.isOpen) then
        error("stream is closed", 2);
    end
    
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
    
    local ret = obj.isFile and fileRead(obj.file, count) or string.sub(obj.bytes, obj.pos+1, newPos);
    
    obj.pos = newPos;
    
    return ret;
end

function func.read_uchar(obj)
    local byte = obj.func.read(obj);
    
    return string.byte(byte);
end

function func.read_ushort(obj, bigEndian)
    if (bigEndian ~= nil) then
        local bigEndian_t = type(bigEndian);
        
        if (bigEndian_t ~= "boolean") then
            error("bad argument #1 to '" ..__func__.. "' (boolean expected, got " ..bigEndian_t.. ")", 2);
        end
    else
        bigEndian = false;
    end
    
    
    local uchar1 = obj.func.read_uchar(obj);
    local uchar2 = obj.func.read_uchar(obj);
    
    return (bigEndian) and 0x100 * uchar1
                         +         uchar2
                         
                        or         uchar1
                         + 0x100 * uchar2;
end

function func.read_uint(obj, bigEndian)
    if (bigEndian ~= nil) then
        local bigEndian_t = type(bigEndian);
        
        if (bigEndian_t ~= "boolean") then
            error("bad argument #1 to '" ..__func__.. "' (boolean expected, got " ..bigEndian_t.. ")", 2);
        end
    else
        bigEndian = false;
    end
    
    
    local ushort1 = obj.func.read_ushort(obj, bigEndian);
    local ushort2 = obj.func.read_ushort(obj, bigEndian);
    

    return (bigEndian) and 0x10000 * ushort1
                         +           ushort2
                         
                        or           ushort1
                         + 0x10000 * ushort2;
end


-- convert unsigned to signed
-- using masks to determine if MSB is 1 or 0
function func.read_char(obj)
    local uchar = obj.func.read_uchar(obj);
    
    return uchar-2*bitAnd(uchar, CHAR_MASK);
end

function func.read_short(obj, bigEndian)
    local ushort = obj.func.read_ushort(obj, bigEndian);
    
    return ushort-2*bitAnd(ushort, SHORT_MASK);
end

function func.read_int(obj, bigEndian)
    local uint = obj.func.read_uint(obj, bigEndian);
    
    return uint-2*bitAnd(uint, INT_MASK);
end



function get.BOF(obj)
    return (obj.pos == 0);
end

function get.EOF(obj)
    return (obj.pos >= obj.size);
end



function set.pos(obj, pos)
    local pos_t = type(pos);
    if (pos_t ~= "number") then
        error("bad argument #1 to 'pos' (number expected, got " ..pos_t.. ")", 2);
    end
    
    pos = math.floor(pos);
    
    if (pos < 0) or (pos > obj.size) then
        error("bad argument #1 to 'pos' (value out of bounds)", 2);
    end
    
    
    if (obj.isFile) then
        fileSetPos(obj.file, pos);
    end
    
    obj.pos = pos;
end



class = {
    name = name,
    func = func, get = get, set = set,
    
    new = new, meta = meta,
    
    concrete = concrete,
}

_G[name] = class;
classes[#classes+1] = class;
