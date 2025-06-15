clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../VertexPaintMod.ms" )	--"./../VertexPaintMod.ms"

delete objects
-- Example usage:
 vp = VertexPaintMod_v()
 result = vp.createVertexPaintBox()
 g = result[1]
 v = result[2]
 s = vp.acquirePaintState v g
 --vp.setVertexColor v g s 1 [1, 0.5, 0, 1]
 vp.setVertexColor v g s 1 (green as point4 )
 
_vertex_color = vp.getVertexAverageColor s 1
--_vertex_color = vp.getRawColor s 1

format "_vertex_color: %\n" _vertex_color 
format "_vertex_color: %\n" (_vertex_color as color ) 
