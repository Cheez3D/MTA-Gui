-- [=======[ FILE ]=======[
-- NAME:		Vector2.lua
-- PURPOSE:		?
-- ]======================]

local Class = {
	Functions = {},
	IndexFunctions = {}
}



local MetaTable = {
	__add = function(FirstProxy,SecondProxy)
		local FirstProxyType = type(FirstProxy);
		if (FirstProxyType ~= "Vector2") then error("bad argument #1 to '"..__func__.."' (Vector2 expected, got "..FirstProxyType..")",2) end
		
		local SecondProxyType = type(SecondProxy);
		if (SecondProxyType ~= "Vector2") then error("bad argument #2 to '"..__func__.."' (Vector2 expected, got "..SecondProxyType..")",2) end
		
		local First = ProxyToObject[FirstProxy];	local Second = ProxyToObject[SecondProxy];
		
		return Class.New(
			First.X+Second.X,
			First.Y+Second.Y
		);
	end,
	__div = function(FirstProxy,SecondProxy)
		local FirstProxyType = type(FirstProxy);
		if (FirstProxyType == "number") then
			local Second = ProxyToObject[SecondProxy];
		
			return Class.New(
				FirstProxy/Second.X,
				FirstProxy/Second.Y
			);
		elseif (FirstProxyType ~= "Vector2") then error("bad argument #1 to '"..__func__.."' (number/Vector2 expected, got "..FirstProxyType..")",2) end
		
		local SecondProxyType = type(SecondProxy);
		if (SecondProxyType == "number") then
			local First = ProxyToObject[FirstProxy];
			
			return Class.New(
				First.X/SecondProxy,
				First.Y/SecondProxy
			);
		elseif (SecondProxyType ~= "Vector2") then error("bad argument #2 to '"..__func__.."' (number/Vector2 expected, got "..SecondProxyType..")",2) end
		
		local First = ProxyToObject[FirstProxy];	local Second = ProxyToObject[SecondProxy];
		
		return Class.New(
			First.X/Second.X,
			First.Y/Second.Y
		);
	end,
	-- __eq = ..., -- memoization takes care of it
	__index = function(Proxy,Key)
		local Object = ProxyToObject[Proxy];
	
		local Value = Object[Key];
		if (Value ~= nil) then return Value end
	
		local Function = Class.Functions[Key];
		if (Function ~= nil) then return Function end
		
		local IndexFunction = Class.IndexFunctions[Key];
		if (IndexFunction ~= nil) then return IndexFunction(Object,Key) end
		
		return nil;
	end,
	__metatable = "Vector2",
	__mul = function(FirstProxy,SecondProxy)
		local FirstProxyType = type(FirstProxy);
		if (FirstProxyType == "number") then
			local Second = ProxyToObject[SecondProxy];
		
			return Class.New(
				FirstProxy*Second.X,
				FirstProxy*Second.Y
			);
		elseif (FirstProxyType ~= "Vector2") then error("bad argument #1 to '"..__func__.."' (number/Vector2 expected, got "..FirstProxyType..")",2) end
		
		local SecondProxyType = type(SecondProxy);
		if (SecondProxyType == "number") then
			local First = ProxyToObject[FirstProxy];
			
			return Class.New(
				First.X*SecondProxy,
				First.Y*SecondProxy
			);
		elseif (SecondProxyType ~= "Vector2") then error("bad argument #2 to '"..__func__.."' (number/Vector2 expected, got "..SecondProxyType..")",2) end
		
		local First = ProxyToObject[FirstProxy];	local Second = ProxyToObject[SecondProxy];
		
		return Class.New(
			First.X*Second.X,
			First.Y*Second.Y
		);
	end,
	__newindex = function(_Proxy,Key) error("attempt to modify a read-only key ("..tostring(Key)..")",2) end,
	__sub = function(FirstProxy,SecondProxy)
		local FirstProxyType = type(FirstProxy);
		if (FirstProxyType ~= "Vector2") then error("bad argument #1 to '"..__func__.."' (Vector2 expected, got "..FirstProxyType..")",2) end
		
		local SecondProxyType = type(SecondProxy);
		if (SecondProxyType ~= "Vector2") then error("bad argument #2 to '"..__func__.."' (Vector2 expected, got "..SecondProxyType..")",2) end
		
		local First = ProxyToObject[FirstProxy];	local Second = ProxyToObject[SecondProxy];
		
		return Class.New(
			First.X-Second.X,
			First.Y-Second.Y
		);
	end,
	__tostring = function(Proxy)
		local Object = ProxyToObject[Proxy];
		
		return Object.X..", "..Object.Y;
	end,
	__unm = function(Proxy)
		local Object = ProxyToObject[Proxy];
		
		return Class.New(
			-Object.X,
			-Object.Y
		);
	end
}

local MemoizedProxies = setmetatable({},{__mode = "v"});
function Class.New(X,Y)
	if (X ~= nil) then
		local XType = type(X);
		if (XType ~= "number") then error("bad argument #1 to '"..__func__.."' (number expected, got "..XType..")",2) end
	else X = 0 end
	
	if (Y ~= nil) then
		local YType = type(Y);
		if (YType ~= "number") then error("bad argument #2 to '"..__func__.."' (number expected, got "..YType..")",2) end
	else Y = 0 end
	
	
	local MemoizedProxyIdentifier = X..Y;
	
	local Proxy = MemoizedProxies[MemoizedProxyIdentifier];
	if (Proxy == nil) then
		local Object = {
			X = X,
			Y = Y
		}
		
		Proxy = setmetatable({},MetaTable);
		ProxyToObject[Proxy] = Object;
		
		MemoizedProxies[MemoizedProxyIdentifier] = Proxy;
	end
	
	return Proxy;
end



do -- Class.Functions
	function Class.Functions.Unpack(Proxy)
		local ProxyType = type(Proxy);
		if (ProxyType ~= "Vector2") then error("bad argument #1 to '"..__func__.."' (Vector2 expected, got "..ProxyType..")",2) end
		
		local Object = ProxyToObject[Proxy]; -- retrieve actual object to avoid useless metamethod invocations
		
		return Object.X,Object.Y;
	end
end



do -- Class.IndexFunctions
	function Class.IndexFunctions.Magnitude(Object)
		local Magnitude = math.sqrt(Object.X^2+Object.Y^2);
		
		Object.Magnitude = Magnitude;
		
		return Magnitude;
	end

	function Class.IndexFunctions.Unit(Object)
		local Magnitude = Object.Magnitude or Class.IndexFunctions.Magnitude(Object);
		
		local Unit = Class.New(
			Object.X/Magnitude,
			Object.Y/Magnitude
		);
		
		Object.Unit = Unit;
		
		return Unit;
	end
end



Vector2 = setmetatable({},{
	__call = function(_Proxy,...)
		local Success,Result = pcall(Class.New,...);
		if (Success == false) then error(format_pcall_error(Result),2) end
		
		return Result;
	end,
	__index = Class,
	__metatable = "Vector2",
	__newindex = function(_Proxy,Key) error("attempt to modify a read-only key ("..tostring(Key)..")",2) end
});