/** Ver island finder

	1) Loop each layer
	2) Get verts in each layer
	3) Find how many mesh island exsits


	4) Test if new or old island - in old, then faces exist in all island

 */
struct VertIslandFinder_v
(
	/* construct */
	obj,

	/* required */

	/* properties */
	verts_process	= #{},
	verts_all	= #{},

	face_islands	= #(),
	--verts_layers	= #(),	-- each item is BitArray of verts in layer
	verts_layers = #(), -- #( #{3..8}, 2 ) vertex numbers in layer, if layer is empty, then layer index is stored
	verts_above	= #{},	-- store verts above last layer, or not yet iterated layers
	verts_processed	= #{},

	islands_data	= #(),
	islands_cache	= #(),
	faces_processed	= #{},

	vert_by_face = (),
	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	--layer_height,

	/** Find points
	 */
	function sortVertsToLayers =
	(
		format "\n"; print "VertIslandFinder_v.sortVertsToLayers()"

		/* ========= DEV DESELECT ALL VERTS ========= */
		--obj.EditablePoly.SetSelection #Vertex #{}

		format "VERTS_PROCESS: %\n" verts_process


		verts_pos = in coordsys world meshop.getVerts obj.mesh verts_all node:obj

		/* SET ALL VERTS TO LAYERS */
		--if verts_process.numberSet == verts_all.numberSet then
		(
			print "SET ALL VERTS TO LAYERS"
			bbox = nodeGetBoundingBox obj ( Matrix3 1)

			pos_z_min = bbox[1].z

			--mesh_height = bbox[2].z - pos_z_min
			mesh_height = bbox[2].z

			verts_fit = copy verts_all
		)

		if pos_z_min < 0 then
		(
			messageBox ("OBJECT IS BELLOW THE GROUND.\n\nMove object "+obj.name+" above ground please.") title:"FIND ISLANDS ERROR"

			return false
		)

		layers_count = ceil ( mesh_height / SUPPORT_OPTIONS.layer_height)
		format "LAYERS_COUNT: %\n" layers_count

		this.verts_layers  = #{1..(layers_count + 1)} as Array -- create with

		for vert in verts_fit do
		(
			layer = ( (verts_pos[vert].z ) / SUPPORT_OPTIONS.layer_height ) as integer + 1

			if classOf this.verts_layers [layer] == BitArray then
				this.verts_layers[layer][vert] = true

			else
				this.verts_layers[layer] = #{vert} -- set first vert in layer
		)

		verts_layers --return --return
	),

	/** GET NEW NEW_ISLANDS PER LAYER
	  *
	  * Loop each print layer and search for new islands_cache
	  *
	  * This method is usefel up to 100k vertex count, higher vertex count is slow
	  * Use lots of RAM memory
	  *
	  * @return islands_data #( #{} )
	 */
	function getNewIslandsPerLayer =
	(
		format "\n"; print "VertIslandFinder_v.getNewIslandsPerLayer()"

		format "verts_process.count: %\n" verts_process.count
		--format "layers_count: %\n" layers_count
		--verts_processed = #{}

		--this.empty_bitarray = verts_all * #{}

		if verts_above.isEmpty then
			verts_above = copy verts_all

		timer__setFaceVerts = timeStamp()
		this._setFaceVerts()
		format "_setFaceVerts: % ms\n" (( timeStamp()) - timer__setFaceVerts)

		layers_with_verts = for layer_index = 1 to verts_layers.count where classOf ( verts_in_layer = verts_layers[layer_index] ) == BitArray collect layer_index -- layer has not verts if item is integer ( layer number )

		used_layers_count = layers_with_verts.count

		
		
		all_layers_timer = timeStamp()
		layer_timer = timeStamp()
		vertex_counter_dev = 0

		format "\nSTART OF SEARCHING FOR ISLANDS\n"

		for l = 1 to used_layers_count do
		--for layer in layers_with_verts do -- layer has not verts if item is integer ( layer number )
		(
			--format "\n==============================\nlayer: %\n" layer
			if mod l 100 == 0 then (
				gc light:true

				--format "TIMER: % seconds\n" ((( timeStamp()) - layer_timer) / 1000.0)
				final_time = timeStamp() - layer_timer
				format "\n"
				format "layer: % of: %\n" l used_layers_count
				format "vertex_counter_dev: %\n" vertex_counter_dev
				format "final_time: %\n" final_time
				format "per vertex: %\n" ((final_time as float / vertex_counter_dev ) as float)
				format "TIMER: % seconds\n" ( final_time / 1000.0)

				--format "islands_cache.count: %\n" islands_cache.count
				layer_timer = timeStamp()
				vertex_counter_dev = 0
			)

			layer = layers_with_verts[l]
			--format "layer: %\n" layer

			/* GET VERTS IN LAYER */
			verts_in_layer = verts_layers[layer]
			vertex_counter_dev += verts_in_layer.numberSet
			
			/* REMOVE VERTS FORM CURENT LAYER FROM VERTS ABOVE */
			--for b in verts_in_layer do verts_above[b] = false
			verts_above  -= verts_in_layer

			/* GET ALL FACES IN LAYER */
			faces_in_layer = polyop.getFacesUsingVert obj verts_in_layer

			/* GET ONLY NEW FACES IN LAYER - avoid repetion of faces across layers */
			new_faces_in_layer = faces_in_layer - faces_processed

			/* JOIN NEW FACES TO ALL NEW_ISLANDS */
			timer_JOIN = timeStamp()

			/*------------------------------------------------------------------------------
				GET NEW ISLANDS
			--------------------------------------------------------------------------------*/
			new_islands = this._joinFacesToIslands(new_faces_in_layer)(verts_in_layer)(layer)
			--this._joinVertsToIslands(new_faces_in_layer)
			--format "new_islands.count: %\n" new_islands.count
			/* IF NEW ISLANDS FOUND */
			if new_islands.count > 0 then
			(
				if new_islands.count > 1 then
				(
					/* MERGE NEW ISLANDS BY VERTS - new islands can be splitten  */
					new_islands = this._collapseNewIslands(new_islands)
			
					--for new_island in new_islands do
					--	format "new_island: %\n" new_island
			
					/* MERGE NEW ISLANDS BY FACES  */
					new_islands = this._mergeIslandsBySharedFaces(new_islands) verts_in_layer
				)
			
				/* ADD NEW ISLANDS TO OTHER ISLANDS */
				join islands_cache new_islands
				--for i = 1 to new_islands.count do islands_cache[islands_cache.count + 1] = new_islands[i]
			
				/* TRY MERGE ALL ISLANDS - islands can be joined by new faces in layer */
				this._mergeNewIslandsToCache(layer)
			
				this._addIslandDataToNewIslands(new_islands)(verts_in_layer)(layer)
			)

			--for b in faces_in_layer do faces_processed[b] = true
			--for b in verts_in_layer do verts_processed[b] = true
			faces_processed += faces_in_layer
			verts_processed += verts_in_layer

			--if mod l 100 == 0 then
				--format "Takes % seconds to process\n" ((( timeStamp()) - layer_timer) / 1000.0)
			free new_faces_in_layer
			free new_islands

			--gc light:true
		)
		gc()
		free faces_processed
		free verts_processed
		
		format "\n------\n\n"
		format "islands_data.count: %\n" islands_data.count
		format "ALL_LAYERS_TIMER: % seconds\n" ((( timeStamp()) - all_layers_timer) / 1000.0)

		this.islands_data --return
	),

	/** Join faces to islands
	 */
	function _joinFacesToIslands new_faces_in_layer verts_in_layer layer =
	(
		--format "\n"; print "VertIslandFinder_v._joinFacesToIslands()"
		layer_verts_processed	= #{}
		faceverts_processed	= #{}

		new_islands = #()
		--format "vert_by_face: %\n" vert_by_face
		--format "new_faces_in_layer: %\n" new_faces_in_layer
		--format "new_faces_in_layer %: %\n" layer new_faces_in_layer.numberSet
		
		
		--faceverts_in_layer = for face in new_faces_in_layer collect vert_by_face[face] as BitArray
		faceverts_in_layer = for face in new_faces_in_layer collect polyop.getVertsUsingFace obj #(face)

		
		
		--format "faceverts_in_layer: %\n" faceverts_in_layer
		/* SEARCH FOR NEW ISLANDS */
		for faceverts in faceverts_in_layer do
		(
			merged = false
			--format "faceverts: %\n" faceverts
			/* TRY MERGE FACE TO EXISTING ISlANDS */
				--where ( connecting_verts = this._getIntersection islands_cache[y] faceverts ).numberSet > 0 \
				--and this._hasIntersection -verts_above connecting_verts \
			for y = 1 to islands_cache.count while not merged                                                  \
				where ( connecting_verts = this._bitsAreShared islands_cache[y] faceverts more_bits_then:0 ) != false \
				and this._bitsAreShared -verts_above connecting_verts != false \
				do
			(
				--print "MERGE"
				merged = true
				
				--islands_cache[y] += faceverts
				for b in faceverts do islands_cache[y][b] = true
			)
			
			/* ADD FACE AS NEW ISLAND IF NOT MERGED */
			if not merged then
			(
				
		
				--if this._bitsAreShared verts_process faceverts != false then
				if this._hasIntersection verts_process faceverts then
					/* ADD NEW ISLAND */
					--append new_islands faceverts
					new_islands[new_islands.count +1] = faceverts
			
				else
					/* ADD TO OTHER ISLANDS IF VERTS ARE NOT MEANT TO BE PROCESED - E.g.: if faces are on top side of object */
					--append islands_cache faceverts
					islands_cache[islands_cache.count +1] = faceverts
			)
			--format "ISLANDS_CACHE: %\n" islands_cache.count
			--format "new_islands: %\n" new_islands.count
		)
		
		
		--free faceverts_in_layer
		--free layer_verts_processed
		--free faceverts_processed
		--free new_faces_in_layer
		
		new_islands --return
	),

	/** Merge bit arrays wich shared bits
	  *
	  * @param #( #{} ) bitarrays Array of bittarays
	 */
	function _mergeNewIslandsToCache current_layer =
	(
		--format "ISLANDS_CACHE: %\n" islands_cache.count
		/* LOOP EACH ISLAND */
		for x = islands_cache.count to 1 by -1 do
		(
			merged = false

			island_x = islands_cache[x]

			/* MERGE ISLANDS IF ISLAND X SHARE VERTS WITH ISLAND Y */
			--for y = islands_cache.count to 1 by -1 while not merged where x != y and this._bitsAreShared islands_cache[y] island_x more_bits_then:1 != false do
			for y = islands_cache.count to 1 by -1 while not merged where x != y and this._hasIntersection islands_cache[y] island_x more_bits_then:1 do
			(
				--islands_cache[y] += island_x
				for b in island_x do islands_cache[y][b] = true

				merged = true
				new_island_added = false

				/* ADD DATA TO MERGED ISLAND */
				for i = 1 to islands_data.count while not new_island_added where islands_data[i][#WHOLE_ISLAND] == undefined and this._bitsAreShared islands_data[i][#NEW_ISLAND] island_x != false do
				--for i = 1 to islands_data.count while not new_island_added where islands_data[i][#WHOLE_ISLAND] == undefined and this._hasIntersection islands_data[i][#NEW_ISLAND] island_x do
				(
					if current_layer != islands_data[i][#BOTTOM] then
					(
						--format "islands_data[#BOTTOM][i]: %\n" islands_data[#BOTTOM][i]
						islands_data[i][#TOP] = current_layer

						islands_data[i][#WHOLE_ISLAND] = (island_x * verts_process)

						new_island_added = true
					)

				)
 
				deleteItem islands_cache x
			)
		)
	),
	
	/** Merge islands by shared faces
	  *
	  * FIX:       2 VERTS on one edge problem
	  * CASED BY: Single island with mutliple faces can by divided by face which is not recognized as face of new island
	  *
	 */
	function _mergeIslandsBySharedFaces new_islands verts_in_layer =
	(
		--format "\n"; print "VertIslandFinder_v._mergeIslandsBySharedFaces()"
		--faces_islands = for new_island in new_islands collect polyop.getFacesUsingVert obj (new_island)
		faces_islands = for new_island in new_islands collect polyop.getFacesUsingVert obj (new_island * verts_in_layer )

		for x = faces_islands.count to 1 by -1 do
		(
			merged = false

			faces_island_x = faces_islands[x]
			new_island_x   = new_islands[x]

			/* MERGE ISLANDS IF SHARE FACE */
			for y = faces_islands.count to 1 by -1 while not merged where x != y and this._bitsAreShared faces_island_x faces_islands[y] more_bits_then:0 != false do
			--for y = faces_islands.count to 1 by -1 while not merged where x != y and this._hasIntersection faces_island_x faces_islands[y] more_bits_then:0 do
			(
				merged = true

				--for b in faces_island_x do faces_islands[y][b] = true
				--for b in new_island_x do new_islands[y][b] = true
				
				faces_islands[y] += faces_island_x
				new_islands[y]   += new_island_x

				deleteItem faces_islands x
				deleteItem new_islands x
			)
			
		)

		new_islands --return
	),


	/** Merge bit arrays wich shared bits
	  *
	  * @param #( #{} ) bitarrays Array of bittarays
	 */
	function _collapseNewIslands bitarrays =
	(
		--format "\n"; print "VertSelector_v._collapseNewIslands()"

		for x = bitarrays.count to 1 by -1 do
		(
			--format "x: %\n" x
			merged = false

			bitarrays_x = bitarrays[x]

			for y = bitarrays.count to 1 by -1 while not merged where x != y and this._bitsAreShared bitarrays_x bitarrays[y] more_bits_then:1 != false  do
			--for y = bitarrays.count to 1 by -1 while not merged where x != y and this._hasIntersection bitarrays_x bitarrays[y] more_bits_then:1 do
			(
				bitarrays[y] += bitarrays[x]
				--for b in bitarrays[x] do bitarrays[y][b] = true
				
				merged = true

				--gc light:true
			)

			if merged then
				deleteItem bitarrays x
		)

		bitarrays --return
	),

	/** Add island data to neww islands
	 */
	function _addIslandDataToNewIslands new_islands verts_in_layer layer =
	(
		--format "\n"; print "VertIslandFinder_v._addIslandDataToNewIslands()"
		for new_island in new_islands do
		(
			--format "\n"; print "VertIslandFinder_v._addIslandDataToNewIslands()"
			island_data = Dictionary()
			--format "%: %\n" layer new_island
			island_data[#NEW_ISLAND] = (new_island * verts_in_layer)

			island_data[#BOTTOM] = layer

			islands_data[islands_data.count +1] = island_data
			--append islands_data island_data
		)
	),
	
	/** Get intersection
	 */
	function _getIntersection bitArr_A bitArr_B  =
	(
		--format "\n"; print "VertIslandFinder_v._getIntersection()"
		intersection = #{}
		
		isBiggerAthenB = bitArr_A.numberSet > bitArr_B.numberSet
		
		arr_small = if isBiggerAthenB then bitArr_B else bitArr_A
		arr_large = if isBiggerAthenB then bitArr_A else bitArr_B
		
		--minCount = amin bitArr_A.count bitArr_B.count
		----format "classOf minCount: %\n" (classOf minCount)
		intersection.count = arr_small.numberSet -- Pre-allocates space for 1000 bits. This is very efficient if you know the final size.
		
		for i in arr_small where arr_large[i] do 
			intersection[i] = true
		
		intersection -- return
	),
	
	/** Test if bitarrays share bits
	 */
	function _bitsAreShared arr_A arr_B more_bits_then:0 =
	(
		if ( intersection = ( arr_A * arr_B ) ).numberSet > more_bits_then then
			intersection --return
		else
			false --return
	),

	/** Bitarrays match
	 */
	function _hasIntersection haystack needle more_bits_then:0 =
	(
		--format "\n"; print "VertIslandFinder_v.bitarraysMatch()"
		founds = 0

		for vert in needle while not founds > more_bits_then  where haystack[vert] do founds += 1

		founds > more_bits_then --return
	),
	
	/** 
	  *	
	  */
	function _setFaceVerts =
	(
		--format "\n"; print "VertIslandFinder_v._setFaceVerts()"
		face_count = polyop.getNumFaces obj
		--format "face_count: %\n" face_count
		this.vert_by_face = #()
	
		for f = 1 to face_count do
			--format "WTF: %\n" ((polyop.getFaceVerts obj f))
			--append this.vert_by_face (polyop.getFaceVerts obj f)
			this.vert_by_face[f] = polyop.getFaceVerts obj f
	),

	--
	--/** Test new islands
	-- */
	--function _testNewIslands =
	--(
	--	--format "\n"; print "VertIslandFinder_v._testNewIslands()"
	--	--for x = islands_data.count to 1 by -1 do
	--	--(
	--	--	--format "x: %\n" x
	--	--
	--	--	island_data = islands_data[x][#NEW_ISLAND]
	--	--
	--	--		--format "island_data: %\n" island_data
	--	--	--if island_data != undefined then
	--	--
	--	--
	--	--		for y = islands_data.count to 1 by -1 where x != y and ( island_data * islands_data[y][#NEW_ISLAND] ).numberSet > 0 do
	--	--		(
	--	--			format "\n\n=========================\n"
	--	--			format "x: % \ny: %\n\n" x y
	--	--			format "NEW_ISLAND: %\n" islands_data[y][#NEW_ISLAND]
	--	--		)
	--	--		--else
	--	--		--(
	--	--		--	format "\n\n=========================\n"
	--	--		--	format "UNDEFINED: %\n" x
	--	--		--)
	--	--	gc light:true
	--	--
	--	--)
	--
	--	for island_data in islands_data do
	--		format "island_data[#NEW_ISLAND]: %\n" island_data[#NEW_ISLAND]
	--
	--),

	/** Set vertex color to new islands
	 */
	function _setVertexColorToNewIslands =
	(
		--format "\n"; print "VertIslandFinder_v.setVertexColorToNewIslands()"
		obj.showVertexColors	= true
		obj.vertexColorsShaded	= true

		polyop.setVertColor obj.baseobject 0 this.verts_all white

		for merged_island in this.merged_islands  do
		(
			format "merged_island: %\n" merged_island

			polyop.setVertColor obj.baseobject 0 (merged_island) green
		)


		--for new_island in this.islands_data[#NEW_ISLANDS]  do
		----for new_island in this.islands_data[#NEW_ISLANDS]  do
		--(
		--	polyop.setVertColor obj.baseobject 0 (new_island) red
		--
		--	this._getCenterOfIsland (new_island)
		--)

	),
	--
	--/** Get first layer
	-- */
	--function _getFirstLayerIslands =
	--(
	--	format "\n"; print "VertIslandFinder_v._getFirstLayer()"
	--	for layer = 1 to verts_layers.count where classOf ( verts_in_layer = verts_layers[layer] ) == BitArray and not ( verts_in_layer * verts_process ).isEmpty  do -- layer has not verts if item is integer ( layer number )
	--	(
	--		faces_in_layer = polyop.getFacesUsingVert obj verts_in_layer
	--		format "faces_in_layer: %\n" faces_in_layer
	--		this.faces_processed += faces_in_layer
	--
	--
	--		this.islands_cache = this.getVertexIslands ( polyop.getVertsUsedOnlyByFaces obj faces_in_layer)
	--		--this.islands_cache = this.getVertexIslands ( polyop.getVertsUsingFace obj faces_in_layer)
	--
	--		return layer
	--	)
	--
	--),

	/** Set verts processed
	 */
	function setVertsProcessed verts =
	(
		--format "\n"; print "VertIslandFinder_v.setVertsProcessed()"
		this.islands_cache = this.getVertexIslands (verts)
	),
	--
	--/** Set verts processed
	-- */
	--function getVertexIslands verts =
	--(
	--	--format "\n"; print "VertIslandFinder_v.getVertexIslands()"
	--	--verts_processed = verts
	--	--
	--	----faceverts = for face_id in faces_of_verts collect ( polyop.getVertsUsingFace obj face_id )
	--	--
	--	--islands_cache = this._sortVertsByIslands( polyop.getFacesUsingVert obj verts_processed
	--	islands = #()
	--
	--	--verts_used = copy verts
	--	--face_verts = polyop.getVertsUsingFace obj face
	--
	--	--vertex_count = getNumVerts obj.mesh
	--	--format "vertex_count: %\n" vertex_count
	--	--
	--	--all_verts = #{1..(vertex_count)}
	--
	--	--faces_sel = polyop.getFaceSelection obj
	--	--format "faces_sel: %\n" faces_sel
	--	--/*------ SPLIT TO NEW_ISLANDS ------*/
	--	--verts_sel = polyop.getVertsUsingFace obj faces_sel
	--	--format "verts_sel: %\n" verts_sel
	--
	--	while not verts.isEmpty do
	--	(
	--		faces_of_vert = polyop.getFacesUsingVert obj (verts as Array )[1]
	--
	--		verts_of_faces = polyop.getVertsUsingFace obj faces_of_vert
	--		format "verts_of_faces: %\n" verts_of_faces
	--		verts_of_faces -= this.verts_above
	--
	--		append islands verts_of_faces
	--
	--		verts -= verts_of_faces
	--	)
	--
	--	this._mergeNewIslandsToCache(islands) --return
	--
	--	--islands --return
	--),

	/** Get center of island
	 */
	function _getCenterOfIsland verts =
	(
		--format "\n"; print "VertIslandFinder_v.getCenterOfIsland()"

		pos_center = point3 0 0 0

		positions = in coordsys world meshop.getVerts obj.mesh verts node:obj


		for pos in positions do pos_center += pos

		pos_center /= positions.count

		_Point = Point pos:pos_center size:5 wirecolor:red

		_Point.parent = obj

	),



	private

	/** Get face layers
	 */
	function getFaceLayers faces_in_layer =
	(
		--format "\n"; print "VertIslandFinder_v.getFaceLayers()"
	),





	/**
	 */
	on create do
	(
		--format "\n"; print "VertIslandFinder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
