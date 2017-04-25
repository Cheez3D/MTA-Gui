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
                http://www.vurdalakov.net/misc/gif/netscape-looping-application-extension
                
                http://www.onicos.com/staff/iz/formats/gif.html
                http://www.martinreddy.net/gfx/2d/GIF87a.txt
                http://www.fileformat.info/format/gif/egff.htm
                https://brianbondy.com/downloads/articles/gif.doc
                http://www.daubnet.com/en/file-format-gif
                
                https://stackoverflow.com/questions/26894809/gif-lzw-decompression
[=============================================================================================] ]]

local OUT = fileOpen("Testers/out.txt");
local FILE = fileOpen("Testers/file.txt");

local log2 = math.log(2);

local math = math;
local string = string;



local EXTENSION_INTRODUCER = 0x21;

local APPLICATION_LABEL = 0xff;
local COMMENT_LABEL = 0xfe;
local GRAPHIC_CONTROL_LABEL = 0xf9;
local PLAIN_TEXT_LABEL = 0x01;

local IMAGE_SEPARATOR = 0x2c;

local BLOCK_TERMINATOR = 0x00; -- signals end of block

local TRAILER = 0x3b; -- signals end of file


local NETSCAPE_LOOP_COUNT = 1;


local DISPOSE_TO_BACKGROUND = 2;
local DISPOSE_TO_PREVIOUS   = 3;

local ALPHA255_BYTE = string.char(0xff);

local TRANSPARENT_PIXEL = string.char(0x00, 0x00, 0x00, 0x00);

-- [ FUNCTION ] --

