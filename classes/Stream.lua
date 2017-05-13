-- [=======[ FILE ]======[
-- NAME:		Stream.lua
-- PURPOSE:		?
-- ]=====================]

local INT_MAX = 2^31;


local Class = {
	Functions = {},
	IndexFunctions = {},
	NewIndexFunctions = {},
	
	PrivateKeys = {
		Bytes = true
	},
	ReadOnlyKeys = {
		Size = true
	}
}


local MetaTable = {
	__index = function(Proxy,Key)
		if (Class.PrivateKeys[Key] == true) then return nil end
		
		
		local Object = ProxyToObject[Proxy];
		
		local Value = Object[Key];
		if (Value ~= nil) then
			return Value;
		end
		
		
		local Function = Class.Functions[Key];
		if (Function ~= nil) then
			return Function;
		end
		
		local IndexFunction = Class.IndexFunctions[Key];
		if (IndexFunction ~= nil) then
			return IndexFunction(Object);
		end
	end,
	__metatable = "Stream",
	__newindex = function(Proxy,Key,Value)
		if (Class.ReadOnlyKeys[Key] == true) then error("attempt to modify a read-only key ("..tostring(Key)..")",2) end
		
		local Object = ProxyToObject[Proxy];
		
		local NewIndexFunction = Class.NewIndexFunctions[Key];
		if (NewIndexFunction ~= nil) then
			local PreviousValue = Object[Key];
			
			NewIndexFunction(Object,Key,Value,PreviousValue);
		end
	end
}

function Class.New(Bytes)
	local BytesType = type(Bytes);
	if (BytesType ~= "string") then error("bad argument #1 to '"..__func__.."' (string expected, got "..BytesType..")",2) end
	
	
	local Object = {
		Bytes = Bytes,
		
		Position = 0,
		Size = #Bytes
	}
	
	local Proxy = setmetatable({},MetaTable);
	ProxyToObject[Proxy] = Object;
	
	return Proxy;
end

do
	function Class.Functions.Read(Proxy,Count)
		local ProxyType = type(Proxy);
		if (ProxyType ~= "Stream") then error("bad argument #1 to '"..__func__.."' (Stream expected, got "..ProxyType..")",2) end
		
		if (Count ~= nil) then
			local CountType = type(Count);
			if (CountType ~= "number") then error("bad argument #2 to '"..__func__.."' (number expected, got "..CountType..")",2)
			elseif (Count < 0) then error ("bad argument #2 to '"..__func__.."' (value out of bounds)",2) end
			
			Count = math.floor(Count);
		else
			Count = 1;
		end
		
		
		local Object = ProxyToObject[Proxy];
		
		local PreviousPosition = Object.Position;
		local NextPosition = PreviousPosition+Count;
		
		local Size = Object.Size;
		if (NextPosition > Size) then
			NextPosition = Size;
		end
		
		Object.Position = NextPosition;
		
		return Object.Bytes:sub(PreviousPosition+1,NextPosition);
	end
	
	function Class.Functions.Read_uchar(Proxy)
		local Success,Result = pcall(Class.Functions.Read,Proxy);
		if (Success == false) then error(format_pcall_error(Result),2)
		--[[elseif (Result == "") then error("bad argument #1 to '"..__func__.."' (EOF)",2)]] end
		
		return Result:byte();
	end
	
	function Class.Functions.Read_ushort(Proxy,Endianness)
		local Success,uchar_1 = pcall(Class.Functions.Read_uchar,Proxy);
		if (Success == false) then error(format_pcall_error(uchar_1),2) end
		
		if (Endianness ~= nil) then
			local EndiannessType = type(Endianness);
			if (EndiannessType ~= "number") then error("bad argument #2 to '"..__func__.."' (number expected, got "..EndiannessType..")",2)
			elseif (Endianness ~= Enum.Endianness.LittleEndian) and (Endianness ~= Enum.Endianness.BigEndian) then error("bad argument #2 to '"..__func__.."' (invalid value)",2) end
		else
			Endianness = Enum.Endianness.LittleEndian;
		end
		
		local uchar_2 = Class.Functions.Read_uchar(Proxy);
		
		return (Endianness == Enum.Endianness.LittleEndian) and uchar_1+uchar_2*256 or uchar_1*256+uchar_2;
	end
	
	function Class.Functions.Read_uint(Proxy,Endianness)
		local Success,ushort_1 = pcall(Class.Functions.Read_ushort,Proxy,Endianness);
		if (Success == false) then error(format_pcall_error(ushort_1),2) end
		
		if (Endianness == nil) then Endianness = Enum.Endianness.LittleEndian end
		
		local ushort_2 = Class.Functions.Read_ushort(Proxy,Endianness);
		
		return (Endianness == Enum.Endianness.LittleEndian) and ushort_1+ushort_2*65536 or ushort_1*65536+ushort_2;
	end
	
	function Class.Functions.Read_int(Proxy,Endianness)
		local Success,Result = pcall(Class.Functions.Read_uint,Proxy,Endianness);
		if (Success == false) then error(format_pcall_error(Result),2) end
		
		return Result-bitAnd(Result,INT_MAX)*2;
	end
end

do
	function Class.IndexFunctions.BOF(Object) return (Object.Position == 0) end

	function Class.IndexFunctions.EOF(Object) return (Object.Position >= Object.Size) end
end

do
	function Class.NewIndexFunctions.Position(Object,Key,Position)
		local PositionType = type(Position);
		if (PositionType ~= "number") then error("bad argument #1 to '"..Key.."' (number expected, got "..PositionType..")",3) end
		
		Position = math.floor(Position);
		if (Position < 0) or (Position > Object.Size) then error("bad argument #1 to '"..Key.."' (value out of bounds)",3) end
		
		Object.Position = Position;
	end
end


Stream = setmetatable({},{
	__call = function(_Proxy,...)
		local Success,Result = pcall(Class.New,...);
		if (Success == false) then error(format_pcall_error(Result),2) end
		
		return Result;
	end,
	__index = Class,
	__metatable = "Stream",
	__newindex = function(_Proxy,Key)
		error("attempt to modify a read-only key ("..tostring(Key)..")",2);
	end
});