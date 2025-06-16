clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../VertexPaintMod.ms" )	--"./../VertexPaintMod.ms"

delete objects

obj1 = Box()

/* PaintLayerMod MODIFIER MUST BE ADDED - VertexPaint modifier doesn't work */ 
VertexPaintMod = VertexPaintMod_v(obj1)
--VertexPaintMod = VertexPaintMod_v(Box())

VertexPaintMod.addPaintLayerMod()
VertexPaintMod.setPaintState()

format "VertexPaintMod: %\n" VertexPaintMod

VertexPaintMod.setVertexColor 1 red
 
--_vertex_color = VertexPaintMod.getVertexAverageColor 1
--VertexPaintMod.setVertexColor 1 red

format "\n===================================\n"

obj2 = Sphere showVertexColors:true isSelected:on
--convertToPoly obj2
_paint_layer_mod = PaintLayerMod()
addModifier obj2 _paint_layer_mod

_VertexPaintMod = VertexPaintMod_v(obj2)
--_VertexPaintMod.paint_layer_mod = _paint_layer_mod

_VertexPaintMod.setPaintLayerMod()
_VertexPaintMod.setPaintState()
--
format "_VertexPaintMod: %\n" _VertexPaintMod

_VertexPaintMod.setVertexColor 1 red

--format "\n===================================\n"
--
--
--VertexPaintMod = VertexPaintMod_v()
--
--VertexPaintMod.createVertexPaintBox()
--VertexPaintMod.setPaintState()
--
--format "VertexPaintMod: %\n" VertexPaintMod
----
----
--VertexPaintMod.setVertexColor 1 red

--
--obj = $Sphere001
----_paint_layer_mod = PaintLayerMod()
----addModifier obj2 _paint_layer_mod
--
--_VertexPaintMod = VertexPaintMod_v(obj2)
----_VertexPaintMod.paint_layer_mod = _paint_layer_mod
--
--_VertexPaintMod.setPaintLayerMod()
--_VertexPaintMod.setPaintState()
----
--format "_VertexPaintMod: %\n" _VertexPaintMod
--
--_VertexPaintMod.setVertexColor 1 red
--_VertexPaintMod.setVertexColor 2 green