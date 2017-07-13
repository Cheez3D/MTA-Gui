extern texture image;
extern texture mask;



sampler imageSampler = sampler_state {
    Texture = <image>;
};

sampler maskSampler = sampler_state {
    Texture = <mask>;
};



float4 ps(float2 texCoord : TEXCOORD0) : COLOR0 {
    float4 imageColor = tex2D(imageSampler, texCoord);
    float4 maskColor  = tex2D(maskSampler,  texCoord);
    
    if (maskColor.a < imageColor.a) imageColor.a = maskColor.a;
    
    return imageColor;
}



technique _mask {
    pass p0 {
        // AlphaBlendEnable = true;
        
        // SrcBlend  = SrcAlpha;
        // DestBlend = InvSrcAlpha;
        
        PixelShader = compile ps_2_0 ps();
    }
}

technique fallback {
    pass p0 {
        AlphaBlendEnable = false;
        
        Texture[0] = image;
    }
}
