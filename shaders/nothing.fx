extern texture image; 

technique nothing {
    pass p0 {
        Texture[0] = image;
    }
}
