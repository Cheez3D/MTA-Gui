setFPSLimit(60);

if (triggerServerEvent ~= nil) then ScreenSizeX,ScreenSizeY = guiGetScreenSize() end

ObjectToProxy = setmetatable({},{__mode = "v"});
ProxyToObject = setmetatable({},{__mode = "k"});

if (triggerServerEvent ~= nil) then
	addCommandHandler("r",function(Command,...)
		local Code = table.concat({...}," ");
		
		local Function = loadstring(Code);
		Function();
	end);
end

-- [========================================[
-- PROJECT:		Gui
-- LICENSE:		?
-- FILE:		Dependencies.lua
-- PURPOSE:		?
-- DEVELOPERS:	Cheez <andrei.st03@gmail.com>
-- ]========================================]

setmetatable(_G,{
	__index = function(_Table,Key)
		if (Key == "__FILE__") then
			return debug.getinfo(2,"S").short_src;
		elseif (Key == "__func__") then
			return debug.getinfo(2,"n").name or "?";
		elseif (Key == "__LINE__") then
			return debug.getinfo(2,"l").currentline;
		end
	end
});



local error_,type_ = error,type;

function assert(Condition,Message,Level,...)
	if (not Condition) then
		do
			if (Message ~= nil) then
				local MessageType = type_(Message);
				if (MessageType ~= "string") then error_("bad argument #2 to '"..__func__.."' (string expected, got "..MessageType..")",2) end
			else Message = "assertion failed!" end
		end
		
		if (Level ~= nil) then
			local LevelType = type_(Level);
			if (LevelType ~= "number") then error_("bad argument #3 to '"..__func__.."' (number expected, got "..LevelType..")",2)
			elseif (Level%1 ~= 0) then error_("bad argument #3 to '"..__func__.."' (number has no integer representation)",2)
			elseif (Level < 1) then error_("bad argument #3 to '"..__func__.."' (invalid value)",2) end
			
			Level = Level+1;
		else
			Level = 2;
		end
		
		local Success,Result = pcall(string.format,Message,...);
		if (Success == false) then
			error_(format_pcall_error(Result,2),2);
		end
		
		error_(Result,Level);
	end
end

-- function error(Message,Level)
	-- do
		-- local MessageType = type_(Message);
		
		-- if (MessageType ~= "string") then
			-- error_("bad argument #1 to '"..__func__.."' (string expected, got "..MessageType..")",2);
		-- end
	-- end
	
	-- if (Level ~= nil) then
		-- local LevelType = type_(Level);
		
		-- if (LevelType ~= "number") then
			-- error_("bad argument #2 to '"..__func__.."' (number expected, got "..LevelType..")",2);
		-- elseif (Level%1 ~= 0) then
			-- error_("bad argument #2 to '"..__func__.."' (number has no integer representation)",2);
		-- elseif (Level < 1) then
			-- error_("bad argument #2 to '"..__func__.."' (invalid value)",2);
		-- end
		
		-- Level = Level+1;
	-- else
		-- Level = 2;
	-- end
	
	-- error_(Message,Level);
-- end

-- formats error message, for use with pcall
function format_pcall_error(Message,ArgumentOffset)
	local MessageType = type(Message);
	if (MessageType ~= "string") then error_("bad argument #1 to '"..__func__.."' (string expected, got "..MessageType..")",2) end
	
	Message = Message:gsub("(.+):(%s)","",1); -- remove redundant location
	
	if (ArgumentOffset ~= nil) then
		local ArgumentOffsetType = type(ArgumentOffset);
		if (ArgumentOffsetType ~= "number") then error_("bad argument #2 to '"..__func__.."' (number expected, got "..ArgumentOffsetType..")",2) end
	
		Message = Message:gsub("#(%d+)",function(ArgumentNumber) return "#"..(ArgumentNumber+ArgumentOffset) end,1); -- offset argument number
	end
	
	local FunctionName = debug.getinfo(2,"n").name or "?";
	-- if (FunctionName ~= nil) then
		Message = (Message:find("'?'",nil,true) ~= nil) and Message:gsub("'%?'","'"..FunctionName.."'",1) or Message:gsub("'([_%w]-)'","'"..FunctionName.."' -> '%1'",1);
	-- end
	
	return Message;
end

function print(...)
	local Strings = {...}
	for i = 1,#Strings do
		Strings[i] = tostring(Strings[i]);
	end

	outputConsole(table.concat(Strings," "));
end

function print_debug(...)
	local Strings = {...}
	for i = 1,#Strings do
		Strings[i] = tostring(Strings[i]);
	end

	outputDebugString(table.concat(Strings," "));
end

function print_table(t, f, d)
	f = f or print;
	
	d = d or 0;
	
	for k, v in pairs(t) do
		if (type(v) == "table") then
			f("[ ", k, " -> ", v, " ]");
			
			print_table(v, f, d+1);
		else
			f(string.rep(" ", d), k, " -> ", v);
		end
	end
end

function type(Argument)
	local ArgumentType = type_(Argument);
	
	if (ArgumentType == "table") then
		ArgumentType = getmetatable(Argument);
		
		if (type_(ArgumentType) == "string") then
			return ArgumentType;
		else
			return "table";
		end
	else
		return ArgumentType;
	end
end