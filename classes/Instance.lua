ClassMetaTable = {__index = function(Class,Key) return Class.Base[Key] end}

local Class = {
	Inherited = {},
	
	Functions = {},
	IndexFunctions = {},
	NewIndexFunctions = {},
	
	Name = "Instance",
	
	PrivateKeys = {
		Children = true,
		ChildrenByName = true
	},
	ReadOnlyKeys = {
		ClassName = true
	}
}



local MetaTable = {
	__index = function(Proxy,Key)
		local Object = PROXY__OBJ[Proxy];
		
		local StartingClass = Class.Inherited[Object.ClassName];	local CurrentClass;
		
		CurrentClass = StartingClass;
		while (CurrentClass ~= nil) do
			if (CurrentClass.PrivateKeys[Key] == true) then
				local Child = Object.ChildrenByName[Key];
				if (Child ~= nil) then return ObjectToProxy[Child]
				else return nil end
			end
			
			CurrentClass = CurrentClass.Base;
		end
		
		local Value = Object[Key];
		if (Value ~= nil) then return Value end
		
		CurrentClass = StartingClass;
		while (CurrentClass ~= nil) do
			local Function = CurrentClass.Functions[Key];
			if (Function ~= nil) then return Function end
			
			local IndexFunction = CurrentClass.IndexFunctions[Key];
			if (IndexFunction ~= nil) then return IndexFunction(Object,Key) end
			
			CurrentClass = CurrentClass.Base;
		end
		
		local Child = Object.ChildrenByName[Key];
		if (Child ~= nil) then return ObjectToProxy[Child] end
		
		return nil;
	end,
	__metatable = "Instance",
	__newindex = function(Proxy,Key,Value)
		local Object = PROXY__OBJ[Proxy];
		
		-- local PreviousValue = Object[Key];
		-- if (PreviousValue == Value) then return end
		
		local NewIndexFunctions = {}
		
		local CurrentClass = Class.Inherited[Object.ClassName];
		while (CurrentClass ~= nil) do
			local IsKeyReadOnly = CurrentClass.ReadOnlyKeys[Key];
			if (IsKeyReadOnly == true) or ((IsKeyReadOnly == false) and (Object[Key] ~= nil)) then error("attempt to modify a read-only key ("..tostring(Key)..")",2) end
			
			local NewIndexFunction = CurrentClass.NewIndexFunctions[Key];
			if (NewIndexFunction ~= nil) then table.insert(NewIndexFunctions,1,NewIndexFunction) end
			
			CurrentClass = CurrentClass.Base;
		end
		
		local NewIndexFunctionsNumber = #NewIndexFunctions;
		if (NewIndexFunctionsNumber > 0) then
			local PreviousValue = Object[Key];
			for i = 1,NewIndexFunctionsNumber do NewIndexFunctions[i](Object,Key,Value,PreviousValue) end
		else print(Proxy) print(Value) error("attempt to modify an invalid key ("..tostring(Key)..")",2) end
	end,
	__tostring = function(Proxy)
		local Object = PROXY__OBJ[Proxy];
		
		return Object.ClassName.." "..Object.Name;
	end
}

function Class.New(ClassName,ParentProxy)
	local ClassNameType = type(ClassName);
	if (ClassNameType ~= "string") then error("bad argument #1 to '"..__func__.."' (string expected, got "..ClassNameType..")",2) end
	
	if (ParentProxy ~= nil) then
		local ParentProxyType = type(ParentProxy);
		if (ParentProxyType ~= "Instance") then error("bad argument #2 to '"..__func__.."' (Instance expected, got "..ParentProxyType..")",2) end
	end
	
	local Class = Class.Inherited[ClassName];
	if (Class == nil) then error("bad argument #1 to '"..__func__.."' (invalid class)",2)
	else
		local Object = {
			ClassName = ClassName,
			Name = ClassName,
			
			Children = {},
			ChildrenByName = {}
		}
		
		Class.New(Object);
		
		local Proxy = setmetatable({},MetaTable);
		OBJ__PROXY[Object] = Proxy;	PROXY__OBJ[Proxy] = Object;
		
		Proxy.Parent = ParentProxy;
		
		return Proxy;
	end
