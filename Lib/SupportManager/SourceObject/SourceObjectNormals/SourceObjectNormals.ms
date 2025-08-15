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

	normals_faces_local = #(),
	--normals_faces_world = #(),
	
	down_verts = #{}, -- Array fot store vertex normals in world space
	down_faces = #{}, -- Array fot store vertex normals in world space
	--Supports = Dictionary #INTEGER, -- KEY:vertex_index VALUE:SupportObject|RaftObject

	/* private */
	en_mod,
	
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
		--format "\n"; print "SourceObjectNormals_v.setWorldSpaceVertexNormals()"
		--format "verts: %\n" verts
		
		normals_world = this._getWorldSpaceNormals normals_local
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
	
	/** Update down faces
	 */
	function setDownFaces =
	(
		format "\n"; print "SourceObjectNormals_v.setDownFaces()"
		--format "normals_faces_local: %\n" normals_faces_local
		format "normals_faces_local: %\n" (for _normal in normals_faces_local where _normal != undefined collect _normal  )
		this.down_verts = #{} -- Array fot store vertex normals in world space
		this.down_faces = #{} -- Array fot store vertex normals in world space
	
		timer_setDownFaces = timeStamp()

		normals_faces_world = this._getWorldSpaceNormals normals_faces_local
		format "normals_faces_world: %\n" (for _normal in normals_faces_world where _normal != undefined and _normal.z == -1 collect _normal  )

		for f = 1 to normals_faces_local.count \
			where normals_faces_local[f] != undefined \
			and normals_faces_local[f].z == -1 do 
			(
				/* ADD FACE TO DOWN FACES */ 
				--this.down_faces[f] = true
				this.down_faces += meshop.getPolysUsingFace obj.mesh #{f}
		
				/* ADD VERTS OF DOWN FACES */ 		
				this.down_verts += meshop.getVertsUsingFace obj.mesh #{f}
			)
		
		--format "setDownFaces: % ms\n" (( timeStamp()) - timer_setDownFaces)


		format "DOWN_VERTS: %\n" this.down_verts
		format "DOWN_FACES: %\n" this.down_faces
	),
	
	private
	
	/**  get world space normla
	 */
	function _getWorldSpaceNormals normals =
	(
		--format "\n"; print "SourceObjectNormals_v._getWorldSpaceNormals()"
		obj_pos	= obj.pos
		obj_transform	= obj.transform
		
		for i = 1 to normals.count where normals[i] != undefined do 
			normals[i] =  normalize (normals[i] * obj_transform - obj_pos)
		
		normals --return
	),
	
	/** Get local vertex normals by modifier
	 */
	function _setLocalNormalsByModifier verts =
	(
		format "\n"; print "SourceObjectNormals_v._setLocalNormalsByModifier()"
		format "\n**********************************************************\n"
		--format "classOf obj: %\n" ( classOf obj )
		
		en_mod = Edit_Normals()

		addModifier obj en_mod

		--total_normals = en_mod.GetNumNormals()
		
		for vert in verts do
		(
			local_normal = point3 0 0 0

			normal_ids_verts = #{}
			
			en_mod.ConvertVertexSelection #{vert} normal_ids_verts node:obj

			for normal in normal_ids_verts do
				local_normal += en_mod.GetNormal normal node:obj
			
			normals_local[vert] = normalize local_normal
			
			
			for face in meshop.getFacesUsingVert obj.mesh vert do
			(
				--local_normal = point3 0 0 0
				--
				--normal_ids_faces = #{}
				--
				--en_mod.ConvertFaceSelection  #{face} normal_ids_faces node:source_obj			
				--
				--for normal in normal_ids_faces do
				--	local_normal += en_mod.GetNormal normal node:obj
				--
				--this.normals_faces_local[face] = normalize local_normal
				this.normals_faces_local[face] = getFaceNormal	obj.mesh face
			)
		)
		
		deleteModifier obj en_mod
	),

	/** Get verts normals
	 */
	function _updateLocalNormals verts =
	(
		format "\n"; print "SourceObjectNormals_v._updateLocalNormals()"
		format "\n#######################################################\n"
		
		--format "verts.numberSet: %\n" verts.numberSet
		timer_updateLocalNormals = timeStamp()
		
		obj_mesh = obj.mesh

		faces_of_verts = meshop.getFacesUsingVert obj_mesh verts

		for face in faces_of_verts do
		(
			face_normal = getFaceNormal	obj_mesh face
			
			/* SAVE FACE NORMAL */ 
			this.normals_faces_local[face] = face_normal

			/* GET VERTS OF FACE */ 
			face_verts = getFace	obj_mesh face
			
			/* SAVE NORMAL FOR EACH VERTEX */ 
			normals_local[face_verts[1]] += face_normal
			normals_local[face_verts[2]] += face_normal
			normals_local[face_verts[3]] += face_normal
		)

		/* NORMALIZE EACH NORMAL */ 
		for vert in verts do normals_local[vert] = normalize normals_local[vert]

		--format "updateLocalNormals: % ms\n" (( timeStamp()) - timer_updateLocalNormals)
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
		
		this.normals_faces_local[getNumFaces obj.mesh]	= undefined
		
	),

	/**
	 */
	on create do
	(
		format "\n"; print "SourceObjectNormals.onCreate()"
		all_verts = #{1..(getNumVerts obj.mesh)}
	)
)
