function CallAscendantNewIndexFunction(Class,Key,...)
	Class = Class.Ascendant;
	local NewIndexFunction = Class.NewIndexFunctions[Key];
	
	while (NewIndexFunction == nil) do
		Class = Class.Ascendant;
		NewIndexFunction = Class.NewIndexFunctions[Key];
	end
	
	NewIndexFunction(...);
end

local x,y = guiGetScreenSize();

local Collector = {
	AbsolutePosition = Vector2(),
	AbsoluteSize = Vector2(x,y),
	
	RenderTarget = dxCreateRenderTarget(x,y,true),
	
	Name = "Collector"
};

local Root = {
	AbsolutePosition = Vector2(),
	AbsoluteSize = Vector2(x,y),
	
	Parent = Collector,
	
	Childs = {},
	
	Name = "Root";
}

function Root.Render()
	dxSetRenderTarget(Collector.RenderTarget,true);
	dxSetBlendMode("modulate_add");

	for _Index,Child in ipairs(Root.Childs) do
		dxDrawImage(0,0,x,y,Child.RenderTarget);
	end
	
	dxSetBlendMode("blend");
	dxSetRenderTarget();
end

addEventHandler("onClientRender",root,function()
	dxSetBlendMode("add");

	dxDrawImage(0,0,x,y,Collector.RenderTarget);
	
	dxSetBlendMode("blend");
end);

do
	local Instance = {
		Inherited = {},
		
		Functions = {},
		NewIndexFunctions = {},
		
		Name = "Instance",
		
		PrivateKeys = {},
		ReadOnlyKeys = {
			ClassName = true
		}
	}
	
	function Instance.New(ClassName,Parent)
		local Class = Instance.Inherited[ClassName];
		
		if (Class ~= nil) then
			local Object = {
				ClassName = ClassName,
				
				Childs = {}
			}
			
			Class.New(Object,Parent);
			
			return setmetatable({},{
				__index = function(_ObjectProxy,Key)
					local CurrentClass = Class;
					
					while (CurrentClass ~= nil) do
						local Function = CurrentClass.Functions[Key];
						
						if (Function ~= nil) then
							return Function;
						end
						
						CurrentClass = CurrentClass.Ascendant;
					end
				
					return Object[Key];
				end,
				__metatable = ClassName,
				__newindex = function(_ObjectProxy,Key,Value)
					local CurrentClass = Class;
					
					while (CurrentClass ~= nil) do
						if (CurrentClass.ReadOnlyKeys[Key] == true) then
							error("attempt to modify a read-only key ("..tostring(Key)..")",2);
						else
							local NewIndexFunction = CurrentClass.NewIndexFunctions[Key];
							
							if (NewIndexFunction ~= nil) then
								NewIndexFunction(Object,Value);
								
								break;
							end
							
							CurrentClass = CurrentClass.Ascendant;
						end
					end
				end
			});
		end
	end
	
	do -- Instance.Functions
		function Instance.Functions.IsA(ObjectProxy,ClassName)
			local CurrentClass = Instance.Inherited[ObjectProxy.ClassName];
			
			while (CurrentClass ~= nil) do
				if (CurrentClass.Name == ClassName) then
					return true;
				end
				
				CurrentClass = CurrentClass.Ascendant;
			end
			
			return false;
		end
	end
	
	do -- Instance.NewIndexFunctions
		function Instance.NewIndexFunctions.Parent(Object,Parent)
			Object.Parent = Parent;
		end
	end
	
	_G.Instance = setmetatable({},{
		__call = function(_ClassProxy,...)
			return Instance.New(...);
		end,
		__index = Instance,
		__metatable = "Instance",
		__newindex = function(_ClassProxy,Key)
			error("attempt to modify a read-only key ("..tostring(Key)..")",2);
		end
	});
end

