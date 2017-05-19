REFERENCE_FPS  = 60;
REFERENCE_FPMS = 1000*REFERENCE_FPS;

setFPSLimit(REFERENCE_FPS);


IS_CLIENT = (triggerServerEvent ~= nil);

if (not IS_CLIENT) then return end


SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize();



setmetatable(_G, {
    __index = function(tbl, key)
        if     (key == "__FILE__") then return debug.getinfo(2, 'S').short_src;
        elseif (key == "__func__") then return debug.getinfo(2, 'n').name or '?';
        elseif (key == "__LINE__") then return debug.getinfo(2, 'l').currentline;
        end
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


local type_ = type;

function type(arg)
    local argType = type_(arg);
    
    if (argType == "table") then
        argType = getmetatable(arg);
        
        -- for use with classes (Vector2, UDim, etc.)
        if (type_(argType) == "string") then return argType;
        else return "table" end
    else
        return argType;
    end
end



OUT  = fileOpen("out.txt");
FILE = fileOpen("file.txt");

function printfunc(f, ...)
    local strings = { ... }
    
    for i = 1, #strings do
        strings[i] = tostring(strings[i]);
    end

    f(table.concat(strings, " "));
end

function print(...)
    printfunc(outputConsole, ...);
end

function printdebug(...)
    printfunc(outputDebugString, ...);
end

function printfile(file, ...)
    local strings = { ... }
    
    for i = 1, #strings do
        strings[i] = tostring(strings[i]);
    end
    
    fileWrite(file, table.concat(strings, ' '));
    
    fileWrite(file, '\n');
end

function printtable(t, f, d)
    f = f or print;
    
    d = d or 0;
    
    for k, v in pairs(t) do
        if (type(v) == "table") then
            f("[ ", k, " -> ", v, " ]");
            
            print_table(v, f, d+1);
        else
            f(string.rep(" ", d), k, " -> ", v);
        end
    end
end



addCommandHandler("r", function(cmd, ...)
    local code = table.concat({ ... }, " ");
    
    local f = loadstring(code);
    f();
end);

addCommandHandler("cls", function()
    for i = 1, 100 do
        outputConsole("\n");
    end
end);
