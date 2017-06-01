function decode_png(bytes)
    
    -- [ ====================== [ ASSERTION ] ====================== ]
    
    local bytesType = type(bytes);
    if (bytesType ~= "string") then
        error("bad argument #1 to '" ..__func__.. "' (string expected, got " .. bytesType .. ")", 2);
    end
    
    
    
    local success, stream = pcall(Stream.new, bytes);
    
    if (not success) then
        error("bad argument #1 to '" ..__func__.. "' (could not create stream)\n-> " ..stream, 2);
    end
    
    
    stream.pos = stream.pos+16;
    
    local width  = stream.read_uint(true);
    local height = stream.read_uint(true);
    
    -- round image width and height to the nearest powers of two
    -- to avoid bulrring when creating texture
    local textureWidth  = 2^math.ceil(math.log(width) /LOG2);
    local textureHeight = 2^math.ceil(math.log(height)/LOG2);
    
    stream.pos = stream.pos-24;
    
    local pixels = stream.read(stream.size);
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
