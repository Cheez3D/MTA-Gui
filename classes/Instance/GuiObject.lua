-- local Color3  = require("Color3");
-- local Vector2 = require("Vector2");



local name = "GuiObject";

local super = GuiBase2D;

local func = {}
local set  = {}

local private = {
	RecreateDescendantsRenderTarget = true
}

local function new(Object)
	super.new(Object);
	
	Object.BackgroundColor3 = Color3.new(255,255,255);
	Object.BackgroundTransparency = 0;
	
	Object.BorderColor3 = Color3.new(27,42,53);
	Object.BorderOffsetPixel = 1;
	Object.BorderSizePixel = 1;
	Object.BorderTransparency = 0;
	
	Object.ClipsDescendants = false;
	
	Object.Position = true;
	Object.Size = true;
	
	Object.Visible = true;
end


function func.RecreateDescendantsRenderTarget(Object,RenderTargetSize)
	if isElement(Object.RenderTarget) then destroyElement(Object.RenderTarget) end
	
	local RenderTargetSizeX,RenderTargetSizeY = RenderTargetSize.unpack();
	Object.RenderTarget = dxCreateRenderTarget(RenderTargetSizeX,RenderTargetSizeY,true);
	Object.RenderTargetSize = RenderTargetSize;
	
	local Children = Object.children;
	for i = 1,#Children do func.RecreateDescendantsRenderTarget(Children[i],RenderTargetSize) end
end


function set.BackgroundColor3(Object,BackgroundColor3,__,Key)
	local BackgroundColor3Type = type(BackgroundColor3);
	if (BackgroundColor3Type ~= "Color3") then error("bad argument #1 to '"..Key.."' (Color3 expected, got "..BackgroundColor3Type..")",3) end
	
	Object.BackgroundColor3 = BackgroundColor3;
	
	Object.Draw();
end

function set.BackgroundTransparency(Object,BackgroundTransparency,__,Key)
	local BackgroundTransparencyType = type(BackgroundTransparency);
	if (BackgroundTransparencyType ~= "number") then error("bad argument #1 to '"..Key.."' (number expected, got "..BackgroundTransparencyType..")",3)
	elseif (BackgroundTransparency < 0) or (BackgroundTransparency > 1) then error("bad argument #1 to '"..Key.."' (value out of bounds)",3) end
	
	Object.BackgroundTransparency = BackgroundTransparency;
	
	Object.Draw();
end

function set.BorderColor3(Object,BorderColor3,__,Key)
	local BorderColor3Type = type(BorderColor3);
	if (BorderColor3Type ~= "Color3") then error("bad argument #1 to '"..Key.."' (Color3 expected, got "..BorderColor3Type..")",3) end
	
	Object.BorderColor3 = BorderColor3;
	
	Object.Draw();
end

function set.BorderOffsetPixel(Object,BorderOffsetPixel,__,Key)
	local BorderOffsetPixelType = type(BorderOffsetPixel);
	if (BorderOffsetPixelType ~= "number") then	error("bad argument #1 to '"..Key.."' (number expected, got "..BorderOffsetPixelType..")",3)
	elseif (BorderOffsetPixel%1 ~= 0) then error ("bad argument #1 to '"..Key.."' (number has no integer representation)",3)
	elseif (BorderOffsetPixel < 0) or (BorderOffsetPixel > Object.BorderSizePixel) then error("bad argument #1 to '"..Key.."' (invalid value)",3) end
	
	Object.BorderOffsetPixel = BorderOffsetPixel;
	
	Object.Draw();
end

function set.BorderSizePixel(Object,BorderSizePixel,__,Key)
	local BorderSizePixelType = type(BorderSizePixel);
	if (BorderSizePixelType ~= "number") then error("bad argument #1 to '"..Key.."' (number expected, got "..BorderSizePixelType..")",3)
	elseif (BorderSizePixel%1 ~= 0) then error ("bad argument #1 to '"..Key.."' (number has no integer representation)",3)
	elseif (BorderSizePixel < 0) then error("bad argument #1 to '"..Key.."' (invalid value)",3) end
	
	if (Object.BorderOffsetPixel > BorderSizePixel) then Object.BorderOffsetPixel = BorderSizePixel end
	Object.BorderSizePixel = BorderSizePixel;
	
	Object.Draw();
end

