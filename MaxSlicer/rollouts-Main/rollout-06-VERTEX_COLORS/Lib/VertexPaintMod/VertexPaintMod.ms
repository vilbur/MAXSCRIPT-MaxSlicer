clearListener(); print("Cleared in:\n"+getSourceFileName())

/*  Struct for managing VertexPaint modifier and paint states
	Provides public functions for various color manipulations
*/
struct VertexPaintMod_v
(
	/* construct */
	obj,
	
	/* required */
	paint_layer_mod,
	paint_state,
	
	/* properties */
	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	

	/* 
	Acquire paint state from modifier on node
	Returns paint state object
	*/
	function setPaintState =
	(
		this.paint_state = paint_layer_mod.AcquirePaintState obj -- return
	),
	
	/* Set raw color by 1-based index, then apply to object
	*/
	function setRawColor raw_index color =
	(
		paint_state.SetRawColor raw_index ( color as Point4 )
		
		paint_layer_mod.ApplyPaintState obj paint_state
	),

	/* Set raw color by 1-based index, then apply to object
	*/
	function getRawColor vertex_index =
	(
		paint_state.GetRawColor ((vertex_index))
	),

	/* Get number of raw color entries in the state
	*/
	function getNumRawColors =
	(
		paint_state.GetNumRawColors() -- return
	),

	/* Set color on vertex index (affects all entries of vertex), apply to object
	*/
	function setVertexColor vertex_index color =
	(
		this.paint_state.SetVertColor vertex_index ( color as Point4 )
		
		paint_layer_mod.ApplyPaintState obj paint_state
	),

	/* Get average color of a vertex from paint state
	*/
	function getVertexAverageColor vertex_index =
	(
		paint_state.GetVertAverageColor vertex_index -- return
	),

	/* Set color on a face (affects all entries of face), apply to object
	*/
	function setFaceColor face_index color =
	(
		paint_state.SetFaceColor face_index ( color as Point4 )
		
		paint_layer_mod.ApplyPaintState obj paint_state
	),

	/* Get average color of a face from paint state
	*/
	function getFaceAverageColor face_index =
	(
		paint_state.GetFaceAverageColor face_index -- return
	),

	/* Set color on a specific face-vert combo or using raw index
	*/
	function setFaceVertColor face_index vertex_index color_raw color_mapped =
	(
		paint_state.SetFaceVertColor face_index vertex_index color_raw
		
		raw_index = paint_state.GetRawIndex face_index vertex_index
		
		paint_state.SetRawColor raw_index color_mapped
		
		paint_layer_mod.ApplyPaintState obj paint_state
	),

	/* Capture existing vertex colors into VertexPaint modifier using specific map channel
	*/
	function captureExistingColors map_channel =
	(
		paint_layer_mod.mapChannel = map_channel
		
		paint_layer_mod.MergeVertexColors obj
		
		paint_layer_mod.AcquirePaintState obj -- return
	),

	on create do
	(
		format "paint_layer_mod: %\n" paint_layer_mod
		format "obj: %\n" obj
		--this.state = this.setPaintState paint_layer_mod obj
		this.setPaintState()
	)
)
