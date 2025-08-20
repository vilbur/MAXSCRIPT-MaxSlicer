/** Source object normals
 */
struct SourceObjectNormals_v
(
	/* construct */
	obj,
	--sync_key,

	/* required */
	/* properties */
	faces_local = #(), -- local face normals
	faces_world = #(), -- world face normals
	
	verts_local = #(), -- Array fot store vertex normals in object space
	verts_world = #(), -- Array fot store vertex normals in world space
	
	down_verts = #{}, -- Array fot store vertex normals in world space
	down_faces = #{}, -- Array fot store vertex normals in world space

	--normal_limit_of_horizontal_face = 2.5, -- angle of face`s z normal where face is considered as horizontal -- 0° is horizontal | 90° is vertical
	normal_limit_of_horizontal_face = 177.5, -- angle of face`s z normal where face is considered as horizontal -- 0 is up | 180° is down
	
	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	
	/*
	 */
	function initFacesLocalNormals verts =
	(
		--FORMAT "\n"; print "SourceObjectNormals_v.setLocalVertexNormals()"
		this.loadNormalsLocal()
		--if not this.loadNormalsLocal() then
		(
			obj_mesh = obj.mesh
			
			--normals_local[getNumFaces obj_mesh] = undefined
			
			for face in meshop.getFacesUsingVert obj_mesh verts do
				faces_local[face] = getFaceNormal obj_mesh face
		)
		
		--	this._setLocalNormalsByModifier( verts )
		--else
		--	this._updateLocalNormals( verts )
	),
	
	/** Set local vertex normals
	 */
	function setLocalVertexNormals verts =
	(
		--format "\n"; print "SourceObjectNormals_v.setLocalVertexNormals()"
		obj_mesh = obj.mesh
		
		this._initNormalsLocalArray()

		face_of_verts = meshop.getFacesUsingVert obj_mesh verts

		--for face = 1 to faces_local.count where (face_normal = faces_local[i]) != undefined do 
		for face in face_of_verts  where (face_normal = faces_local[face]) != undefined do  
		(
			/* GET VERTS OF FACE */ 
			face_verts = getFace	obj_mesh face
			
			/* SAVE NORMAL FOR EACH VERTEX */ 
			verts_local[face_verts[1]] += face_normal
			verts_local[face_verts[2]] += face_normal
			verts_local[face_verts[3]] += face_normal
		)
	),
	
	/** Set world space vertex normals
	 */
	function setWorldSpaceVertexNormals =
	(
		verts_world = this._getWorldSpaceNormals verts_local
	),
	
	/** Set world space face normals
	 */
	function setWorldSpaceFaceNormals =
	(
		faces_world = this._getWorldSpaceNormals faces_local
	),
	
	/** Update down faces
	 */
	function setDownFaces verts =
	(
		FORMAT "\n"; print "SourceObjectNormals_v.setDownFaces()"
		--format "normals_faces_local: %\n" normals_faces_local
	

		this.down_verts = #{} -- Array fot store vertex normals in world space
		this.down_faces = #{} -- Array fot store vertex normals in world space
		
		obj_mesh = obj.mesh

		face_of_verts = meshop.getFacesUsingVert obj_mesh verts
		
		--normal_limit = -1
		--normal_limit = -0.95
		for f in face_of_verts \
			where faces_world[f] != undefined do
			(
				--format "\n%\n" f
				angle_of_normal = this._getAngleOfNormal(faces_world[f])
				--format "angle_of_normal: %\n" angle_of_normal
				--format "normal_limit_of_horizontal_face: %\n" normal_limit_of_horizontal_face
				--format "faces_world[f]: %\n" faces_world[f]
				--format "faces_world[f].z: %\n" faces_world[f].z
				
				if angle_of_normal >= normal_limit_of_horizontal_face then
				(
					timer_face = timeStamp()
					/* ADD FACE TO DOWN FACES */ 
					this.down_faces[f] = true
			
                    /* ADD VERTS OF DOWN FACES */ 		
                    this.down_verts += meshop.getVertsUsingFace obj.mesh #{f}
                    --format "face: % ms\n" (( timeStamp()) - timer_face)
				)
			)
			
		--format "DOWN_VERTS: %\n" this.down_verts
		--format "DOWN_FACES: %\n" this.down_faces
	),
	
	/** Save normals to user props
	 */
	function saveNormalsToUserProps =
	(
		--format "\n"; print "SourceObjectNorwmals_v.saveNormalsRoUserProps()"
		setUserPropVal obj "FACES_LOCAL"	faces_local
	),
	
	/** Is vertex normal pointing DOWN or SIDE but not UP
	 */
	function isNormalValid vert limit:0.0 =
	(
		--format "\n"; print "SourceObjectNormals_v.isNormalValid()"
		----format "\n"; format "SourceObjectNormals_v.isNormalValid: % %\n" normals_world[vert] (normals_world[vert].z < 0)

		is_normal_valid = verts_world[vert].z <= limit
		
		if not is_normal_valid then
			FORMAT "--------- WARNING: NOT CREATED SUPPORT OF VERT: % NORMAL IS NOT POINTING DOWN:% \n" vert verts_world[vert]
		
		is_normal_valid --return
	),
	
	private
	
	/**  get world space normla
	 */
	function _getWorldSpaceNormals normals =
	(
		--format "\n"; print "SourceObjectNormals_v._getWorldSpaceNormals()"
		obj_pos	= obj.pos
		obj_transform	= obj.transform
		
		world_normals = #()
		
		for i = 1 to normals.count where normals[i] != undefined do 
			world_normals[i] =  normalize (normals[i] * obj_transform - obj_pos)
		
		world_normals --return
	),
	
	/** Load normals local
	 */
	function loadNormalsLocal =
	(
		--format "\n"; print "SourceObjectNormals_v.loadNormalsLocal()"
		if ( faces_local_loaded = getUserPropVal obj "FACES_LOCAL" ) != undefined then
			this.faces_local = faces_local_loaded

		faces_local_loaded != undefined
	),
	

	/* 
	Convert normal vector to angle with ground plane (Z axis).
	Returns angle in degrees.
	*/
	function _getAngleOfNormal normal_vector =
	(
		up_vector = [0,0,1]
		
		dot_val = dot (normalize normal_vector) (normalize up_vector)
		
		dot_val = amax (amin dot_val 1.0) -1.0
		
		acos dot_val -- return
	),
	
	/** Set vertex normals empty array
	 */
	function _initNormalsLocalArray =
	(
		--format "\n"; print "SourceObjectNormals_v._initNormalsLocalArray()"
		vertex_count = getNumVerts obj.mesh
		
		if  verts_local.count == 0 then
			for i = 1 to vertex_count do
				verts_local[i] = point3 0 0 0
	),
	
	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObjectNormals.onCreate()"

	)
)
