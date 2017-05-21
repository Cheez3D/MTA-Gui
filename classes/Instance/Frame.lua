-- local Vector2 = require("Vector2");
-- local UDim2   = require("UDim2");



local Base = GuiObject;

local Name = "Frame";

local Functions = {}
local IndexFunctions = {}
local NewIndexFunctions = {}

local PrivateKeys = {}
local ReadOnlyKeys = {} -- setmetatable({},ClassMetaTable);

-- 2D rotation mouse collision detection
-- https://www.siggraph.org/education/materials/HyperGraph/modeling/mod_tran/2drota.htm

local function New(Object)
	Base.New(Object);
	
	Object.AbsolutePosition = Vector2.new();
	Object.AbsoluteSize = Vector2.new(100,100);
	
	Object.Position = UDim2.new();
	Object.Size = UDim2.new(0,100,0,100);
	
	function Object.Draw()
		local Parent = PROXY__OBJ[Object.Parent];
		
		if (Object.Visible == true) then
			dxSetRenderTarget(Object.RenderTarget,true);
			dxSetBlendMode("modulate_add");
			
			local AbsolutePosition,AbsoluteSize = Object.AbsolutePosition,Object.AbsoluteSize;
			
			local BorderColor3 = Object.BorderColor3;
			local BorderOffsetPixel = Object.BorderOffsetPixel;
			local BorderSizePixel = Object.BorderSizePixel;
			
			local BackgroundColor3 = Object.BackgroundColor3;
			
			-- Border
			dxDrawRectangle(
				AbsolutePosition.x-BorderOffsetPixel,AbsolutePosition.y-BorderOffsetPixel,
				AbsoluteSize.x+2*BorderOffsetPixel,AbsoluteSize.y+2*BorderOffsetPixel,
				tocolor(BorderColor3.Red,BorderColor3.Green,BorderColor3.Blue,255*(1-Object.BorderTransparency))
			);
			
			-- Background
			dxSetBlendMode("overwrite");
			dxDrawRectangle(
				AbsolutePosition.x+(BorderSizePixel-BorderOffsetPixel),AbsolutePosition.y+(BorderSizePixel-BorderOffsetPixel),
				AbsoluteSize.x-2*BorderSizePixel+2*BorderOffsetPixel,AbsoluteSize.y-2*BorderSizePixel+2*BorderOffsetPixel,
				tocolor(BackgroundColor3.r,BackgroundColor3.g,BackgroundColor3.b,255*(1-Object.BackgroundTransparency))
			);
			dxSetBlendMode("modulate_add");
			
			local Children = Object.Children;
			if (Object.ClipsDescendants == true) then
				for i = 1,#Children do
					local Child = Children[i];
					
					dxDrawImageSection(
						AbsolutePositionX,AbsolutePositionY,AbsoluteSizeX,AbsoluteSizeY,
						AbsolutePositionX,AbsolutePositionY,AbsoluteSizeX,AbsoluteSizeY,
						Child.RenderTarget
					);
				end
			else
				for i = 1,#Children do
					local Child = Children[i];
					
					local ChildRenderTargetSizeX,ChildRenderTargetSizeY = Child.RenderTargetSize:Unpack();
					dxDrawImage(
						0,0,ChildRenderTargetSizeX,ChildRenderTargetSizeY,
						Child.RenderTarget
					);
				end
			end
			
			dxSetBlendMode("blend");
			dxSetRenderTarget();
		end
		
		Parent.Draw();
	end
end

Instance.Inherited.Frame = {
	Base = Base,
	
	Name = Name,
	
	Functions = Functions,
	IndexFunctions = IndexFunctions,
	NewIndexFunctions = NewIndexFunctions,
	
	PrivateKeys = PrivateKeys,
	ReadOnlyKeys = ReadOnlyKeys,
	
	New = New
}



ScrGui = Instance.New("ScreenGui");


Fr1 = Instance.New("Frame",ScrGui);	Fr1.Name = "Fr1";
Fr1.Position = UDim2.new(0.5,-50,0.5,-50);


-- Fr2 = Instance.New("Frame",Fr1);	Fr2.Name = "Fr2";
-- Fr2.Position = UDim2.New(0,-50,0,-50);
-- Fr2.BackgroundColor3 = Color3.New(223,196,125);
-- Fr2.BorderColor3 = Color3.New();
-- Fr2.BorderSizePixel = 8;
-- Fr2.BorderOffsetPixel = 8;