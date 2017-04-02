--[[ [=============================================================================================================================================]

    NAME:       table decode_ico(string bytes)
    PURPOSE:    Convert .ico and .cur files into drawable MTA:SA textures
    
    RETURNED TABLE STRUCTURE:
    
    {
        [1] = {
            width = 16, height = 16,
            
            [ hotspotX = 0, hotspotY = 0, ] -- only for CUR
            
            texture = userdata: xxxxxxxx
        },
        
        [2] = {
            width = 32, height = 32,
            
            [ hotspotX = 0, hotspotY = 0, ] -- only for CUR
            
            texture = userdata: xxxxxxxx
        },
        
        ...
    }
    
    REFERENCES: http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm
                https://www.daubnet.com/en/file-format-cur
                https://www.daubnet.com/en/file-format-ico
                https://en.wikipedia.org/wiki/BMP_file_format
                https://en.wikipedia.org/wiki/ICO_(file_format)
                https://msdn.microsoft.com/en-us/library/ms997538.aspx
                http://vitiy.info/manual-decoding-of-ico-file-format-small-c-cross-platform-decoder-lib/
                https://social.msdn.microsoft.com/Forums/vstudio/en-US/8da318b3-1c14-4225-859c-138f9b9c749f/resource-injection?forum=winforms
    
    TEST FILES: https://github.com/daleharvey/mozilla-central/tree/master/image/test/reftest/ico
    
[===============================================================================================================================================] ]]

-- [ CONSTANTS ] --

local PNG_SIGNATURE = string.char(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a);

local ICO, CUR = 1, 2;

local BI_RGB = 0;

local ALPHA255_BYTE = string.char(0xff);

local TRANSPARENT_PIXEL = string.char(0x00, 0x00, 0x00, 0x00);

-- [ FUNCTION ] --

