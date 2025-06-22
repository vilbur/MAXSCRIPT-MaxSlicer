clearListener(); print("Cleared in:\n"+getSourceFileName())



/** Vert island finder fn
 */
function islandPerLayerFinderFn obj =
(
	--format "\n"; print ".islandPerLayerFinderFn()"

	if verts_above.isEmpty then
		verts_above = copy verts_all

	layers_with_verts = for layer_index = 1 to verts_layers.count where classOf ( verts_in_layer = verts_layers[layer_index] ) == BitArray collect layer_index -- layer has not verts if item is integer ( layer number )

	used_layers_count = layers_with_verts.count

	all_layers_timer = timeStamp()

	for layer in layers_with_verts do -- layer has not verts if item is integer ( layer number )
	(
		--format "layer: %\n" layer
		--format "\n==============================\nlayer: %\n" layer
		if mod layer 50 == 0 then (

			format "\n"
			format "layer: % of: %\n" layer used_layers_count
			layer_timer = timeStamp()
		)

		/* GET VERTS IN LAYER */
		verts_in_layer = verts_layers[layer]
	--	format "verts_in_layer: %\n" verts_in_layer
		/* REMOVE VERTS FORM CURENT LAYER FROM VERTS ABOVE */
		verts_above  -= verts_in_layer

		/* GET ALL FACES IN LAYER */
		faces_in_layer = polyop.getFacesUsingVert obj verts_in_layer

		/* GET ONLY NEW FACES IN LAYER - avoid repetion of faces across layers */
		new_faces_in_layer = faces_in_layer - faces_processed

		/* GET VERTS OF NEW FACES IN LAYER */
		this.verts_of_new_faces = ( polyop.getVertsUsingFace obj new_faces_in_layer ) * verts_in_layer

		/* JOIN NEW FACES TO ALL ISLANDS */
		this._joinVertsToIslands()











		
	--	format "islands_all: %\n" this.islands_all
		--format "islands_all.count: %\n" this.islands_all.count

		--for verts_island in this.islands_all where (verts_island * verts_processed ).isEmpty do
		----for verts_island in this.islands_all where verts_island != undefined and (verts_island * verts_processed ).isEmpty do
		--(
		--	new_island = verts_island * verts_in_layer
		--
		--	append this.new_islands new_island
		--)

		faces_processed += faces_in_layer
		verts_processed += verts_in_layer

		--if mod layer 200 == 0 then
			--gc light:true
		if mod layer 50 == 0 then (
			format "layer_timer: % seconds\n" ((( timeStamp()) - layer_timer) / 1000.0)
		)

	)






)



islandPerLayerFinderFn( selection[1] )