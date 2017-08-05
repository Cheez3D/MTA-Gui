function extend(class, super)
    for k, v in pairs(super) do
        if (not class[k]) then
            class[k] = v;
        end
    end
    
    return class;
end

function inherit(class, super)
    setmetatable(class, {
        __index = function(tbl, key)
            local val = super[key];
            
            if (val) then
                class[key] = val;
            end
            
            return val;
        end,
    });
    
    return class;
end
