local name = "GuiBase2D";

local super = Instance;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get [key] end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set [key] end });

local private = setmetatable({
        rt     = true,
        
        draw   = true,
    },
    
    { __index = function(tbl, key) return super.private[key] end }
);

local readOnly = setmetatable({
        absPos  = true,
        absSize = true,
    },
    
    { __index = function(tbl, key) return super.readOnly[key] end }
);



local function new(obj)
    obj.absPosOrigin = nil;
    
    obj.absSize = nil;
    obj.absPos  = nil;
    
    obj.absRot      = nil;
    obj.absRotPivot = nil;
    
    obj.rt = nil;
end



GuiBase2D = {
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    private  = private,
    readOnly = readOnly,
    
    new = new,
}
