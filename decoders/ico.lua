--[[ ============================================================================================================================================= ]

    NAME:       table decode_ico(string bytes)
    PURPOSE:    Convert .ico and .cur files into drawable MTA:SA textures
    
    RETURNED TABLE STRUCTURE (EXAMPLE):
    
    {
        [1] = {
            width = 16, height = 16,
            
            -- OPTIONAL: only for cursors
            hotspotX = 0, hotspotY = 0,
            
            texture = userdata,
        },
        
        [2] = {
            width = 32, height = 32,
            
            -- OPTIONAL: only for cursors
            hotspotX = 0, hotspotY = 0,
            
            texture = userdata,
        },
        
        ...
    }
    
    REFERENCES: http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm
                
                https://www.daubnet.com/en/file-format-cur
                https://www.daubnet.com/en/file-format-ico
                
                https://en.wikipedia.org/wiki/BMP_file_format
                https://en.wikipedia.org/wiki/ICO_(file_format)
                
                https://msdn.microsoft.com/en-us/library/ms997538.aspx
                https://social.msdn.microsoft.com/Forums/vstudio/en-US/8da318b3-1c14-4225-859c-138f9b9c749f/resource-injection?forum=winforms
                
                http://vitiy.info/manual-decoding-of-ico-file-format-small-c-cross-platform-decoder-lib/
                
    TEST FILES: https://github.com/daleharvey/mozilla-central/tree/master/image/test/reftest/ico
    
--[ ============================================================================================================================================= ]]


local ICO, CUR = 1, 2;

local PNG_SIGNATURE = string.char(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a);

local BI_RGB = 0;

local ALPHA255_BYTE = string.char(0xff);

local TRANSPARENT_PIXEL = string.char(0x00, 0x00, 0x00, 0x00);



local decode_bitmap_data;

