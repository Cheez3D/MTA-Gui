-- CREATED BY CHEEZ -- all rights reserved --

--[[TO DO 
	Modify SetMetatable;
	Add inheritance; done
	Add variable support with __newindex metamethod; done
]]

-- VARIABLES --
local ScreenSizeX,ScreenSizeY = GuiElement.getScreenSize();
local IsElement,IsTimer = isElement,isTimer;
local GetMetatable,IndexedPairs,Next,Pairs,RawGet,SetMetatable,Type,Unpack = getmetatable,ipairs,next,pairs,rawget,setmetatable,type,unpack;
local ConvertHexToRGB,ConvertRGBToHex,GetGUIAbsolutePosition,InitializeClass,Interpolate,Interpolate2,Interpolate3 = Shared.ConvertHexToRGB,Shared.ConvertRGBToHex,Client.GetGUIAbsolutePosition,Shared.InitializeClass,Shared.Interpolate,Shared.Interpolate2,Shared.Interpolate3;

-- TABLES --
GUI = {
	Window = {},
	Button = {
		Default = {},
		Image = {},
		Radio = {};
	},
	Bar = {
		Progress = {},
		Scroll = {};
	};
	Box = {
		Check = {},
		Combo = {},
		Text = {};
	};
};

-- SCRIPT --
local GUI = GUI;
-- InitializeClass(GUI);

GUI.Window.Animations = {
	Focus = {
		Focusing = function(window)
			local FrameColor = window.Functions.FrameColor;
			local function WindowAnimationHandler()
				local CurrentFrameColorRed,CurrentFrameColorGreen,CurrentFrameColorBlue = Interpolate3(FrameColor[1][1],FrameColor[2][1],FrameColor[1][2],FrameColor[2][2],FrameColor[1][3],FrameColor[2][3],window.Animations.Focus.Progress,"Cubic","InOut");
				local CurrentFrameColor = ConvertRGBToHex(CurrentFrameColorRed,CurrentFrameColorGreen,CurrentFrameColorBlue);
				if IsElement(window.Header) and IsElement(window.Frame) then
					window.Header:setProperty("ImageColours","tl:FF"..CurrentFrameColor.." tr:FF"..CurrentFrameColor.." bl:FF"..CurrentFrameColor.." br:FF"..CurrentFrameColor);
					window.Frame:setProperty("ImageColours","tl:FF"..CurrentFrameColor.." tr:FF"..CurrentFrameColor.." bl:FF"..CurrentFrameColor.." br:FF"..CurrentFrameColor);
				end;
				if window.Animations.Focus.Progress>=1 then
					window.Animations.Focus.Switch = nil;
					removeEventHandler("onClientRender",root,WindowAnimationHandler);
				end;
				window.Animations.Focus.Progress = window.Animations.Focus.Progress+0.075;
				if window.Animations.Focus.Progress>1 then
					window.Animations.Focus.Progress = 1;
				end;
			end;
			window.Animations.Focus.Switch = WindowAnimationHandler;
			addEventHandler("onClientRender",root,WindowAnimationHandler);
		end,
		Blurring = function(window)
			local FrameColor = window.Functions.FrameColor;
			local function WindowAnimationHandler()
				local CurrentFrameColorRed,CurrentFrameColorGreen,CurrentFrameColorBlue = Interpolate3(FrameColor[1][1],FrameColor[2][1],FrameColor[1][2],FrameColor[2][2],FrameColor[1][3],FrameColor[2][3],window.Animations.Focus.Progress,"Cubic","InOut");
				local CurrentFrameColor = ConvertRGBToHex(CurrentFrameColorRed,CurrentFrameColorGreen,CurrentFrameColorBlue);
				if IsElement(window.Header) and IsElement(window.Frame) then
					window.Header:setProperty("ImageColours","tl:FF"..CurrentFrameColor.." tr:FF"..CurrentFrameColor.." bl:FF"..CurrentFrameColor.." br:FF"..CurrentFrameColor);
					window.Frame:setProperty("ImageColours","tl:FF"..CurrentFrameColor.." tr:FF"..CurrentFrameColor.." bl:FF"..CurrentFrameColor.." br:FF"..CurrentFrameColor);
				end;
				if window.Animations.Focus.Progress<=0 then
					window.Animations.Focus.Switch = nil;
					removeEventHandler("onClientRender",root,WindowAnimationHandler);
				end;
				window.Animations.Focus.Progress = window.Animations.Focus.Progress-0.075;
				if window.Animations.Focus.Progress<0 then
					window.Animations.Focus.Progress = 0;
				end;
			end;
			window.Animations.Focus.Switch = WindowAnimationHandler;
			addEventHandler("onClientRender",root,WindowAnimationHandler);
		end;
	};
};

GUI.Button.Default.Animations = {
	Hover = {
		Entering = function(button)
			local FrameColor = button.Functions.FrameColor;
			local function ButtonAnimationHandler()
				local CurrentFrameColorRed,CurrentFrameColorGreen,CurrentFrameColorBlue = Interpolate3(FrameColor[1][1],FrameColor[2][1],FrameColor[1][2],FrameColor[2][2],FrameColor[1][3],FrameColor[2][3],button.Animations.Hover.Progress,"Quadratic","InOut");
				local CurrentFrameColor = ConvertRGBToHex(CurrentFrameColorRed,CurrentFrameColorGreen,CurrentFrameColorBlue);
				if IsElement(button.Frame) then
					button.Frame:setProperty("ImageColours","tl:FF"..CurrentFrameColor.." tr:FF"..CurrentFrameColor.." bl:FF"..CurrentFrameColor.." br:FF"..CurrentFrameColor);
				end;
				if button.Animations.Hover.Progress>=1 then
					button.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,ButtonAnimationHandler);
				end;
				button.Animations.Hover.Progress = button.Animations.Hover.Progress+0.075;
				if button.Animations.Hover.Progress>1 then
					button.Animations.Hover.Progress = 1;
				end;
			end;
			button.Animations.Hover.Switch = ButtonAnimationHandler;
			addEventHandler("onClientRender",root,ButtonAnimationHandler);
		end,
		Leaving = function(button)
			local FrameColor = button.Functions.FrameColor;
			local function ButtonAnimationHandler()
				local CurrentFrameColorRed,CurrentFrameColorGreen,CurrentFrameColorBlue = Interpolate3(FrameColor[1][1],FrameColor[2][1],FrameColor[1][2],FrameColor[2][2],FrameColor[1][3],FrameColor[2][3],button.Animations.Hover.Progress,"Quadratic","InOut");
				local CurrentFrameColor = ConvertRGBToHex(CurrentFrameColorRed,CurrentFrameColorGreen,CurrentFrameColorBlue);
				if IsElement(button.Frame) then
					button.Frame:setProperty("ImageColours","tl:FF"..CurrentFrameColor.." tr:FF"..CurrentFrameColor.." bl:FF"..CurrentFrameColor.." br:FF"..CurrentFrameColor);
				end;
				if button.Animations.Hover.Progress<=0 then
					button.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,ButtonAnimationHandler);
				end;
				button.Animations.Hover.Progress = button.Animations.Hover.Progress-0.075;
				if button.Animations.Hover.Progress<0 then
					button.Animations.Hover.Progress = 0;
				end;
			end;
			button.Animations.Hover.Switch = ButtonAnimationHandler;
			addEventHandler("onClientRender",root,ButtonAnimationHandler);
		end;
	},
	Enable = {
		Disabling = function(button)
			if IsElement(button.Text) then
				button.Text:setEnabled(false);
			end;
			local function ButtonAnimationHandler()
				local CurrentDisableFrameTransparency = Interpolate(0,1,button.Animations.Enable.Progress,"Quadratic","InOut");
				if IsElement(button.DisableFrame) then
					button.DisableFrame:setAlpha(CurrentDisableFrameTransparency);
				end;
				if button.Animations.Enable.Progress>=1 then
					button.Animations.Enable.Switch = nil;
					removeEventHandler("onClientRender",root,ButtonAnimationHandler);
				end;
				button.Animations.Enable.Progress = button.Animations.Enable.Progress+0.075;
				if button.Animations.Enable.Progress>1 then
					button.Animations.Enable.Progress = 1;
				end;
			end;
			button.Animations.Enable.Switch = ButtonAnimationHandler;
			addEventHandler("onClientRender",root,ButtonAnimationHandler);
		end,
		Enabling = function(button)
			local function ButtonAnimationHandler()
				local CurrentDisableFrameTransparency = Interpolate(0,1,button.Animations.Enable.Progress,"Quadratic","InOut");
				if IsElement(button.DisableFrame) then
					button.DisableFrame:setAlpha(CurrentDisableFrameTransparency);
				end;
				if button.Animations.Enable.Progress<=0 then
					button.Animations.Enable.Switch = nil;
					removeEventHandler("onClientRender",root,ButtonAnimationHandler);
					if IsElement(button.Text) then
						button.Text:setEnabled(true);
					end;
				end;
				button.Animations.Enable.Progress = button.Animations.Enable.Progress-0.075;
				if button.Animations.Enable.Progress<0 then
					button.Animations.Enable.Progress = 0;
				end;
			end;
			button.Animations.Enable.Switch = ButtonAnimationHandler;
			addEventHandler("onClientRender",root,ButtonAnimationHandler);
		end;
	};
};

GUI.Button.Image.Animations = {
	Hover = {
		Entering = function(button)
			local function ButtonAnimationHandler()
				local CurrentHoverTransparency = Interpolate(0,1,button.Animations.Hover.Progress,"Quadratic","InOut");
				if IsElement(button.Hover) then
					button.Hover:setAlpha(CurrentHoverTransparency);
				end;
				if button.Animations.Hover.Progress>=1 then
					button.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,ButtonAnimationHandler);
				end;
				button.Animations.Hover.Progress = button.Animations.Hover.Progress+0.1;
				if button.Animations.Hover.Progress>1 then
					button.Animations.Hover.Progress = 1;
				end;
			end;
			button.Animations.Hover.Switch = ButtonAnimationHandler;
			addEventHandler("onClientRender",root,ButtonAnimationHandler);
		end,
		Leaving = function(button)
			local function ButtonAnimationHandler()
				local CurrentHoverTransparency = Interpolate(0,1,button.Animations.Hover.Progress,"Quadratic","InOut");
				if IsElement(button.Hover) then
					button.Hover:setAlpha(CurrentHoverTransparency);
				end;
				if button.Animations.Hover.Progress<=0 then
					button.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,ButtonAnimationHandler);
				end;
				button.Animations.Hover.Progress = button.Animations.Hover.Progress-0.1;
				if button.Animations.Hover.Progress<0 then
					button.Animations.Hover.Progress = 0;
				end;
			end;
			button.Animations.Hover.Switch = ButtonAnimationHandler;
			addEventHandler("onClientRender",root,ButtonAnimationHandler);
		end;
	},
	Enable = {
		Disabling = function(button)
			if IsElement(button.Hover) then
				button.Hover:setEnabled(false);
			end;
			local DisableIdleColor = button.Functions.DisableIdleColor;
			local function ButtonAnimationHandler()
				local CurrentIdleColorRed,CurrentIdleColorGreen,CurrentIdleColorBlue = Interpolate3(255,DisableIdleColor[1],255,DisableIdleColor[2],255,DisableIdleColor[3],button.Animations.Enable.Progress,"Quadratic","InOut");
				local CurrentIdleColor = ConvertRGBToHex(CurrentIdleColorRed,CurrentIdleColorGreen,CurrentIdleColorBlue);
				if IsElement(button.Idle) then
					button.Idle:setProperty("ImageColours","tl:FF"..CurrentIdleColor.." tr:FF"..CurrentIdleColor.." bl:FF"..CurrentIdleColor.." br:FF"..CurrentIdleColor);
				end;
				if button.Animations.Enable.Progress>=1 then
					button.Animations.Enable.Switch = nil;
					removeEventHandler("onClientRender",root,ButtonAnimationHandler);
				end;
				button.Animations.Enable.Progress = button.Animations.Enable.Progress+0.075;
				if button.Animations.Enable.Progress>1 then
					button.Animations.Enable.Progress = 1;
				end;
			end;
			button.Animations.Enable.Switch = ButtonAnimationHandler;
			addEventHandler("onClientRender",root,ButtonAnimationHandler);
		end,
		Enabling = function(button)
			local DisableIdleColor = button.Functions.DisableIdleColor;
			local function ButtonAnimationHandler()
				local CurrentIdleColorRed,CurrentIdleColorGreen,CurrentIdleColorBlue = Interpolate3(255,DisableIdleColor[1],255,DisableIdleColor[2],255,DisableIdleColor[3],button.Animations.Enable.Progress,"Quadratic","InOut");
				local CurrentIdleColor = ConvertRGBToHex(CurrentIdleColorRed,CurrentIdleColorGreen,CurrentIdleColorBlue);
				if IsElement(button.Idle) then
					button.Idle:setProperty("ImageColours","tl:FF"..CurrentIdleColor.." tr:FF"..CurrentIdleColor.." bl:FF"..CurrentIdleColor.." br:FF"..CurrentIdleColor);
				end;
				if button.Animations.Enable.Progress<=0 then
					button.Animations.Enable.Switch = nil;
					removeEventHandler("onClientRender",root,ButtonAnimationHandler);
					if IsElement(button.Hover) then
						button.Hover:setEnabled(true);
					end;
				end;
				button.Animations.Enable.Progress = button.Animations.Enable.Progress-0.075;
				if button.Animations.Enable.Progress<0 then
					button.Animations.Enable.Progress = 0;
				end;
			end;
			button.Animations.Enable.Switch = ButtonAnimationHandler;
			addEventHandler("onClientRender",root,ButtonAnimationHandler);
		end;
	};
};

