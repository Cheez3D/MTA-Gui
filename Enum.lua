local Table = {
	Endianness = {
		LittleEndian = 1,
		BigEndian = 2
	},
	Pointer = {
		Arrow = 1,
		Busy = 2,
		Help = 3,
		Link = 4,
		Move = 5,
		Precision = 6,
		Resize_ew = 7,
		Resize_nesw = 8,
		Resize_ns = 9,
		Resize_nwse = 10,
		Text = 11,
		Unavailable = 12,
		Working = 13
	}
}

local Table2 = {}
for k,Enum in pairs(Table) do
	Table2[k] = {}	local Validity = Table2[k];
	for _k,v in pairs(Enum) do
		Validity[v] = true;
	end
end

Enum = setmetatable({},{
	__index = Table,
	__newindex = function(_TableProxy,Key)
		error("attempt to modify a read-only key ("..tostring(Key)..")",2);
	end
});

EnumValidity = Table2;