function decode_ico(bytes)
    
    -- [ ====================== [ ASSERTION ] ====================== ]
    
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
    
    if (not success) then
        error("bad argument #1 to '" .. __func__ .. "' (could not create stream -> " .. stream .. ")", 2);
    end
    
    
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
    
    ICONDIR.isCUR = (ICONDIR.idType == CUR);
    
    
    for i = 1, ICONDIR.idCount do 
        local ICONDIRENTRY = {
            bWidth  = stream:Read_uchar(),
            bHeight = stream:Read_uchar(),
            
            bColorCount = stream:Read_uchar(),
            
            bReserved = stream:Read_uchar(),
            
            wPlanes   = stream:Read_ushort(),
            wBitCount = stream:Read_ushort(),
            
            dwBytesInRes  = stream:Read_uint(), -- bytes in resource
            dwImageOffset = stream:Read_uint(),
        }
        
        if (ICONDIRENTRY.bReserved ~= 0) then
            error("bad argument #1 to '" .. __func__ .. "' (invalid file format)", 2);
        end
        
        ICONDIR.idEntries[i] = ICONDIRENTRY;
    end
    
    
    local icoVariants = {}
    
    for i = 1, ICONDIR.idCount do
        
        local ICONDIRENTRY = ICONDIR.idEntries[i];
        
        stream.Position = ICONDIRENTRY.dwImageOffset; -- set cursor to image data
        
        
        local texture, textureWidth, textureHeight;
        
        if (stream:Read(8) == PNG_SIGNATURE) then
            
            -- icon is stored as a png image
            
            stream.Position = stream.Position+8;
            
            textureWidth  = stream:Read_uint(Enum.Endianness.BigEndian);
            textureHeight = stream:Read_uint(Enum.Endianness.BigEndian);
            
            stream.Position = stream.Position-24;
            
            pixelData = stream:Read(ICONDIRENTRY.dwBytesInRes);
            
            
            texture = dxCreateTexture(pixelData, "argb", false, "clamp");
            
        else
        
            -- icon is stored as a bitmap
            
            stream.Position = stream.Position-8;
            
            texture, textureWidth, textureHeight = decode_bitmap_data(stream, ICONDIRENTRY);
            
        end
        
        icoVariants[i] = {
            width  = textureWidth,
            height = textureHeight,
            
            hotspotX = ICONDIR.isCUR and ICONDIRENTRY.wPlanes,
            hotspotY = ICONDIR.isCUR and ICONDIRENTRY.wBitCount,
            
            texture = texture,
        }
    end
    
    if (#icoVariants > 1) then
        table.sort(icoVariants, function(first, second)
            return (first.height < second.height) or (first.width < second.width);
        end);
    end
    
    return icoVariants;
end



function decode_bitmap_data(stream, ICONDIRENTRY)
    
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
    -- if height is negative then image is not stored upside-down
    
    local isUpsideDown = true;
    
    if (height < 0) then
        isUpsideDown = false;
        
        height = math.abs(height);
    end
    
    
    -- variable determining if image has AND mask
    -- for images with AND mask BITMAPINFOHEADER.biHeight is double the actual height in ICONDIRENTRY
    
    local hasANDMask = (ICONDIRENTRY.bHeight ~= height);
    if (hasANDMask) then height = height/2 end
    
    
    
    local bitsPerPixel  = BITMAPINFOHEADER.biBitCount;
    local pixelsPerByte = 8/bitsPerPixel;
    
    if (BITMAPINFOHEADER.biCompression ~= BI_RGB) then
        error("bad argument #1 to '" .. __func__ .. "' (unsupported bitmap compression)", 2);
    end
    
    
    
    pixelData = {}
    
    -- every row of pixels in bitmap data is right-padded with zeroes to have a length multiple of 4 bytes
    -- we calculate how many bytes we have to skip after reading each row
    local PADDING = (4 - (width/pixelsPerByte)%4)%4;
    
    -- [ ========================== [ XOR MASK (COLOR) ] ========================== ]
    
    if (bitsPerPixel == 1) or (bitsPerPixel == 2) or (bitsPerPixel == 4) or (bitsPerPixel == 8) then
        
        local colorTable = {}
        
        for j = 1, 2^(BITMAPINFOHEADER.biPlanes*bitsPerPixel) do
            colorTable[j] = stream:Read(3) .. ALPHA255_BYTE;
            
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
                
                local index = bitExtract(currentByte, ((pixelsPerByte-1)-currentBit)*bitsPerPixel, bitsPerPixel);
                
                currentRow[x+1] = colorTable[index+1];
            end
            
            pixelData[y] = currentRow;
            
            stream.Position = stream.Position+PADDING;
        end
    
    -- TO TAKE INTO CONSIDERATION (XRGB555 and RGB565):
    -- elseif (bitsPerPixel == 16) then
        --[[ ================================================================================= ]
            
            REFERENCES: http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm
                        https://en.wikipedia.org/wiki/BMP_file_format
                        http://www.fileformat.info/format/bmp/egff.htm
                        https://msdn.microsoft.com/en-us/library/windows/desktop/dd318229.aspx
                        https://msdn.microsoft.com/en-us/library/windows/desktop/dd390989.aspx
            
        --[ ================================================================================= ]]
        
    elseif (bitsPerPixel == 24) then
        
        for y = 1, height do
            local currentRow = {}
            
            for x = 1, width do
                currentRow[x] = stream:Read(3) .. ALPHA255_BYTE;
            end
            
            pixelData[y] = currentRow;
            
            stream.Position = stream.Position+PADDING;
        end
        
    elseif (bitsPerPixel == 32) then
        for y = 1, height do
            local currentRow = {}
            
            for x = 1, width do
                currentRow[x] = stream:Read(4);
            end
            
            pixelData[y] = currentRow;
            
            stream.Position = stream.Position+PADDING;
        end
    else
        error("bad argument #1 to '" .. __func__ .. "' (unsupported bitmap bit depth)", 2);
    end
    
    
    -- [ ========================== [ AND MASK (TRANSPARENCY) ] ========================== ]
    
    if (hasANDMask or (stream.Position ~= ICONDIRENTRY.dwImageOffset + ICONDIRENTRY.dwBytesInRes)) then
        
        if (bitsPerPixel ~= 1) then PADDING = (4-(width/8)%4)%4 end
        
        for y = 1, height do
            local currentRow = pixelData[y];
            
            for x = 0, width-1 do
                local currentBit = x%8;
                
                if (currentBit == 0) then
                    currentByte = stream:Read_uchar();
                end
                
                if (bitExtract(currentByte, 7-currentBit) == 1) then
                    currentRow[x+1] = TRANSPARENT_PIXEL;
                end
            end
            
            stream.Position = stream.Position+PADDING;
        end
    end
    
    for y = 1, height do
        pixelData[y] = table.concat(pixelData[y]);
    end
    
    -- flip image
    if (isUpsideDown) then
        for y = 1, height/2 do
            local flippedRowY = height-y+1;
            
            local temp = pixelData[y];
            
            pixelData[y] = pixelData[flippedRowY];
            pixelData[flippedRowY] = temp;
        end
    end
    
    -- append size to accomodate MTA pixel data format
    pixelData[#pixelData+1] = string.char(
        bitExtract(width,  0, 8), bitExtract(width,  8, 8),
        bitExtract(height, 0, 8), bitExtract(height, 8, 8)
    );
    
    pixelData = table.concat(pixelData);
    
    
    return dxCreateTexture(pixelData, "argb", false, clamp), width, height;
end






local ico = decode_ico("decoders/ico/windows-4bpp.ico");
ico = ico[#ico];

addEventHandler("onClientRender", root, function()
    dxDrawImage(200, 200, ico.width, ico.height, ico.texture);
end);