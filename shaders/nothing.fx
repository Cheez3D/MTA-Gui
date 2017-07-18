extern texture image; 

technique nothing {
    pass p0 {
        AlphaBlendEnable = true;
        
        SrcBlend = One;
        
        Texture[0] = image;
    }
}
