REFERENCE_FPS  = 60;
REFERENCE_FPMS = REFERENCE_FPS/1000;

setFPSLimit(REFERENCE_FPS);


IS_CLIENT = (triggerServerEvent ~= nil);

if (not IS_CLIENT) then return end



setmetatable(_G, {
    __index = function(tbl, key)
        return (key == "__FILE__") and debug.getinfo(2, "S").short_src
        or (key == "__func__") and (debug.getinfo(2, "n").name or "?")
        or (key == "__LINE__") and debug.getinfo(2, "l").currentline
        or nil;
    end
});




function assert(cond, msg, level, ...)
    if (cond) then return end
    
    if (msg ~= nil) then
        local msgType = type(msg);
        
        if (msgType ~= "string") then
            error("bad argument #2 to '" ..__func__.. "' (string expected, got " ..msgType.. ")", 2);
        end
    else
        msg = "assertion failed!";
    end
    
    if (level ~= nil) then
        local levelType = type(level);
        
        if (levelType ~= "number") then
            error("bad argument #3 to '" ..__func__.. "' (number expected, got " ..levelType.. ")", 2);
        elseif (level%1 ~= 0) then
            error("bad argument #3 to '" ..__func__.. "' (number has no integer representation)", 2);
        elseif (level < 1) then
            error("bad argument #3 to '" ..__func__.. "' (invalid value)",2);
        end
        
        level = level+1;
    else
        level = 2;
    end
    
    local success, result = pcall(string.format, Message, ...);
    if (not success) then
        error("format error", 2);
    end
    
    error(result, level);
end


local _type = type;

function type(arg)
    local argType = _type(arg);
    
    if (argType == "table") then
        argType = getmetatable(arg);
        
        -- for use with classes (Vector2, UDim, etc.) (proxy and object)
        if (_type(argType) == "string") then
            return argType;
        else
            return "table";
        end
    else
        return argType;
    end
end



OUT  = fileOpen("out.txt");
FILE = fileOpen("file.txt");

function print_func(f, ...)
    local strings = { ... }
    
    for i = 1, #strings do
        strings[i] = tostring(strings[i]);
    end

    f(table.concat(strings, ' '));
end

function print(...)
    print_func(outputConsole, ...);
end

function print_chat(...)
    print_func(outputChatBox, ...);
end

function print_debug(...)
    print_func(outputDebugString, ...);
end

function print_file(file, ...)
    local strings = { ... }
    
    for i = 1, #strings do
        strings[i] = tostring(strings[i]);
    end
    
    fileWrite(file, table.concat(strings, ' '));
    
    fileWrite(file, '\n');
end

function print_table(t, f, tab, printed)
    f = f or print;
    
    tab = tab or 0;
    
    printed = printed or {}
    
    if (next(t)) then
        for k, v in pairs(t) do
            if (type(v) == "table" and not printed[v]) then
                f(string.rep(' ', tab), "[", k, "->", v, "]");
                
                printed[v] = true;
                
                print_table(v, f, tab+4, printed);
            else
                f(string.rep(' ', tab), k, "->", v);
            end
        end
    else
        f(string.rep(' ', tab), "EMPTY");
    end
end

addCommandHandler("r", function(cmd, ...)
    local code = table.concat({ ... }, ' ');
    
    local f, err = loadstring(code);
    
    if (not f) then
        error(err);
    end
    
    f();
end);

addCommandHandler("cls", function()
    for i = 1, 256 do
        outputChatBox('');
    end
end);

addCommandHandler("dx", function()
    print_table(dxGetStatus());
end);
