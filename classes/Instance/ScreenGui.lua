-- local Vector2 = require("Vector2");



local name = "ScreenGui";

local super = GuiBase2D;

local function new(Object)
	super.new(Object);
	
	Object.AbsolutePosition = Vector2.new();
	Object.AbsoluteSize = Vector2.new(SCREEN_WIDTH, SCREEN_HEIGHT);
	
	Object.RootGui = Object;
	
	function Object.Draw()
		dxSetRenderTarget(Object.RenderTarget, true);
		dxSetBlendMode("modulate_add");
		
		local Children = Object.children;
		for i = 1,#Children do
			dxDrawImage(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Children[i].RenderTarget);
		end
		
		dxSetBlendMode("blend");
		dxSetRenderTarget();
	end
	
	Object.RenderTarget = dxCreateRenderTarget(SCREEN_WIDTH, SCREEN_HEIGHT, true);
	Object.RenderTargetSize = Vector2.new(SCREEN_WIDTH, SCREEN_HEIGHT);
	
	function Object.Render()
		dxSetBlendMode("add");
		
		dxDrawImage(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Object.RenderTarget);
		
		dxSetBlendMode("blend");
	end
	addEventHandler("onClientPreRender", root, Object.Render);
end

Instance.initializable.ScreenGui = {
    name = name,
    
	super = super,
	
	new = new,
}
