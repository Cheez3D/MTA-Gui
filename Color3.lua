-- [=======[ FILE ]======[
-- NAME:		Color3.lua
-- PURPOSE:		?
-- ]=====================]

local Class = {
	Functions = {},
	IndexFunctions = {}
}



local MetaTable = {
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
		
		local IndexFunction = Class.IndexFunctions[Key];
		if (IndexFunction ~= nil) then
			return IndexFunction(Object);
		end
	end,
	__metatable = "Color3",
	__newindex = function(_Proxy,Key)
		error("attempt to modify a read-only key ("..tostring(Key)..")",2);
	end,
	__tostring = function(Proxy)
		local Object = ProxyToObject[Proxy];
		
		return Object.Red..", "..Object.Green..", "..Object.Blue;
	end,
}

local MemoizedProxies = setmetatable({},{__mode = "v"});
function Class.New(Red,Green,Blue)
	if (Red ~= nil) then
		local RedType = type(Red);
		if (RedType ~= "number") then error("bad argument #1 to '"..__func__.."' (number expected, got "..RedType..")",2) end
		
		if (Red < 0) or (Red > 255) then error("bad argument #1 to '"..__func__.."' (value out of bounds)",2) end
	else
		Red = 0;
	end
	
	if (Green ~= nil) then
		local GreenType = type(Green);
		if (GreenType ~= "number") then
			error("bad argument #1 to '"..__func__.."' (number expected, got "..GreenType..")",2);
		end
		
		if (Green < 0) or (Green > 255) then
			error("bad argument #1 to '"..__func__.."' (value out of bounds)",2);
		end
	else
		Green = 0;
	end
	
	if (Blue ~= nil) then
		local BlueType = type(Blue);
		if (BlueType ~= "number") then
			error("bad argument #1 to '"..__func__.."' (number expected, got "..BlueType..")",2);
		end
		
		if (Blue < 0) or (Blue > 255) then
			error("bad argument #1 to '"..__func__.."' (value out of bounds)",2);
		end
	else
		Blue = 0;
	end
	
	
	
	local MemoizedProxyIdentifier = Red..Green..Blue;
	
	local Proxy = MemoizedProxies[MemoizedProxyIdentifier];
	if (Proxy == nil) then
		local Object = {
			Red = Red,
			Green = Green,
			Blue = Blue
		}
		
		Proxy = setmetatable({},MetaTable);
		ProxyToObject[Proxy] = Object;
		
		MemoizedProxies[MemoizedProxyIdentifier] = Proxy;
	end
	
	return Proxy;
end



function Class.Functions.Unpack(Proxy)
	do
		local ProxyType = type(Proxy);
		if (ProxyType ~= "Color3") then
			error("bad argument #1 to '"..__func__.."' (Color3 expected, got "..ProxyType..")",2);
		end
	end
	
	local Object = ProxyToObject[Proxy];
	
	return Object.Red,Object.Green,Object.Blue;
end



function Class.IndexFunctions.Hex(Object)
	local Hex = Object.Red+Object.Green*256+Object.Blue*65536;
	
	Object.Hex = Hex;

	return Hex;
end



Color3 = setmetatable({},{
	__call = function(_Proxy,...)
		local Success,Result = pcall(Class.New,...);
		if (Success == false) then error(format_pcall_error(Result),2) end
		
		return Result;
	end,
	__index = Class,
	__metatable = "Color3",
	__newindex = function(_Proxy,Key)
		error("attempt to modify a read-only key ("..tostring(Key)..")",2);
	end
});