GUI.Button.Radio.Animations = {
	Hover = {
		Entering = function(button)
			local function BoxAnimationHandler()
				local CurrentCheckFrameTransparency = Interpolate(0,1,button.Animations.Hover.Progress,"Quadratic","InOut");
				if IsElement(button.CheckFrame) then
					button.CheckFrame:setAlpha(CurrentCheckFrameTransparency);
				end;
				if button.Animations.Hover.Progress>=1 then
					button.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				button.Animations.Hover.Progress = button.Animations.Hover.Progress+0.125;
				if button.Animations.Hover.Progress>1 then
					button.Animations.Hover.Progress = 1;
				end;
			end;
			button.Animations.Hover.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end,
		Leaving = function(button)
			local function BoxAnimationHandler()
				local CurrentCheckFrameTransparency = Interpolate(0,1,button.Animations.Hover.Progress,"Quadratic","InOut");
				if IsElement(button.CheckFrame) then
					button.CheckFrame:setAlpha(CurrentCheckFrameTransparency);
				end;
				if button.Animations.Hover.Progress<=0 then
					button.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				button.Animations.Hover.Progress = button.Animations.Hover.Progress-0.125;
				if button.Animations.Hover.Progress<0 then
					button.Animations.Hover.Progress = 0;
				end;
			end;
			button.Animations.Hover.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end;
	},
	Select = {
		Checking = function(button)
			local CheckFrameColor = button.Functions.CheckFrameColor;
			local function BoxAnimationHandler()
				local CurrentCheckFrameColorRed,CurrentCheckFrameColorGreen,CurrentCheckFrameColorBlue = Interpolate3(CheckFrameColor[1][1],CheckFrameColor[2][1],CheckFrameColor[1][2],CheckFrameColor[2][2],CheckFrameColor[1][3],CheckFrameColor[2][3],button.Animations.Select.Progress,"Quadratic","InOut");
				local CurrentCheckFrameColor = ConvertRGBToHex(CurrentCheckFrameColorRed,CurrentCheckFrameColorGreen,CurrentCheckFrameColorBlue);
				if IsElement(button.CheckFrame) then
					button.CheckFrame:setProperty("ImageColours","tl:FF"..CurrentCheckFrameColor.." tr:FF"..CurrentCheckFrameColor.." bl:FF"..CurrentCheckFrameColor.." br:FF"..CurrentCheckFrameColor);
				end;
				if button.Animations.Select.Progress>=1 then
					button.Animations.Select.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				button.Animations.Select.Progress = button.Animations.Select.Progress+0.25;
				if button.Animations.Select.Progress>1 then
					button.Animations.Select.Progress = 1;
				end;
			end;
			button.Animations.Select.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end,
		Unchecking = function(button)
			local CheckFrameColor = button.Functions.CheckFrameColor;
			local function BoxAnimationHandler()
				local CurrentCheckFrameColorRed,CurrentCheckFrameColorGreen,CurrentCheckFrameColorBlue = Interpolate3(CheckFrameColor[1][1],CheckFrameColor[2][1],CheckFrameColor[1][2],CheckFrameColor[2][2],CheckFrameColor[1][3],CheckFrameColor[2][3],button.Animations.Select.Progress,"Quadratic","InOut");
				local CurrentCheckFrameColor = ConvertRGBToHex(CurrentCheckFrameColorRed,CurrentCheckFrameColorGreen,CurrentCheckFrameColorBlue);
				if IsElement(button.CheckFrame) then
					button.CheckFrame:setProperty("ImageColours","tl:FF"..CurrentCheckFrameColor.." tr:FF"..CurrentCheckFrameColor.." bl:FF"..CurrentCheckFrameColor.." br:FF"..CurrentCheckFrameColor);
				end;
				if button.Animations.Select.Progress<=0 then
					button.Animations.Select.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				button.Animations.Select.Progress = button.Animations.Select.Progress-0.25;
				if button.Animations.Select.Progress<0 then
					button.Animations.Select.Progress = 0;
				end;
			end;
			button.Animations.Select.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end;
	};
};

GUI.Bar.Progress.Animations = {
	Shine = {
		Horizontal = function(bar)
			local StartTick,MovementDuration = getTickCount(),2500;
			local MovementEndTick = StartTick+MovementDuration;
			local function MovementHandler()
				local CurrentTick = getTickCount();
				local Progress = (CurrentTick-StartTick)/MovementDuration;
				if Progress>1 then
					Progress = 1;
				end;
				local CurrentShinePositionX = Interpolate(bar.Functions.ShineBoundaries[1],bar.Functions.ShineBoundaries[2],Progress,"Sinusoidal","InOut");
				if IsElement(bar.Shine) then
					bar.Shine:setPosition(CurrentShinePositionX,0,false);
				end;
				if CurrentTick>=MovementEndTick then
					removeEventHandler("onClientRender",root,MovementHandler);
				end;
			end;
			addEventHandler("onClientRender",root,MovementHandler);
		end,
		Vertical = function(bar)
			local StartTick,MovementDuration = getTickCount(),2500;
			local MovementEndTick = StartTick+MovementDuration;
			local function MovementHandler()
				local CurrentTick = getTickCount();
				local Progress = (CurrentTick-StartTick)/MovementDuration;
				if Progress>1 then
					Progress = 1;
				end;
				local CurrentShinePositionY = Interpolate(bar.Functions.ShineBoundaries[1],bar.Functions.ShineBoundaries[2],Progress,"Sinusoidal","InOut");
				if IsElement(bar.Shine) then
					bar.Shine:setPosition(0,CurrentShinePositionY,false);
				end;
				if CurrentTick>=MovementEndTick then
					removeEventHandler("onClientRender",root,MovementHandler);
				end;
			end;
			addEventHandler("onClientRender",root,MovementHandler);
		end;
	},
	Marquee = {
		Horizontal = function(bar)
			local StartTick,MovementDuration = getTickCount(),1500;
			local MovementEndTick = StartTick+MovementDuration;
			local function MovementHandler()
				local CurrentTick = getTickCount();
				local Progress = (CurrentTick-StartTick)/MovementDuration;
				if Progress>1 then
					Progress = 1;
				end;
				local CurrentProgressFramePositionX = Interpolate(bar.Functions.MarqueeBoundaries[1],bar.Functions.MarqueeBoundaries[2],Progress,"Linear");
				if IsElement(bar.ProgressFrame) and isTimer(bar.Functions.MarqueeTimer) then
					bar.ProgressFrame:setPosition(CurrentProgressFramePositionX,1,false);
				end;
				if CurrentTick>=MovementEndTick then
					removeEventHandler("onClientRender",root,MovementHandler);
				end;
			end;
			addEventHandler("onClientRender",root,MovementHandler);
		end,
		Vertical = function(bar)
			local StartTick,MovementDuration = getTickCount(),1500;
			local MovementEndTick = StartTick+MovementDuration;
			local function MovementHandler()
				local CurrentTick = getTickCount();
				local Progress = (CurrentTick-StartTick)/MovementDuration;
				if Progress>1 then
					Progress = 1;
				end;
				local CurrentProgressFramePositionY = Interpolate(bar.Functions.MarqueeBoundaries[1],bar.Functions.MarqueeBoundaries[2],Progress,"Linear");
				if IsElement(bar.ProgressFrame) and isTimer(bar.Functions.MarqueeTimer) then
					bar.ProgressFrame:setPosition(1,CurrentProgressFramePositionY,false);
				end;
				if CurrentTick>=MovementEndTick then
					removeEventHandler("onClientRender",root,MovementHandler);
				end;
			end;
			addEventHandler("onClientRender",root,MovementHandler);
		end;
	};
};

GUI.Bar.Scroll.Animations = {
	Hover = {
		Entering = function(bar)
			local ProgressFrameColor = bar.Animations.Hover.ProgressFrameColor;
			local function BarAnimationHandler()
				local CurrentProgressFrameColorRed,CurrentProgressFrameColorGreen,CurrentProgressFrameColorBlue = Interpolate3(ProgressFrameColor[1][1],ProgressFrameColor[2][1],ProgressFrameColor[1][2],ProgressFrameColor[2][2],ProgressFrameColor[1][3],ProgressFrameColor[2][3],bar.Animations.Hover.Progress,"Quadratic","InOut");
				local CurrentProgressFrameColor = ConvertRGBToHex(CurrentProgressFrameColorRed,CurrentProgressFrameColorGreen,CurrentProgressFrameColorBlue);
				if IsElement(bar.ProgressFrame) then
					bar.ProgressFrame:setProperty("ImageColours","tl:FF"..CurrentProgressFrameColor.." tr:FF"..CurrentProgressFrameColor.." bl:FF"..CurrentProgressFrameColor.." br:FF"..CurrentProgressFrameColor);
				end;
				if bar.Animations.Hover.Progress>=1 then
					bar.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,BarAnimationHandler);
				end;
				bar.Animations.Hover.Progress = bar.Animations.Hover.Progress+0.1;
				if bar.Animations.Hover.Progress>1 then
					bar.Animations.Hover.Progress = 1;
				end;
			end;
			bar.Animations.Hover.Switch = BarAnimationHandler;
			addEventHandler("onClientRender",root,BarAnimationHandler);
		end,
		Leaving = function(bar)
			local ProgressFrameColor = bar.Animations.Hover.ProgressFrameColor;
			local function BarAnimationHandler()
				local CurrentProgressFrameColorRed,CurrentProgressFrameColorGreen,CurrentProgressFrameColorBlue = Interpolate3(ProgressFrameColor[1][1],ProgressFrameColor[2][1],ProgressFrameColor[1][2],ProgressFrameColor[2][2],ProgressFrameColor[1][3],ProgressFrameColor[2][3],bar.Animations.Hover.Progress,"Quadratic","InOut");
				local CurrentProgressFrameColor = ConvertRGBToHex(CurrentProgressFrameColorRed,CurrentProgressFrameColorGreen,CurrentProgressFrameColorBlue);
				if IsElement(bar.ProgressFrame) then
					bar.ProgressFrame:setProperty("ImageColours","tl:FF"..CurrentProgressFrameColor.." tr:FF"..CurrentProgressFrameColor.." bl:FF"..CurrentProgressFrameColor.." br:FF"..CurrentProgressFrameColor);
				end;
				if bar.Animations.Hover.Progress<=0 then
					bar.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,BarAnimationHandler);
				end;
				bar.Animations.Hover.Progress = bar.Animations.Hover.Progress-0.1;
				if bar.Animations.Hover.Progress<0 then
					bar.Animations.Hover.Progress = 0;
				end;
			end;
			bar.Animations.Hover.Switch = BarAnimationHandler;
			addEventHandler("onClientRender",root,BarAnimationHandler);
		end;
	};
};

