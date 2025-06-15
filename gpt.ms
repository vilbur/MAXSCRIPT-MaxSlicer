clearListener(); print("Cleared in:\n"+getSourceFileName())

/* 
Struct for managing VertexPaint modifier and paint states
Provides public functions for various color manipulations
*/
struct VertexPaintMod_v
(
	/* 
	Create geometry object with VertexPaint modifier and enable vertex colors
	Returns tuple #(node, modifier)
	*/
	function createVertexPaintBox =
	(
		g = box()
		v = PaintLayerMod()
		addModifier g v
		g.showVertexColors = on
		#(g, v) -- return
	),

	/* 
	Acquire paint state from modifier on node
	Returns paint state object
	*/
	function acquirePaintState mod obj =
	(
		mod.AcquirePaintState obj -- return
	),

	/* 
	Set raw color by 1-based index, then apply to object
	*/
	function setRawColor mod obj state raw_index color =
	(
		state.SetRawColor raw_index color
		mod.ApplyPaintState obj state
	),

	/* 
	Set raw color by 1-based index, then apply to object
	*/
	function getRawColor state vertex_index =
	(
		state.GetRawColor ((vertex_index))
	),

	/* 
	Get number of raw color entries in the state
	*/
	function getNumRawColors state =
	(
		state.GetNumRawColors() -- return
	),

	/* 
	Set color on vertex index (affects all entries of vertex), apply to object
	*/
	function setVertexColor mod obj state vertex_index color =
	(
		state.SetVertColor vertex_index color
		mod.ApplyPaintState obj state
	),

	/* 
	Get average color of a vertex from paint state
	*/
	function getVertexAverageColor state vertex_index =
	(
		state.GetVertAverageColor vertex_index -- return
	),

	/* 
	Set color on a face (affects all entries of face), apply to object
	*/
	function setFaceColor mod obj state face_index color =
	(
		state.SetFaceColor face_index color
		mod.ApplyPaintState obj state
	),

	/* 
	Get average color of a face from paint state
	*/
	function getFaceAverageColor state face_index =
	(
		state.GetFaceAverageColor face_index -- return
	),

	/* 
	Set color on a specific face-vert combo or using raw index
	*/
	function setFaceVertColor mod obj state face_index vertex_index color_raw color_mapped =
	(
		state.SetFaceVertColor face_index vertex_index color_raw
		raw_index = state.GetRawIndex face_index vertex_index
		state.SetRawColor raw_index color_mapped
		mod.ApplyPaintState obj state
	),

	/* 
	Capture existing vertex colors into VertexPaint modifier using specific map channel
	*/
	function captureExistingColors mod obj map_channel =
	(
		mod.mapChannel = map_channel
		mod.MergeVertexColors obj
		mod.AcquirePaintState obj -- return
	),

	on create do
	(
	)
)
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
