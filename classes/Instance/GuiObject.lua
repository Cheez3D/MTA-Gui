local Base = GuiBase2D;

local Name = "GuiObject";

local Functions = {}
local IndexFunctions = {}
local NewIndexFunctions = {}

local PrivateKeys = {
	RecreateDescendantsRenderTarget = true
}
local ReadOnlyKeys = {} -- setmetatable({},ClassMetaTable);

local function New(Object)
	Base.New(Object);
	
	Object.BackgroundColor3 = Color3.New(255,255,255);
	Object.BackgroundTransparency = 0;
	
	Object.BorderColor3 = Color3.New(27,42,53);
	Object.BorderOffsetPixel = 1;
	Object.BorderSizePixel = 1;
	Object.BorderTransparency = 0;
	
	Object.ClipsDescendants = false;
	
	Object.Position = true;
	Object.Size = true;
	
	Object.Visible = true;
end


function Functions.RecreateDescendantsRenderTarget(Object,RenderTargetSize)
	if isElement(Object.RenderTarget) then destroyElement(Object.RenderTarget) end
	
	local RenderTargetSizeX,RenderTargetSizeY = RenderTargetSize.unpack();
	Object.RenderTarget = dxCreateRenderTarget(RenderTargetSizeX,RenderTargetSizeY,true);
	Object.RenderTargetSize = RenderTargetSize;
	
	local Children = Object.Children;
	for i = 1,#Children do Functions.RecreateDescendantsRenderTarget(Children[i],RenderTargetSize) end
end


function NewIndexFunctions.BackgroundColor3(Object,Key,BackgroundColor3)
	local BackgroundColor3Type = type(BackgroundColor3);
	if (BackgroundColor3Type ~= "Color3") then error("bad argument #1 to '"..Key.."' (Color3 expected, got "..BackgroundColor3Type..")",3) end
	
	Object.BackgroundColor3 = BackgroundColor3;
	
	Object.Draw();
end

function NewIndexFunctions.BackgroundTransparency(Object,Key,BackgroundTransparency)
	local BackgroundTransparencyType = type(BackgroundTransparency);
	if (BackgroundTransparencyType ~= "number") then error("bad argument #1 to '"..Key.."' (number expected, got "..BackgroundTransparencyType..")",3)
	elseif (BackgroundTransparency < 0) or (BackgroundTransparency > 1) then error("bad argument #1 to '"..Key.."' (value out of bounds)",3) end
	
	Object.BackgroundTransparency = BackgroundTransparency;
	
	Object.Draw();
end

function NewIndexFunctions.BorderColor3(Object,Key,BorderColor3)
	local BorderColor3Type = type(BorderColor3);
	if (BorderColor3Type ~= "Color3") then error("bad argument #1 to '"..Key.."' (Color3 expected, got "..BorderColor3Type..")",3) end
	
	Object.BorderColor3 = BorderColor3;
	
	Object.Draw();
end

function NewIndexFunctions.BorderOffsetPixel(Object,Key,BorderOffsetPixel)
	local BorderOffsetPixelType = type(BorderOffsetPixel);
	if (BorderOffsetPixelType ~= "number") then	error("bad argument #1 to '"..Key.."' (number expected, got "..BorderOffsetPixelType..")",3)
	elseif (BorderOffsetPixel%1 ~= 0) then error ("bad argument #1 to '"..Key.."' (number has no integer representation)",3)
	elseif (BorderOffsetPixel < 0) or (BorderOffsetPixel > Object.BorderSizePixel) then error("bad argument #1 to '"..Key.."' (invalid value)",3) end
	
	Object.BorderOffsetPixel = BorderOffsetPixel;
	
	Object.Draw();
end

function NewIndexFunctions.BorderSizePixel(Object,Key,BorderSizePixel)
	local BorderSizePixelType = type(BorderSizePixel);
	if (BorderSizePixelType ~= "number") then error("bad argument #1 to '"..Key.."' (number expected, got "..BorderSizePixelType..")",3)
	elseif (BorderSizePixel%1 ~= 0) then error ("bad argument #1 to '"..Key.."' (number has no integer representation)",3)
	elseif (BorderSizePixel < 0) then error("bad argument #1 to '"..Key.."' (invalid value)",3) end
	
	if (Object.BorderOffsetPixel > BorderSizePixel) then Object.BorderOffsetPixel = BorderSizePixel end
	Object.BorderSizePixel = BorderSizePixel;
	
	Object.Draw();
end

function NewIndexFunctions.BorderTransparency(Object,Key,BorderTransparency)
	local BorderTransparencyType = type(BorderTransparency);
	if (BorderTransparencyType ~= "number") then error("bad argument #1 to '"..Key.."' (number expected, got "..BorderTransparencyType..")",3)
	elseif (BorderTransparency < 0) or (BorderTransparency > 1) then error("bad argument #1 to '"..Key.."' (invalid value)",3) end
	
	Object.BorderTransparency = BorderTransparency;
	
	Object.Draw();
