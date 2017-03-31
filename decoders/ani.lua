--[[ [=======================================================================================]

    NAME:    table decode_ani(string bytes)
    PURPOSE: Convert .ani files into drawable MTA:SA textures
    
    RETURNED TABLE STRUCTURE:
    
    {
        [ name = "cool cursor", ] -- optional
        
        [1] = {
            [1] = {
                width = 16, height = 16,
                
                hotspotX = 0, hotspotY = 0,
                
                rate = 5,
                
                texture = userdata: xxxxxxxx
            },
            
            [2] = {
                width = 16, height = 16,
                
                hotspotX = 0, hotspotY = 0,
                
                rate = 5,
                
                texture = userdata: xxxxxxxx
            },
            
            ...
        },
        
        [2] = {
            [1] = {
                width = 32, height = 32,
                
                hotspotX = 0, hotspotY = 0,
                
                rate = 5,
                
                texture = userdata: xxxxxxxx
            },
            
            ...
        },
        
        ...
    }
    
    REFERENCES: https://www.daubnet.com/en/file-format-ani
                http://www.daubnet.com/en/file-format-riff
                https://en.wikipedia.org/wiki/ANI_(file_format)
                https://en.wikipedia.org/wiki/Resource_Interchange_File_Format
                http://www.gdgsoft.com/anituner/help/aniformat.htm
                http://www.johnloomis.org/cpe102/asgn/asgn1/riff.html
                https://msdn.microsoft.com/en-us/library/windows/desktop/ee415713.aspx
                http://www.informit.com/articles/article.aspx?p=1189080

[=========================================================================================] ]]

-- [ CONSTANTS ] --

local INFO_FIELD_NAMES = { IART = "artist", ICOP = "copyright", INAM = "name" }

-- [ FUNCTION ] --