local decode_image_data;

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
    
    
    local images = {}
    
    
    -- [ Logical Screen Descriptor ]
    
    local lsd = {
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
            gctFlag = bitExtract(fields, 7, 1), -- denotes wether a global color table exists
            gctSize = bitExtract(fields, 0, 3), -- number of entries in gct is 2^(gctSize+1)
            
            sortFlag = bitExtract(fields, 3, 1), -- denotes wether gct sorted (most important colors first)
            
            colorResolution = bitExtract(fields, 4, 3),
        }
    end
    
    
    -- [ Global Color Table ]
    
    local gct;
    
    if (lsd.fields.gctFlag == 1) then
        gct = {}
        
        for i = 1, 2^(lsd.fields.gctSize+1) do
            gct[i] = string.reverse(stream:Read(3)) .. ALPHA255_BYTE;
        end
    end
    
    
    local isAnimation, loopCount;
    
    local gce;
    
    local canvas = dxCreateRenderTarget(
        lsd.canvasWidth, lsd.canvasHeight,
        (version == "89a") -- only version 89a has transparency support
    );
    
    
    local identifier = stream:Read_uchar();
    
    while (identifier ~= TRAILER) do
        
        if (identifier == EXTENSION_INTRODUCER) then
        
            local label = stream:Read_uchar();
            
            local blockSize   = stream:Read_uchar();
            local blockOffset = stream.Position;
            
            if (label == GRAPHIC_CONTROL_LABEL) then
                
                -- [ Graphic Control Extension ]
                
                gce = {
                    size = blockSize,
                    
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
                
                gce.isTransparencyEnabled = (gce.fields.transparentColorFlag == 1);
                
            elseif (label == APPLICATION_LABEL) then
                
                -- [ Application Extension ]
                
                -- any application block begins with 11 bytes (fixed size)
                if (blockSize ~= 11) then
                    error("bad argument #1 to '" .. __func__ .. "' (invalid application block)", 2);
                end
                
                local appIdentifier = stream:Read(8);
                local appAuthCode   = stream:Read(3);
                
                
                blockSize   = stream:Read_uchar();
                blockOffset = stream.Position;
                
                while (blockSize ~= BLOCK_TERMINATOR) do
                    if (appIdentifier == "NETSCAPE") and (appAuthCode == "2.0") then
                        local ID = stream:Read_uchar();
                        
                        if (ID == NETSCAPE_LOOP_COUNT) then
                            isAnimation = true;
                            
                            loopCount = stream:Read_ushort();
                        end
                    end
                    
                    stream.Position = blockOffset+blockSize;
                    
                    blockSize   = stream:Read_uchar();
                    blockOffset = stream.Position;
                end
                
            -- elseif (label == COMMENT_LABEL) then
            
                -- [ Comment Extension ]
            
            -- IGNORED:
            -- elseif (label == PLAIN_TEXT_LABEL) then
            
            else
                while (blockSize ~= BLOCK_TERMINATOR) do printfile(OUT, stream.Position, blockSize);
                    stream.Position = blockOffset+blockSize;
                    
                    blockSize   = stream:Read_uchar();
                    blockOffset = stream.Position;
                end
            end
            
        elseif (identifier == IMAGE_SEPARATOR) then
            
            -- [ Image Descriptor ]
            
            local descriptor = {
                x = stream:Read_ushort(),
                y = stream:Read_ushort(),
                
                width  = stream:Read_ushort(),
                height = stream:Read_ushort(),
                
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
            
            descriptor.isInterlaced = (descriptor.fields.interlaceFlag == 1);
            
            
            -- [ Local Color Table ]
            
            local lct;
            
            if (descriptor.fields.lctFlag == 1) then
                lct = {}
                
                for i = 1, 2^(descriptor.fields.lctSize+1) do
                    lct[i] = string.reverse(stream:Read(3)) .. ALPHA255_BYTE;
                end
            end
            
            
            -- [ Image Data Block ]
            
            -- if lct is not present fall back to gct
            local colorTable = lct or gct;
            
            if (gce) and (gce.isTransparencyEnabled) then
                gce.transparentColor = colorTable[gce.transparentColorIndex+1];
                
                -- temporarily replace transparent color with a transparent pixel
                -- to increase performance vs comparing each index against gce.transparentColorIndex in the decoding process
                colorTable[gce.transparentColorIndex+1] = TRANSPARENT_PIXEL;
            end
            
            
            local texture, textureWidth, textureHeight = decode_image_data(stream, gce, descriptor, colorTable);
            
            
            dxSetRenderTarget(canvas);
            dxSetBlendMode("add");
            
            dxDrawImage(descriptor.x, descriptor.y, textureWidth, textureHeight, texture);
            
            
            local canvasCopy = dxCreateRenderTarget(lsd.canvasWidth, lsd.canvasHeight, true);
            
            dxSetRenderTarget(canvasCopy);
            dxDrawImage(0, 0, lsd.canvasWidth, lsd.canvasHeight, canvas);
            
            if (gce) then
                local disposalMethod = gce.fields.disposalMethod;
                
                if (disposalMethod == DISPOSE_TO_BACKGROUND) then
                    
                    -- TODO:
                    -- http://www.webreference.com/content/studio/disposal.html
                    -- http://www.theimage.com/animation/pages/disposal2.html
                    
                    -- https://bugzilla.mozilla.org/show_bug.cgi?id=85595#c28
                    -- https://github.com/DhyanB/Open-Imaging (see Quirks)
                    
                    -- clear canvas
                    dxSetRenderTarget(canvas);
                    dxSetBlendMode("overwrite");
                    
                    local bgColor = (gce and (gce.isTransparencyEnabled)) and TRANSPARENT_PIXEL or colorTable[lsd.bgColorIndex+1];
                    
                    bgColor = 0x1000000 * string.byte(bgColor, 4)  -- a
                            + 0x10000   * string.byte(bgColor, 1)  -- b
                            + 0x100     * string.byte(bgColor, 2)  -- g
                            +             string.byte(bgColor, 3); -- b
                    
                    -- fill canvas with background color
                    dxDrawRectangle(descriptor.x, descriptor.y, descriptor.width, descriptor.height, bgColor);
                    
                elseif (disposalMethod == DISPOSE_TO_PREVIOUS) then
                
                    -- TODO
                    
                end
            end
            
            dxSetBlendMode("blend");
            dxSetRenderTarget();
            
            
            if (gce) and (gce.transparentColor) then
                -- restore transparent color after decoding of the image data and disposal
                colorTable[gce.transparentColorIndex+1] = gce.transparentColor;
                
                gce.transparentColor = nil;
            end
            
            
            images[#images+1] = {
                image = canvasCopy,
                
                width  = lsd.canvasWidth,
                height = lsd.canvasHeight,
            }
        end
        
        identifier = stream:Read_uchar();
    end
    
    return images;
end



local MAX_CODE_SIZE = 12;

local DEINTERLACE_PASSES = {
    [1] = { y = 0, step = 8 },
    [2] = { y = 4, step = 8 },
    [3] = { y = 2, step = 4 },
    [4] = { y = 1, step = 2 },
}

function decode_image_data(stream, gce, descriptor, colorTable)
    
    -- the minimum LZW code size from which we compute
    -- the starting code size for reading the codes
    -- from the image data (by adding 1 to it)
    local lzwMinCodeSize = stream:Read_uchar();
    
    
    -- round image width and height to the nearest powers of two
    -- for avoiding bulrring when creating texture
    local textureWidth  = 2^math.ceil(math.log(descriptor.width)/log2);
    local textureHeight = 2^math.ceil(math.log(descriptor.height)/log2);
    
    
    local pixelData = {}
    
    -- x, y coordinates of current pixel
    local x = 0;
    local y = 0;
    
    
    local pass; -- pass of deinterlacing process
    local step; -- how many rows to skip
    
    if (descriptor.isInterlaced) then
        pass = 1;
        
        y    = DEINTERLACE_PASSES[pass].y;
        step = DEINTERLACE_PASSES[pass].step;
    end
    
    
    local dict = {} -- initialize the dictionary for storing the LZW codes
    
    -- insert all color indexes into dictionary
    
    -- +---------------------------------------------------------------------------------------+
    -- | ONLY UP TO 2^lzwMinCodeSize                                                           |
    -- +---------------------------------------------------------------------------------------+
    -- | previously used #colorTable and was causing unexpected results for cradle.gif because |
    -- | the colorTable size was 256 whereas the codeSize was 128 for some frames              |
    -- +---------------------------------------------------------------------------------------+
    
    -- using strings to represent indexes in color table
    -- this works because GIF max color table size conicides
    -- with number of ASCII characters, i.e. 256
    
    -- strings are used for efficiency vs tables
    
    for i = 1, 2^lzwMinCodeSize do dict[i] = string.char(i-1) end
    
    -- insert CLEAR_CODE and EOI_CODE into dictionary
    local CLEAR_CODE = 2^lzwMinCodeSize;  dict[#dict+1] = true;
    local EOI_CODE = CLEAR_CODE+1;        dict[#dict+1] = true;
    
    -- index from which LZW compression codes start
    local lzwCodesOffset = #dict+1;
    
    
    local codeSize = lzwMinCodeSize+1;
    local dictMaxSize = 2^codeSize;
    
    local code = 0;
    local codeReadBits = 0;
    local isWholeCode = true;
    
    local previousCode;

    
    local blockSize   = stream:Read_uchar();
    local blockOffset = stream.Position;
    
    local byte = stream:Read_uchar();
    
    -- variable keeping track of starting point for reading from byte
    local bitOffset = 0;
    
    while (true) do
        local codeUnreadBits = codeSize-codeReadBits;
        
        if ((bitOffset+codeUnreadBits) > 8) then
            isWholeCode = false;
            
            -- lower the amount of bits to read so as to reach exactly the byte end
            codeUnreadBits = 8-bitOffset;
        end
        
        code = (2^codeReadBits)*bitExtract(byte, bitOffset, codeUnreadBits) + code;
        codeReadBits = codeReadBits+codeUnreadBits;
        
        bitOffset = (bitOffset+codeUnreadBits)%8;
        
        if (isWholeCode) then
            if (code == CLEAR_CODE) then
                
                -- clear all dictionary entries created during the decoding process
                -- (i.e. all entries > EOI_CODE)
                for j = lzwCodesOffset, #dict do dict[j] = nil end
                
                -- it is necessary to reset previousCode
                -- because otherwise it might get picked up at [*] (see below)
                previousCode = nil;
                
                -- reset code size
                codeSize = lzwMinCodeSize+1;
                dictMaxSize = 2^codeSize;
                
            elseif (code == EOI_CODE) then
                -- TODO: pcall from decode_gif or something else
                if (stream:Read_uchar() ~= BLOCK_TERMINATOR) then
                    error("bad argument #1 to '" .. __func__ .. "' (unexpected EOI_CODE)", 2);
                end
                
                break;
            else
                code = code+1; -- accomodate to Lua indexing which starts from 1
                
                -- [ Code to Indexes Conversion ]
                
                -- +----------------------------------------------------+
                -- | LZW GIF DECOMPRESSION ALGORITHM                    |
                -- +----------------------------------------------------+
                -- | {CODE}   = indexes stored by CODE                  |
                -- | {CODE-1} = indexes stored by CODE-1 (prevous code) |
                -- +----------------------------------------------------+
                -- | <LOOP POINT>                                       |
                -- | let CODE be the next code in the code stream       |
                -- | is CODE in the code table?                         |
                -- | Yes:                                               |
                -- |     output {CODE} to index stream                  |
                -- |     let K be the first index in {CODE}             |
                -- |     add {CODE-1} .. K to the code table            |
                -- | No:                                                |
                -- |     let K be the first index of {CODE-1}           |
                -- |     output {CODE-1} .. K to index stream           |
                -- |     add {CODE-1} .. K to code table                |
                -- | return to <LOOP POINT>                             |
                -- +----------------------------------------------------+
                
                local indexes;
                
                if (dict[code]) then
                    local v = dict[code];
                    
                    indexes = v;
                    
                    local K = string.sub(v, 1, 1);
                    if (previousCode and dict[previousCode]) then
                        dict[#dict+1] = dict[previousCode] .. K;
                    end
                else
                    local v = dict[previousCode];
                    
                    local K = string.sub(v, 1, 1);
                    v = v .. K;
                    
                    indexes = v;
                    
                    dict[#dict+1] = v;
                end
                
                -- if inserting into dictionary increased codeSize
                if (#dict == dictMaxSize) and (codeSize < MAX_CODE_SIZE) then
                    codeSize = codeSize+1;
                    dictMaxSize = 2^codeSize;
                end
                
                previousCode = code;
                
                
                -- [ Indexes to Pixels Conversion ]
                
                -- add colors coresponding to the decompressed color indexes to pixel data
                local pixelsCount = string.len(indexes);
                
                for i = 1, pixelsCount do
                    local index = string.byte(indexes, i);
                    
                    local pixel = colorTable[index+1];
                    
                    -- add 1 to descriptor.width to make room for TRANSPARENT_PIXEL padding
                    -- for getting texture width to the nearest power of two
                    pixelData[y*(descriptor.width+1) + (x+1)] = pixel;
                    
                    x = x+1;
                    
                    if (x >= descriptor.width) then
                        -- pad remaining row space horizontally with transparent pixels
                        pixelData[y*(descriptor.width+1) + (x+1)] = string.rep(TRANSPARENT_PIXEL, textureWidth-x);
                        
                        x = 0;
                        
                        if (descriptor.isInterlaced) then
                            y = y+step;
                            
                            if ((y >= descriptor.height) and (pass < #DEINTERLACE_PASSES)) then
                                pass = pass+1;
                                
                                y    = DEINTERLACE_PASSES[pass].y;
                                step = DEINTERLACE_PASSES[pass].step;
                            end
                        else
                            y = y+1;
                        end
                    end
                end
                
            end
            
            code = 0;
            codeReadBits = 0;
        else
            isWholeCode = true;
        end
        
        
        if ((stream.Position-blockOffset) == blockSize) then
            blockSize   = stream:Read_uchar();
            blockOffset = stream.Position;
        end
        
        -- if we are at the beginning of a new byte
        if (bitOffset == 0) then
            byte = stream:Read_uchar();
        end
    end
    
    -- pad remaining bottom area with transparent pixels
    pixelData[#pixelData+1] = string.rep(TRANSPARENT_PIXEL, (textureHeight-descriptor.height)*textureWidth);
    
    -- append size
    pixelData[#pixelData+1] = string.char(
        bitExtract(textureWidth,  0, 8), bitExtract(textureWidth,  8, 8),
        bitExtract(textureHeight, 0, 8), bitExtract(textureHeight, 8, 8)
    );
    
    local pixels = table.concat(pixelData);
    
    return dxCreateTexture(pixels, "argb", false, "clamp"), textureWidth, textureHeight;
end






local h1, h2, h3 = debug.gethook();
-- debug.sethook();

local s = getTickCount();

local imgs = decode_gif("Testers/fire.gif");

print("elapsed = ", getTickCount() - s, "ms");

debug.sethook(nil, h1, h2, h3);


local i = 1; local t = getTickCount();

addEventHandler("onClientRender", root, function()
    if ((getTickCount() - t) > 200) then
        t = getTickCount();
        
        i = i+1;
        
        if (i > #imgs) then i = 1 end
    end
    
    dxDrawImage(200, 200, imgs[i].width, imgs[i].height, imgs[i].image);
end);

fileClose(OUT);
fileClose(FILE);