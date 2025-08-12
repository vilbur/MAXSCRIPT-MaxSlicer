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
	en_mod,

	--verts_pos,

	normals_local, -- Array fot store vertex normals in object space
	normals_world, -- Array fot store vertex normals in world space

	down_verts = #{}, -- Array fot store vertex normals in world space
	down_faces = #{}, -- Array fot store vertex normals in world space
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
		--format "\n"; print "SourceObjectNormals_v.setLocalVertexNormals()"
		this._initNormalsLocalArray()


		if not this.loadNormalsLocal() then
			this._updateLocalVertexNormalsByModifier( verts )
		else
			this._updateLocalNormals( verts )
	),

	/** Set world space vertex normals
	 */
	function setWorldSpaceVertexNormals verts =
	(
		--format "\n"; print "SourceObjectNormals_v.setWorldSpaceVertexNormals()"
		--format "verts: %\n" verts
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
		
		--for vert in verts where normals_world[vert] != undefined do normals_world[vert] = normalize (normals_local[vert] * obj_transform - obj_pos)
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
	function _updateLocalVertexNormalsByModifier verts =
	(
		--format "\n"; print "SourceObjectNormals_v._updateLocalVertexNormalsByModifier()"
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
			
			
			
			
			if (has_down_faces = this._setDownFaces vert) then
				down_verts[vert] = true
				
			normals_local[vert] = normalize local_normal
			
		)
		
		format "DOWN_FACES:\n%\n" down_faces
		
		deleteModifier obj en_mod
	),
	
	/** Get down faces
	 */
	function _setDownFaces vert =
	(
		obj_pos	= obj.pos
		obj_transform	= obj.transform
		
		--num_faces = getNumFaces obj
		down_faces_of_vert = #{}
	
		faces_of_verts = polyop.getFacesUsingVert obj #{vert}
		format "\nFACES_OF_VERTS:\n%\n" faces_of_verts
		for face in faces_of_verts do 
		--for f = 1 to num_faces do
		(
			format "\n"
			format "face: %\n" face
			z_sum      = 0.0
			normal_ids = #{}
			
			en_mod.ConvertFaceSelection  #{face} normal_ids node:obj
			format "normal_ids: %\n" normal_ids
			
			for nid in normal_ids do
			(
				_normal = en_mod.GetNormal nid
				
				_normal = normalize ( _normal * obj_transform - obj_pos)
				format "_normal: %\n" _normal
				
				z_sum += _normal.z
			)

			avg_z = z_sum / normal_ids.numberSet

			if avg_z == -1 then
				down_faces_of_vert[face] = true
		
		)
		
		/* ADD FACE TO DOWN FACES */ 
		for face in down_faces_of_vert do
			down_faces[face] = true
		
		/* RETURN BOOLEAN */ 
		not down_faces_of_vert.isEmpty --return
		--format "\n"; print "SourceObjectNormals_v.getDownFaces()"
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
