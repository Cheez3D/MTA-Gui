// [==========================================[ FILE ]=========================================]
// NAME:		GaussianBlur.fx
// PURPOSE:		Gaussian blur shader for various effects
// REFERENCES:	http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
// 				http://www.gamasutra.com/view/feature/130229/creating_a_postprocessing_.php
// [===========================================================================================]


extern int limit;

extern float offsets[16], weights[16];

extern float2 direction;


extern texture Texture;
extern float2 TextureSize;


const float4x4 WorldViewProjection : WORLDVIEWPROJECTION;

const sampler2D Sampler = sampler_state {
    Texture = <Texture>;
	
	AddressU = MIRROR;
	AddressV = MIRROR;
};


struct vsInput {
    float3 pos : POSITION0;
    float2 texCoord : TEXCOORD0;
};

struct psInput {
    float4 pos : POSITION0;
    float2 texCoord : TEXCOORD0;
};


psInput vs(const vsInput vertex) {
	psInput pixel;
	
	// calculate screen position of vertex
    pixel.pos = mul(float4(vertex.pos, 1), WorldViewProjection);
	
    pixel.texCoord = vertex.texCoord;

    return pixel;
}

float4 ps(const psInput pixel) : COLOR0 {
	const float2 texCoord = pixel.texCoord;
	
	float4 color = tex2D(Sampler, float2(texCoord.x, texCoord.y))*weights[0];
	
	for (int i = 1; i < limit; ++i) {
		color += tex2D(Sampler, float2(
			texCoord.x - direction.x*( offsets[i] / TextureSize.x ),
			texCoord.y - direction.y*( offsets[i] / TextureSize.y )
		))*weights[i];
		
		color += tex2D(Sampler, float2(
			texCoord.x + direction.x*( offsets[i] / TextureSize.x ),
			texCoord.y + direction.y*( offsets[i] / TextureSize.y )
		))*weights[i];
	}
	
	return color;
}


technique gaussianBlur {
    pass p0 {
		VertexShader = compile vs_3_0 vs();
        PixelShader = compile ps_3_0 ps();
    }
}

technique fallback {
	pass p0 {}
}