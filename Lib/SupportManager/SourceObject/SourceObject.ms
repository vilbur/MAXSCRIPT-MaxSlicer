filein( getFilenamePath(getSourceFileName()) + "/SupportObject/SupportObject.ms" )	--"./SupportObject/SupportObject.ms"

/** Source object
 */
struct SourceObject_v
(
	/* construct */
	obj,
	sync_key,

	/* required */
	/* properties */

	all_verts,

	Supports = Dictionary #INTEGER, -- KEY:vertex_index VALUE:SupportObject|RaftObject

	/* private */
	verts_process,

	verts_pos,

	normals_local, -- store vertex normals in object space
	normals_world,

	obj_rotation, -- store object rotation to find if world normals needs to be recount

	direction_down = [0,0,-1],
	/* dependency */

	VertexColors, --"./../../VertexColors/VertexColors.ms"


	/* reference */
	/* inhered */

	/** Generate supports
	 */
	function generateSupports obj_type:#SUPPORT =
	(
		format "\n"; print "SourceObject_v.generateSupports()"
		format "obj: %\n" obj
		--format "OBJ_TYPE: %\n" obj_type

		new_nodes = #()

		--obj_type =  if isRaft() then #RAFT else #SUPPORT

		this._removeDeletedNodes()

		--this._setVertsToProcess()

		verts_sel	= getVertSelection obj.mesh
		format "verts_sel: %\n" verts_sel

		supports_exists = Supports.keys as BitArray
		--format "SUPPORTS_EXISTS: %\n" supports_exists

		verts_by_colors = this._getVertsByColors()
		--format "VERTS_BY_COLORS: %\n" verts_by_colors

		colored_verts = this._getColoredVerts(verts_by_colors)

		verts_process =  if verts_sel.numberSet > 0 then verts_sel else colored_verts
		--verts_process -= supports_exists -- remove verts which supports exists aleready

		--if normals_local == undefined then
		this._setLocalVertexNormals(verts_process)

		this._setWorldSpaceVertexNormals(verts_process)
		format "VERTS_PROCESS A: %\n" verts_process
		/* FILTER ONLY VERTS WHICH NORMAL IS POINTING DOWN OR TO SIDE */
		verts_process = ( for vert in verts_process where this._isNormalValid(vert) collect vert ) as BitArray
		format "VERTS_PROCESS B: %\n" verts_process

		verts_pos = this._getVertsPositions(verts_process)

		/* FILTER ONLY VERTS TO PROCESS FROM COLORED ARRAYS */
		verts_by_colors_process = Dictionary #STRING

		for vertex_color in verts_by_colors.keys do
			verts_by_colors_process[vertex_color] = verts_by_colors[vertex_color] * verts_process


		/* CREATE SUPPORTS FOR EACH COLOR */
		for vertex_color in verts_by_colors_process.keys do
			for vert in verts_by_colors_process[vertex_color] where not supports_exists[vert]  do

			--if not supports_exists[vert] then
			(
				format "CREATE SUPPORT FOR VERT: % vertex_color: %\n" vert vertex_color
				SupportObject = SupportObject_v source_obj:obj obj_type:obj_type sync_key:sync_key

				/*------------------------------------------------------------------------------
					GENERATE SUPPORT OR RAFT
				--------------------------------------------------------------------------------*/
				second_point_direction = if SUPPORT_OPTIONS.second_point_direction == 1 then normals_world[vert] else direction_down -- direction down

				SupportObject.generateSupport vert first_knot_pos:verts_pos[vert] clr:(execute vertex_color) direction:second_point_direction --"./SupportObject/SupportObject.ms"

				--format "SUPPORTOBJECT.SUPPORT_OBJ: %\n" SupportObject.support_obj
				if SupportObject.support_obj != undefined then
				(

					setUserPropVal SupportObject.support_obj ( toUpper (obj_type as string ) + "_KEY")	SupportObject.support_key asString:true

					setUserPropVal SupportObject.support_obj "SYNC_KEY"	sync_key
					setUserPropVal SupportObject.support_obj "INDEX"	vert

					SupportObject.support_obj.parent = obj

					/* ADD TO ARRAYS */
					this.Supports[vert] = SupportObject

					SUPPORT_MANAGER.SupportObjects[SupportObject.support_key] = SupportObject

					append new_nodes SupportObject.support_obj

				)
			)

		bindSupportToTransformEvent( this.getSupportNodes() )

		bindSourceObjectTransformEvent ( obj )
		format "new_nodes.count: %\n" new_nodes.count
		new_nodes --return
	),

	/** Convert support to raft or vice versa
	  *
	  * @param #SUPPORT|#RAFT obj_type of obejct to covert
	  *
	 */
	function convert support_nodes obj_type:#RAFT  =
	(
		--format "\n"; print "SourceObject_v.convert()"

		from_type =  if obj_type == #RAFT then #SUPPORT else #RAFT

		for support_node in support_nodes do
			(this._getSupportByNode (support_node)).convert(obj_type)


		--MODIFIERS_MANAGER.switchSupportType( SourceObjects[sync_key].getSupportNodes obj_type:obj_type ) obj_type:obj_type

		--for sync_key in supports_by_source.keys do
		--	for support_node in supports_by_source[sync_key] do
		--		SourceObjects[sync_key].convertToRaft(support_node)


		--resumeSupportToTransformEvent()
	),

	/** Update all supports of source objects
	 */
	function updateSupports =
	(
		--format "\n"; print "SourceObject_v.updateSupports()"
		--format "support_nodes: %\n" support_nodes
		verts_pos = this._getVertsPositions( Supports.keys as BitArray )

		for index in Supports.keys where not Supports[index].isRaft() do
			Supports[index].updateSupport first_knot_pos:( verts_pos[index])
	),

	/** Update supports height
	 */
	function updateSupportsHeight =
	(
		--format "\n"; print "SourceObject_v.updateSupportsHeight()"
		--for SupportObjectData in Supports where SupportObjectData.value.is_on_ground do
		--for SupportObjectData in Supports do
			--SupportObjectData.value.updateHeight()

		--for key in Supports.keys where not Supports[key].isRaft() do
		for key in Supports.keys where not Supports[key].isRaft() do
			Supports[key].updateHeight()

	),


	/** Update support
	 */
	function updateSupport support_node =
	(
		--format "\n"; print "SourceObject_v.updateSupport()"
		--format "support_node.name: %\n" support_node.name
		index = getUserPropVal support_node "INDEX"

		if verts_pos == undefined then
			verts_pos = this._getVertsPositions(#{index})

		Supports[index].updateSupport first_knot_pos:verts_pos[index]
	),

	/** Rebuild support
	 */
	function rebuildSupport support_node =
	(
		--format "\n"; print "SourceObject_v.updateSupport()"
		--format "normals_local: %\n" normals_local
		--format "support_node.name: %\n" support_node.name
		index = getUserPropVal support_node "INDEX"

		clr = VertexColors._getVertColor(index)
		--format "clr: %\n" clr
		verts_process = #{index}

		--if normals_local == undefined then
			this._setLocalVertexNormals(verts_process)

		--if normals_world == undefined then
			this._setWorldSpaceVertexNormals(verts_process)

		--if verts_pos == undefined then
			verts_pos = this._getVertsPositions(#{index})

		direction = if SUPPORT_OPTIONS.second_point_direction == 1 then normals_world[index] else direction_down -- direction down

		Supports[index].generateSupport index first_knot_pos:verts_pos[index] direction:direction clr:clr
	),

	/** Get support by node
	 */
	function _getSupportByNode support_node =
	(
		--format "\n"; print "SourceObject_v._getSupportByNode()"
		index = getUserPropVal support_node "INDEX"


		Supports[index] --return
	),

	/** Get support nodes of given type
	  *
	  * @param #SUPPORT|#RAFT Get only supports or rafts. Get both if unsupplied
	  *
	  * @return array of nodes
	 */
	function getSupportNodes obj_type: =
	(
		--format "\n"; print "SourceObject_v.getSupportNodes()"
		if obj_type != unsupplied then
			for SupportObjectData in Supports where SupportObjectData.value.obj_type == obj_type collect SupportObjectData.value.support_obj --return

		else
			for SupportObjectData in Supports collect SupportObjectData.value.support_obj --return
	),

	/** Set verts pos by supports
	 */
	function setVertsPosBySupports =
	(
		--format "\n"; print "SourceObject_v.setVertsPosBySupports()"

		verts_pos = this._getVertsPositions( Supports.keys as BitArray )

	),

	/** Init objects from scene
	 */
	function _setLocalVertexNormals verts =
	(
		--format "\n"; print "SourceObject_v._setLocalVertexNormals()"

		--normals_local = this._getLocalVertexNormalsByModifier(Supports.keys as BitArray )


		if ( normals_local_loaded = getUserPropVal obj "normals_local" ) != undefined then
		(
			--format "normals_local_loaded: %\n" normals_local_loaded
			normals_local = normals_local_loaded

			normals_exists = for i = 1 to normals_local.count where normals_local[i] != point3 0 0 0 collect i

			verts -= normals_exists as BitArray
		)

		timer_NORMLAS = timeStamp()

		--format "VERTS: %\n" verts

		if not verts.isEmpty then
			this._updateLocalVertexNormalsByModifier( verts )

		setUserPropVal obj "normals_local"	normals_local

		--this._updateLocalNormals( verts )
		--format "NORMALS: % seconds\n" ((( timeStamp()) - timer_NORMLAS) / 1000.0)

	),

	/** Delete support
	  UNUSED
	 */
	function _deleteSupport key =
	(
		--format "\n"; print "SourceObject_v._deleteSupport()"

		delete Supports[key].support_obj

		removeDictValue Supports key

		/* TODO: DELETE BEAMS ? */
	),

	private



	/** Get local vertex normals by modifier
	 */
	function _updateLocalVertexNormalsByModifier verts =
	(
		--format "\n"; print "SourceObject_v._updateLocalVertexNormalsByModifier()"

		eMod = Edit_Normals()

		addModifier obj eMod
		--modPanel.addModToSelection (eMod) ui:on

		--vCount = eMod.GetNumVertices node:obj
		--format "vCount: %\n" vCount
		--normalIds = #{}
		--eMod.ConvertVertexSelection #{1..vCount} normalIds node:obj
		--
		--for normal in normalIds do
		--format "%: %\n" normal (eMod.GetNormal normal node:obj)

		for vert in verts do
		(
			--vPos = eMod.GetVertex v node:obj
			--format "Vertex:% Position:%\n" v vPos
			normal_ids = #{}

			if normals_local[vert] == undefined then
				normals_local[vert] = point3 0 0 0


			eMod.ConvertVertexSelection #{vert} normal_ids node:obj

			for normal in normal_ids do
				normals_local[vert] += eMod.GetNormal normal node:obj

			normalize normals_local[vert]
		)


		deleteModifier selection eMod

		--vertex_normals --return
	),



	/** Get verts normals
	 */

	function _updateLocalNormals verts =
	(

		format "\n"; print "SourceObject_v._updateLocalNormals()"
		format "verts.numberSet: %\n" verts.numberSet
		--timer_get_normals = timeStamp()
		obj_mesh = obj.mesh

		faces_of_verts = meshop.getFacesUsingVert obj_mesh verts


		format "faces_of_verts.numberSet: %\n" faces_of_verts.numberSet
		--faces_of_verts = polyop.getFacesUsingVert obj verts
		--format "faces_of_verts.numberSet: %\n" faces_of_verts.numberSet

		for vert in faces_of_verts do
		(
			format "vert: %\n" vert
			face_verts = getFace	obj_mesh vert
			face_normal = getFaceNormal	obj_mesh vert
			--
			--for vert in face_verts * verts do
			--	vertex_normals[vert] += face_normal

			normals_local[face_verts.x] += face_normal
			normals_local[face_verts.y] += face_normal
			normals_local[face_verts.z] += face_normal
		)

		for vert in verts do normals_local[vert] = normalize normals_local[vert]

		format "_updateLocalNormals: % seconds\n" ((( timeStamp()) - timer_get_normals) / 1000.0)

	),

	/** Set world space vertex normals
	 */
	function _setWorldSpaceVertexNormals verts =
	(
		--format "\n"; print "SourceObject_v._setWorldSpaceVertexNormals()"
		--format "verts: %\n" verts
		--format "verts.numberSet: %\n" verts.numberSet
		obj_pos	= obj.pos
		obj_transform	= obj.transform

		if normals_world == undefined then
			normals_world = deepCopy normals_local

		for vert in verts do normals_world[vert] = normalize (normals_local[vert] * obj_transform - obj_pos)
	),

	/** Set verts positions
	 */
	function _getVertsPositions verts =
	(
		--format "\n"; print "SourceObject_v._getVertsPositions()"
		--format "obj: %\n" obj
		--format "verts_process: %\n" verts_process
		--format "verts: %\n" verts
		--format "all_verts: %\n" all_verts
		--format "all_verts.numberSet: %\n" all_verts.numberSet
		--format "verts.numberSet: %\n" verts.numberSet
		timer__getVertsPositions = timeStamp()

		if verts_pos == undefined then
			this.verts_pos = all_verts as Array

		verts_process_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj
		--format "verts_process_pos: %\n" verts_process_pos

		for i = 1 to verts_process_pos.count do
		(
			vert = (verts  as Array )[i]
			--format "vert: %\n" vert

			verts_pos[vert] = verts_process_pos[i]
		)

		--format "_getVertsPositions: % ms\n" (( timeStamp()) - timer__getVertsPositions)

		verts_pos --return

		--verts_pos = in coordsys world meshop.getVerts obj.mesh all_verts node:obj

		--verts_pos --return
	),

	--/** Get vertex pos by support
	-- */
	--function _getVertexPosBySupport support_obj =
	--(
	--	--format "\n"; print "SourceObject_v._getVertexPosBySupport()"
	--	index = getUserPropVal support_obj "INDEX"
	--
	--	verts_pos[index] --return
	--),

	/** Get verts by colors
	 */
	function _getVertsByColors =
	(
		--format "\n"; print "SourceObject_v._getVertsByColors()"
		verts_by_colors = VertexColors.getVertsAndColors()

		/* REPLACE WHITE WITH OBJECT WIRECOLOR */
		verts_by_colors[ obj.wirecolor as string ] = verts_by_colors[ white as string ]

		RemoveDictValue verts_by_colors ( white as string )

		verts_by_colors --return
	),

	/** Flattern dictionary
	 */
	function _getColoredVerts verts_by_colors =
	(
		--format "\n"; print "SourceObject_v._getColoredVerts()"
		flattern_dict = #{}

		for key in verts_by_colors.keys where key != obj.wirecolor as string do flattern_dict += verts_by_colors[key]

		flattern_dict --return
	),

	/** Remove deleted nodes
	 */
	function _removeDeletedNodes =
	(
		--format "\n"; print "SourceObject_v._removeDeletedNodes()"
		for key in Supports.keys where not isValidNode Supports[key].support_obj do removeDictValue Supports key
	),

	/** Set vertex normals empty array
	 */
	function _initNormalsLocalArray =
	(
		--format "\n"; print "SourceObject_v._initNormalsLocalArray()"
		--if normals_local == undefined or normals_local.count != all_verts.numberSet then
		--(
		--)
		normals_local = this.all_verts as Array

		for i = 1 to normals_local.count do
			normals_local[i] = point3 0 0 0
	),

	--/** Get existing support and rafts from scene
	-- */
	--function _loadSupportsAndRaftsFromScene =
	--(
	--	format "\n"; print "SupportManager_v._loadSupportsAndRaftsFromScene()"
	--	for obj_in_scene in objects	where superClassOf obj_in_scene.baseobject == shape \
	--				  and  getUserPropVal obj_in_scene "SYNC_KEY" == sync_key \
	--				  and  (isRaft() = getUserPropVal obj_in_scene "RAFT") != undefined do -- BEAMS DOES NOT HAS isRaft() raft property
	--	(
	--		vert = getUserPropVal obj_in_scene "INDEX"
	--
	--		this.Supports[vert] = SupportObject_v source_obj:obj support_obj:obj_in_scene isRaft():isRaft()
	--	)
	--),

	/** test if obj rotation changed in X and Y axises
	 */
	function _isObjRotationChanged =
	(
		--format "\n"; print "SourceObject_v._isObjRotationChanged()"

		current_rotation = this._getRoundedObjectRotation ( quatToEuler2 obj.rotation.controller.value )

		rotation_changed = current_rotation != obj_rotation

		obj_rotation = current_rotation

		rotation_changed --return
	),

	/** Get rounded object rotation
	 *
	 * Coordinates are changing little bit on unchaged axises beacause of "high precision" of Max values
	 */
	function _getRoundedObjectRotation rot =
	(
		--format "\n"; print "SourceObject_v._getRoundedObjectRotation()"
		/* Round number to 3 deciamls
		*/
		--fn roundFloat val = ( local mult = 10.0 ^ 3; (floor ((val * mult) + 0.5)) / mult )
		fn roundFloat val = ( local mult = 1000.0; (floor ((val * mult) + 0.5)) / mult )

		rounded_rotation = Point2 0 0

		rounded_rotation.x = roundFloat rot.x
		rounded_rotation.y = roundFloat rot.y

		rounded_rotation --return
	),

	/** Is vertex normal pointing DOWN or SIDE but not UP
	 */
	function _isNormalValid vert =
	(
		--format "\n"; print "SourceObject_v._isNormalValid()"
		normals_world[vert].z < 0 --return
		--normals_world[vert].z < 1 --return

	),

	/** Save object rounded rotation in X and Y axis
	 */
	function _saveObjectRotation =
	(
		--format "\n"; print "SourceObject_v._saveObjectRotation()"
		obj_rotation = this._getRoundedObjectRotation ( quatToEuler2 obj.rotation.controller.value )
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObject.onCreate()"
		--format "obj: %\n" obj
		VertexColors = VertexColors_v(obj)

		all_verts = #{1..(getNumVerts obj.mesh)}

		this._saveObjectRotation()

		this._initNormalsLocalArray()
	)
)