GUI.Box.Check.Animations = {
	Hover = {
		Entering = function(box)
			local function BoxAnimationHandler()
				local CurrentCheckFrameTransparency = Interpolate(0,1,box.Animations.Hover.Progress,"Quadratic","InOut");
				if IsElement(box.CheckFrame) then
					box.CheckFrame:setAlpha(CurrentCheckFrameTransparency);
				end;
				if box.Animations.Hover.Progress>=1 then
					box.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				box.Animations.Hover.Progress = box.Animations.Hover.Progress+0.125;
				if box.Animations.Hover.Progress>1 then
					box.Animations.Hover.Progress = 1;
				end;
			end;
			box.Animations.Hover.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end,
		Leaving = function(box)
			local function BoxAnimationHandler()
				local CurrentCheckFrameTransparency = Interpolate(0,1,box.Animations.Hover.Progress,"Quadratic","InOut");
				if IsElement(box.CheckFrame) then
					box.CheckFrame:setAlpha(CurrentCheckFrameTransparency);
				end;
				if box.Animations.Hover.Progress<=0 then
					box.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				box.Animations.Hover.Progress = box.Animations.Hover.Progress-0.125;
				if box.Animations.Hover.Progress<0 then
					box.Animations.Hover.Progress = 0;
				end;
			end;
			box.Animations.Hover.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end;
	},
	Select = {
		Checking = function(box)
			local CheckFrameColor = box.Functions.CheckFrameColor;
			local function BoxAnimationHandler()
				local CurrentCheckFrameColorRed,CurrentCheckFrameColorGreen,CurrentCheckFrameColorBlue = Interpolate3(CheckFrameColor[1][1],CheckFrameColor[2][1],CheckFrameColor[1][2],CheckFrameColor[2][2],CheckFrameColor[1][3],CheckFrameColor[2][3],box.Animations.Select.Progress,"Quadratic","InOut");
				local CurrentCheckFrameColor = ConvertRGBToHex(CurrentCheckFrameColorRed,CurrentCheckFrameColorGreen,CurrentCheckFrameColorBlue);
				if IsElement(box.CheckFrame) then
					box.CheckFrame:setProperty("ImageColours","tl:FF"..CurrentCheckFrameColor.." tr:FF"..CurrentCheckFrameColor.." bl:FF"..CurrentCheckFrameColor.." br:FF"..CurrentCheckFrameColor);
				end;
				if box.Animations.Select.Progress>=1 then
					box.Animations.Select.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				box.Animations.Select.Progress = box.Animations.Select.Progress+0.25;
				if box.Animations.Select.Progress>1 then
					box.Animations.Select.Progress = 1;
				end;
			end;
			box.Animations.Select.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end,
		Unchecking = function(box)
			local CheckFrameColor = box.Functions.CheckFrameColor;
			local function BoxAnimationHandler()
				local CurrentCheckFrameColorRed,CurrentCheckFrameColorGreen,CurrentCheckFrameColorBlue = Interpolate3(CheckFrameColor[1][1],CheckFrameColor[2][1],CheckFrameColor[1][2],CheckFrameColor[2][2],CheckFrameColor[1][3],CheckFrameColor[2][3],box.Animations.Select.Progress,"Quadratic","InOut");
				local CurrentCheckFrameColor = ConvertRGBToHex(CurrentCheckFrameColorRed,CurrentCheckFrameColorGreen,CurrentCheckFrameColorBlue);
				if IsElement(box.CheckFrame) then
					box.CheckFrame:setProperty("ImageColours","tl:FF"..CurrentCheckFrameColor.." tr:FF"..CurrentCheckFrameColor.." bl:FF"..CurrentCheckFrameColor.." br:FF"..CurrentCheckFrameColor);
				end;
				if box.Animations.Select.Progress<=0 then
					box.Animations.Select.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				box.Animations.Select.Progress = box.Animations.Select.Progress-0.25;
				if box.Animations.Select.Progress<0 then
					box.Animations.Select.Progress = 0;
				end;
			end;
			box.Animations.Select.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end;
	};
};

GUI.Box.Combo.Animations = {
	Hover = {
		Entering = function(box)
			local PointerColor = box.Functions.ButtonFrameColor;
			local function BoxAnimationHandler()
				local CurrentPointerColorRed,CurrentPointerColorGreen,CurrentPointerColorBlue = Interpolate3(PointerColor[1][1],PointerColor[2][1],PointerColor[1][2],PointerColor[2][2],PointerColor[1][3],PointerColor[2][3],box.Animations.Hover.Progress,"Quadratic","InOut");
				local CurrentPointerColor = ConvertRGBToHex(CurrentPointerColorRed,CurrentPointerColorGreen,CurrentPointerColorBlue);
				if IsElement(box.Button.Pointer) then
					box.Button.Pointer:setProperty("ImageColours","tl:FF"..CurrentPointerColor.." tr:FF"..CurrentPointerColor.." bl:FF"..CurrentPointerColor.." br:FF"..CurrentPointerColor);
				end;
				if box.Animations.Hover.Progress>=1 then
					box.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				box.Animations.Hover.Progress = box.Animations.Hover.Progress+0.1;
				if box.Animations.Hover.Progress>1 then
					box.Animations.Hover.Progress = 1;
				end;
			end;
			box.Animations.Hover.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end,
		Leaving = function(box)
			local PointerColor = box.Functions.ButtonFrameColor;
			local function BoxAnimationHandler()
				local CurrentPointerColorRed,CurrentPointerColorGreen,CurrentPointerColorBlue = Interpolate3(PointerColor[1][1],PointerColor[2][1],PointerColor[1][2],PointerColor[2][2],PointerColor[1][3],PointerColor[2][3],box.Animations.Hover.Progress,"Quadratic","InOut");
				local CurrentPointerColor = ConvertRGBToHex(CurrentPointerColorRed,CurrentPointerColorGreen,CurrentPointerColorBlue);
				if IsElement(box.Button.Pointer) then
					box.Button.Pointer:setProperty("ImageColours","tl:FF"..CurrentPointerColor.." tr:FF"..CurrentPointerColor.." bl:FF"..CurrentPointerColor.." br:FF"..CurrentPointerColor);
				end;
				if box.Animations.Hover.Progress<=0 then
					box.Animations.Hover.Switch = nil;
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
				box.Animations.Hover.Progress = box.Animations.Hover.Progress-0.1;
				if box.Animations.Hover.Progress<0 then
					box.Animations.Hover.Progress = 0;
				end;
			end;
			box.Animations.Hover.Switch = BoxAnimationHandler;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end;
	},
	Drop = {
		Down = function(box)
			local FinalBoxSizeX,FinalBoxSizeY = box.Holder:getSize(false);
			local FinalContentPositionX = box.Elements.Content.Skeleton:getPosition(false);
			local StartTick,BoxAnimationDuration,ContentAnimationDuration = getTickCount(),750,750;
			local BoxAnimationEndTick = StartTick+BoxAnimationDuration;
			local ContentAnimationEndTick = BoxAnimationEndTick+ContentAnimationDuration;
			if IsElement(box.Button.Pointer) and IsElement(box.Elements.Skeleton) then
				box.Button.Pointer:setEnabled(false);
				box.Elements.Skeleton:setEnabled(false);
			end;
			local function ContentAnimationHandler()
				local CurrentTick = getTickCount();
				local Progress = (CurrentTick-BoxAnimationEndTick)/ContentAnimationDuration;
				if Progress>1 then
					Progress = 1;
				end;
				local CurrentContentPositionY = Interpolate(26-FinalBoxSizeY,1,Progress,"Cubic","InOut");
				if IsElement(box.Elements.Content.Skeleton) then
					box.Elements.Content.Skeleton:setPosition(FinalContentPositionX,CurrentContentPositionY,false);
				end;
				if CurrentTick>=ContentAnimationEndTick then
					removeEventHandler("onClientRender",root,ContentAnimationHandler);
					if IsElement(box.Button.Pointer) and IsElement(box.Elements.Skeleton) then
						box.Button.Pointer:setEnabled(true);
						box.Elements.Skeleton:setEnabled(true);
					end;
				end;
			end;
			local function BoxAnimationHandler()
				local CurrentTick = getTickCount();
				local Progress = (CurrentTick-StartTick)/BoxAnimationDuration;
				if Progress>1 then
					Progress = 1;
				end;
				local CurrentBoxSizeY = Interpolate(0,FinalBoxSizeY-26,Progress,"Cubic","InOut");
				if IsElement(box.Elements.Skeleton) then
					box.Elements.Skeleton:setSize(FinalBoxSizeX,CurrentBoxSizeY,false);
				end;
				if CurrentTick>=BoxAnimationEndTick then
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
					addEventHandler("onClientRender",root,ContentAnimationHandler);
				end;
			end;
			addEventHandler("onClientRender",root,BoxAnimationHandler);
		end,
		Up = function(box)
			local FinalBoxSizeX,InitialBoxSizeY = box.Holder:getSize(false);
			local FinalContentPositionX,InitialContentPositionY = box.Elements.Content.Skeleton:getPosition(false);
			local StartTick,ContentAnimationDuration,BoxAnimationDuration = getTickCount(),750,750;
			local ContentAnimationEndTick = StartTick+ContentAnimationDuration;
			local BoxAnimationEndTick = ContentAnimationEndTick+BoxAnimationDuration;
			if IsElement(box.Button.Pointer) and IsElement(box.Elements.Skeleton) then
				box.Button.Pointer:setEnabled(false);
				box.Elements.Skeleton:setEnabled(false);
			end;
			local function BoxAnimationHandler()
				local CurrentTick = getTickCount();
				local Progress = (CurrentTick-ContentAnimationEndTick)/BoxAnimationDuration;
				if Progress>1 then
					Progress = 1;
				end;
				local CurrentBoxSizeY = Interpolate(InitialBoxSizeY-26,0,Progress,"Cubic","InOut");
				if IsElement(box.Elements.Skeleton) then
					box.Elements.Skeleton:setSize(FinalBoxSizeX,CurrentBoxSizeY,false);
				end;
				if CurrentTick>=BoxAnimationEndTick then
					removeEventHandler("onClientRender",root,BoxAnimationHandler);
					if IsElement(box.Button.Pointer) and IsElement(box.Elements.Skeleton) then
						box.Button.Pointer:setEnabled(true);
						box.Elements.Skeleton:setEnabled(true);
					end;
				end;
			end;
			local function ContentAnimationHandler()
				local CurrentTick = getTickCount();
				local Progress = (CurrentTick-StartTick)/ContentAnimationDuration;
				if Progress>1 then
					Progress = 1;
				end;
				local CurrentContentPositionY = Interpolate(InitialContentPositionY,26-InitialBoxSizeY,Progress,"Cubic","InOut");
				if IsElement(box.Elements.Content.Skeleton) then
					box.Elements.Content.Skeleton:setPosition(FinalContentPositionX,CurrentContentPositionY,false);
				end;
				if CurrentTick>=ContentAnimationEndTick then
					removeEventHandler("onClientRender",root,ContentAnimationHandler);
					addEventHandler("onClientRender",root,BoxAnimationHandler);
				end;
			end;
			addEventHandler("onClientRender",root,ContentAnimationHandler);
		end;
	};
};

