--[[ [===========================================================================================]

    NAME:    table decode_gif(string bytes)
    PURPOSE: Convert .gif files into drawable MTA:SA textures
    
    RETURNED TABLE STRUCTURE:
    
    {
        
    }
    
    REFERENCES: https://en.wikipedia.org/wiki/GIF
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

[=============================================================================================] ]]

-- [ CONSTANTS ]

local function copy(t)
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

-- [ FUNCTION ] --
local FILE_OUT = fileOpen("Testers/out.txt");
function decode_gif(bytes)
    -- [ ASSERTION ] --
    
    local bytesType = type(bytes);
    if (bytesType ~= "string") then
        error("bad argument #1 to '" .. __func__ .. "' (string expected, got " .. bytesType .. ")", 2);
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
            
            
            -- IMAGE DATA BLOCK
            
            local lzwMinCodeSize = stream:Read_uchar();
            
            
            
            local block = {}
            
            local subBlockSize = stream:Read_uchar();
            
            while (subBlockSize ~= BLOCK_TERMINATOR) do
                block[#block + 1] = stream:Read(subBlockSize);
                
                subBlockSize = stream:Read_uchar();
            end
            
            block = table.concat(block);
            
            local success, blockReader = pcall(Stream.New, block);
            if (not success) then error(format_pcall_error(stream), 2) end
            
            
            
            local pixels = {}
            
            local colorTable = lct or gct; -- if lct does not exist fall back to gct
            
            local codes = {}
            
            for i = 1, #colorTable do codes[i] = { i } end
            
            local CLEAR_CODE = #colorTable;   codes[#codes+1] = {}
            local EOI_CODE   = #colorTable+1; codes[#codes+1] = {}
            
            -- index from which lzw compression codes start
            local lzwCodesOffset = #codes + 1;
            
            
            
            local lastCode, code;
            local codeSize = lzwMinCodeSize + 1;
            
            -- dummy variable for testing, simulates increase in codeSize as we are reading codes
            local codesOffset = #codes-1;
            
            
            local byte = blockReader:Read_uchar();
            
            -- variable keeping track of starting point
            -- for reading from byte
            local bitOffset = 0;
            
            while ( (code ~= EOI_CODE) and (not blockReader.EOF) ) do
                
                -- number of codes (including partial ones)
                -- after bitOffset bits residing in byte
                local codesInByte = math.ceil((8 - bitOffset) / codeSize);
                
                local i = 1;
                
                while (i <= codesInByte) do
                    -- if current code is a partial code
                    if ((8-bitOffset) < codeSize) then
                        
                        -- read from bytes separately and then add in base 2 to form the code
                        
                        
                        -- number of bytes occupied by the code
                        -- can span across up to 3 bytes (max codeSize is 12 bits)
                        
                        -- e.g. 12 bit code starting at bit 7 of one byte spans across 3 bytes
                        -- | 1xxx xxxx | 1101 0111 | xxxx x110 |
                        -- |  BYTE 1   |  BYTE 2   |  BYTE 3   |
                        
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
                        
                        -- reading from fully occupied bytes
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
                    
                    if (code == CLEAR_CODE) then
                        -- reset code size
                        codeSize = lzwMinCodeSize + 1;
                        
                        -- clear all codes bigger than those in color table
                        for j = lzwCodesOffset, #codes do codes[j] = nil end
                        
                        codesOffset = #codes-1;
                    elseif (code == EOI_CODE) then
                        -- ?
                    else
                        -- TODO: get rid of this!
                        codesOffset = codesOffset + 1;
                        
                        -- investigate why not -1
                        if (2^codeSize == codesOffset) then
                            codeSize = codeSize + 1;
                            
                            -- if incrementing the codeSize lowers codesInByte for current byte by 1 (max code size is 12 bits)
                            -- (i.e. if advancing with the new codeSize gets us to the end of the byte)
                            if (bitOffset + codeSize == 8) then
                                codesInByte = codesInByte-1;
                            end
                        end
                        
                        
                        if (codes[code+1]) then
                            local codeValue = codes[code+1];
                            output = codeValue;
                            
                            if (lastCode and codes[lastCode+1]) then
                                local K = codeValue[1];
                                
                                local toAdd = copy(codes[lastCode+1]);
                                toAdd[#toAdd+1] = K;
                                
                                codes[#codes+1] = toAdd;
                            end
                        else
                            if (lastCode and codes[lastCode+1]) then
                                local toAdd = copy(codes[lastCode+1]);
                                toAdd[#toAdd+1] = toAdd[1];
                                
                                output = toAdd;
                                
                                codes[#codes+1] = toAdd;
                            end
                        end
                        
                        for j = 1, #output do
                            if (#pixels < descriptor.imageWidth*descriptor.imageHeight) then
                            pixels[#pixels+1] = colorTable[output[j]] .. string.char(0xFF);
                            end
                        end
                        
                        
                        -- update lastCode here so that CLEAR_CODE and EOI_CODE
                        -- are not taken into consideration
                        lastCode = code;
                    end
                    
                    i = i+1;
                end
                
                byte = blockReader:Read_uchar();
            end
            
            pixels[#pixels+1] = string.char(
                bitExtract(descriptor.imageWidth,  0, 8), bitExtract(descriptor.imageWidth,  8, 8),
                bitExtract(descriptor.imageHeight, 0, 8), bitExtract(descriptor.imageHeight, 8, 8)
            );
            
            print(descriptor.imageWidth, descriptor.imageHeight);
            
            pixels = table.concat(pixels);
            print_file(FILE_OUT, pixels);
            
            return dxCreateTexture(pixels, "argb", false, "clamp");
        end
        
        identifier = stream:Read_uchar();
    end
    
    return;
end

local tex = decode_gif("Testers/cradle.gif"); -- corrupted?

addEventHandler("onClientRender", root, function()
    dxDrawImage(200, 200, 480, 360, tex);
end);

fileClose(FILE_OUT);