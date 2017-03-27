function CallAscendantNewIndexFunction(Class,Key,...)
	Class = Class.Ascendant;
	local NewIndexFunction = Class.NewIndex[Key];
	
	while (NewIndexFunction == nil) do
		Class = Class.Ascendant;
		NewIndexFunction = Class.NewIndex[Key];
	end
	
	NewIndexFunction(...);
end

do
	local Instance = {
		Inherited = {},
		
		Functions = {},
		NewIndex = {},
		
		ReadOnlyKeys = {
			ClassName = true
		},
		
		
		
		Name = "Instance"
	}
	
	function Instance.New(Name,Parent)
		local Class = Instance.Inherited[Name];
		
		if (Class ~= nil) then
			local Object = Class.New();
			
			Object.ClassName = Name;
			
			
			
			return setmetatable({},{
			__index = function(_ObjectProxy,Key)
				local Function = Instance.Functions[Key]; -- MAKE RECURSIVE
			
				if (Function ~= nil) then
					return Function;
				else
					return Object[Key];
				end
			end,
			__metatable = Name,
			__newindex = function(_ObjectProxy,Key,Value)
				local CurrentClass = Class;
				
				while (CurrentClass ~= nil) do
					if (CurrentClass.ReadOnlyKeys[Key] == true) then
						error("attempt to modify a read-only key ("..tostring(Key)..")",2);
					else
						local NewIndexFunction = CurrentClass.NewIndex[Key];
						
						if (NewIndexFunction ~= nil) then
							NewIndexFunction(Object,Value); break;
						end
						
						CurrentClass = CurrentClass.Ascendant;
					end
				end
			end
		});
		end
	end
	
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
	
	function Instance.NewIndex.Parent(Object,Parent)
		Object.Parent = Parent;
		print("PARENT SET TO ",Parent);
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



do -- ABSTRACT CLASS
	local GuiObject = {
		Ascendant = Instance,
		
		NewIndex = {},
		
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
		
		NewIndex = {},
		
		ReadOnlyKeys = {},
		
		
		
		Name = "Frame"
    }
    
    function Frame.New(Parent)
        local Object = Frame.Ascendant.New();
		
		Object.Style = "DEFAULT";
        
        return Object;
    end
	
	function Frame.NewIndex.Parent(Object,Parent)
		CallAscendantNewIndexFunction(Frame,"Parent",Object,Parent);
		
		print("parent set");
		-- code
	end
    
	Instance.Inherited.Frame = Frame;
end