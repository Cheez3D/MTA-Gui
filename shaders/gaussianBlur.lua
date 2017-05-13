local math = math;

local exp, sqrt = math.exp, math.sqrt;

local PI = math.pi;


-- compuets kernel for shader
function compute_kernel(radius, sigma)
    
    -- [ ====================== [ ASSERTION ] ====================== ]
    
    local radiusType = type(radius);
    
    if (radiusType ~= "number") then
        error("bad argument #1 to '" ..__func__.. "' (number expected, got " ..radiusType.. ")", 2);
    elseif (radius%1 ~= 0) then
        error("bad argument #1 to '" ..__func__.. "' (number has no integer representation)", 2);
    elseif (radius < 2) or (radius > 31) then
        error("bad argument #1 to '" ..__func__.. "' (value out of bounds)", 2);
    end
    
    local sigmaType = type(sigma);
    
    if (sigmaType ~= "number") then
        error("bad argument #2 to '" ..__func__.. "' (number expected, got " ..sigmaType.. ")", 2);
    elseif (sigma <= 0) then
        error("bad argument #2 to '" ..__func__.. "' (non-positive value)", 2);
    end
    
    
    
    -- initialize table of discrete weights and precalculate center weight
    local discreteWeights = { 1/(sqrt(2*PI)*sigma) }
    
    -- initialize sum of discrete weights to precalculated center weight
    -- used for normalization of all weights (see below at [1])
    local sum = discreteWeights[1];
    
    for i = 2, radius do
        -- calculate i-th weight using gaussian function
        local dw = exp(-((i-1)*(i-1))/(2*sigma*sigma)) / (sqrt(2*PI)*sigma);
        
        discreteWeights[i] = dw;
        
        -- add double the weight as we are only calculating one side of the kernel
        sum = sum + 2*dw;
    end
    
    -- [1]
    -- normalize weights
    for i = 1, radius do
        discreteWeights[i] = discreteWeights[i]/sum;
    end
    
    
    -- implement bilinear filter to halve texture fetches in shader code, thus doubling the radius limit
    -- radius limit doubling is properly handled in ASSERTION section
    
    -- table for storing linear weights which are half the number of discrete weights
    local linearWeights = { discreteWeights[1] }
    
    -- offsets are no longer going ot be integers so we use a table for storing them
    -- add first offset as it is unaffected
    local offsets = { 0 }
    
    -- if radius is even then last weight is left without a pair (see below at [2])
    for i = 2, (radius%2 == 0) and radius-1 or radius, 2 do
        -- index of new linear weight
        local j = i/2+1;
        
        local dw1 = discreteWeights[i];
        local dw2 = discreteWeights[i+1];
        
        
        linearWeights[j] = dw1 + dw2;
        
        -- new offset is weighted average of integers
        offsets[j] = (dw1*(i-1) + dw2*i) / (dw1+dw2);
    end
    
    -- calculate new limit from radius for linear weights (== number of linear weights)
    local limit = math.floor(radius/2 + 1);
    
    -- [2]
    if (radius%2 == 0) then
        linearWeights[limit] = discreteWeights[radius];
        
        offsets[limit] = limit;
    end
    
    
    return limit, linearWeights, offsets;
end






local cur = {
    Texture = dxCreateScreenSource(SCREEN_WIDTH,SCREEN_HEIGHT),
    SizeX = SCREEN_WIDTH,
    SizeY = SCREEN_HEIGHT
} -- decode_ani("Testers/aliendance.ani")[1][5];

local s,t = dxCreateShader("shaders/gaussianBlur.fx");

dxSetShaderValue(s,"imageSize",cur.SizeX,cur.SizeY);

local rt = dxCreateRenderTarget(cur.SizeX,cur.SizeY,true);

local function render()
    dxUpdateScreenSource(cur.Texture); -- update the screen source
    
    dxSetShaderValue(s,"image",cur.Texture);
    dxSetShaderValue(s,"direction",1,0);
    

    dxSetRenderTarget(rt);
    dxDrawImage(0,0,cur.SizeX,cur.SizeY,s);
    dxSetRenderTarget();
    
    dxSetShaderValue(s,"image",rt);
    dxSetShaderValue(s,"direction",0,1);
    
    dxDrawImage(0,0,cur.SizeX,cur.SizeY,s);
end



local IsBlurEnabled = false;

addCommandHandler("blur",function(Command,Radius,Sigma)
    if (IsBlurEnabled) then
        removeEventHandler("onClientPreRender",root,render);
        
        IsBlurEnabled = false;
        
        return;
    end
    
    Radius = tonumber(Radius); Sigma = tonumber(Sigma);
    
    local Limit,Weights,Offsets = compute_kernel(Radius,Sigma);
    
    print("Limit: ",Limit," ");
    print("Weights: ",table.concat(Weights," "));
    print("Offsets: ",table.concat(Offsets," "));
    print("\n");
    
    dxSetShaderValue(s,"limit",Limit);
    dxSetShaderValue(s,"weights",Weights);
    dxSetShaderValue(s,"offsets",Offsets);
    
    addEventHandler("onClientPreRender",root,render);
    
    IsBlurEnabled = true;
end);