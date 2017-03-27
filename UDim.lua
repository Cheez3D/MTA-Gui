-- [======[ FILE ]=====[
-- NAME:		UDim.lua
-- PURPOSE:		?
-- ]===================]

local Class = {
	Functions = {}
}



local MetaTable = {
	__add = function(FirstProxy,SecondProxy)
		local FirstProxyType = type(FirstProxy);
		if (FirstProxyType ~= "UDim") then error("bad argument #1 to '"..__func__.."' (UDim expected, got "..FirstProxyType..")",2) end
		
		local SecondProxyType = type(SecondProxy);
		if (SecondProxyType ~= "UDim") then error("bad argument #2 to '"..__func__.."' (UDim expected, got "..SecondProxyType..")",2) end
		
		local First = ProxyToObject[FirstProxy];	local Second = ProxyToObject[SecondProxy];
		
		return Class.New(
			First.Scale+Second.Scale,
			First.Offset+Second.Offset
		);
	end,
	__index = function(Proxy,Key)
		local Object = ProxyToObject[Proxy];
		
		local Value = Object[Key];
		if (Value ~= nil) then return Value end
		
		local Function = Class.Functions[Key];
		if (Function ~= nil) then return Function end
		
		return nil;
	end,
	__metatable = "UDim",
	__newindex = function(_Proxy,Key) error("attempt to modify a read-only key ("..tostring(Key)..")",2) end,
	__tostring = function(Proxy)
		local Object = ProxyToObject[Proxy];
		
		return Object.Scale..", "..Object.Offset;
	end
}

local MemoizedProxies = setmetatable({},{__mode = "v"});
function Class.New(Scale,Offset)
	if (Scale ~= nil) then
		local ScaleType = type(Scale);
		if (ScaleType ~= "number") then error("bad argument #1 to '"..__func__.."' (number expected, got "..ScaleType..")",2) end
	else Scale = 0 end
	
	if (Offset ~= nil) then
		local OffsetType = type(Offset);
		if (OffsetType ~= "number") then error("bad argument #1 to '"..__func__.."' (number expected, got "..OffsetType..")",2) end
	else Offset = 0 end
	
	
	local MemoizedProxyIdentifier = Scale..Offset;
	
	local Proxy = MemoizedProxies[MemoizedProxyIdentifier];
	if (Proxy == nil) then
		local Object = {
			Scale = Scale,
			Offset = Offset
		}
		
		Proxy = setmetatable({},MetaTable);
		ProxyToObject[Proxy] = Object;
		
		MemoizedProxies[MemoizedProxyIdentifier] = Proxy;
	end
	
	return Proxy;
end



function Class.Functions.Unpack(Proxy)
	local ProxyType = type(Proxy);
	if (ProxyType ~= "UDim") then error("bad argument #1 to '"..__func__.."' (UDim expected, got "..ProxyType..")",2) end
	
	local Object = ProxyToObject[Proxy];
	
	return Object.Scale,Object.Offset;
end



UDim = setmetatable({},{
	__call = function(_Proxy,...)
		local Success,Result = pcall(Class.New,...);
		if (Success == false) then error(format_pcall_error(Result),2) end
		
		return Result;
	end,
	__index = Class,
	__metatable = "UDim",
	__newindex = function(_Proxy,Key) error("attempt to modify a read-only key ("..tostring(Key)..")",2) end
});