do
	local GuiBase2D = {
		Ascendant = Instance,
		
		Functions = {},
		NewIndexFunctions = {},
		
		Name = "GuiBase2D",
		
		PrivateKeys = {},
		ReadOnlyKeys = {
			AbsolutePosition = true,
			AbsoluteSize = true
		}
	}
	
	function GuiBase2D.New(Object)
		Object.AbsolutePosition = true;
		Object.AbsoluteSize = true;
		
		return Object;
	end
	
	_G.GuiBase2D = GuiBase2D;
end

do
	local GuiObject = {
		Ascendant = GuiBase2D,
		
		Functions = {},
		NewIndexFunctions = {},
		
		Name = "GuiObject",
		
		PrivateKeys = {},
		ReadOnlyKeys = {}
	}
	
	function GuiObject.New(Object)
		GuiObject.Ascendant.New(Object);
		
		Object.BackgroundColor3 = Color3.New(255,255,255);
		Object.BackgroundTransparency = 0;
		
		Object.BorderColor3 = Color3.New(27,42,53);
		Object.BorderSizePixel = 1;
		Object.BorderTransparency = 0;
		
		Object.ClipsDescendants = false;
		
		Object.Position = true;
		Object.Size = true;
		
		Object.Visible = true;
		
		return Object;
	end
	
	_G.GuiObject = GuiObject;
end

