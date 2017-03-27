local Class = {
	Ascendant = Instance,
	
	Functions = {},
	NewIndexFunctions = {},
	
	Name = "PointerScheme",
	
	PrivateKeys = {},
	ReadOnlyKeys = {}
}

function Class.New(Object)
	Object.Busy = "PointerSchemes/Vista/Busy.ani";
	Object.BusySize = 1;
	
	Object.Unavailable = "PointerSchemes/Vista/Unavailable.cur";
	Object.UnavailableSize = 1;
	
	
	Object.BusySelect = "PointerSchemes/Vista/BusySelect.ani";
	Object.BusySelectSize = 1;
	
	Object.HelpSelect = "PointerSchemes/Vista/HelpSelect.cur";
	Object.HelpSelectSize = 1;
	
	Object.LinkSelect = "PointerSchemes/Vista/LinkSelect.cur";
	Object.LinkSelectSize = 1;
	
	Object.NormalSelect = "PointerSchemes/Vista/NormalSelect.cur";
	Object.NormalSelectSize = 1;
	
	Object.PrecisionSelect = "PointerSchemes/Vista/PrecisionSelect.cur";
	Object.PrecisionSelectSize = 1;
	
	Object.TextSelect = "PointerSchemes/Vista/TextSelect.cur";
	Object.TextSelectSize = 1;
	
	
	Object.HorizontalResize = "PointerSchemes/Vista/HorizontalResize.cur";
	Object.HorizontalResizeSize = 1;
	
	Object.VerticalResize = "PointerSchemes/Vista/VerticalResize.cur";
	Object.VerticalResizeSize = 1;
	
	Object.DiagonalResizeRightLeft = "PointerSchemes/Vista/DiagonalResizeRightLeft.cur";
	Object.DiagonalResizeRightLeftSize = 1;
	
	Object.DiagonalResizeLeftRight = "PointerSchemes/Vista/DiagonalResizeLeftRight.cur";
	Object.DiagonalResizeLeftRightSize = 1;
	
	
	Object.Move = "PointerSchemes/Vista/Move.cur";
	Object.MoveSize = 1;
	
	
	Object.PointerType = Enum.PointerScheme.NormalSelect;
end

Instance.Inherited.PointerScheme = Class;

local Scheme = Instance.New("PointerScheme");