function GUI.Window:Create(position,size,text,drag,skeleton_color,frame_color,vignette_color,animation,parent)
	local Window = SetMetatable({
		Content = {},
		Functions = {
			FrameColor = frame_color;
		};
	},self);
	local SkeletonColor,FrameColor = ConvertRGBToHex(Unpack(skeleton_color)),{ConvertRGBToHex(Unpack(frame_color[1])),ConvertRGBToHex(Unpack(frame_color[2]))};
	Window.Skeleton = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture1.png",false,parent and parent or nil);
	Window.Skeleton:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	-- setElementCallPropagationEnabled(Window.Skeleton,false); --[[FROM VERSION 1.4]]
	Window.Header = GuiStaticImage(1,1,0,0,"Resources/Visual/Texture1.png",false,Window.Skeleton);
	Window.Header:setProperty("ImageColours","tl:FF"..FrameColor[1].." tr:FF"..FrameColor[1].." bl:FF"..FrameColor[1].." br:FF"..FrameColor[1]);
	Window.Text = GuiLabel(0,0,0,0,text,false,Window.Header);
	Window.Text:setFont("default-small");
	Window.Text:setHorizontalAlign("center",true);
	Window.Text:setVerticalAlign("center");
	Window.Frame = GuiStaticImage(1,20,0,0,"Resources/Visual/Texture1.png",false,Window.Skeleton);
	Window.Frame:setProperty("ImageColours","tl:FF"..FrameColor[1].." tr:FF"..FrameColor[1].." bl:FF"..FrameColor[1].." br:FF"..FrameColor[1]);
	if vignette_color then
		local VignetteColor = ConvertRGBToHex(Unpack(vignette_color));
		Window.Vignette = GuiStaticImage(0,0,0,0,"Resources/Visual/Vignette2.png",false,Window.Frame);
		Window.Vignette:setProperty("ImageColours","tl:FF"..VignetteColor.." tr:FF"..VignetteColor.." bl:FF"..VignetteColor.." br:FF"..VignetteColor);
		Window.Vignette:setEnabled(false);
	end;
	Window.Content.Skeleton = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture2.png",false,Window.Frame);
	if drag then
		Window.Functions.Drag = function(_,_,x,y)
			Window:SetPosition(0,x-Window.Functions.HoldOffset[1],0,y-Window.Functions.HoldOffset[2]);
		end;
		Window.Functions.MouseDown = function(button,x,y)
			if button == "left" then
				Window.Functions.HoldOffset = {x-Window.Functions.AbsoluteHeaderPosition[1],y-Window.Functions.AbsoluteHeaderPosition[2]};
				addEventHandler("onClientKey",root,Window.Functions.MouseUp);
				addEventHandler("onClientCursorMove",root,Window.Functions.Drag);
			end;
		end;
		Window.Functions.MouseUp = function(key,press)
			if key == "mouse1" and not press then
				removeEventHandler("onClientKey",root,Window.Functions.MouseUp);
				removeEventHandler("onClientCursorMove",root,Window.Functions.Drag);
			end;
		end;
		addEventHandler("onClientGUIMouseDown",Window.Text,Window.Functions.MouseDown,false);
	end;
	if animation then
		Window.Animations = {
			Focus = {
				Switch = nil,
				Progress = 0;
			};
		};
		Window.Functions.Focus = function()
			local Animation = eventName == "onClientGUIFocus" and "Focusing" or eventName == "onClientGUIBlur" and "Blurring";
			if Window.Animations.Focus.Switch then
				removeEventHandler("onClientRender",root,Window.Animations.Focus.Switch);
			end;
			self.Animations.Focus[Animation](Window);
		end;
	else
		Window.Functions.Focus = function()
			local Color = eventName == "onClientGUIFocus" and FrameColor[2] or eventName == "onClientGUIBlur" and FrameColor[1];
			Window.Header:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
			Window.Frame:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
		end;
	end;
	Window:SetPosition(position[1],position[2],position[3],position[4]);
	Window:SetSize(size[1],size[2],size[3],size[4]);
	addEventHandler("onClientGUIFocus",Window.Skeleton,Window.Functions.Focus,false);
	addEventHandler("onClientGUIBlur",Window.Skeleton,Window.Functions.Focus,false);
	return Window;
end;

function GUI.Window:SetPosition(sx,ox,sy,oy)
	local Parent = self.Skeleton:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	self.Skeleton:setPosition(ox+ParentSizeX*sx,oy+ParentSizeY*sy,false);
	self.Functions.AbsoluteHeaderPosition = {GetGUIAbsolutePosition(self.Header)};
end;

function GUI.Window:SetSize(sx,ox,sy,oy)
	local Parent = self.Skeleton:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	local SizeX,SizeY = ox+ParentSizeX*sx,oy+ParentSizeY*sy;
	self.Skeleton:setSize(SizeX,SizeY,false);
	self.Header:setSize(SizeX-2,18,false);
	self.Text:setSize(SizeX-2,18,false);
	self.Frame:setSize(SizeX-2,SizeY-21,false);
	if self.Vignette then
		self.Vignette:setSize(SizeX-2,SizeY-21,false);
	end;
	self.Content.Skeleton:setSize(SizeX-2,SizeY-21,false);
end;

function GUI.Window:Destroy()
	for _,element in Pairs(self.Content) do
		if Type(element) == "table" then
			element:Destroy();
		end;
	end;
	if IsElement(self.Skeleton) then
		self.Skeleton:destroy();
	end;
	self = nil;
end;

function GUI.Button.Default:Create(position,size,text,skeleton_color,frame_color,disable_frame_color,animation,parent)
	local Button = {
		OnClick = {},
		Functions = {
			FrameColor = frame_color;
		};
	};
	SetMetatable(Button,self);
	local SkeletonColor,FrameColor,DisableFrameColor = ConvertRGBToHex(Unpack(skeleton_color)),{ConvertRGBToHex(Unpack(frame_color[1])),ConvertRGBToHex(Unpack(frame_color[2]))},ConvertRGBToHex(Unpack(disable_frame_color));
	Button.Skeleton = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture1.png",false,parent and parent or nil);
	Button.Skeleton:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	Button.Frame = GuiStaticImage(1,1,0,0,"Resources/Visual/Texture1.png",false,Button.Skeleton);
	Button.Frame:setProperty("ImageColours","tl:FF"..FrameColor[1].." tr:FF"..FrameColor[1].." bl:FF"..FrameColor[1].." br:FF"..FrameColor[1]);
	Button.Frame:setEnabled(false);
	Button.DisableFrame = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture1.png",false,Button.Frame);
	Button.DisableFrame:setProperty("ImageColours","tl:FF"..DisableFrameColor.." tr:FF"..DisableFrameColor.." bl:FF"..DisableFrameColor.." br:FF"..DisableFrameColor);
	Button.DisableFrame:setAlpha(0);
	Button.Text = GuiLabel(1,1,0,0,text,false,Button.Skeleton);
	Button.Text:setHorizontalAlign("center",true);
	Button.Text:setVerticalAlign("center");
	if animation then
		Button.Animations = {
			Hover = {
				Switch = nil,
				Progress = 0;
			},
			Enable = {
				Switch = nil,
				Progress = 0;
			};
		};
		Button.Functions.Hover = function()
			local Animation = eventName == "onClientMouseEnter" and "Entering" or eventName == "onClientMouseLeave" and "Leaving";
			if Button.Animations.Hover.Switch then
				removeEventHandler("onClientRender",root,Button.Animations.Hover.Switch);
			end;
			self.Animations.Hover[Animation](Button);
			if eventName == "onClientMouseEnter" then
				Sound("Resources/Audio/Button1.ogg"):setVolume(1);
			end;
		end;
		Button.Functions.Enable = function(enable)
			local Animation = not enable and "Disabling" or enable and "Enabling";
			if self.Animations.Enable.Switch then
				removeEventHandler("onClientRender",root,self.Animations.Enable.Switch);
			end;
			self.Animations.Enable[Animation](Button);
		end;
	else
		Button.Functions.Hover = function()
			local Color = eventName == "onClientMouseEnter" and FrameColor[2] or eventName == "onClientMouseLeave" and FrameColor[1];
			Button.Frame:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
			if eventName == "onClientMouseEnter" then
				Sound("Resources/Audio/Button1.ogg"):setVolume(1);
			end;
		end;
		Button.Functions.Enable = function(enable)
			local Alpha = not enable and 1 or enable and 0;
			Button.DisableFrame:setAlpha(Alpha);
			Button.Text:setEnabled(enable);
		end;
	end;
	Button.Functions.Click = function()
		if Next(Button.OnClick) then
			for _,v in Pairs(Button.OnClick) do
				v(Button);
			end;
		end;
		Sound("Resources/Audio/Button2.ogg"):setVolume(1);
	end;
	Button:SetPosition(position[1],position[2],position[3],position[4]);
	Button:SetSize(size[1],size[2],size[3],size[4]);
	addEventHandler("onClientMouseEnter",Button.Text,Button.Functions.Hover,false);
	addEventHandler("onClientMouseLeave",Button.Text,Button.Functions.Hover,false);
	addEventHandler("onClientGUIClick",Button.Text,Button.Functions.Click,false);
	return Button;
end;

function GUI.Button.Default:SetPosition(sx,ox,sy,oy)
	local Parent = self.Skeleton:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	self.Skeleton:setPosition(ox+ParentSizeX*sx,oy+ParentSizeY*sy,false);
end;

function GUI.Button.Default:SetSize(sx,ox,sy,oy)
	local Parent = self.Skeleton:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	local SizeX,SizeY = ox+ParentSizeX*sx,oy+ParentSizeY*sy;
	self.Skeleton:setSize(SizeX,SizeY,false);
	self.Frame:setSize(SizeX-2,SizeY-2,false);
	self.DisableFrame:setSize(SizeX-2,SizeY-2,false);
	self.Text:setSize(SizeX-2,SizeY-2,false);
end;

function GUI.Button.Default:SetEnabled(enabled)
	self.Functions.Enable(enabled);
end;

function GUI.Button.Default:Destroy()
	if IsElement(self.Skeleton) then
		self.Skeleton:destroy();
	end;
	self = nil;
end;

function GUI.Button.Image:Create(position,size,image,disable_idle_color,animation,parent)
	local Button = {
		OnClick = {},
		Functions = {
			DisableIdleColor = disable_idle_color;
		};
	};
	SetMetatable(Button,self);
	local DisableIdleColor = ConvertRGBToHex(Unpack(disable_idle_color));
	Button.Idle = GuiStaticImage(0,0,0,0,image[1],false,parent and parent or nil);
	Button.Hover = GuiStaticImage(0,0,0,0,image[2],false,Button.Idle);
	Button.Hover:setAlpha(0);
	if animation then
		Button.Animations = {
			Hover = {
				Switch = nil,
				Progress = 0;
			},
			Enable = {
				Switch = nil,
				Progress = 0;
			};
		};
		Button.Functions.Hover = function()
			local Animation = eventName == "onClientMouseEnter" and "Entering" or eventName == "onClientMouseLeave" and "Leaving";
			if Button.Animations.Hover.Switch then
				removeEventHandler("onClientRender",root,Button.Animations.Hover.Switch);
			end;
			self.Animations.Hover[Animation](Button);
			if eventName == "onClientMouseEnter" then
				Sound("Resources/Audio/Button1.ogg"):setVolume(1);
			end;
		end;
		Button.Functions.Enable = function(enable)
			local Animation = not enable and "Disabling" or enable and "Enabling";
			if Button.Animations.Enable.Switch then
				removeEventHandler("onClientRender",root,Button.Animations.Enable.Switch);
			end;
			self.Animations.Enable[Animation](Button);
		end;
	else
		Button.Functions.Hover = function()
			local Alpha = eventName == "onClientMouseEnter" and 1 or eventName == "onClientMouseLeave" and 0;
			Button.Hover:setAlpha(Alpha);
			if eventName == "onClientMouseEnter" then
				Sound("Resources/Audio/Button1.ogg"):setVolume(1);
			end;
		end;
		Button.Functions.Enable = function(enable)
			local Color = not enable and DisableIdleColor or enable and "FFFFFF";
			Button.Idle:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
			Button.Hover:setEnabled(enable);
		end;
	end;
	Button.Functions.Click = function()
		if Next(Button.OnClick) then
			for _,v in Pairs(Button.OnClick) do
				v(Button);
			end;
		end;
		Sound("Resources/Audio/Button2.ogg"):setVolume(1);
	end;
	Button:SetPosition(position[1],position[2],position[3],position[4]);
	Button:SetSize(size[1],size[2],size[3],size[4]);
	addEventHandler("onClientMouseEnter",Button.Hover,Button.Functions.Hover,false);
	addEventHandler("onClientMouseLeave",Button.Hover,Button.Functions.Hover,false);
	addEventHandler("onClientGUIClick",Button.Hover,Button.Functions.Click,false);
	return Button;
end;

function GUI.Button.Image:SetPosition(sx,ox,sy,oy)
	local Parent = self.Idle:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	self.Idle:setPosition(ox+ParentSizeX*sx,oy+ParentSizeY*sy,false);
end;

function GUI.Button.Image:SetSize(sx,ox,sy,oy)
	local Parent = self.Idle:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	local SizeX,SizeY = ox+ParentSizeX*sx,oy+ParentSizeY*sy;
	self.Idle:setSize(SizeX,SizeY,false);
	self.Hover:setSize(SizeX,SizeY,false);
end;

function GUI.Button.Image:SetEnabled(enabled)
	self.Functions.Enable(enabled);
end;

function GUI.Button.Image:Destroy()
	if IsElement(self.Idle) then
		self.Idle:destroy();
	end;
	self = nil;
end;

