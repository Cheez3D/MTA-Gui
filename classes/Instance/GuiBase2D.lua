local Base = Instance;

local Name = "GuiBase2D";

local Functions = {}
local IndexFunctions = {}
local NewIndexFunctions = {}

local PrivateKeys = {
	-- RenderTarget = true,
	-- RenderTargetSize = true
}
local ReadOnlyKeys = {
	AbsolutePosition = true,
	AbsoluteSize = true
} -- setmetatable({},ClassMetaTable);

local function New(Object)
	Object.AbsolutePosition = true;
	Object.AbsoluteSize = true;
	
	Object.RenderTarget = true;
	Object.RenderTargetSize = true;
end

GuiBase2D = {
	Base = Base,
	
	Name = Name,
	
	Functions = Functions,
	IndexFunctions = IndexFunctions,
	NewIndexFunctions = NewIndexFunctions,
	
	PrivateKeys = PrivateKeys,
	ReadOnlyKeys = ReadOnlyKeys,
	
	New = New
}