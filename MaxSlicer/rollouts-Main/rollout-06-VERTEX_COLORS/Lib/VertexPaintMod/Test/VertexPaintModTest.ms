clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../VertexPaintMod.ms" )	--"./../VertexPaintMod.ms"

delete objects

/*------------------------------------------------------------------------------
	ADD VERTEX PAINT MODIFIER
--------------------------------------------------------------------------------*/
/** Add vertex paint modifier
 */
function addVertexPaintModifier =
(
	--format "\n"; print ".addVertexPaintModifier()"
	format "\n===================================\n"
	
	obj = Box()
	
	VertexPaintMod = VertexPaintMod_v(obj)
	
	VertexPaintMod.addPaintLayerMod()
	VertexPaintMod.setPaintState()
	
	format "VertexPaintMod: %\n" VertexPaintMod
	
	VertexPaintMod.setVertexColor 1 red
)

 /*------------------------------------------------------------------------------
	GET EXISTING VERTEX PAINT MODIFIER
--------------------------------------------------------------------------------*/
function useExistingVertexPaintModifier =
(
	--format "\n"; print ".useExistingVertexPaintModifier()"
	format "\n===================================\n"
	
	obj = Sphere showVertexColors:true isSelected:on
	
	_paint_layer_mod = PaintLayerMod()
	addModifier obj _paint_layer_mod
	
	VertexPaintMod = VertexPaintMod_v(obj)
	
	--VertexPaintMod.setVertexColor 1 blue
	VertexPaintMod.setVertexColor #{1..10} blue
	
	
	verts_by_colors = VertexPaintMod.getVertsAndColors()
	
	format "verts_by_colors: %\n" verts_by_colors
	--_vertex_color = VertexPaintMod.getVertexAverageColor 1
	--format "_vertex_color: %\n" (_vertex_color as color )
)


--addVertexPaintModifier()
useExistingVertexPaintModifier()