function GUI.Button.Radio:Create(position,size,text,alignment,skeleton_color,frame_color,check_frame_color,animation,parent)
	local Button = {
		OnCheck = {},
		Functions = {
			Alignment = alignment,
			Checked = false,
			CheckFrameColor = check_frame_color;
		};
	};
	SetMetatable(Button,self);
	local SkeletonColor,FrameColor,CheckFrameColor = ConvertRGBToHex(Unpack(skeleton_color)),ConvertRGBToHex(Unpack(frame_color)),{ConvertRGBToHex(Unpack(check_frame_color[1])),ConvertRGBToHex(Unpack(check_frame_color[2]))};
	Button.Holder = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture2.png",false,parent and parent or nil);
	Button.Skeleton = GuiStaticImage(0,0,16,16,"Resources/Visual/Circle.png",false,Button.Holder);
	Button.Skeleton:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	Button.Frame = GuiStaticImage(1,1,14,14,"Resources/Visual/Circle.png",false,Button.Skeleton);
	Button.Frame:setProperty("ImageColours","tl:FF"..FrameColor.." tr:FF"..FrameColor.." bl:FF"..FrameColor.." br:FF"..FrameColor);
	Button.CheckFrame = GuiStaticImage(4,4,6,6,"Resources/Visual/Circle.png",false,Button.Frame);
	Button.CheckFrame:setProperty("ImageColours","tl:FF"..CheckFrameColor[1].." tr:FF"..CheckFrameColor[1].." bl:FF"..CheckFrameColor[1].." br:FF"..CheckFrameColor[1]);
	Button.CheckFrame:setAlpha(0);
	if text then
		Button.Text = GuiLabel(20,0,0,0,text,false,Button.Holder);
		Button.Text:setFont("default-small");
	end;
	if animation then
		Button.Animations = {
			Hover = {
				Switch = nil,
				Progress = 0;
			},
			Select = {
				Switch = nil,
				Progress = 0;
			};
		};
		Button.Functions.Hover = function(animation)
			if not Button.Functions.Checked then
				local Animation = eventName == "onClientMouseEnter" and "Entering" or eventName == "onClientMouseLeave" and "Leaving";
				if Button.Animations.Hover.Switch then
					removeEventHandler("onClientRender",root,Button.Animations.Hover.Switch);
				end;
				self.Animations.Hover[Animation](Button);
				if eventName == "onClientMouseEnter" then
					Sound("Resources/Audio/Button1.ogg"):setVolume(1);
				end;
			end;
		end;
		Button.Functions.Check = function(button)
			if button == "left" then
				local Checked = not Button.Functions.Checked;
				local Animation = Checked and "Checking" or not Checked and "Unchecking";
				if Button.Animations.Select.Switch then
					removeEventHandler("onClientRender",root,Button.Animations.Select.Switch);
				end;
				self.Animations.Select[Animation](Button);
				Button.Functions.Checked = Checked;
				if Button.Functions.Overtake and Checked then
					Button.Functions.Overtake();
				end;
				if Next(Button.OnCheck) then
					for _,v in Pairs(Button.OnCheck) do
						v(Button);
					end;
				end;
				Sound("Resources/Audio/Key1.ogg"):setVolume(1);
			end;
		end;
	else
		Button.Functions.Hover = function(alpha)
			if not Button.Functions.Checked then
				local Alpha = eventName == "onClientMouseEnter" and 1 or eventName == "onClientMouseLeave" and 0;
				Button.CheckFrame:setAlpha(Alpha);
				if eventName == "onClientMouseEnter" then
					Sound("Resources/Audio/Button1.ogg"):setVolume(1);
				end;
			end;
		end;
		Button.Functions.Check = function(button)
			if button == "left" then
				local Checked = not Button.Functions.Checked;
				local Color = Checked and CheckFrameColor[2] or not Checked and CheckFrameColor[1];
				Button.CheckFrame:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
				Button.Functions.Checked = Checked;
				if Button.Functions.Overtake and Checked then
					Button.Functions.Overtake();
				end;
				if Next(Button.OnCheck) then
					for _,v in Pairs(Button.OnCheck) do
						v(Button);
					end;
				end;
				Sound("Resources/Audio/Key1.ogg"):setVolume(1);
			end;
		end;
	end;
	Button:SetPosition(position[1],position[2],position[3],position[4]);
	Button:SetSize(size[1],size[2],size[3],size[4]);
	addEventHandler("onClientMouseEnter",Button.CheckFrame,Button.Functions.Hover,false);
	addEventHandler("onClientMouseLeave",Button.CheckFrame,Button.Functions.Hover,false);
	addEventHandler("onClientGUIClick",Button.CheckFrame,Button.Functions.Check,false);
	return Button;
end;

function GUI.Button.Radio:SetPosition(sx,ox,sy,oy)
	local Parent = self.Holder:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	self.Holder:setPosition(ox+ParentSizeX*sx,oy+ParentSizeY*sy,false);
end;

function GUI.Button.Radio:SetSize(sx,ox,sy,oy)
	local Parent = self.Holder:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	local SizeX,SizeY = ox+ParentSizeX*sx,oy+ParentSizeY*sy;
	self.Holder:setSize(SizeX,SizeY,false);
	self:SetAlignment(self.Functions.Alignment[1],self.Functions.Alignment[2],self.Functions.Alignment[3]);
end;

function GUI.Button.Radio:SetAlignment(direction,horizontal_align,vertical_align)
	local HolderSizeX,HolderSizeY = self.Holder:getSize(false);
	if direction == "up" then
		self.Skeleton:setPosition((HolderSizeX-16)/2,0,false);
		if self.Text then
			self.Text:setPosition(0,20,false);
			self.Text:setSize(HolderSizeX,HolderSizeY-20,false);
		end;
	elseif direction == "right" then
		self.Skeleton:setPosition(HolderSizeX-16,(HolderSizeY-16)/2,false);
		if self.Text then
			self.Text:setPosition(0,0,false);
			self.Text:setSize(HolderSizeX-20,HolderSizeY,false);
		end;
	elseif direction == "down" then
		self.Skeleton:setPosition((HolderSizeX-16)/2,HolderSizeY-16,false);
		if self.Text then
			self.Text:setPosition(0,0,false);
			self.Text:setSize(HolderSizeX,HolderSizeY-20,false);
		end;
	elseif direction == "left" then
		self.Skeleton:setPosition(0,(HolderSizeY-16)/2,false);
		if self.Text then
			self.Text:setPosition(20,0,false);
			self.Text:setSize(HolderSizeX-20,HolderSizeY,false);
		end;
	end;
	if self.Text then
		self.Text:setHorizontalAlign(horizontal_align,true);
		self.Text:setVerticalAlign(vertical_align);
	end;
	self.Functions.Alignment = {direction,horizontal_align,vertical_align};
end;

function GUI.Button.Radio:SetChecked(checked)
	if RawGet(self,"Animations") then
		local Animations,Class = checked and {"Entering","Checking"} or not checked and {"Leaving","Unchecking"},GetMetatable(self).Animations;
		if self.Animations.Hover.Switch then
			removeEventHandler("onClientRender",root,self.Animations.Hover.Switch);
		end;
		Class.Hover[Animations[1]](self);
		if self.Animations.Select.Switch then
			removeEventHandler("onClientRender",root,self.Animations.Select.Switch);
		end;
		Class.Select[Animations[2]](self);
		self.Functions.Checked = checked;
		if self.Functions.Overtake and checked then
			self.Functions.Overtake();
		end;
		if Next(self.OnCheck) then
			for _,v in Pairs(self.OnCheck) do
				v(self);
			end;
		end;
	else
		local Color = checked and ConvertRGBToHex(self.Functions.CheckFrameColor[2]) or not checked and ConvertRGBToHex(self.Functions.CheckFrameColor[1]);
		self.CheckFrame:setAlpha(checked and 1 or not checked and 0);
		self.CheckFrame:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
		self.Functions.Checked = checked;
		if self.Functions.Overtake and checked then
			self.Functions.Overtake();
		end;
		if Next(self.OnCheck) then
			for _,v in Pairs(self.OnCheck) do
				v(self);
			end;
		end;
	end;
end;

function GUI.Button.Radio:Link(...)
	local Buttons = {};
	table.insert(Buttons,self);
	for _,button in IndexedPairs({...}) do
		table.insert(Buttons,button);
	end;
	for _,button in IndexedPairs(Buttons) do
		button.Functions.Link = Buttons;
		button.Functions.Overtake = function()
			for _,v in IndexedPairs(Buttons) do
				if IsElement(v.Skeleton) then
					if v ~= button and v.Functions.Checked then
						v:SetChecked(false);
					end;
				else
					v:Destroy();
				end;
			end;
		end;
	end;
end;

function GUI.Button.Radio:Unlink(...)
	local Buttons = {};
	table.insert(Buttons,self);
	for _,button in IndexedPairs({...}) do
		table.insert(Buttons,v);
	end;
	for _,button in IndexedPairs(Buttons) do
		button.Functions.Link = nil;
		button.Functions.Overtake = nil;
	end;
end;

function GUI.Button.Radio:Destroy()
	if self.Functions.Link then
		for k,v in IndexedPairs(self.Functions.Link) do
			if v == self then
				table.remove(self.Functions.Link,k);
			end;
		end;
	end;
	if IsElement(self.Holder) then
		self.Holder:destroy();
	end;
	self = nil;
end;

function GUI.Bar.Progress:Create(position,size,orientation,skeleton_color,frame_color,progress_frame_color,shine_color,parent)
	local Bar = {
		Functions = {
			Orientation = orientation,
			Progress = 0,
			Style = "Progress";
		};
	};
	SetMetatable(Bar,self);
	local SkeletonColor,FrameColor,ProgressFrameColor = ConvertRGBToHex(Unpack(skeleton_color)),ConvertRGBToHex(Unpack(frame_color)),ConvertRGBToHex(Unpack(progress_frame_color));
	Bar.Skeleton = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture1.png",false,parent and parent or nil);
	Bar.Skeleton:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	Bar.Frame = GuiStaticImage(1,1,0,0,"Resources/Visual/Texture1.png",false,Bar.Skeleton);
	Bar.Frame:setProperty("ImageColours","tl:FF"..FrameColor.." tr:FF"..FrameColor.." bl:FF"..FrameColor.." br:FF"..FrameColor);
	Bar.Frame:setEnabled(false);
	Bar.ProgressFrame = GuiStaticImage(1,1,0,0,"Resources/Visual/Texture1.png",false,Bar.Frame);
	Bar.ProgressFrame:setProperty("ImageColours","tl:FF"..ProgressFrameColor.." tr:FF"..ProgressFrameColor.." bl:FF"..ProgressFrameColor.." br:FF"..ProgressFrameColor);
	if shine_color then
		local ShineColor = ConvertRGBToHex(Unpack(shine_color));
		Bar.Shine = GuiStaticImage(0,0,0,0,orientation and "Resources/Visual/Shine1.png" or not orientation and "Resources/Visual/Shine2.png",false,Bar.ProgressFrame);
		Bar.Shine:setProperty("ImageColours","tl:FF"..ShineColor.." tr:FF"..ShineColor.." bl:FF"..ShineColor.." br:FF"..ShineColor);
		Bar.Functions.Shine = function()
			if not IsElement(Bar.Shine) and IsTimer(Bar.Functions.ShineTimer) then
				Bar.Functions.ShineTimer:destroy();
			end;
			local Animation = orientation and "Horizontal" or not orientation and "Vertical";
			self.Animations.Shine[Animation](Bar);
		end;
		Bar.Functions.ShineTimer = Timer(Bar.Functions.Shine,4000,0);
	end;
	Bar.Functions.Marquee = function()
		if not IsElement(Bar.Skeleton) and IsTimer(Bar.Functions.MarqueeTimer) then
			Bar.Functions.MarqueeTimer:destroy();
		end;
		local Animation = orientation and "Horizontal" or not orientation and "Vertical";
		self.Animations.Marquee[Animation](Bar);
	end;
	Bar:SetPosition(position[1],position[2],position[3],position[4]);
	Bar:SetSize(size[1],size[2],size[3],size[4]);
	return Bar;
end;

function GUI.Bar.Progress:SetPosition(sx,ox,sy,oy)
	local Parent = self.Skeleton:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	self.Skeleton:setPosition(ox+ParentSizeX*sx,oy+ParentSizeY*sy,false);
end;

