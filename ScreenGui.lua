local Base = GuiBase2D;

local Name = "ScreenGui";

local Functions = {}
local IndexFunctions = {}
local NewIndexFunctions = {}

local PrivateKeys = {}
local ReadOnlyKeys = {} -- setmetatable({},ClassMetaTable);

local function New(Object)
	Base.New(Object);
	
	Object.AbsolutePosition = Vector2.New();
	Object.AbsoluteSize = Vector2.New(ScreenSizeX,ScreenSizeY);
	
	Object.RootGui = Object;
	
	function Object.Draw()
		dxSetRenderTarget(Object.RenderTarget,true);
		dxSetBlendMode("modulate_add");
		
		local Children = Object.Children;
		for i = 1,#Children do
			dxDrawImage(
				0,0,
				ScreenSizeX,ScreenSizeY,
				Children[i].RenderTarget
			);
		end
		
		dxSetBlendMode("blend");
		dxSetRenderTarget();
	end
	
	Object.RenderTarget = dxCreateRenderTarget(ScreenSizeX,ScreenSizeY,true);
	Object.RenderTargetSize = Vector2.New(ScreenSizeX,ScreenSizeY);
	
	function Object.Render()
		dxSetBlendMode("add");
		
		dxDrawImage(0,0,ScreenSizeX,ScreenSizeY,Object.RenderTarget);
		
		dxSetBlendMode("blend");
	end
	addEventHandler("onClientPreRender",root,Object.Render);
end

Instance.Inherited.ScreenGui = {
	Base = Base,
	
	Name = Name,
	
	Functions = Functions,
	IndexFunctions = IndexFunctions,
	NewIndexFunctions = NewIndexFunctions,
	
	PrivateKeys = PrivateKeys,
	ReadOnlyKeys = ReadOnlyKeys,
	
	New = New
}