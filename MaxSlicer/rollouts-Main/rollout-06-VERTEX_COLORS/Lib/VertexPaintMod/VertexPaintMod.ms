--clearListener(); print("Cleared in:\n"+getSourceFileName())

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
		/*  Create geometry object with VertexPaint modifier and enable vertex colors
		Returns tuple #(node, modifier)
	*/
	function createVertexPaintBox =
	(
		--this.obj = this.obj
		this.obj = box()

		this.addPaintLayerMod()
	),
	
	/** Add paint layer mod
	 */
	function addPaintLayerMod = 
	(
		--format "\n"; print "for.addPaintLayerMod()"
		this.paint_layer_mod = PaintLayerMod()

		addModifier this.obj this.paint_layer_mod
	),
	
	/** Set paint layer mod
	  * IMPORTATNT:
	  *   1) PaintLayerMod MODIFIER MUST BE ADDED
	  *   2) VertexPain    MODIFIER DOESN'T WORK - EVEN IF classOf(PaintLayerMod()) == classOf(VertexPaint())
	  *   

	 */
	function setPaintLayerMod =
	(
		--format "\n"; print "VertexPaintMod_v.setPaintLayerMod()"
		for _mod in this.obj.modifiers where classOf _mod == PaintLayerMod do
			this.paint_layer_mod = _mod
	),
	
	/*  Acquire paint state from modifier on node
		Returns paint state object
	*/
	function setPaintState =
	(
		--format "\n"; print "VertexPaintMod_v.setPaintState()"
		--format "this.obj: %\n" this.obj
		completeRedraw() -- WITHOUT THIS LINE AcquirePaintState returns undefined
		--max modify mode
		this.paint_state = this.paint_layer_mod.AcquirePaintState this.obj -- return
	),
	
	/* Set raw color by 1-based index, then apply to object
	*/
	function setRawColor raw_index color =
	(
		paint_state.SetRawColor raw_index ( color as Point4 )
		
		paint_layer_mod.ApplyPaintState this.obj paint_state
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
	function setVertexColor vertex_indexes color =
	(
		this.obj.showVertexColors = on
		
		if superClassOf vertex_indexes == Number then
			vertex_indexes = #{vertex_indexes}
		
		for vertex_index in vertex_indexes do 
			this.paint_state.SetVertColor vertex_index ( color as Point4 )
		
		
		paint_layer_mod.ApplyPaintState this.obj paint_state
	),

	/* Get average color of a vertex from paint state
	*/
	function getVertexAverageColor vertex_index =
	(
		
		paint_state.GetVertAverageColor vertex_index -- return
	),
	
	/** Get verts and colors
	 */
	function getVertsAndColors =
	(
		format "\n"; print "for.getVertsAndColors()"
		verts_by_colors	= Dictionary #STRING -- KEY:color as string VALUE:#{ verts of color }
		vertex_count = getNumVerts obj.mesh
--format "vertex_count: %\n" vertex_count
		for v = 1 to vertex_count do
		(
			vertex_color = ((this.getVertexAverageColor v) as color ) as string
			
			if verts_by_colors[vertex_color] == undefined then 
				verts_by_colors[vertex_color] = #{}
			
			verts_by_colors[vertex_color][v] = true
			--format "vertex_color: %\n" (vertex_color as color )
		)
		
		
		--colors_num = this.getNumRawColors()
		
		--format "colors_num: %\n" colors_num
		verts_by_colors --return
	),
	
	/* Set color on a face (affects all entries of face), apply to object
	*/
	function setFaceColor face_index color =
	(
		paint_state.SetFaceColor face_index ( color as Point4 )
		
		paint_layer_mod.ApplyPaintState this.obj paint_state
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
		
		paint_layer_mod.ApplyPaintState this.obj paint_state
	),

	/* Capture existing vertex colors into VertexPaint modifier using specific map channel
	*/
	function captureExistingColors map_channel =
	(
		paint_layer_mod.mapChannel = map_channel
		
		paint_layer_mod.MergeVertexColors this.obj
		
		paint_layer_mod.AcquirePaintState this.obj -- return
	),

	on create do
	(
		this.setPaintLayerMod()

		if this.paint_layer_mod != undefined then
			this.setPaintState()
	)
)