function GUI.Bar.Progress:SetSize(sx,ox,sy,oy)
	local Parent = self.Skeleton:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	local SizeX,SizeY = ox+ParentSizeX*sx,oy+ParentSizeY*sy;
	self.Skeleton:setSize(SizeX,SizeY,false);
	self.Frame:setSize(SizeX-2,SizeY-2,false);
	if self.Functions.Orientation then
		if self.Functions.Style == "Progress" then
			self.ProgressFrame:setSize((SizeX-4)*self.Functions.Progress,SizeY-4,false);
		elseif self.Functions.Style == "Marquee" then
			self.ProgressFrame:setPosition((4-SizeX)/3-1,1,false);
			self.ProgressFrame:setSize((SizeX-4)/3,SizeY-4,false);
			self.Functions.MarqueeBoundaries = {(4-SizeX)/3-1,SizeX-2};
		end;
		if self.Shine then
			self.Shine:setPosition(4-SizeY,0,false);
			self.Shine:setSize(SizeY-4,SizeY-4,false);
			self.Functions.ShineBoundaries = {4-SizeY,SizeX-4};
		end;
	else
		if self.Functions.Style == "Progress" then
			self.ProgressFrame:setSize(SizeX-4,(SizeY-4)*self.Functions.Progress,false);
		elseif self.Functions.Style == "Marquee" then
			self.ProgressFrame:setPosition(1,(4-SizeY)/3-1,false);
			self.ProgressFrame:setSize(SizeX-4,(SizeY-4)/3,false);
			self.Functions.MarqueeBoundaries = {(4-SizeY)/3-1,SizeY-2};
		end;
		if self.Shine then
			self.Shine:setPosition(0,4-SizeX,false);
			self.Shine:setSize(SizeX-4,SizeX-4,false);
			self.Functions.ShineBoundaries = {4-SizeX,SizeY-4};
		end;
	end;
end;

function GUI.Bar.Progress:SetStyle(style)
	local SkeletonSizeX,SkeletonSizeY = self.Skeleton:getSize(false);
	if style == "Progress" then
		if IsTimer(self.Functions.MarqueeTimer) then
			self.Functions.MarqueeTimer:destroy();
		end;
		self.ProgressFrame:setPosition(1,1,false);
		if self.Functions.Orientation then
			self.ProgressFrame:setSize((SkeletonSizeX-4)*self.Functions.Progress,SkeletonSizeY-4,false);
		else
			self.ProgressFrame:setSize(SkeletonSizeX-4,(SkeletonSizeY-4)*self.Functions.Progress,false);
		end;
		self.Functions.Style = "Progress";
	elseif style == "Marquee" then
		if self.Functions.Orientation then
			self.ProgressFrame:setPosition((4-SkeletonSizeX)/3-1,1,false);
			self.ProgressFrame:setSize((SkeletonSizeX-4)/3,SkeletonSizeY-4,false);
			self.Functions.MarqueeBoundaries = {(4-SkeletonSizeX)/3-1,SkeletonSizeX-2};
		else
			self.ProgressFrame:setPosition(1,(4-SkeletonSizeY)/3-1,false);
			self.ProgressFrame:setSize(SkeletonSizeX-4,(SkeletonSizeY-4)/3,false);
			self.Functions.MarqueeBoundaries = {(4-SkeletonSizeY)/3-1,SkeletonSizeY-2};
		end;
		if not IsTimer(self.Functions.MarqueeTimer) then
			self.Functions.MarqueeTimer = Timer(self.Functions.Marquee,1750,0);
		end;
		self.Functions.Style = "Marquee";
	end;
end;

function GUI.Bar.Progress:SetProgress(progress)
	if self.Functions.Style == "Progress" then
		local SkeletonSizeX,SkeletonSizeY = self.Skeleton:getSize(false);
		if self.Functions.Orientation then
			self.ProgressFrame:setSize((SkeletonSizeX-4)*progress,SkeletonSizeY-4,false);
		else
			self.ProgressFrame:setSize(SkeletonSizeX-4,(SkeletonSizeY-4)*progress,false);
		end;
		self.Functions.Progress = progress;
	end;
end;

function GUI.Bar.Progress:Destroy()
	if IsTimer(self.Functions.MarqueeTimer) then
		self.Functions.MarqueeTimer:destroy();
	end;
	if IsTimer(self.Functions.ShineTimer) then
		self.Functions.ShineTimer:destroy();
	end;
	if IsElement(self.Skeleton) then
		self.Skeleton:destroy();
	end;
	self = nil;
end;

function GUI.Bar.Scroll:Create(position,size,orientation,skeleton_color,frame_color,progress_frame_color,animation,parent)
	local Bar = {
		OnScroll = {},
		Functions = {
			Orientation = orientation,
			Progress = 0;
		};
	};
	SetMetatable(Bar,self);
	local SkeletonColor,FrameColor,ProgressFrameColor = ConvertRGBToHex(Unpack(skeleton_color)),ConvertRGBToHex(Unpack(frame_color)),{ConvertRGBToHex(Unpack(progress_frame_color[1])),ConvertRGBToHex(Unpack(progress_frame_color[2]))};
	Bar.Functions.HoldOffset = 0;
	Bar.Skeleton = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture1.png",false,parent and parent or nil);
	Bar.Skeleton:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	Bar.Frame = GuiStaticImage(1,1,0,0,"Resources/Visual/Texture1.png",false,Bar.Skeleton);
	Bar.Frame:setProperty("ImageColours","tl:FF"..FrameColor.." tr:FF"..FrameColor.." bl:FF"..FrameColor.." br:FF"..FrameColor);
	Bar.ProgressFrame = GuiStaticImage(1,1,0,0,"Resources/Visual/Texture1.png",false,Bar.Frame);
	Bar.ProgressFrame:setProperty("ImageColours","tl:FF"..ProgressFrameColor[1].." tr:FF"..ProgressFrameColor[1].." bl:FF"..ProgressFrameColor[1].." br:FF"..ProgressFrameColor[1]);
	if orientation then
		Bar.Functions.Scroll = function(direction)
			direction = direction*-1;
			local CurrentProgressFramePositionX,CurrentProgressFramePositionY = Bar.ProgressFrame:getPosition(false);
			local NextProgressFramePositionX = CurrentProgressFramePositionX+Bar.Functions.Increment*direction;
			if not (NextProgressFramePositionX<Bar.Functions.Boundaries[1] or NextProgressFramePositionX>Bar.Functions.Boundaries[2]) then
				Bar.ProgressFrame:setPosition(NextProgressFramePositionX,CurrentProgressFramePositionY,false);
				Bar.Functions.Progress = (NextProgressFramePositionX-1)/Bar.Functions.MaximumScroll;
				if Next(Bar.OnScroll) then
					for _,v in Pairs(Bar.OnScroll) do
						v(Bar);
					end;
				end;
			else
				Bar.ProgressFrame:setPosition(Bar.Functions.Boundaries[direction == -1 and 1 or direction == 1 and 2],CurrentProgressFramePositionY,false);
				Bar.Functions.Progress = direction == -1 and 0 or direction == 1 and 1;
				if Next(Bar.OnScroll) then
					for _,v in Pairs(Bar.OnScroll) do
						v(Bar);
					end;
				end;
			end;
		end;
		Bar.Functions.Move = function(_,_,x)
			local NextProgressFramePositionX = x-Bar.Functions.AbsoluteFramePosition[1]-Bar.Functions.HoldOffset;
			if not (NextProgressFramePositionX<Bar.Functions.Boundaries[1] or NextProgressFramePositionX>Bar.Functions.Boundaries[2]) then
				Bar.ProgressFrame:setPosition(NextProgressFramePositionX,1,false);
				Bar.Functions.Progress = (NextProgressFramePositionX-1)/Bar.Functions.MaximumScroll;
				if Next(Bar.OnScroll) then
					for _,v in Pairs(Bar.OnScroll) do
						v(Bar);
					end;
				end;
			else
				local Center = (Bar.Functions.MaximumScroll+1)/2;
				local Boundary = NextProgressFramePositionX<Center and 1 or NextProgressFramePositionX>Center and 2;
				Bar.ProgressFrame:setPosition(Bar.Functions.Boundaries[Boundary],1,false);
				Bar.Functions.Progress = (Bar.Functions.Boundaries[Boundary]-1)/Bar.Functions.MaximumScroll;
				if Next(Bar.OnScroll) then
					for _,v in Pairs(Bar.OnScroll) do
						v(Bar);
					end;
				end;
			end;
		end;
		Bar.Functions.MouseDown = function(button,x)
			if button == "left" then
				local CurrentProgressFramePositionX = Bar.ProgressFrame:getPosition(false);
				Bar.Functions.HoldOffset = x-Bar.Functions.AbsoluteFramePosition[1]-CurrentProgressFramePositionX;
				addEventHandler("onClientKey",root,Bar.Functions.MouseUp);
				addEventHandler("onClientCursorMove",root,Bar.Functions.Move);
				Sound("Resources/Audio/Key1.ogg"):setVolume(1);
			end;
		end;
		Bar.Functions.MouseUp = function(key,press)
			if key == "mouse1" and not press then
				removeEventHandler("onClientKey",root,Bar.Functions.MouseUp);
				removeEventHandler("onClientCursorMove",root,Bar.Functions.Move);
			end;
		end;
	else
		Bar.Functions.Scroll = function(direction)
			direction = direction*-1;
			local CurrentProgressFramePositionX,CurrentProgressFramePositionY = Bar.ProgressFrame:getPosition(false);
			local NextProgressFramePositionY = CurrentProgressFramePositionY+Bar.Functions.Increment*direction;
			if not (NextProgressFramePositionY<Bar.Functions.Boundaries[1] or NextProgressFramePositionY>Bar.Functions.Boundaries[2]) then
				Bar.ProgressFrame:setPosition(CurrentProgressFramePositionX,NextProgressFramePositionY,false);
				Bar.Functions.Progress = (NextProgressFramePositionY-1)/Bar.Functions.MaximumScroll;
				if Next(Bar.OnScroll) then
					for _,v in Pairs(Bar.OnScroll) do
						v(Bar);
					end;
				end;
			else
				Bar.ProgressFrame:setPosition(CurrentProgressFramePositionX,Bar.Functions.Boundaries[direction == -1 and 1 or direction == 1 and 2],false);
				Bar.Functions.Progress = direction == -1 and 0 or direction == 1 and 1;
				if Next(Bar.OnScroll) then
					for _,v in Pairs(Bar.OnScroll) do
						v(Bar);
					end;
				end;
			end;
		end;
		Bar.Functions.Move = function(_,_,_,y)
			local NextProgressFramePositionY = y-Bar.Functions.AbsoluteFramePosition[2]-Bar.Functions.HoldOffset;
			if not (NextProgressFramePositionY<Bar.Functions.Boundaries[1] or NextProgressFramePositionY>Bar.Functions.Boundaries[2]) then
				Bar.ProgressFrame:setPosition(1,NextProgressFramePositionY,false);
				Bar.Functions.Progress = (NextProgressFramePositionY-1)/Bar.Functions.MaximumScroll;
				if Next(Bar.OnScroll) then
					for _,v in Pairs(Bar.OnScroll) do
						v(Bar);
					end;
				end;
			else
				local Center = (Bar.Functions.MaximumScroll+1)/2;
				local Boundary = NextProgressFramePositionY<Center and 1 or NextProgressFramePositionY>Center and 2;
				Bar.ProgressFrame:setPosition(1,Bar.Functions.Boundaries[Boundary],false);
				Bar.Functions.Progress = (Bar.Functions.Boundaries[Boundary]-1)/Bar.Functions.MaximumScroll;
				if Next(Bar.OnScroll) then
					for _,v in Pairs(Bar.OnScroll) do
						v(Bar);
					end;
				end;
			end;
		end;
		Bar.Functions.MouseDown = function(button,_,y)
			if button == "left" then
				local _,CurrentProgressFramePositionY = Bar.ProgressFrame:getPosition(false);
				Bar.Functions.HoldOffset = y-Bar.Functions.AbsoluteFramePosition[2]-CurrentProgressFramePositionY;
				addEventHandler("onClientKey",root,Bar.Functions.MouseUp);
				addEventHandler("onClientCursorMove",root,Bar.Functions.Move);
				Sound("Resources/Audio/Key1.ogg"):setVolume(1);
			end;
		end;
		Bar.Functions.MouseUp = function(key,press)
			if key == "mouse1" and not press then
				removeEventHandler("onClientKey",root,Bar.Functions.MouseUp);
				removeEventHandler("onClientCursorMove",root,Bar.Functions.Move);
			end;
		end;
	end;
	if animation then
		Bar.Animations = {
			Hover = {
				ProgressFrameColor = progress_frame_color,
				Switch = nil,
				Progress = 0;
			};
		};
		Bar.Functions.Hover = function()
			local Animation = eventName == "onClientMouseEnter" and "Entering" or eventName == "onClientMouseLeave" and "Leaving";
			if Bar.Animations.Hover.Switch then
				removeEventHandler("onClientRender",root,Bar.Animations.Hover.Switch);
			end;
			self.Animations.Hover[Animation](Bar);
		end;
	else
		Bar.Functions.Hover = function()
			local Color = eventName == "onClientMouseEnter" and ProgressFrameColor[2] or eventName == "onClientMouseLeave" and ProgressFrameColor[1];
			Bar.ProgressFrame:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
		end;
	end;
	Bar:SetPosition(position[1],position[2],position[3],position[4]);
	Bar:SetSize(size[1],size[2],size[3],size[4]);
	addEventHandler("onClientMouseWheel",Bar.Frame,Bar.Functions.Scroll,false);
	addEventHandler("onClientMouseWheel",Bar.ProgressFrame,Bar.Functions.Scroll,false);
	addEventHandler("onClientGUIMouseDown",Bar.ProgressFrame,Bar.Functions.MouseDown,false);
	addEventHandler("onClientMouseEnter",Bar.ProgressFrame,Bar.Functions.Hover,false);
	addEventHandler("onClientMouseLeave",Bar.ProgressFrame,Bar.Functions.Hover,false);
	return Bar;
