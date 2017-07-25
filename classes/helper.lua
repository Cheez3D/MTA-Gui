function inherit(class, super)
    return setmetatable(class, {
        __index = function(tbl, key)
            local val = super[key];
            
            if (val) then
                class[key] = val;
            end
            
            return val;
        end,
    });
end
