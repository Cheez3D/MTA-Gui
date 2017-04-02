--[[ [===========================================================================================]

    NAME:    table decode_gif(string bytes)
    PURPOSE: Convert .gif files into drawable MTA:SA textures
    
    RETURNED TABLE STRUCTURE:
    
    {
        
    }
    
    REFERENCES: https://www.w3.org/Graphics/GIF/spec-gif89a.txt
                
                https://en.wikipedia.org/wiki/GIF
                
                http://commandlinefanatic.com/cgi-bin/showarticle.cgi?article=art011
                http://commandlinefanatic.com/cgi-bin/showarticle.cgi?article=art010
                
                http://giflib.sourceforge.net/whatsinagif/bits_and_bytes.html
                http://giflib.sourceforge.net/whatsinagif/lzw_image_data.html
                http://giflib.sourceforge.net/whatsinagif/animation_and_transparency.html
                
                http://www.onicos.com/staff/iz/formats/gif.html
                http://www.martinreddy.net/gfx/2d/GIF87a.txt
                http://www.fileformat.info/format/gif/egff.htm
                https://brianbondy.com/downloads/articles/gif.doc
                http://www.daubnet.com/en/file-format-gif
                
                https://stackoverflow.com/questions/26894809/gif-lzw-decompression

[=============================================================================================] ]]

-- [ CONSTANTS ] --

local function copy(t)
    if (t == nil) then
        error("caught nil", 2);
    end
    
    local t_copy = {}
    
    for k, v in pairs(t) do
        t_copy[k] = v;
    end
    
    return t_copy;
end

local EXTENSION_INTRODUCER = 0x21;

local APPLICATION_LABEL = 0xff;
local COMMENT_LABEL = 0xfe;
local GRAPHIC_CONTROL_LABEL = 0xf9;
local PLAIN_TEXT_LABEL = 0x01;

local IMAGE_SEPARATOR = 0x2c;

local TRAILER = 0x3b; -- signals EOF

local BLOCK_TERMINATOR = 0x00; -- signals end of block

local ALPHA255_BYTE = string.char(0xff);

local TRANSPARENT_PIXEL = string.char(0x00, 0x00, 0x00, 0x00);

