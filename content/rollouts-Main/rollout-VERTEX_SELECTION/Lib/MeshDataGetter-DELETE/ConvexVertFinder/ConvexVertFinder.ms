
--if VERTS_CAVITY_CACHE == undefined then
	--global VERTS_CAVITY_CACHE = #() -- VERTS_CAVITY_CACHE[current_frame][object pointer][#VERTS|#POSITIONS|CONVEX|CONCAVE|MIXED|CORNER]

/** Convex vert finder
 */
struct ConvexVertFinder_v
(
	/* construct */
	obj,

	/* required */
	faces_data = Dictionary(),

	/* properties */
	verts_types = #( #CONVEX, #CONCAVE, #MIXED, #CORNER ),

	verts_by_type  = Dictionary(), --  #( #CONVEX, #{} ) #( #CONCAVE, #{} ) #( #MIXED, #{} )  #( #CORNER, #{} )     -- store verts by angle


	/* PROPERTIES USED FOR METHOD: getConvexityTypes */
	_angles_by_vert = Dictionary(), --  #( #CONVEX, #() ) #( #CONCAVE, #() ) #( #MIXED, #() )  #( #CORNER, boolean ) -- store angles of single vert

	faces_angles = Dictionary #integer, -- #( face_A * face_B,  #( angles ) ) -- store angle between 2 faces

	verts_convexity = #(), -- store convex state of vert: #CONVEX|#CONCAVE|#MIXED|#CORNER -- keys are verts in parameter of "this.getVerts (verts)"


	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Get convexity types by poly tools
	 */
	function getConvexityTypesByPolyTools verts =
	(
		format "\n"; print "ConvexVertFinder_v.getConvexityTypesByPolyTools()"
		--format "verts: %\n" verts

		--if ( verts_by_type_chache = this._getDataFromCache() ) == undefined then
		(
			--format "\n"; print " !!!! SET NEW CACHE"

			max modify mode

			with redraw off
			(
				--polyop.unHideAllVerts obj

				PolyToolsSelect.ConvexConcave 0.1 2 -- select convex and convex-concave
				convex = getVertSelection obj.mesh

				PolyToolsSelect.ConvexConcave 0.1 1 -- select concave and convex-concave
				concave = getVertSelection obj.mesh

				PolyToolsSelect.NumericVertex 2 1 false -- vertices with 2 edges
				corner = getVertSelection obj.mesh

				this._selectVerts (verts)
			)

			flat = convex * concave


			verts_by_type[#CONVEX]	= convex	- flat
			verts_by_type[#CONCAVE]	= concave	- flat
			verts_by_type[#MIXED]	= flat	- corner
			verts_by_type[#CORNER]	= corner

			--this._setDataToCache()
			--format "verts_by_type: %\n" verts_by_type
			verts_by_type --return
		)
		--else
			--verts_by_type_chache --return
	),

	/** Get verts OBSOLETE - VERY SLOW

	 * @param BitArray verts to ge their convex or concave state
	 *
	 * @return Arrray
	 *
	 */
	function getConvexityTypes verts faces_data: =
	(
		format "\n"; print "ConvexVertFinder_obj.getConvexityTypes()"
		this.verts_convexity = #() -- reset for mutliple rounds of same isntance

		faces_of_verts  = polyop.getFacesUsingVert obj verts

		tested_edges	= #{}
		tested_faces	= #{}
		--for i = 1 to faces_of_verts.count do
		timer_CONVEXITY = timeStamp()

		--for i = faces_of_verts.count to 1 by -1 do
		for face_A in faces_of_verts do
		(
			--face_A = faces_of_verts[i]
			normal_A = polyop.getFaceNormal obj face_A

			for edge_of_face in (edges_of_face = polyop.getEdgesUsingFace obj face_A) where not tested_edges[edge_of_face] do
			--for edge_of_face in (edges_of_face = polyop.getEdgesUsingFace obj face_A) do
			(
				verts_of_edge  = polyop.getVertsUsingEdge obj edge_of_face

				--for face_B in (faces_of_edge = polyop.getFacesUsingEdge obj edge_of_face) where face_A != face_B and not tested_faces[face_B] do
				for face_B in (faces_of_edge = polyop.getFacesUsingEdge obj edge_of_face) where face_A != face_B  do
				(
					normal_B = polyop.getFaceNormal obj face_B

					_angle =  this._getFacesAngle (face_A) (face_B) (normal_A) ( normal_B )  ( this._getFaceCenter face_A )

					/* TEST CONVEX\CONCAVE */
					angle_type = case of
					(
						(_angle < 180):	#CONVEX
						(_angle > 180):	#CONCAVE
						default:	#MIXED
					)

					this.verts_by_type[angle_type] += verts_of_edge

					tested_edges[edge_of_face] = true
					--tested_faces[face_B] = true

				)
			)
		)

		format "\n CONVEXITY: % ms\n" (( timeStamp()) - timer_CONVEXITY)

		this.verts_by_type --return
	),

	private

	--/** Get face data
	-- */
	--function _setFaceData verts _faces_data =
	--(
	--	--format "\n"; print "ConvexVertFinder_v._setFaceData()"
	--	--format "verts: %\n" verts
	--	--format "_faces_data: %\n" _faces_data
	--	if _faces_data == unsupplied then
	--	(
	--		this.faces_data[#FACES] = polyop.getFacesUsingVert obj verts
	--
	--		this.faces_data[#NORMALS] = for face in this.faces_data[#FACES] collect polyop.getFaceNormal obj face
	--	)
	--	else
	--		this.faces_data = _faces_data
	--
	--),

	/** Find angle between faces
	 */
	function _getFacesAngle face_A face_B normal_A normal_B face_center_A =
	(
		--format "\n"; print "ConvexVertFinder_obj._getFacesAngle()"
		vector_faces_centres = normalize ( face_center_A - (this._getFaceCenter face_B) )



		dot_faces  = dot normal_A normal_B
		dot_center = dot vector_faces_centres normal_A

		angle_raw    = acos(dot_faces)
		angle_center = acos(dot_center)

		--format "\n"
		--format "dot_faces: %\n" dot_faces
		--format "dot_center: %\n" dot_center
		--format "angle_center: %\n" angle_center
		--format "\nangle_raw: %\n" angle_raw
		--format "\n"

		/* CONCAVE: ( dot_center > 0 )  CONVEX: ( dot_center < 0 ) */
		angle_final = case of
		(
			(dot_center > 0 and (dot_faces < 0 or  dot_faces == 1)):  abs(180 - angle_raw)

			(dot_center < 0  ):	 abs(180 + angle_raw) ---- if dot_faces >= 0 then --??? dont know if its needed actualy

			default: angle_raw
		)

		--format "ANGLE % % : %\n" face_A face_B angle_final

		/* MAK PAIR OF FACES AS TESTED  */
		--faces_angles[face_A * face_B] = angle_final

		angle_final --return
	),

	/** Save vert by type
	 */
	function _saveVertByType vert angles_by_vert =
	(
		--format "\n"; print "ConvexVertFinder_obj._saveVertByType()"
		--format "vert: %\n" vert
		--format "angles_by_vert: %\n" angles_by_vert

		convex_angles  = angles_by_vert[#CONVEX].numberSet
		concave_angles = angles_by_vert[#CONCAVE].numberSet

		vert_type = case of
		(
			(angles_by_vert[#CORNER][1] ):	#CORNER
			(convex_angles > concave_angles):	#CONVEX
			(convex_angles < concave_angles):	#CONCAVE
			default:	#MIXED
		)

		--format "vert_type: %\n" vert_type
		verts_by_type[vert_type][vert] = true

		--append verts_convexity vert_type
	),

	/* Get index of verts_data by vertex number in this.positions|normlas|colors|
	*
	* Bitarray way to accomplish : findItem (this.verts_arr) face_id
	*/
	function dataIndexFaceNormal face_id =
	(
		----format "\n"; print "VertDataGetter_v.dataIndexVert()"
		--missing = -faces_data[#FACES] - #{face_id..(faces_data[#FACES].numberSet)} -- find how many indexes is false before vertex_index
		--
		--face_id - missing.numberSet

		 findItem this.faces_data[#FACES] face_id
	),

	/** Select final selection
	 */
	function _selectVerts verts =
	(
		format "\n"; print "ConvexVertFinder_v.selectVerts()"
		--if this.sel_modified.isEmpty then
			--this.sel_modified = deepCopy data_verts[#VERTS]

		--if not verts.isEmpty then
		(
			max modify mode

			subObjectLevel = 1

			_mod = modPanel.getCurrentObject()

			_mod.SetSelection #Vertex #{}

			if classOf _mod == Edit_Poly then
				_mod.Select #Vertex verts

			else if classOf _mod  == Editable_Poly then
				_mod.SetSelection #Vertex verts
		)
	),

	/** Get face center
	 */
	function _getFaceCenter face_id =
	(
		--format "\n"; print "VertSelector_v._getFaceCenter()"
		if ( face_center = polyop.getSafeFaceCenter obj face_id ) == undefined then
			face_center = polyop.getFaceCenter obj face_id

		face_center --return
	),

	--/** Get data from cache
	-- */
	--function _getDataFromCache =
	--(
	--	--format "\n"; print "ConvexVertFinder_v._getDataFromCache()"
	--	--verts_by_type_cahced = undefined
	--	curernt_frame = ( sliderTime as integer ) +1
	--	obj_pointer	= (getHandleByAnim obj) as string
	--
	--	if ( cache_of_frame = VERTS_CAVITY_CACHE[curernt_frame] ) != undefined and ( verts_by_type_cahced = cache_of_frame[obj_pointer] ) != undefined then
	--		verts_by_type_cahced --return
	--),
	--
	--/** Set data to cache
	-- */
	--function _setDataToCache =
	--(
	--	--format "\n"; print "ConvexVertFinder_v._setDataToCache()"
	--	curernt_frame = ( sliderTime as integer ) +1
	--	obj_pointer	= (getHandleByAnim obj) as string
	--	vertex_count = getNumVerts obj.mesh
	--	all_verts = #{1..(vertex_count)}
	--
	--
	--	data_to_cache = copy verts_by_type
	--
	--	data_to_cache[#VERTS]	= all_verts
	--	data_to_cache[#POSITIONS]	= meshop.getVerts obj.mesh all_verts node:obj
	--
	--
	--
	--	if ( cache_of_frame = VERTS_CAVITY_CACHE[curernt_frame] ) == undefined then
	--			VERTS_CAVITY_CACHE[curernt_frame] = Dictionary #STRING
	--
	--
	--	VERTS_CAVITY_CACHE[curernt_frame][obj_pointer] = data_to_cache
	--
	--),

	/**
	 */
	on create do
	(
		--format "\n"; print "ConvexVertFinder.onCreate()"

		/* PREFILL DICTIONARIES WITH KEYS AND EMPTY VALUES */
		for vert_type in verts_types do verts_by_type[vert_type]   = #{}


		--for vert_type in verts_types do this._angles_by_vert[vert_type] = #{}

		--for vert_type in verts_types where vert_type != #CORNER do this._angles_by_vert[vert_type] = #()

	)
)