end

function NewIndexFunctions.ClipsDescendants(Object,Key,ClipsDescendants)
	local ClipsDescendantsType = type(ClipsDescendants);
	if (ClipsDescendantsType ~= "boolean") then error("bad argument #1 to '"..Key.."' (boolean expected, got "..ClipsDescendantsType..")",3) end
	
	Object.ClipsDescendants = ClipsDescendants;
	
	local Children = Object.Children;
	for i = 1,#Children do
		local Child = Children[i];
		
		Child.Draw();
	end
end

function NewIndexFunctions.Parent(Object,_Key,ParentProxy,PreviousParentProxy)
	if (PreviousParentProxy ~= nil) and (PreviousParentProxy:IsA("GuiBase2D") == true) then
		local PreviousParent = ProxyToObject[PreviousParentProxy];
		
		PreviousParent.Draw();
	end
	
	
	if (ParentProxy ~= nil) and (ParentProxy:IsA("GuiBase2D") == true) then
		local Parent = ProxyToObject[ParentProxy];
		
		local ParentRenderTargetSize = Parent.RenderTargetSize;
		if (ParentRenderTargetSize ~= Object.RenderTargetSize) then Functions.RecreateDescendantsRenderTarget(Object,ParentRenderTargetSize) end
		
		local Proxy = ObjectToProxy[Object];
		
		Proxy.Position = Object.Position;
		Proxy.Size = Object.Size;
	end
end

function NewIndexFunctions.Position(Object,Key,Position)
	local PositionType = type(Position);
	if (PositionType ~= "UDim2") then error("bad argument #1 to '"..Key.."' (UDim2 expected, got "..PositionType..")",3) end
	
	Object.Position = Position;
	
	local ParentProxy = Object.Parent;
	if (ParentProxy ~= nil) then
		local Parent = ProxyToObject[ParentProxy];
	
		local ParentAbsolutePositionX,ParentAbsolutePositionY = Parent.AbsolutePosition.unpack();
		local ParentAbsoluteSizeX,ParentAbsoluteSizeY = Parent.AbsoluteSize.unpack();
		
		local PositionXScale,PositionXOffset,PositionYScale,PositionYOffset = Position.unpack();
		
		Object.AbsolutePosition = Vector2.new(
			ParentAbsolutePositionX+PositionXOffset+ParentAbsoluteSizeX*PositionXScale,
			ParentAbsolutePositionY+PositionYOffset+ParentAbsoluteSizeY*PositionYScale
		);
		
		
		Object.Draw();
	end
end

function NewIndexFunctions.Size(Object,Key,Size)
	local SizeType = type(Size);
	if (SizeType ~= "UDim2") then error("bad argument #1 to '"..Key.."' (UDim2 expected, got "..SizeType..")",3) end
	
	
	Object.Size = Size;
	
	local ParentProxy = Object.Parent;
	if (ParentProxy ~= nil) then -- TO DO ASSERTION AS IN Frame.NewIndexFunctions.Parent
		local Parent = ProxyToObject[ParentProxy];
		
		local ParentAbsoluteSizeX,ParentAbsoluteSizeY = Parent.AbsoluteSize.unpack();
		
		local SizeXScale,SizeXOffset,SizeYScale,SizeYOffset = Size.unpack();
		
		Object.AbsoluteSize = Vector2.new(
			SizeXOffset+ParentAbsoluteSizeX*SizeXScale,
			SizeYOffset+ParentAbsoluteSizeY*SizeYScale
		);
		
		
		local Children = Object.Children;	local ChildrenNumber = #Children;
		if (ChildrenNumber > 0) then
			for i = 1,ChildrenNumber do
				local Child = Children[i];	local ChildProxy = ObjectToProxy[Child];
				
				ChildProxy.Position = Child.Position;
				ChildProxy.Size = Child.Size;
			end
		else Object.Draw() end
	end
end

function NewIndexFunctions.Visible(Object,Key,Visible)
	local VisibleType = type(Visible);
	if (VisibleType ~= "boolean") then error("bad argument #1 to '"..Key.."' (boolean expected, got "..VisibleType..")",3) end
	
	
	Object.Visible = Visible;
	
	Object.Draw();
end


GuiObject = {
	Base = Base,
	
	Name = Name,
	
	Functions = Functions,
	IndexFunctions = IndexFunctions,
	NewIndexFunctions = NewIndexFunctions,
	
	PrivateKeys = PrivateKeys,
	ReadOnlyKeys = ReadOnlyKeys,
	
	New = New
}