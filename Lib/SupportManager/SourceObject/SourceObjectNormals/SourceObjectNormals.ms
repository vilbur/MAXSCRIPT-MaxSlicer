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

	normals_local, -- Array fot store vertex normals in object space
	normals_world, -- Array fot store vertex normals in world space

	down_verts = #{}, -- Array fot store vertex normals in world space
	down_faces = #{}, -- Array fot store vertex normals in world space
	--Supports = Dictionary #INTEGER, -- KEY:vertex_index VALUE:SupportObject|RaftObject

	/* private */
	en_mod,

	--verts_pos,

	--obj_rotation, -- store object rotation to find if world n1`ormals needs to be recount
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
			this._setLocalNormalsByModifier( verts )
		else
			this._updateLocalNormals( verts )
	),

	/** Set world space vertex normals
	 */
	function setWorldSpaceVertexNormals verts =
	(
		format "\n"; print "SourceObjectNormals_v.setWorldSpaceVertexNormals()"
		format "verts: %\n" verts
		--format "verts.numberset : %\n" verts.numberset 
		
		obj_pos	= obj.pos
		obj_transform	= obj.transform

		if normals_world == undefined then
		(
			normals_world = deepCopy normals_local
			
			verts = #{1..normals_world.count}
		)

		--for vert in verts where normals_world[vert] != undefined do normals_world[vert] = normalize (normals_local[vert] * obj_transform - obj_pos)
		--for normal_world in normals_world do
		--format "normal_world: %\n" normal_world
		for vert in verts do normals_world[vert] = normalize (normals_local[vert] * obj_transform - obj_pos)
		
		
			--if (has_down_faces = this.setDownFaces vert) then
		--this.setDownFaces verts
		
		--for vert in verts where normals_world[vert] != undefined do normals_world[vert] = normalize (normals_local[vert] * obj_transform - obj_pos)
	),
	
	/** Update down faces
	 */
	function setDownFaces verts =
	(
		format "\n"; print "SourceObjectNormals_v.setDownFaces()"
		obj_pos	= obj.pos
		obj_transform	= obj.transform
		
		this.down_verts = #{} -- Array fot store vertex normals in world space
		this.down_faces = #{} -- Array fot store vertex normals in world space
	
		timer_setDownFaces = timeStamp()
		for vert in verts do
		(
			down_faces_of_vert = #{}
			
			--normal_ids = #{}
			--z_sum      = 0.0
			
			--faces_of_verts = polyop.getFacesUsingVert obj #{vert}
			faces_of_verts = meshop.getFacesUsingVert obj.mesh #{vert}
			
			
			--for face = 1 to faces_of_verts.count do
			for face in faces_of_verts do 
			(
				--face_normal = polyop.getFaceNormal obj face
				face_normal = getFaceNormal obj.mesh face
				
				face_normal = normalize ( face_normal * obj_transform - obj_pos)
				
				--z_sum += face_normal.z

				if face_normal.z == -1 then
					down_faces_of_vert[face] = true
			)
			
			--avg_z = z_sum / faces_of_verts.numberSet

			--if avg_z == -1 then
				--down_faces[face] = true
				--down_faces_of_vert[face] = true
			if not down_faces_of_vert.isEmpty then
			(
				down_verts[vert] = true
				
				down_faces += down_faces_of_vert
				
			)
			
		)
		
		format "setDownFaces: % ms\n" (( timeStamp()) - timer_setDownFaces)
		format "THIS.DOWN_FACES: %\n" this.down_faces
		/* ADD FACE TO DOWN FACES */ 
		--for face in down_faces_of_vert do
			--down_faces[face] = true
		
		/* RETURN BOOLEAN */ 
		--not down_faces_of_vert.isEmpty --return
	),
		
	/** Load normals local
	 */
	function loadNormalsLocal =
	(
		--format "\n"; print "SourceObjectNormals_v.loadNormalsLocal()"
		if ( normals_local_loaded = getUserPropVal obj "normals_local" ) != undefined then
			this.normals_local = normals_local_loaded
		--format "normals_local_loaded: %\n" normals_local_loaded
		normals_local_loaded != undefined
	),
	
	/** Is vertex normal pointing DOWN or SIDE but not UP
	 */
	function isNormalValid vert limit:0.0 =
	(
		--format "\n"; print "SourceObjectNormals_v.isNormalValid()"
		----format "\n"; format "SourceObjectNormals_v.isNormalValid: % %\n" normals_world[vert] (normals_world[vert].z < 0)
		--format "normals_world[vert].z: %\n" normals_world[vert].z
		--
		--format "limit: %\n" limit
		--format "TEST: %\n" (normals_world[vert].z <= limit)
		
		is_normal_valid = normals_world[vert].z <= limit
		
		if not is_normal_valid then
			FORMAT "--------- WARNING: NOT CREATED SUPPORT OF VERT: % NORMAL IS NOT POINTING DOWN:% \n" vert normals_world[vert]
		
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
	function _setLocalNormalsByModifier verts =
	(
		format "\n"; print "SourceObjectNormals_v._setLocalNormalsByModifier()"
		--format "classOf obj: %\n" ( classOf obj )
		
		en_mod = Edit_Normals()

		addModifier obj en_mod

		total_normals = en_mod.GetNumNormals()
		
		for vert in verts do
		(
			local_normal = point3 0 0 0

			normal_ids = #{}
			
			en_mod.ConvertVertexSelection #{vert} normal_ids node:obj

			for normal in normal_ids do
				local_normal += en_mod.GetNormal normal node:obj
			
			--if (has_down_faces = this.setDownFaces vert) then
				--down_verts[vert] = true
				
			normals_local[vert] = normalize local_normal
			
		)
		
		--format "DOWN_FACES:\n%\n" down_faces
		
		deleteModifier obj en_mod
	),

	/** Get verts normals
	 */
	function _updateLocalNormals verts =
	(
		format "\n"; print "SourceObjectNormals_v._updateLocalNormals()"
		format "verts.numberSet: %\n" verts.numberSet
		timer_updateLocalNormals = timeStamp()
		
		obj_mesh = obj.mesh

		faces_of_verts = meshop.getFacesUsingVert obj_mesh verts

		for face in faces_of_verts do
		(
			format "face: %\n" face
			face_verts = getFace	obj_mesh face
			face_normal = getFaceNormal	obj_mesh face
			--
			--for face in face_verts * verts do
			--	vertex_normals[face] += face_normal

			normals_local[face_verts.x] += face_normal
			normals_local[face_verts.y] += face_normal
			normals_local[face_verts.z] += face_normal
		)

		for vert in verts do normals_local[vert] = normalize normals_local[vert]

		format "updateLocalNormals: % ms\n" (( timeStamp()) - timer_updateLocalNormals)
		--format "SourceObjectNormals._updateLocalNormals: % seconds\n" ((( timeStamp()) - timer_get_normals) / 1000.0)
	),
	
	/** Set vertex normals empty array
	 */
	function _initNormalsLocalArray =
	(
		--format "\n"; print "SourceObjectNormals_v._initNormalsLocalArray()"
		
		if (normals_local != undefined and normals_local.count != all_verts.numberSet ) \
		or normals_local == undefined then
		(
			normals_local = this.all_verts as Array

			for i = 1 to normals_local.count do
				normals_local[i] = point3 0 0 0
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