function decode_ani(bytes, ignoreInfo)
    -- [ ASSERTION ] --
    
    local bytesType = type(bytes);
    
    if (bytesType ~= "string") then
        error("bad argument #1 to '" .. __func__ .. "' (string expected, got " .. bytesType .. ")");
    end
    
    if (ignoreInfo ~= nil) then
        local ignoreInfoType = type(ignoreInfo);
        
        if (ignoreInfoType ~= "boolean") then
            error("bad argument #2 to '" .. __func__ .. "' (boolean expected, got " .. ignoreInfoType .. ")");
        end
    else
        ignoreInfo = true;
    end
    
    -- [ ACTUAL CODE ]
    
    -- function can olso be supplied with a file path instead of raw data
    -- we treat variable bytes as a file path to see if the file exists
    if (fileExists(bytes)) then
        local f = fileOpen(bytes, true); -- open file read-only
        
        bytes = fileRead(f, fileGetSize(f));
        
        fileClose(f);
    end
    
    
    local success, stream = pcall(Stream.New, bytes);
    if (not success) then error(format_pcall_error(stream), 2) end
    
    if (stream:Read(4) ~= "RIFF") then
        error("bad argument #1 to '" .. __func__ .. "' (invalid file format)", 2);
    end
    
    
    local RIFF_Size = stream:Read_uint();
    local RIFF_End = stream.Position + RIFF_Size;
    
    -- handle invalid RIFF_Size
    -- if length stored in file is greater than the actual length
    if (RIFF_End > stream.Size) then RIFF_End = RIFF_End-stream.Position end
    
    
    if (stream:Read(4) ~= "ACON") then
        error("bad argument #1 to '" .. __func__ .. "' (invalid file format)", 2);
    end
    
    
    local ANIHEADER;
    
    local LIST_INFO = {}
    local LIST_fram = {}
    local rate = {}
    local seq  = {}
    
    -- read all possible chunks (they can be stored in any order)
    while (stream.Position ~= RIFF_End) do
        
        local ckID = stream:Read(4); -- chunk ID
        
        local ckSize = stream:Read_uint(); -- chunk size
        local ckEnd = stream.Position + ckSize; -- chunk end position
        
        if (ckID == "anih") then
        
            ANIHEADER = {
                cbSize = stream:Read_uint(),
                
                nFrames = stream:Read_uint(), -- number of stored frames
                nSteps = stream:Read_uint(), -- number of steps (might contain duplicate frames, depends on seq  chunk)
                
                iWidth = stream:Read_uint(),
                iHeight = stream:Read_uint(),
                
                iBitCount = stream:Read_uint(),
                nPlanes = stream:Read_uint(),
                
                iDispRate = stream:Read_uint(), -- display rate in jiffies (1 jiffy = 1/60 of a second)
                
                bfAttributes = stream:Read_uint(),
            }
            
            if (ANIHEADER.cbSize ~= 36) then
                error("bad argument #1 to '" .. __func__ .. "' (unsupported version)", 2);
            end
            
            local bfAttributes = ANIHEADER.bfAttributes;
            
            ANIHEADER.bfAttributes = {
                icoFlag = bitExtract(bfAttributes, 0, 1), -- denotes whether file contains ico/cur data or raw data
                seqFlag = bitExtract(bfAttributes, 1, 1)  -- denotes whether file contains sequence data (seq  chunk)
            }
            
        elseif (ckID == "LIST") then
            
            local LIST_Type = stream:Read(4);
            
            if (LIST_Type == "INFO") and (not ignoreInfo) then
            
                while (stream.Position ~= ckEnd) do
                
                    local INFO_Type = stream:Read(4);
                    local INFO_Size = stream:Read_uint();
                    
                    local fieldName = INFO_FIELD_NAMES[INFO_Type] or INFO_Type;
                    
                    LIST_INFO[fieldName] = stream:Read(INFO_Size);
                    
                    -- skip one byte padding if size is odd
                    if (INFO_Size%2 == 1) then
                        stream.Position = stream.Position+1;
                    end
                end
                
            elseif (LIST_Type == "fram") then
                
                if (ANIHEADER == nil) then
                    error("bad argument #1 to '" .. __func__ .. "' (invalid chunk order)", 2);
                end
                
                if (ANIHEADER.bfAttributes.icoFlag ~= 1) then
                    error("bad argument #1 to '" .. __func__ .. "' (invalid file format)", 2);
                end
                
                for i = 1, ANIHEADER.nFrames do
                    if (stream:Read(4) ~= "icon") then
                        error("bad argument #1 to '" .. __func__ .. "' (invalid file format)", 2);
                    end
                    
                    local frameSize = stream:Read_uint();
                    
                    local success, frame = pcall(decode_ico, stream:Read(frameSize));
                    if (not success) then error(format_pcall_error(frame), 2) end
                    
                    -- if hotspot data does not exist set to a default value
                    if (frame.hotspotX == nil) then frame.hotspotX = 0 end
                    if (frame.hotspotY == nil) then frame.hotspotY = 0 end
                    
                    LIST_fram[i] = frame;
                    
                    -- one byte padding if size is odd
                    if (frameSize%2 == 1) then
                        stream.Position = stream.Position+1;
                    end
                    
                end
            else -- unnecessary list, just skip it
                stream.Position = ckEnd;
            end
            
        elseif (ckID == "rate") then
            -- if anih was not reached until now
            if (ANIHEADER == nil) then
                error("bad argument #1 to '" .. __func__ .. "' (invalid chunk order)", 2);
            end
            
            for i = 1, ANIHEADER.nSteps do
                rate[i] = stream:Read_uint();
            end
        elseif (ckID == "seq ") then
            if (ANIHEADER == nil) then
                error("bad argument #1 to '" .. __func__ .. "' (invalid chunk order)", 2);
            end
            
            for i = 1, ANIHEADER.nSteps do
                seq [i] = stream:Read_uint()+1; -- add 1 to accomodate Lua index start
            end
        else -- unnecessary chunk, just skip it
            stream.Position = ckEnd;
        end
        
        -- one byte padding if chunk size is odd
        if (ckSize%2 == 1) then
            stream.Position = stream.Position+1;
        end
    end
    
    
    local animation = {}
    
    if (not ignoreInfo) then
        for k, v in pairs(LIST_INFO) do
            animation[k] = v;
        end
    end
    
    for step = 1, ANIHEADER.nSteps do
        local frame = LIST_fram[seq [step] or step]; -- if seq [step] is empty then fall back to step
        
        -- append corresponding rate to corresponding frames
        local rate = rate[step] or ANIHEADER.iDispRate;
        
        -- loop through all sizes of an icon (see decode_ico return table format)
        for frameVariant = 1, #frame do
            -- create a table to store all icon sizes
            if (animation[frameVariant] == nil) then animation[frameVariant] = {} end
            
            frame[frameVariant].rate = rate;
            
            animation[frameVariant][step] = frame[frameVariant];
        end
    end
    
    return animation;
end