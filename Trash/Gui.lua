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



-- DEPENDENCIES
local IsPointValidToObject;
do
	local function IsPointInsideObject(X,Y,Object)
		local AbsolutePosition = Object.AbsolutePosition;
		
		local MinimumObjectX,MinimumObjectY = AbsolutePosition:Unpack();
		local MaximumObjectX,MaximumObjectY = (AbsolutePosition+Object.AbsoluteSize):Unpack();
		
		return (X >= MinimumObjectX) and (Y >= MinimumObjectY) and (X <= MaximumObjectX) and (Y <= MaximumObjectY);
	end
				
	local function AreObjectDescendantsObstructing(X,Y,Adjacent)
		if (Adjacent.ClipsDescendants == false) then
			for _Index,Child in ipairs(Adjacent.Childs) do
				if (IsPointInsideObject(X,Y,Child) == true) then
					return true;
				else
					return AreObjectDescendantsObstructing(X,Y,Child);
				end
			end
		else
			return false;
		end
	end
	
	function IsPointValidToObject(X,Y,Object)
		if (IsPointInsideObject(X,Y,Object) == true) then
			while (Object ~= Root) do -- TO MODIFY
				local Parent = Object.Parent;
				
				local Adjacents = Parent.Childs;
				
				for Index = Object.Index+1,#Adjacents do
					local Adjacent = Adjacents[Index];
					
					if (IsPointInsideObject(X,Y,Adjacent) == true) or (AreObjectDescendantsObstructing(X,Y,Adjacent) == true) then
						return false;
					end
				end
				
				Object = Parent;
			end
				
			return true;
		else
			return false;
		end
	end
end

