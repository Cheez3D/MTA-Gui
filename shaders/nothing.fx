extern texture image; 

technique nothing {
    pass p0 {
        AlphaBlendEnable = false;
        
        Texture[0] = image;
    }
}