do
	local Frame = {
		Ascendant = GuiObject,
		
		Name = "Frame",
		
		Functions = {},
		NewIndexFunctions = {},
		
		PrivateKeys = {},
		ReadOnlyKeys = {}
	}
	
	function Frame.New(Object,Parent)
		Frame.Ascendant.New(Object);
		
		Object.AbsolutePosition = Vector2.New();
		Object.AbsoluteSize = Vector2.New(100,100);
		
		Object.Position = UDim2.New();
		Object.Size = UDim2.New(0,100,0,100);
		
		function Object.Render()
			local Parent = Object.Parent;
			
			dxSetRenderTarget(Object.RenderTarget,true);
			if (Object.Visible == true) then
				dxSetBlendMode("modulate_add");
				
				do -- Body
					local AbsolutePositionX,AbsolutePositionY = ((Parent.ClipsDescendants == true) and Object.AbsolutePosition-Parent.AbsolutePosition or Object.AbsolutePosition):Unpack();
					local AbsoluteSizeX,AbsoluteSizeY = Object.AbsoluteSize:Unpack();
					
					
					
					do -- Background
						local BackgroundColor3 = Object.BackgroundColor3;
						
						
						
						dxDrawRectangle(
							AbsolutePositionX,AbsolutePositionY,
							AbsoluteSizeX,AbsoluteSizeY,
							tocolor(
								BackgroundColor3.Red,
								BackgroundColor3.Green,
								BackgroundColor3.Blue,
								255*(1-Object.BackgroundTransparency)
							)
						);
					end
					
					
					
					do -- Border
						local BorderSizePixel = Object.BorderSizePixel;
						
						if (BorderSizePixel ~= 0) then
							local BorderColor;
							
							do
								local BorderColor3 = Object.BorderColor3;
								
								BorderColor = tocolor(
									BorderColor3.Red,
									BorderColor3.Green,
									BorderColor3.Blue,
									255*(1-Object.BorderTransparency)
								);
							end
							
							
							
							dxDrawRectangle( -- top
								AbsolutePositionX-BorderSizePixel,AbsolutePositionY-BorderSizePixel,
								AbsoluteSizeX+BorderSizePixel,BorderSizePixel,
								BorderColor
							);
							dxDrawRectangle( -- right
								AbsolutePositionX+AbsoluteSizeX,AbsolutePositionY-BorderSizePixel,
								BorderSizePixel,AbsoluteSizeY+BorderSizePixel,
								BorderColor
							);
							dxDrawRectangle( -- bottom
								AbsolutePositionX,AbsolutePositionY+AbsoluteSizeY,
								AbsoluteSizeX+BorderSizePixel,BorderSizePixel,
								BorderColor
							);
							dxDrawRectangle( -- left
								AbsolutePositionX-BorderSizePixel,AbsolutePositionY,
								BorderSizePixel,AbsoluteSizeY+BorderSizePixel,
								BorderColor
							);
						end
					end
				end
				
				do -- Children
					local AbsolutePositionX,AbsolutePositionY;
					local AbsoluteSizeX,AbsoluteSizeY;
					
					if (Object.ClipsDescendants == true) then
						AbsolutePositionX,AbsolutePositionY = ((Parent.ClipsDescendants == true) and Object.AbsolutePosition-Parent.AbsolutePosition or Object.AbsolutePosition):Unpack();
						AbsoluteSizeX,AbsoluteSizeY = Object.AbsoluteSize:Unpack();
					else
						do
							local CurrentAscendant = Object.Parent;
							
							while (CurrentAscendant ~= Root) and (CurrentAscendant.ClipsDescendants == false) do -- TO MODIFIY
								CurrentAscendant = CurrentAscendant.Parent;
							end
							
							AbsolutePositionX,AbsolutePositionY = (-CurrentAscendant.AbsolutePosition):Unpack();
						end
						
						AbsoluteSizeX,AbsoluteSizeY = Root.AbsoluteSize:Unpack();
					end
					
					
					
					for _Index,Child in ipairs(Object.Childs) do
						if (Child.Visible == true) then
							dxDrawImage(
								AbsolutePositionX,AbsolutePositionY,
								AbsoluteSizeX,AbsoluteSizeY,
								Child.RenderTarget
							);
						end
					end
				end
				
				dxSetBlendMode("blend");
			end
			dxSetRenderTarget();
			
			
			
			Parent.Render();
		end
		
		Frame.NewIndexFunctions.Parent(Object,Parent);
		
		return Object;
	end
	
	do
		function Frame.NewIndexFunctions.ClipsDescendants(Object,ClipsDescendants)
			do
				local ClipsDescendantsType = type(ClipsDescendants);
				
				assert(ClipsDescendantsType == "boolean","bad argument #1 to 'ClipsDescendants' (boolean expected, got "..ClipsDescendantsType..")",3);
			end
			
			
			
			local AbsoluteSize = (ClipsDescendants == true) and Object.AbsoluteSize or Root.AbsoluteSize; -- TO MODIFY
			
			for _Index,Child in ipairs(Object.Childs) do
				destroyElement(Child.RenderTarget);
				
				Child.RenderTarget = dxCreateRenderTarget(AbsoluteSize.X,AbsoluteSize.Y,true);
				
				Child.Render();
			end
			
			Object.ClipsDescendants = ClipsDescendants;
		end
	
		function Frame.NewIndexFunctions.Parent(Object,Parent)
			-- TO DO ASSERTION
			-- ERRORS:
			-- Attempt to set parent of StarterGui.ScreenGui.Frame2 to StarterGui.ScreenGui.Frame2.Frame1 would result in circular reference
			-- Attempt to set Players.Player1.PlayerGui.ScreenGui.Frame1 as its own parent
			
			do
				local PreviousParent = Object.Parent;
				
				if (PreviousParent ~= nil) then -- any previous parent?
					destroyElement(Object.RenderTarget);
					
					table.remove(PreviousParent.Childs,Object.Index);
					
					PreviousParent.Render();
				end
			end
			
			
			
			do
				local AbsoluteSize = (Parent.ClipsDescendants == true) and Parent.AbsoluteSize or Root.AbsoluteSize;
				Object.RenderTarget = dxCreateRenderTarget(AbsoluteSize.X,AbsoluteSize.Y,true);
			end
			
			do
				local Childs = Parent.Childs;
				local Index = #Childs+1;
				
				Object.Index = Index;
				Childs[Index] = Object;
			end
			
			
			
			do -- maybe transform into function?
				local CurrentClass = Frame.Ascendant;
				
				while (CurrentClass ~= nil) do
					local NewIndexFunction = CurrentClass.NewIndexFunctions.Parent;
					
					if (NewIndexFunction ~= nil) then
						NewIndexFunction(Object,Parent);
						
						break;
					end
					
					CurrentClass = CurrentClass.Ascendant;
				end
			end
			
			Frame.NewIndexFunctions.Position(Object,Object.Position); -- update position to new parent
			Frame.NewIndexFunctions.Size(Object,Object.Size); -- update size to new parent
		end
		
		function Frame.NewIndexFunctions.Position(Object,Position)
			do
				local PositionType = type(Position);
				assert(PositionType == "UDim2","bad argument #1 to 'Position' (UDim2 expected, got "..PositionType..")",3);
			end
			
			
			
			local Parent = Object.Parent;
			if (Parent ~= nil) then -- TO DO ASSERTION AS IN Frame.NewIndexFunctions.Parent
				local AbsolutePosition = Parent.AbsolutePosition;
				local AbsoluteSize = Parent.AbsoluteSize;
				
				local PositionX,PositionY = Position.X,Position.Y;
				
				Object.AbsolutePosition = Vector2.New(
					AbsolutePosition.X+PositionX.Offset+AbsoluteSize.X*PositionX.Scale,
					AbsolutePosition.Y+PositionY.Offset+AbsoluteSize.Y*PositionY.Scale
				);
				
				
				
				local Childs = Object.Childs;
				
				if (Childs[1] == nil) then
					Object.Render();
				else
					for _Index,Child in ipairs(Childs) do
						if (Child.ClipsDescendants == false) then
							Frame.NewIndexFunctions.Position(Child,Child.Position);
							
							Child.Render();
						end
					end
				end
			end
			
			Object.Position = Position;
		end
		
		function Frame.NewIndexFunctions.Size(Object,Size)
			do
				local SizeType = type(Size);
				assert(SizeType == "UDim2","bad argument #1 to 'Size' (UDim2 expected, got "..SizeType..")",3);
			end
			
			
			
			local Parent = Object.Parent;
			if (Parent ~= nil) then -- TO DO ASSERTION AS IN Frame.NewIndexFunctions.Parent
				local AbsoluteSize = Parent.AbsoluteSize;
				
				local SizeX,SizeY = Size.X,Size.Y;
				
				Object.AbsoluteSize = Vector2.New(
					SizeX.Offset+AbsoluteSize.X*SizeX.Scale,
					SizeY.Offset+AbsoluteSize.Y*SizeY.Scale
				);
				
				
				
				AbsoluteSize = Object.AbsoluteSize;
				
				local Childs = Object.Childs;
				
				if (Childs[1] == nil) then
					Object.Render();
				else
					for _Index,Child in pairs(Childs) do
						destroyElement(Child.RenderTarget);
						
						Child.RenderTarget = dxCreateRenderTarget(AbsoluteSize.X,AbsoluteSize.Y,true);
						
						
						
						Frame.NewIndexFunctions.Position(Child,Child.Position);
						Frame.NewIndexFunctions.Size(Child,Child.Size);
						
						Child.Render();
					end
				end
			end
			
			Object.Size = Size;
		end
	end
	
	Instance.Inherited.Frame = Frame;
end



local x = Instance.New("Frame",Root);



--[[do -- ABSTRACT CLASS
	local GuiObject = {
		Ascendant = Instance,
		
		NewIndexFunctions = {},
		
		ReadOnlyKeys = {
			AbsolutePosition = true,
			AbsoluteSize = true
		},
		
		
		
		Name = "GuiObject"
	}
	
	function GuiObject.New()
		local Object = {
			AbsolutePosition = 10,
			AbsoluteSize = 73
		}
		
		return Object;
	end
	
	_G.GuiObject = GuiObject;
end

do
    local Frame = {
		Ascendant = GuiObject, -- Inherited from
		
		NewIndexFunctions = {},
		
		ReadOnlyKeys = {},
		
		
		
		Name = "Frame"
    }
    
    function Frame.New(Parent)
        local Object = Frame.Ascendant.New();
		
		Object.Style = "DEFAULT";
        
        return Object;
    end
	
	function Frame.NewIndexFunctions.Parent(Object,Parent)
		CallAscendantNewIndexFunction(Frame,"Parent",Object,Parent);
		
		print("parent set");
		-- code
	end
    
	Instance.Inherited.Frame = Frame;
end]]