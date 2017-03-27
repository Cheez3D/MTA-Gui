extern texture Texture;	


const sampler Sampler = sampler_state {
	Texture = <Texture>;
};


float4 ps(const float2 texCoord : TEXCOORD0) : COLOR0 { 
    float4 color = tex2D(Sampler, texCoord);
	color.rgb = 1-color.rgb;
	
    return color;
}


technique negative {
	pass p0 {
		PixelShader = compile ps_2_0 ps();
	}
}

technique Fallback {
	pass P0 {}
}