function set.BorderTransparency(Object,BorderTransparency,__,Key)
	local BorderTransparencyType = type(BorderTransparency);
	if (BorderTransparencyType ~= "number") then error("bad argument #1 to '"..Key.."' (number expected, got "..BorderTransparencyType..")",3)
	elseif (BorderTransparency < 0) or (BorderTransparency > 1) then error("bad argument #1 to '"..Key.."' (invalid value)",3) end
	
	Object.BorderTransparency = BorderTransparency;
	
	Object.Draw();
end

function set.ClipsDescendants(Object,ClipsDescendants,__,Key)
	local ClipsDescendantsType = type(ClipsDescendants);
	if (ClipsDescendantsType ~= "boolean") then error("bad argument #1 to '"..Key.."' (boolean expected, got "..ClipsDescendantsType..")",3) end
	
	Object.ClipsDescendants = ClipsDescendants;
	
	local Children = Object.children;
	for i = 1,#Children do
		local Child = Children[i];
		
		Child.Draw();
	end
end

function set.parent(Object, ParentProxy, PreviousParentProxy, Key)
	if (PreviousParentProxy ~= nil) and PreviousParentProxy.isA("GuiBase2D") then
		local PreviousParent = PROXY__OBJ[PreviousParentProxy];
		
		PreviousParent.Draw();
	end
	
	
	if (ParentProxy ~= nil) and ParentProxy.isA("GuiBase2D") then
		local parent = Object.parent -- new parent was set above in Instance function -- PROXY__OBJ[ParentProxy];
		
		local ParentRenderTargetSize = parent.RenderTargetSize;
		if (ParentRenderTargetSize ~= Object.RenderTargetSize) then func.RecreateDescendantsRenderTarget(Object,ParentRenderTargetSize) end
		
		local Proxy = OBJ__PROXY[Object];
		
		Proxy.Position = Object.Position;
		Proxy.Size = Object.Size;
	end
end

function set.Position(Object,Position,__,Key)
	local PositionType = type(Position);
	if (PositionType ~= "UDim2") then error("bad argument #1 to '"..Key.."' (UDim2 expected, got "..PositionType..")",3) end
	
	Object.Position = Position;
	
	if (Object.parent) then
		local parent = Object.parent;
	
		local ParentAbsolutePositionX,ParentAbsolutePositionY = parent.AbsolutePosition.unpack();
		local ParentAbsoluteSizeX,ParentAbsoluteSizeY = parent.AbsoluteSize.unpack();
		
		local PositionXScale,PositionXOffset,PositionYScale,PositionYOffset = Position.unpack();
		
		Object.AbsolutePosition = Vector2.new(
			ParentAbsolutePositionX+PositionXOffset+ParentAbsoluteSizeX*PositionXScale,
			ParentAbsolutePositionY+PositionYOffset+ParentAbsoluteSizeY*PositionYScale
		);
		
		
		Object.Draw();
	end
end

function set.Size(Object,Size,__,Key)
	local SizeType = type(Size);
	if (SizeType ~= "UDim2") then error("bad argument #1 to '"..Key.."' (UDim2 expected, got "..SizeType..")",3) end
	
	
	Object.Size = Size;
	
	if (Object.parent) then
		local parent = Object.parent;
		
		local ParentAbsoluteSizeX,ParentAbsoluteSizeY = parent.AbsoluteSize.unpack();
		
		local SizeXScale,SizeXOffset,SizeYScale,SizeYOffset = Size.unpack();
		
		Object.AbsoluteSize = Vector2.new(
			SizeXOffset+ParentAbsoluteSizeX*SizeXScale,
			SizeYOffset+ParentAbsoluteSizeY*SizeYScale
		);
		
		
		local Children = Object.children;	local ChildrenNumber = #Children;
		if (ChildrenNumber > 0) then
			for i = 1,ChildrenNumber do
				local Child = Children[i];	local ChildProxy = OBJ__PROXY[Child];
				
				ChildProxy.Position = Child.Position;
				ChildProxy.Size = Child.Size;
			end
		else Object.Draw() end
	end
end

function set.Visible(Object,Visible,__,Key)
	local VisibleType = type(Visible);
	if (VisibleType ~= "boolean") then error("bad argument #1 to '"..Key.."' (boolean expected, got "..VisibleType..")",3) end
	
	
	Object.Visible = Visible;
	
	Object.Draw();
end


GuiObject = {
	name = name,
    
    super = super,
	
	func = func,
	set  = set,
	
	private  = private,
	
	new = new,
}
