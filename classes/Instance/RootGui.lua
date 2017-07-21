local name = "RootGui";

local super = GuiBase2D;

local func = setmetatable({}, { __index = function(tbl, key) return super.func[key] end });
local get  = setmetatable({}, { __index = function(tbl, key) return super.get[key]  end });
local set  = setmetatable({}, { __index = function(tbl, key) return super.set[key]  end });

local event = setmetatable({}, { __index = function(tbl, key) return super.event[key] end });

local private  = setmetatable({}, { __index = function(tbl, key) return super.private[key]  end });
local readOnly = setmetatable({}, { __index = function(tbl, key) return super.readOnly[key] end });



local function new(obj)
    super.new(obj);
    
    
    
end



RootGui = {
    name = name,
    
    super = super,
    
    func = func,
    get  = get,
    set  = set,
    
    event = event,
    
    private  = private,
    readOnly = readOnly,
    
    new = new,
}
