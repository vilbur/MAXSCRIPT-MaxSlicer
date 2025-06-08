filein( getFilenamePath(getSourceFileName()) + "/../VertexGrid/VertexGrid.ms" )	--"./../VertexGrid/VertexGrid.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertexGridGetter/VertexGridGetter.ms" )	--"./../VertexGridGetter/VertexGridGetter.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertIslandFinder/VertIslandFinder.ms" )	--"./../VertIslandFinder/VertIslandFinder.ms"

/** Get lowest verts in grid


	IMPORTANT:
		  DIFFERENT METHODS CAN RETURN DIFFERENT BitArray ON SAME SELECTION e.g.: #{1..157090} and #{1..930, 932..157091} -- vertext index 931 is missing and array is larger

		  In polyop methods is one vertex index missing in middle of BitArray

			Noticed on model imported from Zbrush

		  SOLUTION: REXPORT OBJECT, xform and attach to new object doesnt help

		  A) 'getVertSelection obj.mesh'	returns #{1..1000}
		  B) 'polyop.getVertSelection obj'	returns #{1..930, 932..1001}


 */
struct VertSelector_v
(
	/* construct */
	obj,	-- editable poly object used to process
	--obj_original,	-- not collapesd original object

	/* properties */
	sel_modified = #{},
	face_elements = #(),

	verts_pos,
	--data_verts,
	--resolution = 5,
	--resolution = 10,

	/* dependency */
	--MeshDataGetter,
	VertexGridGetter,
	--VertexLayers,
	VertIslandFinder,

	/* reference */
	/* inhered */
	/** Find islands per layer
	 */
	function findIslandsPerLayer layer_height =
	(
		--format "\n"; print "VertSelector_v.findIslandsPerLayer()"
		--format "VertexLayers: %\n" VertexLayers

		vertex_count = getNumVerts obj.mesh

		verts_all = #{1..(vertex_count)}

		/* GET VERTS WITH NORMAL POINTING DOWN */
		--bottom_verts = this.getBottom()
		/* GET ONLY CONVEX VERTS */
		--convex_verts = this.selectConvex()

		visible_verts = -( polyop.getHiddenVerts obj)

		verts_process = if (verts_sel = polyop.getVertSelection obj ).numberSet > 0 then verts_sel else verts_all

		verts_process *= visible_verts

		VertIslandFinder.verts_all	= verts_all
		VertIslandFinder.verts_process	= verts_process


		--if ( VertIslandFinder.findVertsOfNewIslands()) != undefined then
		(
			VertIslandFinder.sortVertsToLayers()

			 --for layer_index = 1 to VertIslandFinder.verts_layers.count where classOf ( verts_in_layer = VertIslandFinder.verts_layers[layer_index] ) == BitArray do
				--format "%: %\n" layer_index verts_in_layer

			--format "VertIslandFinder.verts_layers: %\n" VertIslandFinder.verts_layers

			VertIslandFinder.getNewIslandsPerLayer()

			/* ADD ISLAND DATA */
			for i = 1 to VertIslandFinder.islands_data.count do
			(
				island_data = VertIslandFinder.islands_data[i]

				VertIslandFinder.islands_data[i][#LOWEST_VERT] = this._getLowestVertOnZaxis( island_data[#NEW_ISLAND] )

				verts_get_size = if island_data[#WHOLE_ISLAND] != undefined then island_data[#WHOLE_ISLAND] else island_data[#NEW_ISLAND]

				if island_data[#WHOLE_ISLAND] != undefined then
				(
					x_positions = for vert in verts_get_size collect verts_pos[vert].x
					y_positions = for vert in verts_get_size collect verts_pos[vert].y


					x_length = (amax x_positions) - (amin x_positions)
					y_length = (amax y_positions) - (amin y_positions)


					VertIslandFinder.islands_data[i][#SIZE] = [x_length, y_length]
				)
			)
		)

		VertIslandFinder.islands_data --return
	),

	/** Get lowest verts in grid
	 */
	function selectLowestVertsInGrid resolution:10 =
	(
		format "\n"; print "VertSelector_v.selectLowestVertsInGrid()"
		VertexGridGetter.resolution = resolution

		this.sel_modified = VertexGridGetter.getLowestVertsInGrid()

		this._selectVertsAndReturn(true) --return
	),

	/** Get lowest verts in grid
	 */
	function selectMiddleVertsInGrid resolution:10 =
	(
		format "\n"; print "VertSelector_v.selectMiddleVertsInGrid()"
		VertexGridGetter.resolution = resolution

		this.sel_modified = VertexGridGetter.getMiddlePointsInGrid()

		this._selectVertsAndReturn(true) --return
	),

	/** Get lowest verts in grid
	 */
	function selectChecker mode:#2D resolution:10 =
	(
		format "\n"; print "VertSelector_v.selectChecker()"
		format "RESOLUTION: %\n" resolution
		VertexGridGetter.resolution = resolution

		this.sel_modified = if mode == #3D then
								VertexGridGetter.getCheckerPattern3D()
							else
								VertexGridGetter.getCheckerPattern2D()

		this._selectVertsAndReturn(true) --return

	),

	/** Get lowest verts in grid
	 */
	function selectChecker2D resolution:10 invert_sel:false =
	(
		format "\n"; print "VertSelector_v.selectChecker()"
		format "RESOLUTION: %\n" resolution
		VertexGridGetter.resolution = resolution

		this.sel_modified = VertexGridGetter.selectChecker2D invert_sel:invert_sel

		this._selectVertsAndReturn(true) --return

	),

	/** Select sinlge vert per face island

		Point with lowest position on Z
	 */
	function selectSingleVertPerFaceIsland make_selection:true =
	(
		format "\n"; print "VertSelector_v.selectSingleVertPerFaceIsland()"
		/**  Left only single lowest vert of verts
		  *   Verts above are removed from selection
		 */
		function _filterOnlyMinZVerts verts =
		(
			/* VERTS CAN BE UNDEFINED IF CELL IS EMPTY */
			if verts.numberSet > 0 then
			(
				if ( lowest_vert = this._getLowestVertOnZaxis(verts) ) != undefined then
					this.sel_modified[lowest_vert] = true
				else
					this.sel_modified[(verts as Array )[1] ] = true
			)

		)

		verts_sel	= getVertSelection obj.mesh


		this._setVertsPositions(verts_sel)

		hidden_verts = polyop.getHiddenVerts obj

		this.sel_modified = #{}

		verts_islands = this._sortVertsByIslands(verts_sel)
		--format "verts_islands.count: %\n" verts_islands.count
		--format "verts_islands: %\n" verts_islands

		/* LOOP EACH ISLAND OF VERTS */
		for verts_island in verts_islands do
			_filterOnlyMinZVerts ( verts_island  )


		free verts_islands

		this._selectVertsAndReturn(make_selection) --return
	),

	/** Get lowest verts
	 */
	function getLowestVerts bitarrays =
	(
		format "\n"; print "VertSelector_v.getLowestVerts()"

		if classOf bitarrays == BitArray then
			bitarrays = #(bitarrays)

		--this._mergeBitArraysbySharedBits(bitarrays)

		lowest_verts = #{}

		for verts in bitarrays do
		(
			--format "verts: %\n" verts
			--lowest_verts += verts

			lowest_verts[this._getLowestVertOnZaxis(verts)] = true
		)

		lowest_verts --return

	),


	/** select verts which normal points
	  *
	  * #INNER  - verts VISIBLE form top view
	  * #OUTTER - verts INVISIBLE form top view
	  *
	  * @param #INNER|#OUTTER
	 */
	function selectInnerOutterVerts mode =
	(
		--format "\n"; print ".selectInnerUpperVerts()"
		gc light:true

		--obj	= selection[1]

		ray_grid = RayMeshGridIntersect()

		ray_grid.initialize 10
		ray_grid.addNode obj
		ray_grid.buildGrid()

		direction = point3 0 0 1

		offset = point3 0 0 0.1

		--max modify mode

		subObjectLevel = 1

		--if mode == #INNER then
			PolyToolsSelect.Normal 3 15 false

		vertex_sel	= getVertSelection obj.mesh
		--format "vertex_sel.numberSet: %\n" vertex_sel.numberSet

		format "\n\nESTIMATED TIME of processing % vertices: % seconds\n" vertex_sel.numberSet ((vertex_sel.numberSet / 100) as integer )


		vertex_count = getNumVerts obj.mesh

		verts_all = #{1..vertex_count}

		verts_pos = in coordsys world meshop.getVerts obj.mesh verts_all node:obj

		processed = copy verts_all * #{}

		result = #{}
		result_grid = #{}

		timer_get_verts = timeStamp()

		--format "vertex_sel.numberSet: %\n" vertex_sel.numberSet
		for vert in vertex_sel do
		(
			--hits = ray_grid.intersectRay ( verts_pos[vert] + offset ) direction true
			--if( mode == #INNER and hits == 0 ) or ( mode != #INNER and hits > 0 ) then
			--	result_grid[vert] = true

			hits = intersectRay obj ( Ray ( verts_pos[vert] + offset ) direction )

			--format "%: %\n" vert hits
			if( mode == #INNER and hits != undefined ) or ( mode != #INNER and hits == undefined ) then
				result[vert] = true
		)

		--format "GRID.numberSet: %\n" result_grid.numberSet
		--format "%\n" result_grid
		--format "\n"
		--
		--format "RESULT.numberSet: %\n" result.numberSet
		--format "%\n" result

		obj.EditablePoly.SetSelection #Vertex #{}
		obj.EditablePoly.SetSelection #Vertex result

	),

	/** Get ace islands by verts
	  *
	  * @param BitArray verts which faces will be sorted by islands
	  *
	  * @return #( #{..} ) array of vertex ids, each array are verts of one island
	 */
	function _sortVertsByIslands verts =
	(
		--format "\n"; print "VertSelector_v._sortVertsByIslands()"

		function facesShareVerts verts1 verts2 = not ( verts1 * verts2 ).isEmpty
		--function facesShareVerts verts1 verts2 = ( verts1 * verts2 ).numberSet > 1

		--tested_pairs	= #{} -- store stringified array of face id used in loop already
		--verts_islands	= #() -- #( #{ veret_ids } ) array of bitarrays of verts sorted by island the occupy
		----face_islands	= #() -- #( #{ faces_ids } ) array of bitarrays of faces sorted by island the occupy
		--verts_per_faces	= #()

		--all_verts = #{1..(getNumVerts obj.mesh)}
		--empty_bitarray = #{1..(getNumVerts obj.mesh)} * #{}
		--faces_by_verts = polyop.getFacesUsingVert obj verts
		--
		--faceverts = for f in faces_by_verts collect polyop.getVertsUsingFace obj #{f}
		--
		--format "faceverts: %\n" faceverts
		--
		--this._mergeBitArraysbySharedBits (faceverts)



		faces_by_verts = for vert in verts collect polyop.getFacesUsingVert obj #{vert}
		format "faces_by_verts: %\n" faces_by_verts
		format "faces_by_verts.count: %\n" faces_by_verts.count

		face_islands = this._mergeBitArraysbySharedBits (faces_by_verts)
		format "face_islands: %\n" face_islands
		format "face_islands.count: %\n" face_islands.count


		verts_islands = for face_island in face_islands collect ( polyop.getVertsUsingFace obj face_island ) * verts

		free faces_by_verts
		free face_islands

		verts_islands--return

	),

	/** Select final selection
	 */
	function setSelection sel_bitarray subobject:#VERTEX isolate:false =
	(
		format "\n"; print "VertSelector_v.setSelection()"
		format "sel_bitarray: %\n" sel_bitarray
		format "subobject: %\n" subobject

		--/** Pass vertex selection to editable poly
		--  *
		--  * 1) Get selected verts in modifier like Edit Poly|Poly Select
		--  * 2) Find same vertex by position in Editable Poly baseobject
		--  *
		--  * #return BitArray of vertex indexes of Editable Poly Baseobject
		-- */
		--function getVertsByBaseobject obj verts =
		--(
		--	--format "\n"; print "VertexColorProcessor_v.getBaseObjectVerts()"
		--	verts_baseobject = #()
		--
		--	--verts_mesh_all	= #{1..( getNumVerts obj.mesh  )} as Array
		--	verts_base_all	= #{1..( polyop.getNumVerts obj.baseobject)} as Array
		--
		--	verts_pos_baseobjects = polyop.getVerts obj.baseobject verts_base_all --node:obj
		--
		--	--if verts.count > 0 then
		--	(
		--		verts_sel_pos  = for vert in verts collect getVert obj.mesh vert
		--
		--		for vert_pos in verts_sel_pos where (index = findItem verts_pos_baseobjects (vert_pos)) > 0 do
		--			append verts_baseobject index
		--	)
		--
		--	verts_baseobject --return
		--)

		max modify mode

		_mod = modPanel.getCurrentObject()

		setSelectionLevel _mod subobject
		--_mod.SetSelection subobject #{}

		if classOf _mod == Edit_Poly then
		(

			--format "SEL_BITARRAY: %\n" sel_bitarray
			--if obj.modifiers[#SLICE_PLANE_TOP] != undefined then
			--(
			--	sel_bitarray = getVertsByBaseobject(obj)(sel_bitarray)
			--)
			
			
			if isolate and subobject == #VERTEX then
			(
				_mod.ButtonOp #UnhideAllVertex
			
				_mod.SetSelection #VERTEX #{}
			
				_mod.Select #VERTEX sel_bitarray
			
				_mod.ButtonOp #HideUnselectedVertex	
				
			)
			else
				_mod.Select subobject sel_bitarray
			

		)
		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection subobject sel_bitarray

	),

	private

	/**  Left only single lowest vert of verts
	  *   Verts above are removed from selection
	 */
	function _filterOnlyMinZVerts verts =
	(
		/* VERTS CAN BE UNDEFINED IF CELL IS EMPTY */
		if verts.numberSet > 0 then
		(
			if ( lowest_vert = this._getLowestVertOnZaxis(verts) ) != undefined then
				this.sel_modified[lowest_vert] = true
			else
				this.sel_modified[(verts as Array )[1] ] = true
		)

	),

	--/** Select final selection
	-- */
	--function selectVerts subobject:#VERTEX =
	--(
	--	--format "\n"; print "VertSelector_v.selectVerts()"
	--	--format "verts: %\n" verts
	--
	--	max modify mode
	--
	--	setSelectionLevel obj subobject
	--
	--	_mod = modPanel.getCurrentObject()
	--
	--	_mod.SetSelection subobject #{}
	--
	--	if classOf _mod == Edit_Poly then
	--		_mod.Select subobject this.sel_modified
	--
	--	else if classOf _mod  == Editable_Poly then
	--		_mod.SetSelection subobject this.sel_modified
	--),

	/** Detach method
	 */
	function setFaceElements faces_of_verts =
	(
		--format "\n"; print ".detachMethod()"
		--format "faces_of_verts: %\n" faces_of_verts
		obj_snap = snapshot obj

		convertTo obj_snap PolyMeshObject

		polyop.detachFaces obj_snap faces_of_verts delete:true

		local poGetElementsUsingFace = polyop.getElementsUsingFace

		while not faces_of_verts.isEmpty do
        (
			face = (faces_of_verts as array)[1]

			element = poGetElementsUsingFace obj_snap #(face)

			append face_elements element

			faces_of_verts -= element
		)

		delete obj_snap

		--face_elements --return
	),

	--/**  Left only single lowest vert of verts
	--  *   Verts above are removed from selection
	-- */
	--function _filterOnlyMinZVerts verts =
	--(
	--	--format "\n"; print "VertexGridGetter_v._SelectOnlyMinZVerts()"
	--	--format "verts: %\n" verts
	--
	----	/* VERTS CAN BE UNDEFINED IF CELL IS EMPTY */
	--	if verts.numberSet > 0 and ( lowest_vert = this._getLowestVertOnZaxis(verts) ) != undefined then
	--		this.sel_modified[lowest_vert] = true
	--
	--	lowest_vert --return
	--
	--	/* REMOVE OTHER VERTS FROM SELECTION */
	--	--for vert in verts_to_remove do
	--		--this.sel_modified[vert] = false
	--),

	/** Get vert with min z pos
	  *
	  * @param BitArray verts
	 */
	function _getLowestVertOnZaxis verts =
	(
		--format "\n"; print "VertSelector_v._getLowestVertOnZaxis()"
		--format "verts: %\n" verts
		verts_arr = verts as Array

		if verts_pos == undefined then
			this.verts_pos = this._setVertsPositions(verts)


		/* GET LOWEST POINT IN CELL */
		if verts_arr.count > 1 then
		(
			z_positions = for vert in verts collect verts_pos[vert].z
			--format "Z_POSITIONS: %\n" z_positions
			--z_positions = for pos in (meshop.getVerts obj.mesh verts node:obj) collect pos.z

			if ( index = findItem z_positions (amin z_positions) ) > 0 then
				verts_arr[index] --return
		)
		else
			verts_arr[1] --return

			--verts_arr[1] --return
	),

	/** Select and return mofified selection
	 */
	function _selectVertsAndReturn make_selection =
	(
		if make_selection then
			this.setSelection this.sel_modified

		this.sel_modified  --return
	),

	/** Set verts positions
	 */
	function _setVertsPositions verts =
	(
		--format "\n"; print "VertSelector_v._setVertsPositions()"
		--format "verts_process: %\n" verts_process
		--format "verts: %\n" verts
		--format "verts.numberSet: %\n" verts.numberSet
		all_verts = #{1..(getNumVerts obj.mesh)}

		--if verts_pos == undefined then
		--	this.verts_pos = all_verts as Array
		--
		----verts_process_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj
		--
		--verts_process_pos = in coordsys world polyop.getVerts obj verts node:obj
		--
		----format "verts_process_pos: %\n" verts_process_pos
		--
		--for i = 1 to verts_process_pos.count do
		--(
		--	vert = (verts  as Array )[i]
		--	--format "vert: %\n" vert
		--
		--	verts_pos[vert] = verts_process_pos[i]
		--)
		--
		--
		--verts_pos --return

		--verts_pos = in coordsys world meshop.getVerts obj.mesh all_verts node:obj
		timer_setVertsPositions = timeStamp()
		verts_pos = in coordsys world polyop.getVerts obj all_verts node:obj
		format "setVertsPositions: % seconds\n" ((( timeStamp()) - timer_setVertsPositions) / 1000.0)

		verts_pos --return
	),

	--/** Set object
	-- */
	--function _setObject =
	--(
	--	format "\n"; print "VertSelector_v._setObject()"
	--	format "this.obj_original: %\n" this.obj_original
	--	--this.obj = this.obj_original -- DEV
	--
	--	--this.obj  = snapshot this.obj_original
	--
	--	--convertTo this.obj PolyMeshObject
	--),

	/** Merge bit arrays wich shared bits
	  *
	  * @param #( #{} ) bitarrays Array of bittarays
	 */
	function _mergeBitArraysbySharedBits bitarrays =
	(
		--format "\n"; print "VertSelector_v._mergeBitArraysbySharedBits()"

		for x = bitarrays.count to 1 by -1 do
		(
			--format "x: %\n" x
			merged = false

			bitarrays_x = bitarrays[x]
			--for y = bitarrays.count to 1 by -1 while where x != y and not ( bitarrays_x * bitarrays[y] ).isEmpty do
			--for y = bitarrays.count to 1 by -1 where x != y and not ( bitarrays_x * bitarrays[y] ).isEmpty do

			--for y = bitarrays.count to 1 by -1 where x != y and ( bitarrays_x * bitarrays[y] ).numberSet > 1 do
			for y = bitarrays.count to 1 by -1 while not merged where x != y and ( bitarrays_x * bitarrays[y] ).numberSet > 1 do
			(
				bitarrays[y] += bitarrays[x]

				merged = true

				--gc light:true
			)

			if merged then
				deleteItem bitarrays x
		)

		bitarrays --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "VertSelector_v.onCreate()"
		--print "***********************\n***********************"
		--this._setObject()

		--VertexLayers 	= VertexLayers_v( obj )
		VertexGrid 	= VertexGrid_v( obj )
		VertIslandFinder 	= VertIslandFinder_v(obj)
		VertexGridGetter 	= VertexGridGetter_v( obj )

	)
)