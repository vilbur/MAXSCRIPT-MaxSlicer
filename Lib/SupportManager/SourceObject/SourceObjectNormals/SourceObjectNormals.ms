/** Source object normals
 */
struct SourceObjectNormals_v
(
	/* construct */
	obj,
	--sync_key,

	/* required */
	/* properties */

	all_verts,

	--Supports = Dictionary #INTEGER, -- KEY:vertex_index VALUE:SupportObject|RaftObject

	/* private */
	--verts_process,

	--verts_pos,

	normals_local, -- Array fot store vertex normals in object space
	normals_world, -- Array fot store vertex normals in world space

	--obj_rotation, -- store object rotation to find if world normals needs to be recount
	--
	--direction_down = [0,0,-1],
	/* dependency */


	/* reference */
	/* inhered */

	
	/*
	 */
	function setLocalVertexNormals verts =
	(
		format "\n"; print "SourceObjectNormals_v.setLocalVertexNormals()"
		this._initNormalsLocalArray()

		if not this.loadNormalsLocal() then
			this._updateLocalVertexNormalsByModifier( verts )
	),

	/** Set world space vertex normals
	 */
	function setWorldSpaceVertexNormals verts =
	(
		format "\n"; print "SourceObjectNormals_v.setWorldSpaceVertexNormals()"
		format "verts.numberset : %\n" verts.numberset 
		
		obj_pos	= obj.pos
		obj_transform	= obj.transform

		--timer_TEST = timeStamp()
		--if normals_world == undefined then
			--normals_world = deepCopy normals_local
			--normals_world = deepCopy normals_local
		--format "TEST: % ms\n" (( timeStamp()) - timer_TEST)

		--for vert in verts do format "VERT: % LOCAL: % WORLD: %\n" vert normals_local[vert] normals_world[vert]
			
		for vert in verts where normals_world[vert] != undefined do normals_world[vert] = normalize (normals_local[vert] * obj_transform - obj_pos)
	),
	
	/** Load normals local
	 */
	function loadNormalsLocal =
	(
		--format "\n"; print "SourceObjectNormals_v.loadNormalsLocal()"
		if ( normals_local_loaded = getUserPropVal obj "normals_local" ) != undefined then
			this.normals_local = normals_local_loaded

		normals_local_loaded != undefined
	),
	
	/** Is vertex normal pointing DOWN or SIDE but not UP
	 */
	function isNormalValid vert =
	(
		--format "\n"; format "SourceObjectNormals_v.isNormalValid: % %\n" normals_world[vert] (normals_world[vert].z < 0)
		
		if not (is_normal_valid = normals_world[vert].z <= 0 ) then
			format "--------- WARNING: NOT CREATED SUPPORT OF VERT: % NORMAL IS NOT POINTING DOWN:% \n" vert normals_world[vert]
		
		is_normal_valid --return
	),
	
	/** Save normals to user props
	 */
	function saveNormalsToUserProps =
	(
		--format "\n"; print "SourceObjectNorwmals_v.saveNormalsRoUserProps()"
		setUserPropVal obj "normals_local"	normals_local
	),
	
	private
	
	/** Get local vertex normals by modifier
	 */
	function _updateLocalVertexNormalsByModifier verts =
	(
		--format "\n"; print "SourceObjectNormals_v._updateLocalVertexNormalsByModifier()"

		eMod = Edit_Normals()

		addModifier obj eMod

		for vert in verts do
		(
			local_normal = point3 0 0 0

			normal_ids = #{}
			
			eMod.ConvertVertexSelection #{vert} normal_ids node:obj

			for normal in normal_ids do
				local_normal += eMod.GetNormal normal node:obj

			normals_local[vert] = normalize local_normal
		)

		deleteModifier selection eMod

		--vertex_normals --return
	),

	/** Get verts normals
	 */
	function _updateLocalNormals verts =
	(
		--format "\n"; print "SourceObjectNormals_v._updateLocalNormals()"

		obj_mesh = obj.mesh

		faces_of_verts = meshop.getFacesUsingVert obj_mesh verts

		for vert in faces_of_verts do
		(
			--format "vert: %\n" vert
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

		format "SourceObjectNormals._updateLocalNormals: % seconds\n" ((( timeStamp()) - timer_get_normals) / 1000.0)
	),
	
	/** Set vertex normals empty array
	 */
	function _initNormalsLocalArray =
	(
		--format "\n"; print "SourceObjectNormals_v._initNormalsLocalArray()"
		--if normals_local == undefined or normals_local.count != all_verts.numberSet then
		--(
		--)
		normals_local = this.all_verts as Array
		normals_world = this.all_verts as Array

		for i = 1 to normals_local.count do
		(
			normals_local[i] = point3 0 0 0
			
			normals_world[i] = point3 0 0 0
		)
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObjectNormals.onCreate()"
		all_verts = #{1..(getNumVerts obj.mesh)}

	)
)
