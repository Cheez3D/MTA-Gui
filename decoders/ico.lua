--[[ ============================================================================================================================================= ]

    NAME:       table decode_ico(string bytes)
    PURPOSE:    Convert .ico and .cur files into drawable MTA:SA textures
    
    RETURNED TABLE STRUCTURE (EXAMPLE):
    
    {
        [1] = {
            width = 16, height = 16,
            
            -- OPTIONAL: only for cursors, otherwise nil
            [ hotspotX = 0, hotspotY = 0, ]
            
            image = userdata,
        },
        
        [2] = {
            width = 32, height = 32,
            
            -- OPTIONAL: only for cursors, otherwise nil
            [ hotspotX = 0, hotspotY = 0, ]
            
            image = userdata,
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

local math = math;
local string = string;

local LOG2 = math.log(2);



local ICO = 1;
local CUR = 2;

local PNG_SIGNATURE = string.char(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a);

local BI_RGB       = 0;
local BI_RLE8      = 1;
local BI_RLE4      = 2;
local BI_BITFIELDS = 3; -- http://www.virtualdub.org/blog/pivot/entry.php?id=177

local ALPHA255_BYTE = string.char(0xff);
local TRANSPARENT_PIXEL = string.char(0x00, 0x00, 0x00, 0x00);



local decode_bitmap_data;
local decode_png_data;

function decode_ico(bytes)
    
    -- [ ====================== [ ASSERTION ] ====================== ]
    
    local bytesType = type(bytes);
    if (bytesType ~= "string") then
        error("bad argument #1 to '" ..__func__.. "' (string expected, got " .. bytesType .. ")", 2);
    end
    
    
    
    -- function can also be supplied with a file path instead of raw data
    -- we treat variable bytes as a file path to see if the file exists
    if (fileExists(bytes)) then
        local f = fileOpen(bytes, true); -- open file read-only
        
        if (not f) then
            error("bad argument #1 to '" ..__func__.. "' (cannot open file)", 2);
        end
        
        -- if file exists then we substitute bytes with the contents of the file located in the path supplied
        bytes = fileRead(f, fileGetSize(f));
        
        fileClose(f);
    end
    
    
    local success, stream = pcall(Stream.new, bytes);
    
    if (not success) then
        error("bad argument #1 to '" ..__func__.. "' (could not create stream) -> " ..stream, 2);
    end
    
    
    local ICONDIR = {
        idReserved = stream.read_ushort(),
        
        idType = stream.read_ushort(),
        
        idCount   = stream.read_ushort(),
        idEntries = {}
    }
    
    if (ICONDIR.idReserved ~= 0) then
        error("bad argument #1 to '" ..__func__.. "' (invalid file format)", 2);
    elseif (ICONDIR.idType ~= ICO) and (ICONDIR.idType ~= CUR) then
        error("bad argument #1 to '" ..__func__.. "' (invalid icon type)", 2);
    elseif (ICONDIR.idCount == 0) then
        error("bad argument #1 to '" ..__func__.. "' (no entries found in ICONDIR)", 2);
    end
    
    ICONDIR.isCUR = (ICONDIR.idType == CUR);
    
    
    for i = 1, ICONDIR.idCount do 
        local ICONDIRENTRY = {
            bWidth  = stream.read_uchar(),
            bHeight = stream.read_uchar(),
            
            bColorCount = stream.read_uchar(),
            
            bReserved = stream.read_uchar(),
            
            wPlanes   = stream.read_ushort(),
            wBitCount = stream.read_ushort(),
            
            dwBytesInRes  = stream.read_uint(), -- bytes in resource
            dwImageOffset = stream.read_uint(), -- offset to image data
        }
        
        if (ICONDIRENTRY.bReserved ~= 0) then
            error("bad argument #1 to '" ..__func__.. "' (invalid file format)", 2);
        end
        
        ICONDIR.idEntries[i] = ICONDIRENTRY;
    end
    
    
    local icoVariants = {}
    
    for i = 1, ICONDIR.idCount do
        
        local ICONDIRENTRY = ICONDIR.idEntries[i];
        
        stream.pos = ICONDIRENTRY.dwImageOffset; -- set read position to image data start
        
        
        local isPNG = (stream.read(8) == PNG_SIGNATURE);
        stream.pos = stream.pos-8;
        
        
        local decoder = isPNG and decode_png_data or decode_bitmap_data;
        local texture, textureWidth, textureHeight, width, height = decoder(stream, ICONDIRENTRY);
        
        
        local image = dxCreateRenderTarget(width, height, true);
        
        dxSetBlendMode("add");
        
        dxSetRenderTarget(image);
        dxDrawImage(0, 0, textureWidth, textureHeight, texture);
        
        dxSetRenderTarget();
        
        dxSetBlendMode("blend");
        
        
        icoVariants[i] = {
            width  = width,
            height = height,
            
            hotspotX = ICONDIR.isCUR and ICONDIRENTRY.wPlanes,
            hotspotY = ICONDIR.isCUR and ICONDIRENTRY.wBitCount,
            
            image = image,
        }
    end
    
    if (#icoVariants > 1) then
        table.sort(icoVariants, function(first, second)
            return (first.height < second.height) or (first.width < second.width);
        end);
    end
    
    return icoVariants;
end



function decode_png_data(stream, ICONDIRENTRY)
    stream.pos = stream.pos+16;
    
    local width  = stream.read_uint(false);
    local height = stream.read_uint(false);
    
    -- round image width and height to the nearest powers of two
    -- to avoid bulrring when creating texture
    local textureWidth  = 2^math.ceil(math.log(width) /LOG2);
    local textureHeight = 2^math.ceil(math.log(height)/LOG2);
    
    stream.pos = stream.pos-24;
    
    local pixels = stream.read(ICONDIRENTRY.dwBytesInRes);
    pixels = dxConvertPixels(pixels, "plain");
    
    
    local pixelData = {}
    
    for y = 0, height-1 do
        -- multiply width by 4 because every pixel occupies 4 bytes (RGBA)
        pixelData[#pixelData+1] = string.sub(pixels, y*(4*width) + 1, (y+1)*(4*width));
        
        -- pad remaining row space horizontally with transparent pixels to reach nearest power of two size
        pixelData[#pixelData+1] = string.rep(TRANSPARENT_PIXEL, textureWidth-width);
    end
    
    -- pad remaining bottom area with transparent pixels
    pixelData[#pixelData+1] = string.rep(TRANSPARENT_PIXEL, (textureHeight-height)*textureWidth);
    
    -- append size to accomodate MTA pixel data format
    pixelData[#pixelData+1] = string.char(
        bitExtract(textureWidth,  0, 8), bitExtract(textureWidth,  8, 8),
        bitExtract(textureHeight, 0, 8), bitExtract(textureHeight, 8, 8)
    );
    
    pixels = table.concat(pixelData);
    
    return dxCreateTexture(pixels, "argb", false, "clamp"), textureWidth, textureHeight, width, height;
end

function decode_bitmap_data(stream, ICONDIRENTRY)
    
    local BITMAPINFOHEADER = {
        biSize = stream.read_uint(),
        
        biWidth  = stream.read_uint(),
        biHeight = stream.read_int(),
        
        biPlanes   = stream.read_ushort(),
        biBitCount = stream.read_ushort(),
        
        biCompression = stream.read_uint(),
        biSizeImage   = stream.read_uint(),
        
        biXPelsPerMeter = stream.read_uint(), -- preferred resolution in pixels per meter
        biYPelsPerMeter = stream.read_uint(),
        
        biClrUsed      = stream.read_uint(), -- number color map entries that are actually used
        biClrImportant = stream.read_uint(), -- number of significant colors
    }
    
    
    if (BITMAPINFOHEADER.biSize ~= 40) then
        error("bad argument #1 to '" ..__func__.. "' (unsupported bitmap)", 2);
    elseif (BITMAPINFOHEADER.biPlanes ~= 1) then
        error("bad argument #1 to '" ..__func__.. "' (invalid number of planes)", 2);
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
    
    -- round image width and height to the nearest powers of two
    -- to avoid bulrring when creating texture
    local textureWidth  = 2^math.ceil(math.log(width) /LOG2);
    local textureHeight = 2^math.ceil(math.log(height)/LOG2);
    
    
    local bitsPerPixel  = BITMAPINFOHEADER.biBitCount;
    local pixelsPerByte = 8/bitsPerPixel;
    
    
    if (BITMAPINFOHEADER.biCompression ~= BI_RGB) then
        error("bad argument #1 to '" ..__func__.. "' (unsupported bitmap compression)", 2);
    end
    
    
    -- every row of pixels in bitmap data is right-padded with zeroes to have a length multiple of 4 bytes
    -- we calculate how many bytes we have to skip after reading each row
    local PADDING = (4-(width/pixelsPerByte)%4)%4;
    
    local pixelData = {}
    
    -- [ ========================== [ XOR MASK (COLOR) ] ========================== ]
    
    local startRow = isUpsideDown and height-1 or 0;
    local endRow   = isUpsideDown and 0 or height-1;
    
    local step = isUpsideDown and -1 or 1;
    
    if (bitsPerPixel == 1) or (bitsPerPixel == 2) or (bitsPerPixel == 4) or (bitsPerPixel == 8) then
        local colorTable = {}
        
        for i = 1, 2^bitsPerPixel do
            colorTable[i] = stream.read(3) .. ALPHA255_BYTE;
            
            stream.pos = stream.pos+1; -- skip icReserved
        end
        
        
        local byte;
        
        for y = startRow, endRow, step do
            for x = 0, width-1 do
                local bitOffset = x%pixelsPerByte;
                
                if (bitOffset == 0) then
                    byte = stream.read_uchar();
                end
                
                local index = bitExtract(byte, ((pixelsPerByte-1)-bitOffset)*bitsPerPixel, bitsPerPixel);
                local pixel = colorTable[index+1];
                
                -- add 1 to width to allocate an index in the array for TRANSPARENT_PIXEL padding
                -- (for power of two size)
                pixelData[y*(width+1) + (x+1)] = pixel;
            end
            
            -- pad remaining row space horizontally with transparent pixels
            pixelData[y*(width+1) + (width+1)] = string.rep(TRANSPARENT_PIXEL, textureWidth-width);
            
            stream.pos = stream.pos+PADDING;
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
    
        for y = startRow, endRow, step do
            for x = 0, width-1 do
                pixelData[y*(width+1) + (x+1)] = stream.read(3) .. ALPHA255_BYTE;
            end
            
            pixelData[y*(width+1) + (width+1)] = string.rep(TRANSPARENT_PIXEL, textureWidth-width);
            
            stream.pos = stream.pos+PADDING;
        end
        
    elseif (bitsPerPixel == 32) then
    
        for y = startRow, endRow, step do
            for x = 0, width-1 do
                pixelData[y*(width+1) + (x+1)] = stream.read(4);
            end
            
            pixelData[y*(width+1) + (width+1)] = string.rep(TRANSPARENT_PIXEL, textureWidth-width);
            
            stream.pos = stream.pos+PADDING;
        end
        
    else
        error("bad argument #1 to '" ..__func__.. "' (unsupported bitmap bit depth)", 2);
    end
    
    -- [ ========================== [ AND MASK (TRANSPARENCY) ] ========================== ]
    
    if (hasANDMask or (stream.pos ~= ICONDIRENTRY.dwImageOffset + ICONDIRENTRY.dwBytesInRes)) then
        
        -- if bitsPerPixel == 1 PADDING remains the same as that for XOR mask
        if (bitsPerPixel ~= 1) then
            PADDING = (4-(width/8)%4)%4;
        end
        
        local byte;
        
        for y = startRow, endRow, step do
            for x = 0, width-1 do
                local bitOffset = x%8;
                
                if (bitOffset == 0) then
                    byte = stream.read_uchar();
                end
                
                if (bitExtract(byte, 7-bitOffset) == 1) then
                    pixelData[y*(width+1) + (x+1)] = TRANSPARENT_PIXEL;
                end
            end
            
            stream.pos = stream.pos+PADDING;
        end
        
    end
    
    -- pad remaining bottom area with transparent pixels
    pixelData[#pixelData+1] = string.rep(TRANSPARENT_PIXEL, (textureHeight-height)*textureWidth);
    
    -- append size to accomodate MTA pixel data format
    pixelData[#pixelData+1] = string.char(
        bitExtract(textureWidth,  0, 8), bitExtract(textureWidth,  8, 8),
        bitExtract(textureHeight, 0, 8), bitExtract(textureHeight, 8, 8)
    );
    
    local pixels = table.concat(pixelData);
    
    return dxCreateTexture(pixels, "argb", false, clamp), textureWidth, textureHeight, width, height;
end






-- local ico = decode_ico("decoders/ico/256x256-1bpp.ico");
-- ico = ico[#ico];

-- addEventHandler("onClientRender", root, function()
    -- dxDrawImage(200, 200, ico.width, ico.height, ico.image);
-- end);