function decode_ico(bytes)
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
    
    
    local ICONDIR = {
        idReserved = stream:Read_ushort(),
        
        idType = stream:Read_ushort(),
        
        idCount   = stream:Read_ushort(),
        idEntries = {}
    }
    
    if (ICONDIR.idReserved ~= 0) then
        error("bad argument #1 to '" .. __func__ .. "' (invalid file format)", 2);
    elseif (ICONDIR.idType ~= ICO) and (ICONDIR.idType ~= CUR) then
        error("bad argument #1 to '" .. __func__ .. "' (invalid icon type)", 2);
    elseif (ICONDIR.idCount == 0) then
        error("bad argument #1 to '" .. __func__ .. "' (no entries found in ICONDIR)", 2);
    end
    
    for i = 1, ICONDIR.idCount do 
        local ICONDIRENTRY = {
            bWidth  = stream:Read_uchar(),
            bHeight = stream:Read_uchar(),
            
            bColorCount = stream:Read_uchar(),
            
            bReserved = stream:Read_uchar(),
            
            wPlanes   = stream:Read_ushort(),
            wBitCount = stream:Read_ushort(),
            
            dwBytesInRes  = stream:Read_uint(),
            dwImageOffset = stream:Read_uint(),
        }
        
        if (ICONDIRENTRY.bReserved ~= 0) then
            error("bad argument #1 to '" .. __func__ .. "' (invalid file format)", 2);
        end
        
        ICONDIR.idEntries[i] = ICONDIRENTRY;
    end
    
    
    local iconVariants = {}
    
    for i = 1, ICONDIR.idCount do
        local icon = {}
        
        local ICONDIRENTRY = ICONDIR.idEntries[i];
        
        -- if file type is CUR then add hotspot data
        if (ICONDIR.idType == CUR) then
            icon.hotspotX = ICONDIRENTRY.wPlanes;
            icon.hotspotY = ICONDIRENTRY.wBitCount;
        end
        
        -- set cursor to image data
        stream.Position = ICONDIRENTRY.dwImageOffset;
        
        
        local pixels;
        
        if (stream:Read(8) == PNG_SIGNATURE) then -- png
            stream.Position = stream.Position+8;
            
            icon.width  = stream:Read_uint(Enum.Endianness.BigEndian);
            icon.height = stream:Read_uint(Enum.Endianness.BigEndian);
            
            stream.Position = stream.Position-24;
            
            pixels = stream:Read(size);
        else -- bitmap
            stream.Position = stream.Position-8;
            
            local BITMAPINFOHEADER = {
                biSize = stream:Read_uint(),
                
                biWidth  = stream:Read_uint(),
                biHeight = stream:Read_int(),
                
                biPlanes   = stream:Read_ushort(),
                biBitCount = stream:Read_ushort(),
                
                biCompression = stream:Read_uint(),
                biSizeImage   = stream:Read_uint(),
                
                -- preferred resolution in pixels per meter
                biXPelsPerMeter = stream:Read_uint(),
                biYPelsPerMeter = stream:Read_uint(),
                
                biClrUsed      = stream:Read_uint(), -- number color map entries that are actually used
                biClrImportant = stream:Read_uint(), -- number of significant colors
            }
            
            if (BITMAPINFOHEADER.biSize ~= 40) then
                error("bad argument #1 to '" .. __func__ .. "' (unsupported bitmap)", 2);
            end
            
            local width  = BITMAPINFOHEADER.biWidth;
            local height = BITMAPINFOHEADER.biHeight;
            
            -- variable determining if image is stored upside-down
            local isUpsideDown = true;
            
            -- if height is negative then image is not stored upside-down
            if (height < 0) then
                isUpsideDown = false;
                
                height = math.abs(height);
            end
            
            -- variable determining if image has AND mask
            -- for images with AND mask BITMAPINFOHEADER.biHeight is double the actual height in ICONDIRENTRY
            local hasAndMask = (ICONDIRENTRY.bHeight ~= height);
            
            if (hasAndMask) then
                height = height/2;
            end
            
            icon.width  = width;
            icon.height = height;
            
            local bitsPerPixel  = BITMAPINFOHEADER.biBitCount;
            local pixelsPerByte = 8/bitsPerPixel;
            
            if (BITMAPINFOHEADER.biCompression ~= BI_RGB) then
                error("bad argument #1 to '" .. __func__ .. "' (unsupported bitmap compression)", 2);
            end
            
            pixels = {}
            
            local padding = (4-(width/pixelsPerByte)%4)%4;
            
            if (bitsPerPixel == 1) or (bitsPerPixel == 2) or (bitsPerPixel == 4) or (bitsPerPixel == 8) then
                local colors = {} -- color table
                
                for j = 1, 2^(BITMAPINFOHEADER.biPlanes*bitsPerPixel) do
                    colors[j] = stream:Read(3) .. ALPHA255_BYTE;
                    
                    stream.Position = stream.Position+1; -- skip icReserved
                end
                
                local currentByte;
                
                for y = 1, height do -- XOR mask
                    local currentRow = {}
                    
                    for x = 0, width-1 do
                        local currentBit = x%pixelsPerByte;
                        
                        if (currentBit == 0) then
                            currentByte = stream:Read_uchar();
                        end
                        
                        currentRow[x+1] = colors[bitExtract(currentByte, ((pixelsPerByte-1)-currentBit)*bitsPerPixel, bitsPerPixel) + 1];
                    end
                    
                    pixels[y] = currentRow;
                    
                    stream.Position = stream.Position+padding;
                end
            -- elseif (bitsPerPixel == 16) then
                -- [=================================================================================]
                -- TO TAKE INTO CONSIDERATION (XRGB555 and RGB565)
                -- REFERENCES: http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm
                --             https://en.wikipedia.org/wiki/BMP_file_format
                --             http://www.fileformat.info/format/bmp/egff.htm
                --             https://msdn.microsoft.com/en-us/library/windows/desktop/dd318229.aspx
                --             https://msdn.microsoft.com/en-us/library/windows/desktop/dd390989.aspx
                -- [=================================================================================]
            elseif (bitsPerPixel == 24) then
                for y = 1, height do
                    local currentRow = {}
                    
                    for x = 1, width do
                        currentRow[x] = stream:Read(3) .. ALPHA255_BYTE;
                    end
                    
                    pixels[y] = currentRow;
                    
                    stream.Position = stream.Position+padding;
                end
            elseif (bitsPerPixel == 32) then
                for y = 1, height do
                    local currentRow = {}
                    
                    for x = 1, width do
                        currentRow[x] = stream:Read(4);
                    end
                    
                    pixels[y] = currentRow;
                    
                    stream.Position = stream.Position+padding;
                end
            else
                error("bad argument #1 to '" .. __func__ .. "' (unsupported bitmap bit depth)", 2);
            end
            
            if (hasAndMask or (stream.Position ~= ICONDIRENTRY.dwImageOffset + ICONDIRENTRY.dwBytesInRes)) then -- AND mask
                if (bitsPerPixel ~= 1) then
                    padding = (4-(width/8)%4)%4;
                end
                
                for y = 1, height do
                    local currentRow = pixels[y];
                    
                    for x = 0, width-1 do
                        local currentBit = x%8;
                        
                        if (currentBit == 0) then
                            currentByte = stream:Read_uchar();
                        end
                        
                        if (bitExtract(currentByte, 7-currentBit) == 1) then
                            currentRow[x+1] = TRANSPARENT_PIXEL;
                        end
                    end
                    
                    stream.Position = stream.Position+padding;
                end
            end
            
            for y = 1, height do
                pixels[y] = table.concat(pixels[y]);
            end
            
            -- flip image
            if (isUpsideDown) then
                for y = 1, height/2 do
                    local flippedRowY = height-y+1;
                    
                    local temp = pixels[y];
                    
                    pixels[y] = pixels[flippedRowY];
                    pixels[flippedRowY] = temp;
                end
            end
            
            -- append size to accomodate MTA pixel data format
            pixels[#pixels+1] = string.char(
                bitExtract(width,  0, 8), bitExtract(width,  8, 8),
                bitExtract(height, 0, 8), bitExtract(height, 8, 8)
            );
            
            pixels = table.concat(pixels);
        end
        
        local texture = dxCreateTexture(pixels, "argb", false, "clamp");
        
        if (not texture) then
            error("bad argument #1 to '" .. __func__ .. "' (invalid image data)", 2);
        end
        
        icon.texture = texture;
        
        iconVariants[i] = icon;
    end
    
    if (#iconVariants > 1) then
        table.sort(iconVariants, function(first, second)
            return (first.height < second.height) or (first.width < second.width);
        end);
    end
    
    return iconVariants;
end



-- local ico = decode_ico("Testers/4bpp-24x14-Transparent.ico")[1];

-- addEventHandler("onClientRender", root, function()
    -- dxDrawImage(200, 200, ico.width, ico.height, ico.texture);
-- end);