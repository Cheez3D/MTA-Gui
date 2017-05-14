local CHAR_MASK  = 2^7;
local SHORT_MASK = 2^15;
local INT_MASK   = 2^31;



local func = {}
local get  = {}
local set  = {}

local private = {
    bytes = true,
}

local readonly = {
    size = true,
}

local new;

local meta = {
    __metatable = "Stream",
    
    
	__index = function(proxy, key)
        if (private[key]) then return end
        
        
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
	
	__newindex = function(proxy, key, val)
		if (readonly[key]) then
            error("attempt to modify a read-only key (" ..tostring(key).. ")", 2);
        end
		
        
		local obj = PROXY__OBJ[proxy];
		
		local set_f = set[key];
		if (set_f) then
			local prev = obj[key];
			
			set_f(obj, key, val, prev);
		end
	end
}

function new(bytes)
	local bytesType = type(bytes);
	if (bytesType ~= "string") then error("bad argument #1 to '"..__func__.."' (string expected, got "..bytesType..")",2) end
	
	
	local obj = {
		bytes = bytes,
		
		pos = 0, size = #bytes,
	}
	
	local proxy = setmetatable({}, meta);
    
	PROXY__OBJ[proxy] = obj;
	
	return proxy;
end



function func.read(obj, count)
    if (count ~= nil) then
        local countType = type(count);
        
        if (countType ~= "number") then
            error("bad argument #2 to '" ..__func__.. "' (number expected, got "..countType..")", 2);
        elseif (count < 0) then
            error("bad argument #2 to '" ..__func__.. "' (value out of bounds)", 2);
        end
        
        count = math.floor(count);
    else
        count = 1;
    end
    
    
    local prevPos = obj.pos;
    local nextPos = prevPos+count;
    
     if (nextPos > obj.size) then
        nextPos = obj.size;
    end
    
    obj.pos = nextPos;
    
    return string.sub(obj.bytes, prevPos+1, nextPos);
end

function func.read_uchar(obj)    
    return string.byte(func.read(obj, 1));
end

function func.read_ushort(obj, isLittleEndian)
    isLittleEndian = isLittleEndian or true; -- TODO: change this into proper assertion
    
    local uchar1 = func.read_uchar(obj);
    local uchar2 = func.read_uchar(obj);
    
    return (isLittleEndian) and 0x100 * uchar2
                              +         uchar1
                            
                            or  0x100 * uchar1
                              +         uchar2;
end

function func.read_uint(obj, isLittleEndian)
    isLittleEndian = isLittleEndian or true; -- TODO: change this into proper assertion
    
    local ushort1 = func.read_ushort(obj, isLittleEndian);
    local ushort2 = func.read_ushort(obj, isLittleEndian);
    

    return (isLittleEndian) and 0x10000 * ushort2
                              +           ushort1
                            
                            or  0x10000 * ushort1
                              +           ushort2;
end

function func.read_int(obj, isLittleEndian)
    local uint = func.read_uint(obj, isLittleEndian);
    
    -- convert unsigned to signed
    -- using INT_MASK to determine if MSB is 1 or 0
    return uint-2*bitAnd(uint, INT_MASK);
end



function get.BOF(obj)
    return (obj.pos == 0);
end

function get.EOF(obj)
    return (obj.pos >= obj.size);
end



function set.pos(obj, key, pos)
    local posType = type(pos);
    
    if (posType ~= "number") then
        error("bad argument #1 to '" ..key.. "' (number expected, got " ..posType.. ")", 3);
    end
    
    pos = math.floor(pos);
    if (pos < 0) or (pos > obj.size) then
        error("bad argument #1 to '" ..key.. "' (value out of bounds)", 3);
    end
    
    
    obj.pos = pos;
end



Stream = setmetatable({}, {
    __metatable = "Stream",
    
    
    __index = function(proxy, key)
        return (key == "new") and new or nil;
    end,
    
    __newindex = function(proxy, key)
        error("attempt to modify a read-only key (" ..tostring(key).. ")", 2);
    end,
    
    
    __call = function(proxy, ...)
        local success, result = pcall(new, ...);
        
        if (not success) then
            error("call error", 2);
        end
        
        return result;
    end,
});
