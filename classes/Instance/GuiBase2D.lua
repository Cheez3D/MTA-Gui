local name = "GuiBase2D";

local super = Instance;

local private = {
	-- RenderTarget = true,
	-- RenderTargetSize = true
}
local readOnly = {
	AbsolutePosition = true,
	AbsoluteSize = true
} -- setmetatable({},ClassMetaTable);

local function new(Object)
	Object.AbsolutePosition = true;
	Object.AbsoluteSize = true;
	
	Object.RenderTarget = true;
	Object.RenderTargetSize = true;
end

GuiBase2D = {
	name = name,
    
    super = super,
	
	private  = private,
	readOnly = readOnly,
	
	new = new,
}
