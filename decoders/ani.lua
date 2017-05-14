--[[ [=======================================================================================]

    NAME:    table decode_ani(string bytes)
    PURPOSE: Convert .ani files into drawable MTA:SA textures
    
    RETURNED TABLE STRUCTURE:
    
    {
        -- OPTIONAL: only if ani contains any info and ignoreInfo is false, otherwise nil
        [ name = "Cursor Name",
          artist = "Artist Name",
          copyright = "Copyright", ]
        
        [1] = {
            [1] = {
                width = 16, height = 16,
                
                hotspotX = 0, hotspotY = 0,
                
                rate = 5,
                
                image = userdata
            },
            
            [2] = {
                width = 16, height = 16,
                
                hotspotX = 0, hotspotY = 0,
                
                rate = 5,
                
                image = userdata
            },
            
            ...
        },
        
        [2] = {
            [1] = {
                width = 32, height = 32,
                
                hotspotX = 0, hotspotY = 0,
                
                rate = 5,
                
                image = userdata
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

local INFO_FIELD_NAMES = { IART = "artist", ICOP = "copyright", INAM = "name" }



function decode_ani(bytes, ignoreInfo)
    
    -- [ ====================== [ ASSERTION ] ====================== ]
    
    local bytesType = type(bytes);
    
    if (bytesType ~= "string") then
        error("bad argument #1 to '" ..__func__.. "' (string expected, got " ..bytesType.. ")");
    end
    
    if (ignoreInfo ~= nil) then
        local ignoreInfoType = type(ignoreInfo);
        
        if (ignoreInfoType ~= "boolean") then
            error("bad argument #2 to '" ..__func__.. "' (boolean expected, got " ..ignoreInfoType.. ")");
        end
    else
        ignoreInfo = true;
    end
    
    
    
    -- function can also be supplied with a file path instead of raw data
    -- we treat variable bytes as a file path to see if the file exists
    if (fileExists(bytes)) then
        local f = fileOpen(bytes, true); -- open file read-only
        
        bytes = fileRead(f, fileGetSize(f));
        
        fileClose(f);
    end
    
    
    local success, stream = pcall(Stream.new, bytes);
    
    if (not success) then
        error("bad argument #1 to '" ..__func__.. "' (could not create stream) -> " ..stream, 2);
    end
    
    if (stream.read(4) ~= "RIFF") then
        error("bad argument #1 to '" ..__func__.. "' (invalid file format)", 2);
    end
    
    
    local RIFF_Size = stream.read_uint();
    local RIFF_End = stream.pos + RIFF_Size;
    
    
    if (stream.read(4) ~= "ACON") then
        error("bad argument #1 to '" ..__func__.. "' (invalid file format)", 2);
    end
    
    
    local ANIHEADER;
    
    local LIST_INFO = {}
    local LIST_fram = {}
    local rate = {}
    local seq  = {}
    
    -- read all possible chunks (they can be stored in any order)
    while (stream.pos ~= RIFF_End) do
        
        local ckID = stream.read(4); -- chunk ID
        
        local ckSize = stream.read_uint(); -- chunk size
        local ckEnd = stream.pos + ckSize; -- chunk end position
        
        if (ckID == "anih") then
        
            ANIHEADER = {
                cbSize = stream.read_uint(),
                
                nFrames = stream.read_uint(), -- number of stored frames
                nSteps = stream.read_uint(), -- number of steps (might contain duplicate frames, depends on seq  chunk)
                
                iWidth = stream.read_uint(),
                iHeight = stream.read_uint(),
                
                iBitCount = stream.read_uint(),
                nPlanes = stream.read_uint(),
                
                iDispRate = stream.read_uint(), -- display rate in jiffies (1 jiffy = 1/60 of a second)
                
                bfAttributes = stream.read_uint(),
            }
            
            if (ANIHEADER.cbSize ~= 36) then
                error("bad argument #1 to '" ..__func__.. "' (unsupported version)", 2);
            end
            
            local bfAttributes = ANIHEADER.bfAttributes;
            
            ANIHEADER.bfAttributes = {
                icoFlag = bitExtract(bfAttributes, 0, 1), -- denotes whether file contains ico/cur data or raw data
                seqFlag = bitExtract(bfAttributes, 1, 1)  -- denotes whether file contains sequence data (seq  chunk)
            }
            
        elseif (ckID == "LIST") then
            
            local LIST_Type = stream.read(4);
            
            if (LIST_Type == "INFO") and (not ignoreInfo) then
            
                while (stream.pos ~= ckEnd) do
                
                    local INFO_Type = stream.read(4);
                    local INFO_Size = stream.read_uint();
                    
                    local fieldName = INFO_FIELD_NAMES[INFO_Type] or INFO_Type;
                    
                    LIST_INFO[fieldName] = stream.read(INFO_Size);
                    
                    -- skip one byte padding if size is odd
                    if (INFO_Size%2 == 1) then
                        stream.pos = stream.pos+1;
                    end
                end
                
            elseif (LIST_Type == "fram") then
                
                if (ANIHEADER == nil) then
                    error("bad argument #1 to '" ..__func__.. "' (invalid chunk order)", 2);
                end
                
                if (ANIHEADER.bfAttributes.icoFlag ~= 1) then
                    error("bad argument #1 to '" ..__func__.. "' (invalid file format)", 2);
                end
                
                for i = 1, ANIHEADER.nFrames do
                    if (stream.read(4) ~= "icon") then
                        error("bad argument #1 to '" ..__func__.. "' (invalid file format)", 2);
                    end
                    
                    local frameSize = stream.read_uint();
                    
                    local success, frame = pcall(decode_ico, stream.read(frameSize));
                    
                    if (not success) then
                        error("bad argument #1 to '" ..__func__.. "' (could not decode frame) -> " .. frame, 2);
                    end
                    
                    -- if hotspot data does not exist set to a default value
                    if (frame.hotspotX == nil) then frame.hotspotX = 0 end
                    if (frame.hotspotY == nil) then frame.hotspotY = 0 end
                    
                    LIST_fram[i] = frame;
                    
                    -- one byte padding if size is odd
                    if (frameSize%2 == 1) then
                        stream.pos = stream.pos+1;
                    end
                    
                end
            else
                -- unnecessary list, just skip it
                stream.pos = ckEnd;
            end
            
        elseif (ckID == "rate") then
            
            -- if anih was not reached until now
            if (ANIHEADER == nil) then
                error("bad argument #1 to '" ..__func__.. "' (invalid chunk order)", 2);
            end
            
            for i = 1, ANIHEADER.nSteps do
                rate[i] = stream.read_uint();
            end
            
        elseif (ckID == "seq ") then
            
            if (ANIHEADER == nil) then
                error("bad argument #1 to '" ..__func__.. "' (invalid chunk order)", 2);
            end
            
            for i = 1, ANIHEADER.nSteps do
                seq [i] = stream.read_uint()+1; -- add 1 to accomodate Lua index start
            end
            
        else
            -- unnecessary chunk, just skip it
            stream.pos = ckEnd;
        end
        
        -- one byte padding if chunk size is odd
        if (ckSize%2 == 1) then
            stream.pos = stream.pos+1;
        end
    end
    
    
    local aniVariants = {}
    
    if (not ignoreInfo) then
        for k, v in pairs(LIST_INFO) do
            aniVariants[k] = v;
        end
    end
    
    
    for step = 1, ANIHEADER.nSteps do
        
        -- variable containing all the ico variants (sizes) for the current frame
        -- if seq [step] is empty then fall back to step
        local frame = LIST_fram[seq [step] or step];
        
        -- append corresponding rate to corresponding frames
        local rate = rate[step] or ANIHEADER.iDispRate;
        
        
        -- loop through all sizes of an icon (see decode_ico return table format)
        for sizeID = 1, #frame do
            
            -- create a table to store all icon sizes
            if (not aniVariants[sizeID]) then
                aniVariants[sizeID] = {}
            end
            
            frame[sizeID].rate = rate;
            
            aniVariants[sizeID][step] = frame[sizeID];
            
        end
        
    end
    
    return aniVariants;
end






-- local ani = decode_ani("PointerSchemes/PulseGlass/Busy.ani")[1];

-- local i = 1;
-- local t = getTickCount();

-- addEventHandler("onClientRender", root, function()
    -- if ((getTickCount() - t) >= ani[i].rate*(50/3)) then print(i, ani[i].rate*(50/3), "ms");
        -- t = getTickCount();
        
        -- i = i+1;
        
        -- if (i > #ani) then i = 1 end
    -- end
    
    -- dxDrawImage(200, 200, ani[i].width, ani[i].height, ani[i].image);
-- end);