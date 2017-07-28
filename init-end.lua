fileClose(OUT);
fileClose(FILE);

addEventHandler("onClientPreRender", root, function()
    if (selFr.vertex1) then
        dxDrawLine(
            selFr.absRotPivot.x,
            selFr.absRotPivot.y,
            
            selFr.vertex1.x, selFr.vertex1.y,
            
            GuiObject.DEBUG_ROT_LINE_COLOR, 3
        );
        
        dxDrawLine(
            selFr.absRotPivot.x,
            selFr.absRotPivot.y,
            
            selFr.vertex2.x, selFr.vertex2.y,
            
            GuiObject.DEBUG_ROT_LINE_COLOR, 3
        );
        
        dxDrawLine(
            selFr.absRotPivot.x,
            selFr.absRotPivot.y,
            
            selFr.vertex3.x, selFr.vertex3.y,
            
            GuiObject.DEBUG_ROT_LINE_COLOR, 3
        );
        
        dxDrawLine(
            selFr.absRotPivot.x,
            selFr.absRotPivot.y,
            
            selFr.vertex4.x, selFr.vertex4.y,
            
            GuiObject.DEBUG_ROT_LINE_COLOR, 3
        );
    end
end);
