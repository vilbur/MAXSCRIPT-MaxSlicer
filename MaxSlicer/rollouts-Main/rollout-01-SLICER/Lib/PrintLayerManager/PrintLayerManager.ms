/** Print layer manager
 */
struct PrintLayerManager_v
(
	/* construct */
	obj,

	/* required */
	

	/* properties */
	

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Get layer contours
	 */
	function getLayerContours =
	(
		format "\n"; print "PrintLayerManager_v.getLayerContours()"

		--stripe_height = 20 -- number of layers in stripe
		stripe_height = ( 1 / DIALOG_maxslicer.SPIN_layer_height.value ) as integer -- get number of layers per 1mm
		
		first_layer = 0
		counter     = 0
		
		stripes = #{} -- verts in stripes
		
		add_verts = true
		
		verts_all = #{1..(getNumVerts obj.mesh)}
		
		bottom_verts = this._getBottomVerts(obj)
		--format "bottom_verts: %\n" bottom_verts
		/* SORT VERTS TO LAYERS */ 
		VertIslandFinder = VertIslandFinder_v(obj)
		
		VertIslandFinder.verts_all = verts_all
		
		VertIslandFinder.verts_process = bottom_verts
		
		verts_layers = VertIslandFinder.sortVertsToLayers only_verts_process:true
	
		/* SERACH FOR INDEX OF FIRST LAYER */ 
		for i = 1 to verts_layers.count while classOf verts_layers[i] != BitArray do  
			first_layer = i + 1

		--format "FIRST_LAYER: %\n" first_layer
	
		/* GET "LAYERS" OF LAYERS */ 
		for i = first_layer to verts_layers.count do
		(
			counter += 1

			/* ADD ONLY EVENT SET OF LAYERS */ 
			if classOf verts_layers[i] == BitArray and add_verts then
				stripes += verts_layers[i]
			
			if counter == stripe_height then
			(
				add_verts = not add_verts
				
				counter = 0
			)
		)
		
		max modify mode

		subobjectLevel = 1

		obj.EditablePoly.SetSelection #Vertex #{}
		obj.EditablePoly.SetSelection #Vertex stripes

		
		
	),

	private

	/** Get bottom verts
	 */
	function _getBottomVerts obj =
	(
		--format "\n"; print "._getBottomVerts()"
		PolyToolsSelect.Normal 3 120 true

		if classOf (_mod = modPanel.getCurrentObject()) == Edit_Poly then
		(
			subObjectLevel = 1
			
			selected_verts = _mod.getSelection #VERTEX
			
		)
		else if classOf _mod  == Editable_Poly then
			_mod.getSelection #VERTEX
		
	),
	
	/**
	 */
	on create do
	(
		--format "\n"; print "PrintLayerManager.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
