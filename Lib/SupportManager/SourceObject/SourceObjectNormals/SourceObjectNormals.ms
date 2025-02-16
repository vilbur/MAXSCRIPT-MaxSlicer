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
		format "VERTS A: %\n" verts
		--normals_local = this._getLocalVertexNormalsByModifier(Supports.keys as BitArray )


		if ( normals_local_loaded = getUserPropVal obj "normals_local" asString:true ) != undefined then
		(
			format "NORMALS_LOCAL_LOADED: %\n" normals_local_loaded
			--format "classOf normals_local_loaded: %\n" (classOf normals_local_loaded)
			format "classOf normals_local_loaded: %\n" (classOf (execute normals_local_loaded))
			normals_local = execute normals_local_loaded
			
			--format "classOf normals_local: %\n" (classOf normals_local)
			--normals_exists = for i = 1 to normals_local.count where normals_local[i] != point3 0 0 0 collect i
			--
			--verts -= normals_exists as BitArray
		)

		format "VERTS B: %\n" verts
		
		timer_NORMLAS = timeStamp()

		--format "VERTS: %\n" verts

		if not verts.isEmpty then
			this._updateLocalVertexNormalsByModifier( verts )
		
		setUserPropVal obj "normals_local"	normals_local

		--this._updateLocalNormals( verts )
		--format "NORMALS: % seconds\n" ((( timeStamp()) - timer_NORMLAS) / 1000.0)

	),

	/** Get local vertex normals by modifier
	 */
	function _updateLocalVertexNormalsByModifier verts =
	(
		format "\n"; print "SourceObjectNormals_v._updateLocalVertexNormalsByModifier()"
		format "VERTS: %\n" verts

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
		format "verts: %\n" verts
		format "all_verts: %\n" all_verts
		format "all_verts.count: %\n" all_verts.count
		format "normals_local.count: %\n" normals_local.count

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

		format "\n"; print "SourceObjectNormals_v._updateLocalNormals()"
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
	function setWorldSpaceVertexNormals verts =
	(
		--format "\n"; print "SourceObject_v.setWorldSpaceVertexNormals()"
		--format "verts: %\n" verts
		--format "verts.numberSet: %\n" verts.numberSet
		obj_pos	= obj.pos
		obj_transform	= obj.transform

		if normals_world == undefined then
			normals_world = deepCopy normals_local

		for vert in verts do normals_world[vert] = normalize (normals_local[vert] * obj_transform - obj_pos)
	),

	private

	
	/** Set vertex normals empty array
	 */
	function _initNormalsLocalArray =
	(
		--format "\n"; print "SourceObjectNormals_v._initNormalsLocalArray()"
		--if normals_local == undefined or normals_local.count != all_verts.numberSet then
		--(
		--)
		normals_local = this.all_verts as Array

		for i = 1 to normals_local.count do
			normals_local[i] = point3 0 0 0
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObjectNormals.onCreate()"
		all_verts = #{1..(getNumVerts obj.mesh)}

		this._initNormalsLocalArray()
	)
)