end;

function GUI.Bar.Scroll:SetPosition(sx,ox,sy,oy)
	local Parent = self.Skeleton:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	self.Skeleton:setPosition(ox+ParentSizeX*sx,oy+ParentSizeY*sy,false);
	self.Functions.AbsoluteFramePosition = {GetGUIAbsolutePosition(self.Frame)};
end;

function GUI.Bar.Scroll:SetSize(sx,ox,sy,oy)
	local Parent = self.Skeleton:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	local SizeX,SizeY = ox+ParentSizeX*sx,oy+ParentSizeY*sy;
	self.Skeleton:setSize(SizeX,SizeY,false);
	self.Frame:setSize(SizeX-2,SizeY-2,false);
	if self.Functions.Orientation then
		self.ProgressFrame:setSize((SizeX-4)*0.25,SizeY-4,false);
		self.Functions.Boundaries = {1,math.floor(SizeX-4-(SizeX-4)*0.25+1)};
	else
		self.ProgressFrame:setSize(SizeX-4,(SizeY-4)*0.25,false);
		self.Functions.Boundaries = {1,math.floor(SizeY-4-(SizeY-4)*0.25+1)};
	end;
	self.Functions.Increment = (self.Functions.Boundaries[2]-1)*0.1;
	self.Functions.MaximumScroll = self.Functions.Boundaries[2]-self.Functions.Boundaries[1];
end;

function GUI.Bar.Scroll:Destroy()
	if IsElement(self.Skeleton) then
		self.Skeleton:destroy();
	end;
	self = nil;
end;

function GUI.Box.Check:Create(position,size,text,alignment,skeleton_color,frame_color,check_frame_color,animation,parent)
	local Box = {
		OnCheck = {},
		Functions = {
			Alignment = alignment,
			Checked = false,
			CheckFrameColor = check_frame_color;
		};
	};
	SetMetatable(Box,self);
	local SkeletonColor,FrameColor,CheckFrameColor = ConvertRGBToHex(Unpack(skeleton_color)),ConvertRGBToHex(Unpack(frame_color)),{ConvertRGBToHex(Unpack(check_frame_color[1])),ConvertRGBToHex(Unpack(check_frame_color[2]))};
	Box.Holder = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture2.png",false,parent and parent or nil);
	Box.Skeleton = GuiStaticImage(0,0,16,16,"Resources/Visual/Texture1.png",false,Box.Holder);
	Box.Skeleton:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	Box.Frame = GuiStaticImage(1,1,14,14,"Resources/Visual/Texture1.png",false,Box.Skeleton);
	Box.Frame:setProperty("ImageColours","tl:FF"..FrameColor.." tr:FF"..FrameColor.." bl:FF"..FrameColor.." br:FF"..FrameColor);
	Box.CheckFrame = GuiStaticImage(2,2,10,10,"Resources/Visual/Texture1.png",false,Box.Frame);
	Box.CheckFrame:setProperty("ImageColours","tl:FF"..CheckFrameColor[1].." tr:FF"..CheckFrameColor[1].." bl:FF"..CheckFrameColor[1].." br:FF"..CheckFrameColor[1]);
	Box.CheckFrame:setAlpha(0);
	if text then
		Box.Text = GuiLabel(20,0,0,0,text,false,Box.Holder);
		Box.Text:setFont("default-small");
	end;
	if animation then
		Box.Animations = {
			Hover = {
				Switch = nil,
				Progress = 0;
			},
			Select = {
				Switch = nil,
				Progress = 0;
			};
		};
		Box.Functions.Hover = function(animation)
			if not Box.Functions.Checked then
				local Animation = eventName == "onClientMouseEnter" and "Entering" or eventName == "onClientMouseLeave" and "Leaving";
				if Box.Animations.Hover.Switch then
					removeEventHandler("onClientRender",root,Box.Animations.Hover.Switch);
				end;
				self.Animations.Hover[Animation](Box);
				if eventName == "onClientMouseEnter" then
					Sound("Resources/Audio/Button1.ogg"):setVolume(1);
				end;
			end;
		end;
		Box.Functions.Check = function(button)
			if button == "left" then
				local Checked = not Box.Functions.Checked;
				Box.Functions.Checked = Checked;
				local Animation = Checked and "Checking" or not Checked and "Unchecking";
				if Box.Animations.Select.Switch then
					removeEventHandler("onClientRender",root,Box.Animations.Select.Switch);
				end;
				self.Animations.Select[Animation](Box);
				if Next(Box.OnCheck) then
					for _,v in Pairs(Box.OnCheck) do
						v(Box);
					end;
				end;
				Sound("Resources/Audio/Key1.ogg"):setVolume(1);
			end;
		end;
	else
		Box.Functions.Hover = function(alpha)
			if not Box.Functions.Checked then
				local Alpha = eventName == "onClientMouseEnter" and 1 or eventName == "onClientMouseLeave" and 0;
				Box.CheckFrame:setAlpha(Alpha);
				if eventName == "onClientMouseEnter" then
					Sound("Resources/Audio/Button1.ogg"):setVolume(1);
				end;
			end;
		end;
		Box.Functions.Check = function(button)
			if button == "left" then
				local Checked = not Box.Functions.Checked;
				Box.Functions.Checked = Checked;
				local Color = Checked and CheckFrameColor[2] or not Checked and CheckFrameColor[1];
				Box.CheckFrame:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
				if Next(Box.OnCheck) then
					for _,v in Pairs(Box.OnCheck) do
						v(Box);
					end;
				end;
				Sound("Resources/Audio/Key1.ogg"):setVolume(1);
			end;
		end;
	end;
	Box:SetPosition(position[1],position[2],position[3],position[4]);
	Box:SetSize(size[1],size[2],size[3],size[4]);
	addEventHandler("onClientMouseEnter",Box.CheckFrame,Box.Functions.Hover,false);
	addEventHandler("onClientMouseLeave",Box.CheckFrame,Box.Functions.Hover,false);
	addEventHandler("onClientGUIClick",Box.CheckFrame,Box.Functions.Check,false);
	return Box;
end;

function GUI.Box.Check:SetPosition(sx,ox,sy,oy)
	local Parent = self.Holder:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	self.Holder:setPosition(ox+ParentSizeX*sx,oy+ParentSizeY*sy,false);
end;

function GUI.Box.Check:SetSize(sx,ox,sy,oy)
	local Parent = getElementParent(self.Holder);
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	local SizeX,SizeY = ox+ParentSizeX*sx,oy+ParentSizeY*sy;
	self.Holder:setSize(SizeX,SizeY,false);
	self:SetAlignment(self.Functions.Alignment[1],self.Functions.Alignment[2],self.Functions.Alignment[3]);
end;

function GUI.Box.Check:SetAlignment(direction,horizontal_align,vertical_align)
	local HolderSizeX,HolderSizeY = self.Holder:getSize(false);
	if direction == "up" then
		self.Skeleton:setPosition((HolderSizeX-16)/2,0,false);
		if self.Text then
			self.Text:setPosition(0,20,false);
			self.Text:setSize(HolderSizeX,HolderSizeY-20,false);
		end;
	elseif direction == "right" then
		self.Skeleton:setPosition(HolderSizeX-16,(HolderSizeY-16)/2,false);
		if self.Text then
			self.Text:setPosition(0,0,false);
			self.Text:setSize(HolderSizeX-20,HolderSizeY,false);
		end;
	elseif direction == "down" then
		self.Skeleton:setPosition((HolderSizeX-16)/2,HolderSizeY-16,false);
		if self.Text then
			self.Text:setPosition(0,0,false);
			self.Text:setSize(HolderSizeX,HolderSizeY-20,false);
		end;
	elseif direction == "left" then
		self.Skeleton:setPosition(0,(HolderSizeY-16)/2,false);
		if self.Text then
			self.Text:setPosition(20,0,false);
			self.Text:setSize(HolderSizeX-20,HolderSizeY,false);
		end;
	end;
	if self.Text then
		self.Text:setHorizontalAlign(horizontal_align,true);
		self.Text:setVerticalAlign(vertical_align);
	end;
	self.Functions.Alignment = {direction,horizontal_align,vertical_align};
end;

function GUI.Box.Check:SetChecked(checked)
	if RawGet(self,"Animations") then
		local Animations,Class = checked and {"Entering","Checking"} or not checked and {"Leaving","Unchecking"},GetMetatable(self).Animations;
		if self.Animations.Hover.Switch then
			removeEventHandler("onClientRender",root,self.Animations.Hover.Switch);
		end;
		Class.Hover[Animations[1]](self);
		if self.Animations.Select.Switch then
			removeEventHandler("onClientRender",root,self.Animations.Select.Switch);
		end;
		Class.Select[Animations[2]](self);
		self.Functions.Checked = checked;
		if Next(self.OnCheck) then
			for _,v in Pairs(self.OnCheck) do
				v(self);
			end;
		end;
	else
		local Color = checked and ConvertRGBToHex(self.Functions.CheckFrameColor[2]) or not checked and ConvertRGBToHex(self.Functions.CheckFrameColor[1]);
		self.CheckFrame:setAlpha(checked and 1 or not checked and 0);
		self.CheckFrame:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
		self.Functions.Checked = checked;
		if Next(self.OnCheck) then
			for _,v in Pairs(self.OnCheck) do
				v(self);
			end;
		end;
	end;
end;

function GUI.Box.Check:Destroy()
	if IsElement(self.Holder) then
		self.Holder:destroy();
	end;
	self = nil;
end;

