clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../VertexPaintMod.ms" )	--"./../VertexPaintMod.ms"

delete objects

obj = Box showVertexColors:true

paint_layer_mod = PaintLayerMod()

addModifier obj paint_layer_mod

-- Example usage:
VertexPaintMod = VertexPaintMod_v(obj)(paint_layer_mod)
format "VertexPaintMod: %\n" VertexPaintMod

VertexPaintMod.setVertexColor 1 red
 
_vertex_color = VertexPaintMod.getVertexAverageColor 1

format "_vertex_color: %\n" (_vertex_color as color ) 

