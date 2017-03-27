-- setCursorAlpha(0);

local Mouse = {
	Base = Instance,
	
	Name = "Mouse",
	
	Functions = {},
	NewIndexFunctions = {},
	
	PrivateKeys = {
		IconData = true
	},
	ReadOnlyKeys = {
		Move = true,
		
		ViewSizeX = true,
		ViewSizeY = true,
		
		X = true,
		Y = true
	}
}

-- local anims = decode_ani("PointerSchemes/PulseGlass/Arrow.ani");

-- local Controller = 1;	local CurrentFrame = 1;
-- local CurrentAnim = anims[1];
-- addEventHandler("onClientPreRender",root,function(Delta)
	-- local CurrentFrame = CurrentAnim[math.floor(Controller)];
	
	-- dxDrawImage(0,200,CurrentFrame.SizeX,CurrentFrame.SizeY,CurrentFrame.Texture);
	
	-- Controller = Controller+((Delta/1000)*(60/CurrentFrame.Rate));
	-- if (Controller >= #CurrentAnim+1) then Controller = 1 end
-- end);

function Mouse.New(Object)
	Object.ViewSizeX = ScreenSizeX;
	Object.ViewSizeY = ScreenSizeY;
	
	Object.X = ScreenSizeX/2;
	Object.Y = ScreenSizeY/2;
	
	Object.Pointer = Enum.Pointer.Arrow;
	Object.PointersData = {
		[Enum.Pointer.Arrow] = decode_ani("PointerSchemes/PulseGlass/Arrow.ani")[1],
		[Enum.Pointer.Busy] = decode_ani("PointerSchemes/PulseGlass/Busy.ani")[1]
	}
	Object.PointerData = Object.PointersData[Object.Pointer];
	
	setCursorPosition(Object.X,Object.Y);
	
	
	local PointerAnimationController = 1;
	local IsConsoleCursorAlphaSet = false;	local IsMainMenuCursorAlphaSet = false;
	function Object.Render(Delta)
		if (isMainMenuActive() == false) then
			local IsConsoleActive = isConsoleActive();
			
			if (isChatBoxInputActive() == true) or (IsConsoleActive == true) or (isCursorShowing() == true) then
				local PointerData = Object.PointerData;
				
				local PointerAnimationFramesNumber = #PointerData;
				if (PointerAnimationFramesNumber ~= 0) then
					if (PointerAnimationController >= PointerAnimationFramesNumber+1) then PointerAnimationController = 1 end
					
					PointerData = PointerData[math.floor(PointerAnimationController)];
					
					PointerAnimationController = PointerAnimationController+(Delta/1000)*(60/PointerData.rate);
				end
				
				-- SHADOW
				dxDrawImage(
					Object.X-PointerData.hotspotX+2,Object.Y-PointerData.hotspotY+2,
					PointerData.width,PointerData.height,
					PointerData.texture,
					nil,nil,tocolor(0,0,0,125),true
				);
				
				dxDrawImage(
					Object.X-PointerData.hotspotX,Object.Y-PointerData.hotspotY,
					PointerData.width,PointerData.height,
					PointerData.texture,
					nil,nil,nil,true
				);
			end
			
			if (IsConsoleActive == true) then
				if (IsConsoleCursorAlphaSet == false) then
					setCursorAlpha(0);
					
					IsConsoleCursorAlphaSet = true;
				end
			elseif (IsConsoleCursorAlphaSet == true) then IsConsoleCursorAlphaSet = false end
			
			if (IsMainMenuCursorAlphaSet == true) then
				setCursorAlpha(0);
				
				IsMainMenuCursorAlphaSet = false;
			end
		elseif (IsMainMenuCursorAlphaSet == false) then
			setCursorAlpha(255);
			
			IsMainMenuCursorAlphaSet = true;
		end
	end
	addEventHandler("onClientPreRender",root,Object.Render);
	
	do
		local MoveConnections,MoveTrigger;
		Object.Move,MoveConnections,MoveTrigger = Signal.New();
		
		addEventHandler("onClientCursorMove",root,function(_RelativeCursorX,_RelativeCursorY,AbsoluteCursorX,AbsoluteCursorY)
			Object.X = AbsoluteCursorX;
			Object.Y = AbsoluteCursorY;
			
			MoveTrigger(AbsoluteCursorX,AbsoluteCursorY);
		end);
	end
end

do
	for k,v in pairs(Enum.Pointer) do
		Mouse.NewIndexFunctions[k.."Icon"] = function(Object,Key,Icon)
			local IconType = type(Icon);
			if (IconType ~= "string") then error("bad argument #1 to '"..Key.."' (string expected, got "..IconType..")",3) end
			
			if (fileExists(Icon) == false) then error("bad argument #1 to '"..Key.."' (nonexistent file)",3) end
			
			local File = fileOpen(Icon);
			if (File == false) then error("bad argument #1 to '"..Key.."' (invalid file)",3) end
			
			local IconBytes = fileRead(File,fileGetSize(File));
			
			local Success,Result = pcall(decode_ani,IconBytes);
			if (Success == false) then
				Success,Result = pcall(decode_ico,IconBytes);
				if (Success == false) then error(format_pcall_error(Result):gsub("?",Key,1),3) end
				
				Result = Result[1];
				if (Result.HotspotX == nil) or (Result.HotspotY == nil) then error("bad argument #1 to '"..Key.."' (invalid file)") end -- make sure file is not ICO
			else Result = Result[1] end
			
			Object.PointersData[v] = Result;
			if (Object.Pointer == v) then Object.PointerData = Result end
			
			Object[Key] = Icon;
		end
	end
	
	function Mouse.NewIndexFunctions.Pointer(Object,Key,Pointer)
		local PointerType = type(Pointer);
		if (PointerType ~= "number") then error("bad argument #1 to '"..Key.."' (number expected, got "..PointerType..")",3) end
		
		if (EnumValidity.Pointer[Pointer] ~= true) then error("bad argument #1 to '"..Key.."' (invalid value)",3) end
		
		Object.PointerData = Object.PointersData[Pointer];
		
		Object.Pointer = Pointer;
	end
end

Instance.Inherited.Mouse = Mouse;



local Mouse = Instance.New("Mouse");
-- Mouse.ArrowIcon = "Testers/aliendance.ani";



-- local h1,h2,h3 = debug.gethook();
-- debug.sethook();

-- local start = getTickCount();

-- local pow = math.pow;
-- local x = 2;
-- for i = 1,10000000 do
	-- local n = pow(x,2);
-- end

-- print(getTickCount()-start);

-- debug.sethook(nil,h1,h2,h3);