function GUI.Box.Combo:Create(position,size,text,skeleton_color,frame_color,button_frame_color,animation,parent)
	local Box = {
		OnSelect = {},
		Button = {},
		Elements = {
			Content = {
				Holder = {
					List = {};
				};
			};
		},
		Functions = {
			DefaultText = text,
			Dropped = false,
			Selected = 0,
			FrameColor = frame_color,
			ButtonFrameColor = button_frame_color;
		};
	};
	SetMetatable(Box,self);
	local SkeletonColor,FrameColor,ButtonFrameColor = ConvertRGBToHex(Unpack(skeleton_color)),ConvertRGBToHex(Unpack(frame_color)),{ConvertRGBToHex(Unpack(button_frame_color[1])),ConvertRGBToHex(Unpack(button_frame_color[2]))};
	Box.Holder = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture2.png",false,parent and parent or nil);
	Box.Skeleton = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture1.png",false,Box.Holder);
	Box.Skeleton:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	Box.Frame = GuiStaticImage(1,1,0,0,"Resources/Visual/Texture1.png",false,Box.Skeleton);
	Box.Frame:setProperty("ImageColours","tl:FF"..FrameColor.." tr:FF"..FrameColor.." bl:FF"..FrameColor.." br:FF"..FrameColor);
	Box.Selected = GUI.Button.Default({0,2,0,2},{0,0,0,0},text,skeleton_color,{frame_color,button_frame_color[2]},{185,0,0},animation,Box.Frame);
	Box.Selected.Text:setFont("default-small");
	Box.Button.Skeleton = GuiStaticImage(0,0,20,20,"Resources/Visual/Texture1.png",false,Box.Frame);
	Box.Button.Skeleton:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	Box.Button.Frame = GuiStaticImage(1,1,18,18,"Resources/Visual/Texture1.png",false,Box.Button.Skeleton);
	Box.Button.Frame:setProperty("ImageColours","tl:FF"..FrameColor.." tr:FF"..FrameColor.." bl:FF"..FrameColor.." br:FF"..FrameColor);
	Box.Button.Pointer = GuiStaticImage(1,2,16,16,"Resources/Visual/Pointer.png",false,Box.Button.Frame);
	Box.Button.Pointer:setProperty("ImageColours","tl:FF"..ButtonFrameColor[1].." tr:FF"..ButtonFrameColor[1].." bl:FF"..ButtonFrameColor[1].." br:FF"..ButtonFrameColor[1]);
	Box.Elements.Skeleton = GuiStaticImage(0,26,0,0,"Resources/Visual/Texture1.png",false,Box.Holder);
	Box.Elements.Skeleton:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	Box.Elements.Content.Skeleton = GuiStaticImage(1,1,0,0,"Resources/Visual/Texture1.png",false,Box.Elements.Skeleton);
	Box.Elements.Content.Skeleton:setProperty("ImageColours","tl:FF"..FrameColor.." tr:FF"..FrameColor.." bl:FF"..FrameColor.." br:FF"..FrameColor);
	Box.Elements.Content.Scrollbar = GUI.Bar.Scroll({0,0,0,0},{0,0,0,0},false,skeleton_color,frame_color,{button_frame_color[1],button_frame_color[2]},animation,Box.Elements.Content.Skeleton);
	Box.Elements.Content.Frame = GuiStaticImage(2,2,0,0,"Resources/Visual/Texture1.png",false,Box.Elements.Content.Skeleton);
	Box.Elements.Content.Frame:setProperty("ImageColours","tl:FF"..SkeletonColor.." tr:FF"..SkeletonColor.." bl:FF"..SkeletonColor.." br:FF"..SkeletonColor);
	Box.Elements.Content.Holder.Skeleton = GuiStaticImage(0,0,0,0,"Resources/Visual/Texture2.png",false,Box.Elements.Content.Frame);
	if animation then
		Box.Animations = {
			Hover = {
				Switch = nil,
				Progress = 0;
			};
		};
		Box.Functions.Hover = function()
			local Animation = eventName == "onClientMouseEnter" and "Entering" or eventName == "onClientMouseLeave" and "Leaving";
			if Box.Animations.Hover.Switch then
				removeEventHandler("onClientRender",root,Box.Animations.Hover.Switch);
			end;
			self.Animations.Hover[Animation](Box);
		end;
		Box.Functions.Drop = function()
			local Direction = not Box.Functions.Dropped and "Down" or Box.Functions.Dropped and "Up";
			Box.Functions.Dropped = not Box.Functions.Dropped;
			self.Animations.Drop[Direction](Box);
			Sound("Resources/Audio/Key1.ogg"):setVolume(1);
		end;
	else
		local HolderSizeX,HolderSizeY = Box.Holder:getSize(false);
		Box.Functions.Hover = function()
			local Color = eventName == "onClientMouseEnter" and ButtonFrameColor[2] or eventName == "onClientMouseLeave" and ButtonFrameColor[1];
			Box.Button.Pointer:setProperty("ImageColours","tl:FF"..Color.." tr:FF"..Color.." bl:FF"..Color.." br:FF"..Color);
		end;
		Box.Functions.Drop = function()
			local SizeY = not Box.Functions.Dropped and HolderSizeY-26 or Box.Functions.Dropped and 0;
			Box.Functions.Dropped = not Box.Functions.Dropped;
			Box.Elements.Skeleton:setSize(HolderSizeX,SizeY,false);
		end;
	end;
	Box:SetPosition(position[1],position[2],position[3],position[4]);
	Box:SetSize(size[1],size[2],size[3],size[4]);
	Box:ShowScrollbar(false);
	addEventHandler("onClientMouseEnter",Box.Button.Pointer,Box.Functions.Hover,false);
	addEventHandler("onClientMouseLeave",Box.Button.Pointer,Box.Functions.Hover,false);
	addEventHandler("onClientGUIClick",Box.Button.Pointer,Box.Functions.Drop,false);
	return Box;
end;

function GUI.Box.Combo:SetPosition(sx,ox,sy,oy)
	local Parent = self.Holder:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	self.Holder:setPosition(ox+ParentSizeX*sx,oy+ParentSizeY*sy,false);
end;

function GUI.Box.Combo:SetSize(sx,ox,sy,oy)
	local Parent = self.Holder:getParent();
	local ParentSizeX,ParentSizeY = nil,nil;
	if Parent == guiRoot then
		ParentSizeX,ParentSizeY = ScreenSizeX,ScreenSizeY;
	else
		ParentSizeX,ParentSizeY = Parent:getSize(false);
	end;
	local SizeX,SizeY = ox+ParentSizeX*sx,oy+ParentSizeY*sy;
	local Dropped,ScrollbarVisible = self.Functions.Dropped,self.Elements.Content.Scrollbar.Skeleton:getVisible();
	self.Holder:setSize(SizeX,SizeY,false);
	self.Skeleton:setSize(SizeX,26,false);
	self.Frame:setSize(SizeX-2,24,false);
	self.Button.Skeleton:setPosition(SizeX-24,2,false);
	self.Selected:SetSize(0,SizeX-28,0,20);
	self.Elements.Skeleton:setSize(SizeX,not Dropped and 0 or Dropped and SizeY-26,false);
	if RawGet(self,"Animations") then
		self.Elements.Content.Skeleton:setPosition(1,not Dropped and 26-SizeY or Dropped and 1,false);
	end;
	self.Elements.Content.Skeleton:setSize(SizeX-2,SizeY-28,false);
	self.Elements.Content.Scrollbar:SetPosition(0,SizeX-24,0,2);
	self.Elements.Content.Scrollbar:SetSize(0,20,0,SizeY-32);
	self.Elements.Content.Frame:setSize(not ScrollbarVisible and SizeX-6 or ScrollbarVisible and SizeX-28,SizeY-32,false);
	self.Elements.Content.Holder.Skeleton:setSize(not ScrollbarVisible and SizeX-6 or ScrollbarVisible and SizeX-28,1+23*#self.Elements.Content.Holder.List,false);
	for _,v in IndexedPairs(self.Elements.Content.Holder.List) do
		v:SetSize(0,not ScrollbarVisible and SizeX-8 or ScrollbarVisible and SizeX-30,0,22);
	end;
end;

function GUI.Box.Combo:ShowScrollbar(show)
	local HolderSizeX,HolderSizeY = self.Holder:getSize(false);
	if show then
		self.Elements.Content.Frame:setSize(HolderSizeX-28,HolderSizeY-32,false);
		self.Elements.Content.Holder.Skeleton:setSize(HolderSizeX-28,1+23*(#self.Elements.Content.Holder.List),false);
		for _,v in IndexedPairs(self.Elements.Content.Holder.List) do
			v:SetSize(0,HolderSizeX-30,0,22);
		end;
		self.Elements.Content.Scrollbar.Skeleton:setVisible(true);
	else
		self.Elements.Content.Frame:setSize(HolderSizeX-6,HolderSizeY-32,false);
		self.Elements.Content.Holder.Skeleton:setSize(HolderSizeX-6,1+23*(#self.Elements.Content.Holder.List),false);
		for _,v in IndexedPairs(self.Elements.Content.Holder.List) do
			v:SetSize(0,HolderSizeX-8,0,22);
		end;
		self.Elements.Content.Scrollbar.Skeleton:setVisible(false);
	end;
end;

function GUI.Box.Combo:AddElement(text)
	local Index,Animation = #self.Elements.Content.Holder.List+1,RawGet(self,"Animations") and true or false;
	local HolderSizeX,HolderSizeY = self.Holder:getSize(false);
	local ElementPositionY = 1+23*(Index-1);
	if self.Elements.Content.Holder.List[Index] then
		self.Elements.Content.Holder.List[Index]:Destroy();
	end;
	local Element = GUI.Button.Default({0,1,0,ElementPositionY},{0,HolderSizeX-30,0,22},text,self.Functions.FrameColor,{self.Functions.ButtonFrameColor[1],self.Functions.ButtonFrameColor[2]},{185,0,0},Animation,self.Elements.Content.Holder.Skeleton);
	self.Elements.Content.Holder.List[Index] = Element;
	local Box = self;
	function Element.OnClick.Select()
		Box:SetSelected(Index,true);
	end;
	local ScrollOffset = ((HolderSizeY-32)-(ElementPositionY+23))-1;
	if ScrollOffset<0 then
		local ContentHolder = self.Elements.Content.Holder.Skeleton;
		function self.Elements.Content.Scrollbar.OnScroll:Move()
			ContentHolder:setPosition(0,ScrollOffset*self.Functions.Progress,false)
		end;
		self:ShowScrollbar(true);
	else
		self.Elements.Content.Scrollbar.OnScroll.Move = nil;
		self.Elements.Content.Holder.Skeleton:setPosition(0,0,false);
		self:ShowScrollbar(false);
	end;
	return Element;
end;

function GUI.Box.Combo:RemoveElement(index)
	if self.Elements.Content.Holder.List[index] then
		local Size = #self.Elements.Content.Holder.List;
		local HolderSizeX,HolderSizeY = self.Holder:getSize(false);
		self.Elements.Content.Holder.List[index]:Destroy();
		if self.Functions.Selected ~= 0 then
			self:SetSelected(index-1);
		end;
		local Box = self;
		if index+1<Size then
			for i = index+1,Size do
				local Element = self.Elements.Content.Holder.List[i]
				self.Elements.Content.Holder.List[i-1] = Element;
				Element:SetPosition(0,1,0,1+23*(i-2));
				function Element.OnClick.Select()
					Box:SetSelected(i-1,true);
				end;
			end;
		end;
		self.Elements.Content.Holder.List[Size] = nil;
		local ScrollOffset = ((HolderSizeY-32)-(1+23*(Size-1)))-1;
		if ScrollOffset<0 then
			local ContentHolder = self.Elements.Content.Holder.Skeleton;
			function self.Elements.Content.Scrollbar.OnScroll:Move()
				ContentHolder:setPosition(0,ScrollOffset*self.Functions.Progress,false)
			end;
			self:ShowScrollbar(true);
		else
			self.Elements.Content.Scrollbar.OnScroll.Move = nil;
			self.Elements.Content.Holder.Skeleton:setPosition(0,0,false);
			self:ShowScrollbar(false);
		end;
	end;
end;

function GUI.Box.Combo:SetSelected(index,drop)
	if index ~= 0 then
		local Element = self.Elements.Content.Holder.List[index];
		local Text,Name,Font = Element.Text:getText(),Element.Text:getFont();
		self.Selected.Text:setText(Text);
		if Font then
			self.Selected.Text:setFont(Font);
		else
			self.Selected.Text:setFont(Name);
		end;
	else
		self.Selected.Text:setText(self.Functions.DefaultText);
		self.Selected.Text:setFont("default-small");
	end;
	if drop then
		self.Functions.Drop();
	end;
	self.Functions.Selected = index;
	if Next(self.OnSelect) then
		for _,v in pairs(self.OnSelect) do
			v(self);
		end;
	end;
end;

function GUI.Box.Combo:Destroy()
	for i = #self.Elements.Content.Holder.List,1,-1 do
		self:RemoveElement(i);
	end;
	self.Selected:Destroy();
	self.Elements.Content.Scrollbar:Destroy();
	if IsElement(self.Holder) then
		self.Holder:destroy();
	end;
	self = nil;
end;

--[[local Box = GUI.Box.Combo({0.5,-150,0.5,-150},{0,300,0,300},"GUI.Box.Combo",{25,25,25},{50,50,50},{{75,75,75},{200,200,200}},true);
Box:AddElement("Element");]]

function GUI.Box.Text:Create(position,size,text,alignment,skeleton_color,frame_color,edit_frame_color,animation,parent)
	local Box = {
		OnText = {},
		Functions = {};
	};
	SetMetatable(Box,self);
	-- code;
	return Box;
end;