--[[ TO DO:

	+ Cursor Class DONE
	+ Function for every property DONE
	+ Private keys
	+ Recreate render targets on client minimize

]]

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
			-- Parent = nil,
		
			AbsolutePosition = Vector2.New(),
			AbsoluteSize = Vector2.New(100,100),
			
			BackgroundColor3 = Color3.New(255,255,255), 
			BackgroundTransparency = 0,
			
			BorderColor3 = Color3.New(27,42,53),
			BorderSizePixel = 1,
			BorderTransparency = 0,
			
			ClipsDescendants = false,
			
			Position = UDim2.New(),
			Size = UDim2.New(0,100,0,100),
			
			Childs = {},
			
			Visible = true,
			
			-- MouseMoved = nil,
			
			
			
			Name = Name
		}
		
		
		
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
		
		
		
		NewIndex.Parent(Object,Parent or Root);
		
		
		
		do -- Signal MouseEnter MouseLeave MouseMove
			local MouseEnterConnections,MouseEnterTrigger;
			Object.MouseEnter,MouseEnterConnections,MouseEnterTrigger = Signal.New();
			
			local MouseLeaveConnections,MouseLeaveTrigger;
			Object.MouseLeave,MouseLeaveConnections,MouseLeaveTrigger = Signal.New();
			
			local MouseMoveConnections,MouseMoveTrigger;
			Object.MouseMove,MouseMoveConnections,MouseMoveTrigger = Signal.New();
			
			
			
			local IsMouseInside = false;
			
			PlayerMouse.Move:Connect(function(MouseX,MouseY)
				if (Object.Visible == true) and (next(MouseEnterConnections) or next(MouseLeaveConnections) or next(MouseMoveConnections)) then
					if (IsPointValidToObject(MouseX,MouseY,Object) == true) then
						if (IsMouseInside == false) then
							MouseEnterTrigger(MouseX,MouseY);
							
							IsMouseInside = true;
						end
					
						MouseMoveTrigger(MouseX,MouseY);
					elseif (IsMouseInside == true) then
						MouseLeaveTrigger(MouseX,MouseY);
						
						IsMouseInside = false;
					end
				end
			end);
		end
		
		do
			local MouseWheelBackwardConnections,MouseWheelBackwardTrigger;
			Object.MouseWheelBackward,MouseWheelBackwardConnections,MouseWheelBackwardTrigger = Signal.New();
			
			local MouseWheelForwardConnections,MouseWheelForwardTrigger;
			Object.MouseWheelForward,MouseWheelForwardConnections,MouseWheelForwardTrigger = Signal.New();
			
			
			
			addEventHandler("onClientKey",root,function(Key)
				if (Object.Visible == true) and (next(MouseWheelBackwardConnections) or next(MouseWheelForwardConnections)) then
					local PlayerMouseX,PlayerMouseY = PlayerMouse.X,PlayerMouse.Y;
					
					if (IsPointValidToObject(PlayerMouseX,PlayerMouseY,Object) == true) then
						if (Key == "mouse_wheel_down") then
							MouseWheelBackwardTrigger(PlayerMouseX,PlayerMouseY);
						elseif (Key == "mouse_wheel_up") then
							MouseWheelForwardTrigger(PlayerMouseX,PlayerMouseY);
						end
					end
				end
			end);
		end
		
		return setmetatable({},{
			__index = Object,
			__metatable = "Window",
			__newindex = function(_ObjectProxy,Key,Value)
				if (ReadOnlyKeys[Key] == true) then
					error("attempt to modify a read-only key ("..tostring(Key)..")",2);
				else
					local NewIndexFunction = NewIndex[Key];
					
					if NewIndexFunction then
						NewIndexFunction(Object,Value);
					else
						error("attempt to modify an invalid key ("..Key..")",2);
					end
				end
			end
		});
	end
	
	
	function NewIndex.BackgroundColor3(Object,BackgroundColor3)
		do
			local BackgroundColor3Type = type(BackgroundColor3);
			
			assert(BackgroundColor3Type == "Color3","bad argument #1 to 'BackgroundColor3' (Color3 expected, got "..BackgroundColor3Type..")",3);
		end
		
		
		
		Object.BackgroundColor3 = BackgroundColor3;
		
		Object.Render();
	end
	
	function NewIndex.BackgroundTransparency(Object,BackgroundTransparency)
		do
			local BackgroundTransparencyType = type(BackgroundTransparency);
			
			assert(BackgroundTransparencyType == "number","bad argument #1 to 'BackgroundTransparency' (number expected, got "..BackgroundTransparencyType..")",3);
			
			assert((BackgroundTransparency >= 0) and (BackgroundTransparency <= 1),"bad argument #1 to 'BackgroundTransparency' (value out of bounds)",3);
		end
		
		
		
		Object.BackgroundTransparency = BackgroundTransparency;
		
		Object.Render();
	end
	
	
	
	function NewIndex.BorderColor3(Object,BorderColor3)
		do
			local BorderColor3Type = type(BorderColor3);
			
			assert(BorderColor3Type == "Color3","bad argument #1 to 'BorderColor3' (Color3 expected, got "..BorderColor3Type..")",3);
		end
		
		
		
		Object.BorderColor3 = BorderColor3;
		
		Object.Render();
	end
	
	function NewIndex.BorderSizePixel(Object,BorderSizePixel)
		do
			local BorderSizePixelType = type(BorderSizePixel);
			
			assert(BorderSizePixelType == "number","bad argument #1 to 'BorderSizePixel' (number expected, got "..BorderSizePixelType..")",3);
			
			assert(BorderSizePixel >= 0,"bad argument #1 to 'BorderSizePixel' (negative number)",3);
			
			assert(BorderSizePixel%1 == 0,"bad argument #1 to 'BorderSizePixel' (number has no integer representation)",3);
		end
		
		
		
		Object.BorderSizePixel = BorderSizePixel;
		
		Object.Render();
	end
	
	function NewIndex.BorderTransparency(Object,BorderTransparency)
		do
			local BorderTransparencyType = type(BorderTransparency);
			
			assert(BorderTransparencyType == "number","bad argument #1 to 'BorderTransparency' (number expected, got "..BorderTransparencyType..")",3);
			
			assert((BorderTransparency >= 0) and (BorderTransparency <= 1),"bad argument #1 to 'BorderTransparency' (value out of bounds)",3);
		end
		
		
		
		Object.BorderTransparency = BorderTransparency;
		
		Object.Render();
	end
	
	
	
	function NewIndex.ClipsDescendants(Object,ClipsDescendants)
		do
			local ClipsDescendantsType = type(ClipsDescendants);
			
			assert(ClipsDescendantsType == "boolean","bad argument #1 to 'ClipsDescendants' (boolean expected, got "..ClipsDescendantsType..")",3);
		end
		
		if (ClipsDescendants == Object.ClipsDescendants) then
			return;
		end
		
		
		
		local AbsoluteSize = (ClipsDescendants == true) and Object.AbsoluteSize or Root.AbsoluteSize;
		
		for _Index,Child in ipairs(Object.Childs) do
			destroyElement(Child.RenderTarget);
			
			Child.RenderTarget = dxCreateRenderTarget(AbsoluteSize.X,AbsoluteSize.Y,true);
			
			Child.Render();
		end
		
		
		
		Object.ClipsDescendants = ClipsDescendants;
	end
	
	
	
	function NewIndex.Position(Object,Position)
		do
			local PositionType = type(Position);
			
			assert(PositionType == "UDim2","bad argument #1 to 'Position' (UDim2 expected, got "..PositionType..")",3);
		end
		
		
		
		local Parent = Object.Parent;
		
		if Parent then -- TO MODIFIY
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
						NewIndex.Position(Child,Child.Position);
						
						Child.Render();
					end
				end
			end
		end
		
		
		
		Object.Position = Position;
	end
	
	function NewIndex.Size(Object,Size)
		do
			local SizeType = type(Size);
			
			assert(SizeType == "UDim2","bad argument #1 to 'Size' (UDim2 expected, got "..SizeType..")",3);
		end
		
		
		
		local Parent = Object.Parent;
		
		if Parent then -- TO MODIFIY
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
					
					
					
					NewIndex.Position(Child,Child.Position);
					
					NewIndex.Size(Child,Child.Size);
					
					Child.Render();
				end
			end
		end
		
		
		
		Object.Size = Size;
	end
	
	
	
	function NewIndex.Visible(Object,Visible)
		do
			local VisibleType = type(Visible);
			
			assert(VisibleType == "boolean","bad argument #1 to 'Visible' (boolean expected, got "..VisibleType..")",3);
		end
		
		
		
		Object.Visible = Visible;
		
		Object.Render();
	end
	
	
	
	function NewIndex.Parent(Object,Parent)
		-- TO DO ASSERTION
		-- ERRORS:
		-- Attempt to set parent of StarterGui.ScreenGui.Frame2 to StarterGui.ScreenGui.Frame2.Frame1 would result in circular reference
		-- Attempt to set Players.Player1.PlayerGui.ScreenGui.Frame1 as its own parent
		
		
		do
			local PreviousParent = Object.Parent;
			
			if PreviousParent then -- TO MODIFIY
				destroyElement(Object.RenderTarget);
				
				
				
				local Childs = PreviousParent.Childs;
				local ChildsSize = #Childs;
				
				for Index = Object.Index+1,ChildsSize do
					Childs[Index] = Childs[Index-1];
				end
				
				Childs[ChildsSize] = nil;
				
				PreviousParent.Render();
			end
		end
		
		
		
		do
			local AbsoluteSize = Parent.ClipsDescendants and Parent.AbsoluteSize or Root.AbsoluteSize;
			
			Object.RenderTarget = dxCreateRenderTarget(AbsoluteSize.X,AbsoluteSize.Y,true);
		end
		
		do
			local Childs = Parent.Childs;
			
			local Index = #Childs+1;
			
			Object.Index = Index;
			
			Childs[Index] = Object; 
		end
		
		
		
		Object.Parent = Parent;
		
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

local Instance2 = Window("Instance2");
Instance2.Position = UDim2.New(0,0,0,0);
Instance2.Size = UDim2.New(0,600,0,300);
Instance2.BackgroundColor3 = Color3.New(255,0,0);

Instance2.MouseMove:Connect(function(x,y)
	outputDebugString("move "..tostring(x).." "..tostring(y));
end);

Instance2.MouseWheelBackward:Connect(function(x,y)
	outputDebugString("scroll backward "..tostring(x).." "..tostring(y));
end);

local Instance = Window("Instance");
Instance.Position = UDim2.New(0.5,-400,0.5,-250);
Instance.Size = UDim2.New(0,800,0,500);
Instance.BackgroundColor3 = Color3.New(125,125,125);
-- Instance.ClipsDescendants = true;

local Instance3 = Window("Instance3",Instance);
Instance3.Position = UDim2.New(0,-90,0,-90);

-- Instance.Position = UDim2.New(0,800,0,200);