-- [ FUNCTION ] --
local OUT = fileOpen("Testers/out.txt");
local FILE = fileOpen("Testers/file.txt");
function decode_gif(bytes, powerOfTwo)
    
    -- [ ASSERTION ] --
    
    local bytesType = type(bytes);
    if (bytesType ~= "string") then
        error("bad argument #1 to '" .. __func__ .. "' (string expected, got " .. bytesType .. ")", 2);
    end
    
    if (powerOfTwo ~= nil) then
        local powerOfTwoType = type(powerOfTwo);
        if (powerOfTwoType ~= "boolean") then
            error("bad argument #2 to '" .. __func__ .. "' (boolean expected, got " .. powerOfTwoType .. ")", 2);
        end
    else
        powerOfTwo = true;
    end
    
    -- [ ACTUAL CODE ] --
    
    -- function can olso be supplied with a file path instead of raw data
    -- we treat variable bytes as a file path to see if the file exists
    if (fileExists(bytes)) then
        local f = fileOpen(bytes, true); -- open file read-only
        
        if (not f) then
            error("bad argument #1 to '" .. __func__ .. "' (cannot open file)", 2);
        end
        
        -- if file exists then we substitute bytes with the contents of the file located in the path supplied
        bytes = fileRead(f, fileGetSize(f));
        
        fileClose(f);
    end
    
    
    local success, stream = pcall(Stream.New, bytes);
    if (not success) then error(format_pcall_error(stream), 2) end
    
    
    if (stream:Read(3) ~= "GIF") then
        error("bad argument #1 to '" .. __func__ .. "' (invalid file format)", 2);
    end
    
    local version = stream:Read(3);
    
    if (version ~= "87a") and (version ~= "89a") then
        error("bad argument #1 to '" .. __func__ .. "' (unsupported version)", 2);
    end
    
    
    local lsd = { -- logical screen descriptor
        canvasWidth  = stream:Read_ushort(),
        canvasHeight = stream:Read_ushort(),
        
        fields = stream:Read_uchar(),
        
        -- background color index, denotes which color to use for pixels with unspecified color index
        bgColorIndex = stream:Read_uchar(),
        
        pixelAspectRatio = stream:Read_uchar(),
    }
    
    do
        local fields = lsd.fields;
        
        lsd.fields = {
            gctFlag = bitExtract(fields, 7, 1), -- global color table flag, denotes wether a global color table exists
            gctSize = bitExtract(fields, 0, 3), -- number of entries in table is 2^(gctSize + 1)
            
            sortFlag = bitExtract(fields, 3, 1),
            
            colorResolution = bitExtract(fields, 4, 3),
        }
    end
    
    local gct; -- global color table
    
    if (lsd.fields.gctFlag == 1) then
        gct = {}
        
        for i = 1, 2^(lsd.fields.gctSize+1) do
            gct[i] = string.reverse(stream:Read(3));
        end
    end
    
    
    local identifier = stream:Read_uchar();
    
    while (identifier ~= TRAILER) do
        
        local current_gce;
        
        if (identifier == EXTENSION_INTRODUCER) then
            
            local label = stream:Read_uchar();
            
            if (label == GRAPHIC_CONTROL_LABEL) then
                
                local gce = { -- graphics control extension
                    size = stream:Read_uchar(),
                    
                    fields = stream:Read_uchar(),
                    
                    delayTime = stream:Read_ushort(),
                    
                    transparentColorIndex = stream:Read_uchar(),
                }
                
                local fields = gce.fields;
                
                gce.fields = {
                    transparentColorFlag = bitExtract(fields, 0, 1),
                    userInputFlag = bitExtract(fields, 1, 1),
                    
                    disposalMethod = bitExtract(fields, 2, 3),
                    
                    reserved = bitExtract(fields, 5, 3),
                }
                
                current_gce = gce;
                
            -- TODO:
            -- elseif (label == APPLICATION_LABEL) then
            -- elseif (label == COMMENT_LABEL) then
            -- elseif (label == PLAIN_TEXT_LABEL) then
            end
            
            -- continue reading possible left data until block terminator is reached
            repeat local byte = stream:Read_uchar();
            until (byte == BLOCK_TERMINATOR);
            
        elseif (identifier == IMAGE_SEPARATOR) then
        
            local descriptor = {
                imageX = stream:Read_ushort(),
                imageY = stream:Read_ushort(),
                
                imageWidth  = stream:Read_ushort(),
                imageHeight = stream:Read_ushort(),
                
                fields = stream:Read_uchar(),
            }
            
            local fields = descriptor.fields;
            
            descriptor.fields = {
                lctFlag = bitExtract(fields, 7, 1), -- local color table flag, denotes wether a local color table exists
                lctSize = bitExtract(fields, 0, 3), -- number of entries in table is 2^(lctSize + 1)
                
                interlaceFlag = bitExtract(fields, 6, 1),
                sortFlag = bitExtract(fields, 5, 1),
                
                reserved = bitExtract(fields, 3, 2),
            }
            
            local lct; -- local color table
            
            if (descriptor.fields.lctFlag == 1) then
                lct = {}
                
                for i = 1, 2^(descriptor.fields.lctSize+1) do
                    lct[i] = string.reverse(stream:Read(3));
                end
            end
            
            
            -- [ Image Data Block ]
            
            -- the minimum LZW code size from which we compute
            -- the starting code size for reading the codes
            -- from the image data (by adding 1 to it)
            local lzwMinCodeSize = stream:Read_uchar();
            
            
            -- reading all the sub blocks and converting them into a stream
            -- to avoid having to deal with reading the sizes of the subblocks
            local blockData = {}
            
            local subBlockSize = stream:Read_uchar();
            
            while (subBlockSize ~= BLOCK_TERMINATOR) do
                blockData[#blockData+1] = stream:Read(subBlockSize);
                
                subBlockSize = stream:Read_uchar();
            end
            
            blockData = table.concat(blockData);
            
            local success, blockReader = pcall(Stream.New, blockData);
            if (not success) then error(format_pcall_error(blockReader), 2) end
            
            
            
            local pixels = {}
            
            -- color table to use for this image block
            -- if lct does not exist fall back to gct
            local colorTable = lct or gct;
            
            -- initialize the dictionary for storing the LZW codes
            local dict = {}
            
            -- insert all colors into dictionary
            for i = 1, #colorTable do dict[i] = { i } end
            
            -- insert CLEAR_CODE and EOI_CODE into dictionary
            local CLEAR_CODE = #colorTable; dict[#dict+1] = {}
            local EOI_CODE = CLEAR_CODE+1;  dict[#dict+1] = {}
            
            -- index from which LZW compression codes start
            local lzwCodesOffset = #dict+1;
            
            local previousCode, code;
            local codeSize = lzwMinCodeSize+1;

            -- variable keeping track of starting point
            -- for reading from byte
            local bitOffset = 0;
            
            local byte = blockReader:Read_uchar();
            
            -- while we haven't reached the EOI_CODE or the end of the blockReader
            while ( (code ~= EOI_CODE) and (not blockReader.EOF) ) do
                
                -- number of codes (including partial ones)
                -- after bitOffset bits residing in byte
                local codesInByte = math.ceil((8-bitOffset) / codeSize);
                
                
                local i = 1;
                
                while (i <= codesInByte) do
                    
                    -- if current code is a partial code
                    if ((8-bitOffset) < codeSize) then
                        
                        -- reading from bytes separately and then adding the results in base 2 to form the code
                        
                        -- number of bytes occupied by the code
                        -- can span across up to 3 bytes (max codeSize is 12 bits)
                        
                        -- e.g. 12 bit code starting at bit 7 of a first byte spans across 3 bytes
                        -- +-----------------------------------+
                        -- | 1xxx xxxx | 1101 0111 | xxxx x110 |
                        -- |  BYTE 1   |  BYTE 2   |  BYTE 3   |
                        -- +-----------------------------------+
                        
                        -- bits are read from right to left!
                        local bytesOccupied = math.ceil((bitOffset+codeSize) / 8);
                        
                        -- we substract 2 from bytesCount because we exclude first and last bytes
                        local middleBytes = bytesOccupied-2;
                        
                        -- how many bits are occupied in the first byte by the code
                        local firstByteBitSpan = 8-bitOffset;
                        
                        -- how many bits are occupied in the last byte by the code
                        local lastByteBitSpan = codeSize - (firstByteBitSpan + 8*middleBytes);
                        
                        
                        -- reading from first byte
                        code = bitExtract(byte, bitOffset, firstByteBitSpan);
                        
                        -- reading from fully occupied intermediate bytes
                        for j = 1, middleBytes do
                            byte = blockReader:Read_uchar();
                            
                            code = 2^(firstByteBitSpan + 8*(j-1))*byte + code;
                        end
                        
                        -- reading from last byte
                        byte = blockReader:Read_uchar();
                        
                        code = 2^(firstByteBitSpan + 8*middleBytes) * bitExtract(byte, 0, lastByteBitSpan) + code;
                        
                        -- if there are still codes left to read
                        -- from byte then back up
                        if (lastByteBitSpan < 8) then
                            blockReader.Position = blockReader.Position-1;
                        end
                        
                    -- if it is not a partial code then reading is straight forward
                    else
                        code = bitExtract(byte, bitOffset, codeSize);
                    end
                    
                    -- advance bitOffset for reading next code (wrapping around 8)
                    bitOffset = (bitOffset+codeSize)%8;
                    
                    -- print_file(OUT, code);
                    
                    if (code == CLEAR_CODE) then
                        -- clear all dictionary entries created during the decoding process
                        -- (i.e. all entries > EOI_CODE)
                        for j = lzwCodesOffset, #dict do dict[j] = nil end
                        
                        -- it is necessary to reset previousCode
                        -- because otherwise it might get picked up at [*] (see below)
                        previousCode = nil;
                        
                        -- reset code size
                        codeSize = lzwMinCodeSize+1;
                        
                        codesOffset = #dict;
                    else
                        -- accomodate Lua indexing which starts from 1
                        code = code+1;
                        
                        -- output of the decoding of the LZW code
                        local colorIndexes;
                        
                        -- Initialize code table
                        -- let CODE be the first code in the code stream
                        -- output {CODE} to index stream
                        -- <LOOP POINT>
                        -- let CODE be the next code in the code stream
                        -- is CODE in the code table?
                        -- Yes:
                            -- output {CODE} to index stream
                            -- let K be the first index in {CODE}
                            -- add {CODE-1}+K to the code table
                        -- No:
                            -- let K be the first index of {CODE-1}
                            -- output {CODE-1}+K to index stream
                            -- add {CODE-1}+K to code table
                        -- return to LOOP POINT
                        
                        local dictEntry = dict[code];
                        
                        if (dictEntry) then
                            colorIndexes = dictEntry;
                            
                            local K = dictEntry[1];
                            
                            if (previousCode and dict[previousCode]) then -- [*]
                                local v = copy(dict[previousCode]);
                                v[#v+1] = K;
                                
                                dict[#dict+1] = v;
                            end
                        else
                            local v = copy(dict[previousCode]);
                            
                            local K = v[1];
                            
                            v[#v+1] = K;
                            
                            colorIndexes = v;
                            
                            
                            dict[#dict+1] = v;
                        end
                        
                        for j = 1, #colorIndexes do
                            pixels[#pixels+1] = colorTable[colorIndexes[j]] .. ALPHA255_BYTE;
                        end
                        
                        
                        -- if inserting into dictionary increased codeSize by 1 bit
                        if (#dict == 2^codeSize) and (codeSize < 12) then
                            codeSize = codeSize+1;
                            
                            -- if incrementing the codeSize lowers codesInByte for current byte by 1 (max code size is 12 bits)
                            -- (i.e. if advancing with the new codeSize gets us to the end of the byte)
                            if (bitOffset + codeSize == 8) then
                                codesInByte = codesInByte-1;
                            end
                        end
                        
                        -- update lastCode on this branch so that
                        -- CLEAR_CODE and EOI_CODE are not taken into consideration
                        previousCode = code;
                    end
                    
                    i = i+1;
                end
                
                byte = blockReader:Read_uchar();
            end
            
            pixels[#pixels+1] = string.char(
                bitExtract(descriptor.imageWidth,  0, 8), bitExtract(descriptor.imageWidth,  8, 8),
                bitExtract(descriptor.imageHeight, 0, 8), bitExtract(descriptor.imageHeight, 8, 8)
            );
            
            pixels = table.concat(pixels);
            
            return dxCreateTexture(pixels, "argb", false, "clamp"), descriptor.imageWidth, descriptor.imageHeight;
        end
        
        identifier = stream:Read_uchar();
    end
    
    return;
end

local h1, h2, h3 = debug.gethook();
debug.sethook();

local s = getTickCount();

local tex, w, h = decode_gif("Testers/globe.gif");

print(getTickCount() - s);

debug.sethook(nil, h1, h2, h3);

addEventHandler("onClientRender", root, function()
    dxDrawImage(200, 200, w, h, tex);
end);

fileClose(OUT);
fileClose(FILE);