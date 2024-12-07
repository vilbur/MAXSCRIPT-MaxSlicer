

filein( getFilenamePath(getSourceFileName()) + "/NormalLimits/NormalLimits.ms" )	--"./NormalLimits/NormalLimits.ms"
filein( getFilenamePath(getSourceFileName()) + "/ConvexVertFinder/ConvexVertFinder.ms" )	--"./ConvexVertFinder/ConvexVertFinder.ms"

/**
 */
struct MeshDataGetter_v
(
	/* required */
	obj,

	/* construct */
	absolute,

	/* properties */
	vertex_count,
	face_count,

    verts_process 	= #{}, -- source vertex to operate, selection or all verts if nothing selected

	verts_data = Dictionary(),
	face_data  = Dictionary(),

	/* dependency */
	VertNormalLimits = NormalLimits_v(),
	FaceNormalLimits = NormalLimits_v(),

	MeshVertToColorVertexConvert,
	ConvexVertFinder,

	/* reference */
	/* inhered */

	/** Get verts_data
	  *
	  *  1) Get verts to process: SELECTED|ALL|DEFINED IN PARAM
	  *  2) Modify verts to process by desired way ( remove by normal )
	  *  3) Set verts to grid.
	  *  4) Get vertex data
	  *
	  * @return Dictionary KEYS: #VERTS|#POSITIONS|#COLORS|#FACES|#NORMALS  VALUES:vertex_ids|vertex_positions|vertex_colors|faces_ids|faces_normals
	 */
	function getVertexData verts: positions:false colors:false normals:false convexity:false =
	(
		format "\n"; print "MeshDataGetter_v.getData()"
		function pararmExists param = param != unsupplied and param == true

		/* ALL APRAMS ARE TRUE IF ARE NOT DEFINED */
		--if positions == unsupplied and colors == unsupplied and normals == unsupplied and convexity == unsupplied then
		--	positions = colors = normals = convexity = true

		/* RESET DATA */
		verts_data = Dictionary()

		/* GET VERTS INDEXES */
		verts_data[#VERTS] = this._setVertsToProcess verts:verts


		--if this.VertNormalLimits.limitsExists() then
		--	this._filterVertsByNormalLimit()

		--if this.FaceNormalLimits.limitsExists() then
			--this._filterVertsByFaceNormalLimit()

		/* GET POSITIONS */
		if pararmExists(positions) and verts_data[#POSITIONS] == undefined  then
			verts_data[#POSITIONS] = this._getVertsPositions()

		/* GET POSITIONS */
		if pararmExists(convexity) and verts_data[#CONVEXITY] == undefined  then
			verts_data[#CONVEXITY] = this._getVertsConvexity()

		/* GET COLORS */
		if pararmExists(colors) and verts_data[#COLORS] == undefined  then
			verts_data[#COLORS] = this._getVertexColors()


		/* GET NORMALS */
		if pararmExists(normals) and verts_data[#NORMALS] == undefined then -- if normals are not already set by this._filterVertsByFaceNormalLimit()
			verts_data[#NORMALS] = this._getVertsNormals()


		verts_data --return
	),

	/** Get faces data

	  * @return Dictionary KEYS: #VERTS|#POSITIONS|#COLORS|#FACES|#NORMALS  VALUES:vertex_ids|vertex_positions|vertex_colors|faces_ids|faces_normals
	 */
	function getFacesData faces: normals: =
	(
		format "\n"; print "MeshDataGetter_v.getData()"
		function pararmExists param = param != unsupplied and param

		/* ALL APRAMS ARE TRUE IF ARE NOT DEFINED */
		if  normals == unsupplied then
			normals = true

		/* RESET DATA */

		this.face_data = Dictionary()

		/* GET VERTS INDEXES */
		verts_data[#VERTS] = this._setVertsToProcess faces:faces

		--face_data[#FACES] = polyop.getFacesUsingVert obj verts_data[#VERTS]

		if this.FaceNormalLimits.limitsExists() then
			this._getFaceNormalsByLimit()

		--/* GET POSITIONS */
		--if pararmExists(positions) then
		--	verts_data[#POSITIONS] = this._getVertsPositions()
		--
		--
		--/* GET COLORS */
		--if pararmExists(colors) then
		--	verts_data[#COLORS] = this._getVertexColors()
		--

		/* GET NORMALS */
		if pararmExists(normals) and face_data[#NORMALS] == undefined then -- if normals are not already set by this._filterVertsByFaceNormalLimit()
			face_data[#NORMALS] = this._getFaceNormals()


		face_data --return
	),

	/** Get vertex normal

	  * @param #X|#Y|#Z axis
	 */
	function getVertNormal vert =
	(
		--format "\n"; print "VertDataGetter_v.getVertNormal()"
		--format "this.dataIndexVert(vert): %\n" (this.dataIndexVert(vert))
		--format "verts_data[#NORMALS]: %\n" verts_data[#NORMALS].count
		verts_data[#NORMALS][this.dataIndexVert(vert)]  --return
	),

	/** Get position

	  * @param #X|#Y|#Z axis
	 */
	function getPosition vert axis: =
	(
		--format "\n"; print "VertDataGetter_v.getPosition()"
		local pos

		if ( pos = verts_data[#POSITIONS][this.dataIndexVert(vert)] ) != undefined and axis != unsupplied then
			pos = getProperty pos axis

		--format "pos: %\n" pos
		pos --return
	),


	/** Get positions of each vert splitted to XYZ
	  * Usefull for gettin min and max values of verts by each axis separatly
	  *
	  * @return #( #(X pos), #(Y pos), #(Z pos) )
	 */
	function getPositionsSplitByAxis =
	(
		--format "\n"; print "MeshDataGetter_v.getPositionsSplitted()"
		if verts_data[#POSITIONS] == undefined then
			verts_data[#POSITIONS] = this._getVertsPositions()


		x_positions = #()
		y_positions = #()
		z_positions = #()

		for pos in verts_data[#POSITIONS] do
		(
			append x_positions pos.x
			append y_positions pos.y
			append z_positions pos.z
		)

		#( x_positions, y_positions, z_positions  ) --return
	),

	/* Get index of verts_data by vertex number in this.positions|normlas|colors|
	*
	* Bitarray way to accomplish : findItem (verts_data[#VERTS] as Array ) vertex_index
	*/
	function dataIndexVert vertex_index =
	(
		--format "\n"; print "VertDataGetter_v.dataIndexVert()"
		missing = -verts_data[#VERTS] - #{vertex_index..(vertex_count)} -- find how many indexes is false before vertex_index

		vertex_index - missing.numberSet
	),

	/**
	*/
	function dataIndexFace face_id =
	(
		--format "\n"; print "VertDataGetter_v.dataIndexVert()"
		missing = -face_data[#FACES] - #{face_id..(face_count)} -- find how many indexes is false before face_id

		face_id - missing.numberSet
	),

	/*------------------------------------------------------------------------------
		SETTERS
	--------------------------------------------------------------------------------*/

	/** Get convexity types
	 */
	function _getVertsConvexity =
	(
		format "\n"; print "MeshDataGetter_v._getVertsConvexity()"
		--format "verts_data[#VERTS]: %\n" verts_data[#VERTS]
		----ConvexVertFinder.getConvexityTypesByVert (verts_data[#VERTS]) -- VERY SLOW

		timer_getVertsConvexity = timeStamp()
		--data = ConvexVertFinder.getConvexityTypes (verts_data[#VERTS])
		data = ConvexVertFinder.getConvexityTypesByPolyTools (verts_data[#VERTS])

		format "\n timer_getVertsConvexity: % ms\n" (( timeStamp()) - timer_getVertsConvexity)
		data --return
	),

	/** Set verts positions
	 */
	function _getVertsPositions =
	(
		format "\n"; print "VertDataGetter_v._getVertsPositions()"
		in coordsys world  meshop.getVerts obj.mesh this.verts_process node:obj
	),

	/** Filter verts by normals
	 */
	function _filterVertsByFaceNormalLimit =
	(
		--format "\n"; print "MeshDataGetter_v._filterVertsByFaceNormalLimit()"
		this._getFaceNormals()

		verts_of_valid_faces = polyop.getVertsUsingFace obj face_data[#FACES]

		verts_data[#VERTS] *= verts_of_valid_faces -- left only valid verts in BitArray
	),

	/** Filter verts by normal limit
	 */
	function _filterVertsByNormalLimit =
	(
		--format "\n"; print "MeshDataGetter_v._filterVertsByNormalLimit()"
		if verts_data[#NORMALS] == undefined then
			verts_data[#NORMALS] = this._getVertsNormals()

		normal_limit = this.VertNormalLimits.get #Z
		absolute 	   = this.VertNormalLimits.absolute

		--for i = 1 to verts_data[#NORMALS].count do
		for i = verts_data[#NORMALS].count to 1 by -1 do -- loop backwards because deleteing noramls from verts_data[#NORMALS]
		(
			--vert_normal = verts_data[#NORMALS][i]
			----vert_normal = polyop.getFaceNormal obj face
			--
			--dot_prod = dot vert_normal z_axis
			--
			--normal_angle = if VertNormalLimits.absolute then acos( abs dot_prod ) else acos dot_prod

			/* COPMMARE ANGLES OF NORMAL AND LIMIT */
			--if not (normal_angle > normal_limit[1] and normal_angle < normal_limit[2]) then
			if not ( this._testAngleOfNormalLimit( verts_data[#NORMALS][i] )(normal_limit)(absolute) ) then
			(
				deleteItem verts_data[#NORMALS] i
				deleteItem verts_data[#VERTS] i
			)

		)
	),

	/** Test angle of normal limit
	 */
	function _testAngleOfNormalLimit normal normal_limit absolute  =
	(
		--format "\n"; print "MeshDataGetter_v._testAngleOfNormalLimit()"

		dot_prod = dot normal z_axis

		normal_angle = if absolute then acos( abs dot_prod ) else acos dot_prod

		normal_angle > normal_limit[1] and normal_angle < normal_limit[2]
	),

	/** Get verts normals
	 */
	function _getVertsNormals =
	(
		--format "\n"; print "MeshDataGetter_v._getVertsNormals()"

		if face_data[#NORMALS] == undefined then
			face_data[#NORMALS] = this._getFaceNormals()


		vertex_normals = for vert in verts_data[#VERTS] collect
		(
			average_normal = point3 0 0 0

			faces_of_vert = polyop.getFacesUsingVert obj vert

			for face_id in faces_of_vert do average_normal += face_data[#NORMALS][dataIndexFace(face_id)]

			--average_normal /= faces_of_vert.count

			--normalize average_normal
			normalize ( average_normal )  --return

		)

		vertex_normals --return
	),

	/** Get normals of faces which belongs to this.verts_process
	 */
	function _getFaceNormals =
	(
		format "\n"; print "MeshDataGetter_v._getFaceNormals()"

		if face_data[#FACES] == undefined then
			this._setFaces()

		timer_GET_NORMALS = timeStamp()
		face_normals = for face in face_data[#FACES] collect polyop.getFaceNormal obj face
		format "\n GET_NORMALS: % ms\n" (( timeStamp()) - timer_GET_NORMALS)

		face_normals --return
	),

	/** Get normals of faces which belongs to this.verts_process
	 */
	function _getFaceNormalsByLimit =
	(
		--format "\n"; print "MeshDataGetter_v._getFaceNormals()"
		local face_normal

		local face_normals = #()

		this._setFaces()

		normal_limit = this.FaceNormalLimits.get #Z
		absolute 	   = this.FaceNormalLimits.absolute

		for face in face_data[#FACES] do
		(
			--face_normal = polyop.getFaceNormal obj face
			--
			--dot_prod = dot face_normal z_axis
			--
			--normal_angle = if FaceNormalLimits.absolute then acos( abs dot_prod ) else acos dot_prod

			/* COPMMARE ANGLES OF NORMAL AND LIMIT */
			--if normal_angle > normal_limit[1] and normal_angle < normal_limit[2] then
			if this._testAngleOfNormalLimit( polyop.getFaceNormal obj face )(normal_limit)(absolute) then
				/* ADD NORMAL IF FIT BETWEEN LIMITS */
				append face_normals face_normal

			else /* REMOVE FACE IF NOT FIT NORMAL LIMIT */
				face_data[#FACES][face] = false
		)

		face_normals --return
	),

	/** Set faces
	 */
	function _setFaces =
	(
		--format "\n"; print "MeshDataGetter_v.setFaces()"
		--format "verts_data[#VERTS]: %\n" verts_data[#VERTS]
		face_data[#FACES] = polyop.getFacesUsingVert obj verts_data[#VERTS]
	),

	/*
	 */
	function _setVertsToProcess verts: faces: =
	(
		format "\n"; print "MeshDataGetter_v._setVertsToProcess()"
		--format "verts: %\n" verts
		this.vertex_count = getNumVerts obj.mesh
		this.face_count   = polyop.getNumFaces obj
		--format "this.vertex_count: %\n" this.vertex_count

		all_verts = #{1..(vertex_count)}
		verts_sel	= getVertSelection obj.mesh
		--format "verts_sel: %\n" verts_sel
		if faces != unsupplied then
			verts =  polyop.getVertsUsingFace obj faces


		this.verts_process = case verts of
		(
			(#ALL_OR_SELECTED): if verts_sel.numberSet > 0 then verts_sel else all_verts
			(#SELECTED):	verts_sel
			(#ALL):	all_verts
			(undefined ):	all_verts
			(unsupplied):	all_verts
			default:	if classOf verts == BitArray then verts else all_verts
		)
		format "this.verts_process: %\n" this.verts_process

		/* REMOVE HIDDEN VERTS */
		this.verts_process -= polyop.getHiddenVerts obj

		this.verts_process --return

		--format "this.verts: %\n" this.verts
		--this.verts_arr = this.verts as Array
	),

	/** Set vertex colors Ditionary
	  *
	  * SINGLE MESH VERT CAN APPEAR IN MULTIPLE COLORS - Each map vert can has its own color
	  *
	  * NOTES:
	  *		1) getvertcolor()	INPUT CPV vertex
	  *		2) getVertsByColor()	RETURN MESH VERTEX
	  *
	  *
	  * KNOWING ISSUE: remove_multi_colored_verts_from_white
	  *				If vertex has mutliple colors, then first is used, include white color.
	  *				Only way to make it work seem to iterate all map verts. THIS IS OVERKIL FOR SUCH SIPMPLE OPARTION ON HIGH VERTEX COUNT OBJECTS... MAX SUCKS !
	  *
	  * @param boolean remove_multi_colored_verts_from_white TRUE: collect first non white color | FALSE: collect all colors for vert ( mesh vert is occuring in muliple colors )
	  *
	  * @return Dictionary of BitArrays of mesh verts sorted by color E.G.: #( "color 255 255 255", #{1..999}  )  #( "color 0 255 255", #{1..3}  )
	  */
	function _getVertexColors =
	(
		format "\n"; print "MeshDataGetter_v._getVertexColors()"
		/** Loop map verts of single mesh vert
		  *
		  * Test if vertex color is new
		  *
		  * @retrun color of map vertex
		 */
		function _searchNewVertexColor colors map_verts =
		(
			--format "\n"; print "MeshDataGetter_v._searchNewVertexColor()"
			--format "map_verts: %\n" map_verts
			--format "this.colors: %\n" this.colors
			--format "COLOR: %\n" (getvertcolor obj.mesh map_verts[1])
			local color_of_vert

			i = 1
			while map_verts[i] != undefined and hasDictValue colors ( (color_of_vert = getvertcolor obj.mesh map_verts[i]) as string )  do
				i += 1

			color_of_vert --return
		)

		/** White verts exists
		 */
		function whiteVertsExists colors = hasDictValue colors ( white as string )

		local colors 	= Dictionary #string

		local white_clr = white as string

		local color_of_vert


		/* IF VERTEX COLORS EXISTS */
		if  (getNumCPVVerts obj.mesh != 0) then
		(
			MeshVertToColorVertexConvert.get_single_vert = false

			verts_get_colors = copy verts_data[#VERTS]

			while not verts_get_colors.isEmpty do
			(
				mesh_vert = ( verts_get_colors as Array )[1]

				map_verts_of_mesh_vert = makeUniqueArray (MeshVertToColorVertexConvert.meshVertsToMapVerts (mesh_vert) flat:true )

				color_of_vert = _searchNewVertexColor (colors) (map_verts_of_mesh_vert)

				mesh_verts_by_color = meshop.getVertsByColor obj.mesh color_of_vert 0.01 0.01 0.01 	-- get all verts by thath color

				colors[ color_of_vert as string ] = mesh_verts_by_color

				verts_get_colors -= mesh_verts_by_color
			)

			/* REMOVE MULTI COLORED VERTS FROM WHITE - (if one of vert colors is not white, then vert is not white) */
			if whiteVertsExists(colors) then
				for clr in colors.keys  where clr != white_clr do
					colors[white_clr] -= colors[clr]
		)

		colors --return
	),

	/**
	 */
	on create do
	(
		format "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"; print "MESHDATAGETTER.onCreate()"

		ConvexVertFinder	= ConvexVertFinder_v(obj)
		MeshVertToColorVertexConvert	= MeshVertToColorVertexConvertor_v(obj)


		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
