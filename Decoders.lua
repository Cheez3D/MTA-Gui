--[[ [=============================================================================================================================================]

	NAME:		table decode_ico(string bytes)
	PURPOSE:	Convert .ico and .cur files into drawable MTA:SA textures
	
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
	
	REFERENCES:	http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm
				https://www.daubnet.com/en/file-format-cur
				https://www.daubnet.com/en/file-format-ico
				https://en.wikipedia.org/wiki/BMP_file_format
				https://en.wikipedia.org/wiki/ICO_(file_format)
				https://msdn.microsoft.com/en-us/library/ms997538.aspx
				http://vitiy.info/manual-decoding-of-ico-file-format-small-c-cross-platform-decoder-lib/
				https://social.msdn.microsoft.com/Forums/vstudio/en-US/8da318b3-1c14-4225-859c-138f9b9c749f/resource-injection?forum=winforms
	
	TEST FILES:	https://github.com/daleharvey/mozilla-central/tree/master/image/test/reftest/ico
	
[===============================================================================================================================================] ]]

-- [ CONSTANTS ] --

local PNG_SIGNATURE = string.char(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a);

local ICO, CUR = 1, 2;

local BI_RGB = 0;

local ALPHA255_BYTE = string.char(0xff);

local TRANSPARENT_PIXEL = string.char(0, 0, 0, 0);

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
				-- REFERENCES:	http://www.dragonwins.com/domains/getteched/bmp/bmpfileformat.htm
				-- 				https://en.wikipedia.org/wiki/BMP_file_format
				-- 				http://www.fileformat.info/format/bmp/egff.htm
				-- 				https://msdn.microsoft.com/en-us/library/windows/desktop/dd318229.aspx
				-- 				https://msdn.microsoft.com/en-us/library/windows/desktop/dd390989.aspx
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
			
			-- append size to accomodate MTA pixel data
			pixels = table.concat(pixels) .. string.char(
				bitExtract(width,  0, 8), bitExtract(width,  8, 8),
				bitExtract(height, 0, 8), bitExtract(height, 8, 8)
			);
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



--[[ [=======================================================================================]

	NAME:		table decode_ani(string bytes)
	PURPOSE:	Convert .ani files into drawable MTA:SA textures
	
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
	
	REFERENCES:	https://www.daubnet.com/en/file-format-ani
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



--[[ [===========================================================================================]

	NAME:		table decode_gif(string bytes)
	PURPOSE:	Convert .gif files into drawable MTA:SA textures
	
	RETURNED TABLE STRUCTURE:
	
	{
		
	}
	
	REFERENCES:	https://en.wikipedia.org/wiki/GIF
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
			gctSize = bitExtract(fields, 0, 3), -- number of entries is 2^(gctSize + 1)
			
			sortFlag = bitExtract(fields, 3, 1),
			
			colorResolution = bitExtract(fields, 4, 3),
		}
	end
	
	local gct; -- global color table
	
	if (lsd.fields.gctFlag == 1) then
		gct = {}
		
		for i = 1, 2^(lsd.fields.gctSize + 1) do
			gct[i] = stream:Read(3);
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
				lctSize = bitExtract(fields, 0, 3),
				
				interlaceFlag = bitExtract(fields, 6, 1),
				sortFlag = bitExtract(fields, 5, 1),
				
				reserved = bitExtract(fields, 3, 2),
			}
			
			local lct; -- local color table
			
			if (descriptor.fields.lctFlag == 1) then
				lct = {}
				
				for i = 1, 2^(descriptor.fields.lctSize + 1) do
					lct[i] = stream:Read(3);
				end
			end
			
			
			-- Image Data Block
			
			local lzwMinCodeSize = stream:Read_uchar();
			
			-- number of bytes contained by the image data sub-block
			local bytesCount = stream:Read_uchar();
			
			
			local colorTable = lct or gct; -- if lct does not exist fall back to gct
			local colorsCount = #colorTable;
			
			local CLEAR_CODE = colorsCount;
			local EOI_CODE = colorsCount + 1;
			
			local codeTable = {}
			
			
			local indexStream = {}
			
			
			
			local bitOffset = 0;
			
			local currentCodeSize = lzwMinCodeSize + 1;
			
			local lastCode, currentCode;
			
			-- using while loop here because
			-- you cannot modify for loop variable in Lua (see below [*])
			local i = 1;
			
			while (i <= bytesCount) do
				local currentByte = stream:Read_uchar();
				
				-- number of codes (including partial ones) after bitOffset bits residing in currentByte
				local codesInByte = math.ceil((8 - bitOffset) / currentCodeSize);
				
				for j = 1, codesInByte do
					lastCode = currentCode;
					
					-- if current code is a partial code
					if ( (8 - bitOffset) < currentCodeSize ) then
						
						-- back up 1 and read ushort instead of uchar for extracting the partial code
						stream.Position = stream.Position - 1;
						currentByte = stream:Read_ushort();
						
						currentCode = bitExtract(currentByte, bitOffset, currentCodeSize);
						
						-- if reading from the ushort actually gets us to the end of it then we jump to the next byte
						if ((bitOffset + currentCodeSize)%8 == 0) then
							i = i + 1; -- [*]
							
						-- otherwise we back up 1 byte
						else
							stream.Position = stream.Position - 1;
						end
						
					-- if it is not a partial code
					else
						currentCode = bitExtract(currentByte, bitOffset, currentCodeSize);
					end
					
					bitOffset = (bitOffset + currentCodeSize)%8; -- wrap around 8
					
					
					print(lastCode, " -> ", currentCode);
					
					-- TODO:
					-- decompression algorithm
					-- USE TABLES!!!! easier!!
					
					-- if (currentCode == CLEAR_CODE) then
						-- codeTable = {}
					
					-- -- if code actually represents a color index
					-- elseif (currentCode < colorsCount) then
						-- indexStream[#indexStream] = currentCode;
						
						-- if (lastCode < colorsCount) then
							-- codeTable[colorsCount + 2 + #codeTable] = {lastCode, currentCode}
						-- elseif (lastCode > EOI_CODE) then
							-- local x = copy(codeTable[lastCode]);
							
							-- x[#x] = currentCode;
							
							-- codeTable[colorsCount + 2 + #codeTable] = x;
						-- end
					-- elseif (currentCode > EOI_CODE) then
						
					-- end
				end
				
				i = i + 1;
			end
		end
		
		identifier = stream:Read_uchar();
	end
	
	return;
end

decode_gif("Testers/sample_1.gif");


-- local ico = decode_ico("Testers/4bpp-24x14-Transparent.ico")[1];

-- addEventHandler("onClientRender", root, function()
	-- dxDrawImage(200, 200, ico.width, ico.height, ico.texture);
-- end);


















