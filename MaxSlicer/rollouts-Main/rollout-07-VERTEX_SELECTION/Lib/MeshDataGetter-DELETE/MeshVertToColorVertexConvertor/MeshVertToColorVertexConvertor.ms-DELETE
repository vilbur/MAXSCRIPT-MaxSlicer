/** Mesh vert to color vertex convertor
 */
struct MeshVertToColorVertexConvertor_v
(
	/* construct */
	obj,

	get_single_vert = false,

	/* properties */
	faces_of_vert_cache   	= Dictionary (#integer),
	map_verts_of_face_cache = Dictionary (#integer),
	mesh_verts_of_face_cache = Dictionary (#integer),

	/* dependency */
	/* reference */
	/* inhered */


	/** Get Color per vertex indexes verts by geo vert
	  *
	  * @param boolean flat if true then ARRAY is returned not 2D MATRIX - handy if getting sinlge vertex
	  *
	  * @return array|2Dmatrix
	 */
	function meshVertsToMapVerts verts flat:false =
	(
		--format "\n"; print "MeshVertToColorVertexConvertor_v.meshVertsToMapVerts()"

		/** Get faces using by given vert
		  *
		  * Each face is defined by map verts
		 */
		function getFacesUsingVert obj vert =
		(
			/* GET ALL FACES USED BY VERTEX */
			faces_of_vertex =  meshop.getFacesUsingVert obj.mesh vert

			/* GET ALL VERTS USED BY FACES in faces_of_vertex */
			all_verts_of_faces = for face_id in faces_of_vertex collect meshop.getVertsUsingFace obj.mesh face_id

			all_verts_of_faces --return
		)

		/**
		 */
		function getMapVertsOface obj map_face_index =
		(
			--format "\n"; print ".verts_of_face()"
			map_verts_of_face_p3 = getVCFace obj.mesh map_face_index -- map_verts_of_face is defined by its 3 vertext indexes E.G.: [1,3,4]

			sort #( map_verts_of_face_p3.x as integer , map_verts_of_face_p3.y as integer , map_verts_of_face_p3.z as integer )
		)


		/* SET CORRENT DATATYPE - BitArray */
		if superClassOf verts == Number then verts = #{verts}
		--format "verts.numberSet	= % \n" verts.numberSet

		local CPV_verts_all	= #()


		for vert in verts do
		(
			--format "VERT	= % \n" vert
			CPV_verts = #()

			--faces_of_vertex_pattern =  this._getFacesUsingVert (vert)
			faces_of_vertex_pattern =  getFacesUsingVert obj (vert)
			--format "FACES_OF_VERTEX_PATTERN	= % \n" faces_of_vertex_pattern

			map_faces = faces_using_vertex =  ( meshop.getFacesUsingVert obj.mesh vert) as Array

			 if get_single_vert then
				map_faces = #((faces_using_vertex as Array )[1]) -- use only one map face


			--map_face_index = (faces_using_vertex as Array)[1]
			for map_face_index in map_faces do
			(
				--format "\n--------------------------\n\nMAP_FACE_INDEX = % \n" map_face_index

				/* SET TO CHACHE */
				if map_verts_of_face_cache[map_face_index] == undefined then
					map_verts_of_face_cache[map_face_index] =  getMapVertsOface obj map_face_index

				/* GET FROM CHACHE */
				map_verts_of_face = map_verts_of_face_cache[map_face_index]

				/* DEV - NOT USE CACHE */
				------map_verts_of_face =  getMapVertsOface obj map_face_index


				/* SET TO CHACHE */
				if mesh_verts_of_face_cache[map_face_index] == undefined then
					mesh_verts_of_face_cache[map_face_index] =  ( meshop.getVertsUsingFace obj.mesh map_face_index) as Array

				/* GET FROM CHACHE */
				mesh_verts_of_face = mesh_verts_of_face_cache[map_face_index]

				/* DEV - NOT USE CACHE */
				------mesh_verts_of_face =  ( meshop.getVertsUsingFace obj.mesh map_face_index) as Array


				v = 1
				found = false

				/* LOOP EACH GEOMETRY VERTEX OF FACE and find which vert share same faces as faces_of_vertex_pattern ( it means that it is the same geometry vert ) */
				while v <= mesh_verts_of_face.count and not found do
				(
					vert_mesh = mesh_verts_of_face[v]

					/* SAVE TO CACHE */
					if faces_of_vert_cache[vert_mesh] == undefined then
						faces_of_vert_cache[vert_mesh] =  getFacesUsingVert obj vert_mesh

					/* GET FROM CHACHE */
					faces_of_vert = faces_of_vert_cache[vert_mesh]


					/* DEV - NOT USE CACHE */
					------faces_of_vert = getFacesUsingVert obj vert_mesh

					found = faces_of_vertex_pattern.count == faces_of_vert.count and (with PrintAllElements on faces_of_vertex_pattern as string == faces_of_vert as string )

					/* APPEND map verts to sinlge array or to 2D matrix by its face  */
					if found then
						append ( if get_single_vert then CPV_verts_all else CPV_verts ) map_verts_of_face[v]

					v += 1
				)

			)

			if not get_single_vert then
			(
				if flat then
					join CPV_verts_all CPV_verts
				else
					append CPV_verts_all (CPV_verts as BitArray )
			)
		)

		--free	faces_of_vert_cache
		--free	map_verts_of_face_cache
		--free	mesh_verts_of_face_cache

		gc()	--Garbage Collection.
		--format "CPV_verts_all	= % \n" CPV_verts_all
		CPV_verts_all --return
	),

	/** Map verts to mesh verts
	 */
	function mapVertsToMeshVerts map_verts =
	(
		--format "\n"; print "MeshVertToColorVertexConvertor_v.mapVertsToMeshVerts()"

		if classOf map_verts == Array then map_verts = map_verts as BitArray

		local mesh_verts = #{}

		v = 1

		while mesh_verts.numberSet < map_verts.numberSet do
		(
			map_verts_of_vert = (this.meshVertsToMapVerts(v) flat:true) as BitArray

			intersection = map_verts * map_verts_of_vert -- test if arrays contains same indexes

			if not intersection.isEmpty then
				mesh_verts[v] = true

			v += 1
		)

		gc()	--Garbage Collection.

		mesh_verts --return
	),


	private

	/**
	 */
	on create do
	(
		--format "\n"; print "MeshVertToColorVertexConvertor.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
