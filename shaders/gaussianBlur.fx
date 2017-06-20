/* ================================================================================================= *
    
    REFERENCES: http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
                http://www.gamasutra.com/view/feature/130229/creating_a_postprocessing_.php

 * ================================================================================================= */


extern int limit;

extern float offsets[16];
extern float weights[16];

extern float2 direction;


extern texture image;
extern float2  imageSize;



float4x4 worldViewProj : WORLDVIEWPROJECTION;

sampler imageSampler = sampler_state {
    Texture = <image>;
    
    AddressU = MIRROR;
    AddressV = MIRROR;
};



struct VS_INPUT {
    float3 pos      : POSITION0;
    float2 texCoord : TEXCOORD0;
};

struct PS_INPUT {
    float4 pos      : POSITION0;
    float2 texCoord : TEXCOORD0;
};



PS_INPUT vs(VS_INPUT vertex) {
    PS_INPUT pixel;
    
    // calculate screen position of vertex
    pixel.pos = mul(float4(vertex.pos, 1), worldViewProj);
    
    pixel.texCoord = vertex.texCoord;

    return pixel;
}

float4 ps(PS_INPUT pixel) : COLOR0 {
    // sample current (center) pixel
    float4 color = tex2D(imageSampler, pixel.texCoord)*weights[0];
    
    for (int i = 1; i < limit; ++i) {
        // sample LHS
        color += tex2D(imageSampler, float2(
            pixel.texCoord.x - direction.x*(offsets[i]/imageSize.x),
            pixel.texCoord.y - direction.y*(offsets[i]/imageSize.y)
        ))*weights[i];
        
        // sample RHS
        color += tex2D(imageSampler, float2(
            pixel.texCoord.x + direction.x*(offsets[i]/imageSize.x),
            pixel.texCoord.y + direction.y*(offsets[i]/imageSize.y)
        ))*weights[i];
    }
    
    return color;
}



technique gaussianBlur {
    pass p0 {
        VertexShader = compile vs_3_0 vs();
        PixelShader  = compile ps_3_0 ps();
    }
}

technique fallback {
    pass p0 {}
}
