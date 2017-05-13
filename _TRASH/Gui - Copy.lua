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
	
	RenderTargets = {},
	
	Name = "Root";
}

function Root.Render()
	dxSetRenderTarget(Collector.RenderTarget,true);
	dxSetBlendMode("modulate_add");

	for _k,v in pairs(Root.RenderTargets) do
		dxDrawImage(0,0,x,y,v);
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
	local Class = {}
	
	local NewIndex = {}
	
	
	
	local PrivateKeys = {
		
	}
	
	local ReadOnlyKeys = {
		AbsolutePosition = true,
		AbsoluteSize = true,
		
		MouseMoved = true
	}
	
	
	
	function Class.New(Name,Parent) -- Parent: Gui
		local Object = {
			Parent = nil,
		
			AbsolutePosition = Vector2.New(),
			AbsoluteSize = Vector2.New(100,100),
			
			BackgroundColor3 = Color3.New(255,255,255), 
			BackgroundTransparency = 0,
			
			BorderColor3 = Color3.New(27,42,53),
			BorderSizePixel = 1,
			BorderTransparency = 0,
			
			ClipsDescendants = nil,
			
			Position = UDim2.New(),
			Size = UDim2.New(0,100,0,100),
			
			RenderTargets = {},
			
			Visible = true,
			
			MouseMoved = nil,
			
			
			
			Name = Name
		}
		
		
		
		function Object.Render()
			local Parent = Object.Parent;
			
			
			
			dxSetRenderTarget(Parent.RenderTargets[Object],true);
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
						
						local BorderSizePixel = Object.BorderSizePixel;
						
						
						
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
				
				do -- Children
					local AbsolutePositionX,AbsolutePositionY;
					local AbsoluteSizeX,AbsoluteSizeY;
					
					if (Object.ClipsDescendants == true) then
						AbsolutePositionX,AbsolutePositionY = ((Parent.ClipsDescendants == true) and Object.AbsolutePosition-Parent.AbsolutePosition or Object.AbsolutePosition):Unpack();
						AbsoluteSizeX,AbsoluteSizeY = Object.AbsoluteSize:Unpack();
					else
						do
							local CurrentAscendent = Object.Parent;
							
							while (CurrentAscendant ~= Root) and (CurrentAscendent.ClipsDescendants == false) do -- TO MODIFIY
								CurrentAscendent = CurrentAscendent.Parent;
							end
							
							AbsolutePositionX,AbsolutePositionY = (-CurrentAscendent.AbsolutePosition):Unpack();
						end
						
						AbsoluteSizeX,AbsoluteSizeY = Root.AbsoluteSize:Unpack();
					end
					
					
					
					for Child,RenderTarget in pairs(Object.RenderTargets) do
						if (Child.Visible == true) then
							dxDrawImage(
								AbsolutePositionX,AbsolutePositionY,
								AbsoluteSizeX,AbsoluteSizeY,
								RenderTarget
							);
						end
					end
				end
				
				dxSetBlendMode("blend");
			end
			dxSetRenderTarget();
			
			
			
			Parent.Render();
		end
		
		
		
		NewIndex.ClipsDescendants(Object,false);
		
		NewIndex.Parent(Object,Parent or Root);
		
		
		
		do -- Signal MouseMoved
			local Connections,Trigger;
			do
				local SignalProxy,Signal = Signal.New();
				
				Object.MouseMoved = SignalProxy;
				
				Connections,Trigger = Signal.Connections,Signal.Trigger;
			end
			
			addEventHandler("onClientCursorMove",root,function(_RelativeX,_RelativeY,AbsoluteX,AbsoluteY)
				if next(Connections) then
					local MinimumX,MinimumY;
					local MaximumX,MaximumY;
					
					do
						local AbsolutePosition = Object.AbsolutePosition;
						
						MinimumX,MinimumY = AbsolutePosition:Unpack();
						MaximumX,MaximumY = (AbsolutePosition+Object.AbsoluteSize):Unpack();
					end
					
					if (AbsoluteX >= MinimumX) and (AbsoluteX <= MaximumX) and (AbsoluteY >= MinimumY) and (AbsoluteY <= MaximumY) then
						Trigger(AbsoluteX,AbsoluteY);
					end
				end
			end);
		end
		
		return setmetatable({},{
			__index = Object,
			__metatable = "Window",
			__newindex = function(_ObjectProxy,Key,Value)
				if ReadOnlyKeys[Key] then
					error("attempt to modify a read-only key ("..tostring(Key)..")",2);
				end
				
				do
					local NewIndexFunction = NewIndex[Key];
					if NewIndexFunction then
						NewIndexFunction(Object,Value);
						
						-- Object.Render();
						
						return;
					end
				end	
				
				if (Object[Key] ~= nil) then
					Object[Key] = Value;
					
					Object.Render();
					
					return;
				end
				
				error("attempt to modify an invalid key ("..Key..")",2);
			end
		});
	end
	
	
	
	function NewIndex.ClipsDescendants(Object,ClipsDescendants)
		do
			local ClipsDescendantsType = type(ClipsDescendants);
			
			assert(ClipsDescendantsType == "boolean","bad argument #1 to 'ClipsDescendants' (boolean expected, got "..ClipsDescendantsType..")",3);
		end
		
		if (ClipsDescendants == Object.ClipsDescendants) then
			return;
		end
		
		
		
		Object.ClipsDescendants = ClipsDescendants;
		
		
		
		local AbsoluteSize = (ClipsDescendants == true) and Object.AbsoluteSize or Root.AbsoluteSize;
		
		local RenderTargets = Object.RenderTargets;
		
		for Child,RenderTarget in pairs(RenderTargets) do
			destroyElement(RenderTarget);
			
			RenderTargets[Child] = dxCreateRenderTarget(AbsoluteSize.X,AbsoluteSize.Y,true);
			
			Child.Render();
		end
	end
	
	
	
	function NewIndex.Position(Object,Position)
		do
			local PositionType = type(Position);
			
			assert(PositionType == "UDim2","bad argument #1 to 'Position' (UDim2 expected, got "..PositionType..")",3);
		end
		
		
		
		Object.Position = Position;
		
		
		
		local Parent = Object.Parent;
		
		if Parent then -- TO MODIFIY
			local AbsolutePosition = Parent.AbsolutePosition;
			local AbsoluteSize = Parent.AbsoluteSize;
			
			local PositionX,PositionY = Position.X,Position.Y;
			
			Object.AbsolutePosition = Vector2.New(
				AbsolutePosition.X+PositionX.Offset+AbsoluteSize.X*PositionX.Scale,
				AbsolutePosition.Y+PositionY.Offset+AbsoluteSize.Y*PositionY.Scale
			);
			
			
			
			local RenderTargets = Object.RenderTargets;
			
			if (next(RenderTargets) == nil) then
				Object.Render();
			else
				for Child,RenderTarget in pairs(RenderTargets) do
					NewIndex.Position(Child,Child.Position);
					
					NewIndex.Size(Child,Child.Size);
					
					Child.Render();
				end
			end
		end
	end
	
	
	
	function NewIndex.Size(Object,Size)
		do
			local SizeType = type(Size);
			
			assert(SizeType == "UDim2","bad argument #1 to 'Size' (UDim2 expected, got "..SizeType..")",3);
		end
		
		
		
		Object.Size = Size;
		
		
		
		local Parent = Object.Parent;
		
		if Parent then -- TO MODIFIY
			local AbsoluteSize = Parent.AbsoluteSize;
			
			local SizeX,SizeY = Size.X,Size.Y;
			
			Object.AbsoluteSize = Vector2.New(
				SizeX.Offset+AbsoluteSize.X*SizeX.Scale,
				SizeY.Offset+AbsoluteSize.Y*SizeY.Scale
			);
			
			
			
			AbsoluteSize = Object.AbsoluteSize;
			
			local RenderTargets = Object.RenderTargets;
			
			if (next(RenderTargets) == nil) then
				Object.Render();
			else
				for Child,RenderTarget in pairs(RenderTargets) do
					destroyElement(RenderTarget);
					
					RenderTargets[Child] = dxCreateRenderTarget(AbsoluteSize.X,AbsoluteSize.Y,true);
					
					NewIndex.Position(Child,Child.Position);
					
					NewIndex.Size(Child,Child.Size);
					
					Child.Render();
				end
			end
		end
	end
	
	
	
	function NewIndex.Parent(Object,Parent)
		-- TO DO ASSERTION
		-- ERRORS:
		-- Attempt to set parent of StarterGui.ScreenGui.Frame2 to StarterGui.ScreenGui.Frame2.Frame1 would result in circular reference
		-- Attempt to set Players.Player1.PlayerGui.ScreenGui.Frame1 as its own parent
		
		
		do
			local PreviousParent = Object.Parent;
			
			if PreviousParent then -- TO MODIFIY
				local RenderTargets = PreviousParent.RenderTargets
			
				destroyElement(PreviousParent.RenderTargets[Object]);
				
				PreviousParent.RenderTargets[Object] = nil;
				
				PreviousParent.Render();
			end
		end
		
		
		
		Object.Parent = Parent;
		
		
		
		local AbsoluteSize = Parent.ClipsDescendants and Parent.AbsoluteSize or Root.AbsoluteSize;
		
		Parent.RenderTargets[Object] = dxCreateRenderTarget(AbsoluteSize.X,AbsoluteSize.Y,true);
		
		
		
		NewIndex.Position(Object,Object.Position);
		
		NewIndex.Size(Object,Object.Size);
	end
	
	
	
	Window = setmetatable({},{
		__call = function(_ClassProxy,...)
			return Class.New(...);
		end,
		__index = Class,
		__metatable = "Window",
		__newindex = function(_ClassProxy,Key)
			error("attempt to modify a read-only key ("..tostring(Key)..")",2);
		end
	});
end


local Instance = Window("Instance");
Instance.Position = UDim2.New(0.5,-400,0.5,-250);
Instance.Size = UDim2.New(0,800,0,500);
Instance.BackgroundColor3 = Color3.New(125,125,125);

Instance.ClipsDescendants = false;

local Instance2 = Window("Instance2",Instance);
Instance2.Position = UDim2.New(0,0,0,0);
Instance2.Size = UDim2.New(0,600,0,300);
Instance2.BackgroundColor3 = Color3.New(200,0,0);

Instance2.Parent = Root;

Instance2.MouseMoved:Connect(function(x,y)
	outputDebugString("moved "..tostring(x).." "..tostring(y));
end);