end

do -- Class.Functions
	function Class.Functions.IsA(Proxy,ClassName)
		local ProxyType = type(Proxy);
		if (ProxyType ~= "Instance") then error("bad argument #1 to '"..__func__.."' (Instance expected, got "..ProxyType..")",2) end
		
		local ClassNameType = type(ClassName);
		if (ClassNameType ~= "string") then error("bad argument #2 to '"..__func__.."' (string expected, got "..ClassNameType..")",2) end
		
		local Object = PROXY__OBJ[Proxy];
		
		local CurrentClass = Class.Inherited[Object.ClassName];
		while (CurrentClass ~= nil) do
			if (CurrentClass.Name == ClassName) then return true end
			
			CurrentClass = CurrentClass.Base;
		end
		
		return false;
	end
end

do -- Class.NewIndexFunctions
	function Class.NewIndexFunctions.Name(Object,Key,Name,PreviousName)
		local NameType = type(Name);
		if (NameType ~= "string") then error("bad argument #1 to '"..Key.."' (string expected, got "..NameType..")",3) end
		
		
		local Parent = PROXY__OBJ[Object.Parent];
		
		local ParentChildrenByName = Parent.ChildrenByName;
		
		local Index = Object.Index;
		if (ParentChildrenByName[PreviousName].Index == Index) then
			local ParentChildren = Parent.Children;
			for i = Index+1,#ParentChildren do
				local Child = ParentChildren[i];
				if (Child.Name == PreviousName) then ParentChildrenByName[PreviousName] = Child end
			end
		end
		
		if (ParentChildrenByName[Name] == nil) then ParentChildrenByName[Name] = Object end
		
		Object.Name = Name;
	end
	
	function Class.NewIndexFunctions.Parent(Object,Key,ParentProxy,PreviousParentProxy)
		local Name = Object.Name;
		
		if (ParentProxy ~= nil) then
			local ParentProxyType = type(ParentProxy);
			if (ParentProxyType ~= "Instance") then error("bad argument #1 to '"..Key.."' (Instance expected, got "..ParentProxyType..")",3) end
			
			local Parent = PROXY__OBJ[ParentProxy];
			
			local Children = Object.Children;
			for i = 1,#Children do
				if (Parent == Children[i]) then error("bad argument #1 to '"..Key.."' (circular reference)",3) end
			end
			
			if (Parent == Object) then error("bad argument #1 to '"..Key.."' (self parenting)",3) end
			
			
			local ParentChildren = Parent.Children;
			local Index = #ParentChildren+1;
			
			Object.Index = Index;
			ParentChildren[Index] = Object;
			
			local ParentChildrenByName = Parent.ChildrenByName;
			if (ParentChildrenByName[Name] == nil) then ParentChildrenByName[Name] = Object end
		end
		
		
		if (PreviousParentProxy ~= nil) then
			local PreviousParent = PROXY__OBJ[PreviousParentProxy];
			
			local PreviousParentChildren = PreviousParent.Children;
			local PreviousParentChildrenByName = PreviousParent.ChildrenByName;
			
			local Index = Object.Index;
			
			if (PreviousParentChildrenByName[Name].Index == Index) then
				for i = Index+1,#PreviousParentChildren do
					local Child = PreviousParentChildren[i];
					if (Child.Name == Name) then PreviousParentChildrenByName[Name] = Child end
				end
			end
			
			table.remove(PreviousParentChildren,Index);
		end
		
		
		Object.Parent = ParentProxy;
	end
end

Instance = setmetatable({},{
	__call = function(_Proxy,...)
		local Success,Result = pcall(Class.New,...);
		if (Success == false) then error(fromat_pcall_error(Result),2) end
		
		return Result;
	end,
	__index = Class,
	__metatable = "Instance",
	__newindex = function(_Proxy,Key)
		error("attempt to modify a read-only key ("..tostring(Key)..")",2);
	end
});