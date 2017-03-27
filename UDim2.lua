-- [======[ FILE ]======[
-- NAME:		UDim2.lua
-- PURPOSE:		?
-- ]====================]

local Class = {
	Functions = {}
}



local MetaTable = {
	__add = function(FirstProxy,SecondProxy)
		local FirstProxyType = type(First);
		if (FirstProxyType ~= "UDim2") then error("bad argument #1 to '"..__func__.."' (UDim2 expected, got "..FirstProxyType..")",2) end
		
		local SecondProxyType = type(Second);
		if (SecondProxyType ~= "UDim2") then error("bad argument #2 to '"..__func__.."' (UDim2 expected, got "..SecondProxyType..")",2) end
		
		local First = ProxyToObject[FirstProxy];	local Second = ProxyToObject[SecondProxy];
		
		local FirstX,FirstY = ProxyToObject[First.X],ProxyToObject[First.Y];
		local SecondX,SecondY = ProxyToObject[Second.X],ProxyToObject[Second.Y];
		
		return Class.New(
			FirstX.Scale+SecondX.Scale,
			FirstX.Offset+SecondX.Offset,
			FirstY.Scale+SecondY.Scale,
			FirstY.Offset+SecondY.Offset
		);
	end,
	__index = function(Proxy,Key)
		local Object = ProxyToObject[Proxy];
		
		local Value = Object[Key];
		if (Value ~= nil) then
			return Value;
		end
		
		
		
		local Function = Class.Functions[Key];
		if (Function ~= nil) then
			return Function;
		end
	end,
	__metatable = "UDim2",
	__newindex = function(_Proxy,Key) error("attempt to modify a read-only key ("..tostring(Key)..")",2) end,
	__tostring = function(Proxy)
		local Object = ProxyToObject[Proxy];
		
		local ObjectX,ObjectY = ProxyToObject[Object.X],ProxyToObject[Object.Y];
		
		return "{"..ObjectX.Scale..","..ObjectX.Offset.."}, {"..ObjectY.Scale..","..ObjectY.Offset.."}";
	end
}

local MemoizedProxies = setmetatable({},{__mode = "v"});
function Class.New(ScaleX,OffsetX,ScaleY,OffsetY)
	if (ScaleX ~= nil) then
		local ScaleXType = type(ScaleX);
		if (ScaleXType ~= "number") then error("bad argument #1 to '"..__func__.."' (number expected, got "..ScaleXType..")",2) end
	else
		ScaleX = 0;
	end
	
	if (OffsetX ~= nil) then
		local OffsetXType = type(OffsetX);
		if (OffsetXType ~= "number") then error("bad argument #2 to '"..__func__.."' (number expected, got "..OffsetXType..")",2) end
	else
		OffsetX = 0;
	end
	
	if (ScaleY ~= nil) then
		local ScaleYType = type(ScaleY);
		if (ScaleYType ~= "number") then error("bad argument #3 to '"..__func__.."' (number expected, got "..ScaleYType..")",2) end
	else
		ScaleY = 0;
	end
	
	if (OffsetY ~= nil) then
		local OffsetYType = type(OffsetY);
		if (OffsetYType ~= "number") then error("bad argument #4 to '"..__func__.."' (number expected, got "..OffsetYType..")",2) end
	else
		OffsetY = 0;
	end
	
	
	
	local MemoizedProxyIdentifier = ScaleX..OffsetX..ScaleY..OffsetY;
	
	local Proxy = MemoizedProxies[MemoizedProxyIdentifier];
	if (Proxy == nil) then
		local Object = {
			X = UDim.New(ScaleX,OffsetX),
			Y = UDim.New(ScaleY,OffsetY)
		}
		
		Proxy = setmetatable({},MetaTable);
		ProxyToObject[Proxy] = Object;
		
		MemoizedProxies[MemoizedProxyIdentifier] = Proxy;
	end
	
	return Proxy;
end



function Class.Functions.Unpack(Proxy)
	local ProxyType = type(Proxy);
	if (ProxyType ~= "UDim2") then error("bad argument #1 to '"..__func__.."' (UDim2 expected, got "..ProxyType..")",2) end
	
	local Object = ProxyToObject[Proxy];
	
	local ObjectX,ObjectY = ProxyToObject[Object.X],ProxyToObject[Object.Y];
	
	return ObjectX.Scale,ObjectX.Offset,ObjectY.Scale,ObjectY.Offset;
end



UDim2 = setmetatable({},{
	__call = function(_Proxy,...)
		local Success,Result = pcall(Class.New,...);
		if (Success == false) then error(format_pcall_error(Result),2) end
		
		return Result;
	end,
	__index = Class,
	__metatable = "UDim2",
	__newindex = function(_Proxy,Key) error("attempt to modify a read-only key ("..tostring(Key)..")",2) end
});