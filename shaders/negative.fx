extern texture image;



sampler imageSampler = sampler_state {
    Texture = <image>;
};



float4 ps(const float2 texCoord : TEXCOORD0) : COLOR0 {
    float4 color = tex2D(imageSampler, texCoord);
    
    color.rgb = 1-color.rgb;
    
    return color;
}



technique negative {
    pass p0 {
        PixelShader = compile ps_2_0 ps();
    }
}

technique fallback {
    pass p0 {}
}
