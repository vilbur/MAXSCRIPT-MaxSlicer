clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../VertexPaintMod.ms" )	--"./../VertexPaintMod.ms"

delete objects

obj1 = Box()

/* PaintLayerMod MODIFIER MUST BE ADDED - VertexPaint modifier doesn't work */ 
VertexPaintMod = VertexPaintMod_v(obj1)

VertexPaintMod.addPaintLayerMod()
VertexPaintMod.setPaintState()

format "VertexPaintMod: %\n" VertexPaintMod

VertexPaintMod.setVertexColor 1 red
 
format "\n===================================\n"

obj2 = Sphere showVertexColors:true isSelected:on

_paint_layer_mod = PaintLayerMod()
addModifier obj2 _paint_layer_mod

_VertexPaintMod = VertexPaintMod_v(obj2)

_VertexPaintMod.setVertexColor 1 red
_vertex_color = _VertexPaintMod.getVertexAverageColor 1
format "_vertex_color: %\n" (_vertex_color as color )
