-- local Vector2 = require("Vector2");
-- local UDim2   = require("UDim2");



local name = "Frame";

local super = GuiObject;

-- ???
-- ClassMetaTable = {__index = function(Class,Key) return Class.super[Key] end}
-- local ReadOnlyKeys = setmetatable({},ClassMetaTable);
-- ???


-- TODO: 2D rotation mouse collision detection
-- https://www.siggraph.org/education/materials/HyperGraph/modeling/mod_tran/2drota.htm

local function new(Object)
	super.new(Object);
	
	Object.AbsolutePosition = Vector2.new();
	Object.AbsoluteSize = Vector2.new(100, 100);
	
	Object.Position = UDim2.new();
	Object.Size = UDim2.new(0, 100, 0, 100);
	
	function Object.Draw()
		-- local parent = PROXY__OBJ[Object.parent];
		
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
			
			local Children = Object.children;
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
					
					local ChildRenderTargetSizeX,ChildRenderTargetSizeY = Child.RenderTargetSize.unpack();
					dxDrawImage(
						0,0,ChildRenderTargetSizeX,ChildRenderTargetSizeY,
						Child.RenderTarget
					);
				end
			end
			
			dxSetBlendMode("blend");
			dxSetRenderTarget();
		end
		
		Object.parent.Draw();
	end
end

Instance.initializable.Frame = {
	name = name,
    
    super = super,
	
	new = new,
}



local scrGui = Instance.new("ScreenGui");

local fr1 = Instance.new("Frame", scrGui);
fr1.Position = UDim2.new(0.5, -50, 0.5, -50);


-- fr2 = Instance.new("Frame", fr1);
-- fr2.name = "fr2";
-- fr2.Position = UDim2.new(0, -50, 0, -50);
-- fr2.BackgroundColor3 = Color3.new(223, 196, 125);
-- fr2.BorderColor3 = Color3.new();
-- fr2.BorderSizePixel = 8;
-- fr2.BorderOffsetPixel = 8;
