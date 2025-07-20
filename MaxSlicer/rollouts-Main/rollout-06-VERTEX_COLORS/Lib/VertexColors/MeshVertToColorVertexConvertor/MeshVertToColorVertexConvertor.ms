

/** Mesh vert to color vertex convertor
 */
struct MeshVertToColorVertexConvertor_v
(
	/* construct */
	obj,
	obj_mesh,

	get_single_vert = false,

	/* properties */
	--faces_of_vert_cache   	= Dictionary (#integer),
	--map_verts_of_face_cache = Dictionary (#integer),
	--mesh_verts_of_face_cache = Dictionary (#integer),

	--map_verts_of_face_cache = #(),
	--mesh_verts_of_face_cache = #(),

	/* dependency */
	/* reference */
	/* inhered */

	/** Get Color per vertex indexes of verts by geo vert
	  *
	  * @param boolean flat if true then ARRAY is returned not 2D MATRIX - handy if getting sinlge vertex
	  *
	  * @return array|2Dmatrix
	 */
	function meshVertsToMapVerts verts flat:false =
	(
		--format "\n"; print "MeshVertToColorVertexConvertor_v.meshVertsToMapVerts()"

		--obj_mesh = obj.baseobject.mesh
		obj_mesh = if classOf obj != TriMesh then obj.baseobject.mesh else obj

		/** Get map vert from face
		 */
		function getMapVertFromFace vert face_id =
		(
			--format "\n"; print "MeshVertToColorVertexConvertor_v.getMapVertFromFace()"

			mesh_verts	= getFace obj_mesh face_id
			map_verts	= getVCFace	obj_mesh	face_id

			case of
			(
				(mesh_verts[1] == vert): map_verts[1]
				(mesh_verts[2] == vert): map_verts[2]
				(mesh_verts[3] == vert): map_verts[3]
			)
		)

		/** Flattern array
		 */
		function flatternArray matrix =
		(
			--format "\n"; print "MeshVertToColorVertexConvertor_v.flatternArray()"
			array_flat = #()

			for arr in matrix do
				join array_flat arr

			array_flat --return flattern matrix
		)

		--obj_numverts = obj.numverts

		--map_verts_of_face_cache[obj_mesh.numverts]  = undefined
		--mesh_verts_of_face_cache[obj_mesh.numverts] = undefined


		if classOf verts == integer then
			verts = #( verts )

		else if classOf verts == BitArray then
			verts = verts as Array


		--CPV_verts_all = deepCopy verts
		--CPV_verts_all = #()
		--CPV_verts_all[verts.count] = undefined --initialize a 100 elements array in memory
		CPV_verts_all = verts as Array

		--format "verts: %\n" verts
		--format "CPV_verts_all: %\n" CPV_verts_all
		/*------ GET CPV VERTS ------*/
		for i = 1 to verts.count do
		(
			vert = verts[i]
			--format "vert: %\n" vert

			faces =  ( meshop.getFacesUsingVert obj_mesh vert ) as Array
			format "faces.count: %\n" faces.count
			--format "faces: %\n" faces

			if faces != undefined and faces.count > 0 then
			(
				if not get_single_vert then
					CPV_verts_all[i] = for face_id in faces collect getMapVertFromFace(vert)(face_id)
	
				else
					CPV_verts_all[i] = getMapVertFromFace(vert)(faces[1])
			)
			else
				FORMAT "VERT WITHOUT FACES ver: % of object: % \n" vert obj.name
			
		)
		--format "CPV_verts_all: %\n" CPV_verts_all

		/*------ FLATTERN RESULT ARRAY ------*/
		if flat and not get_single_vert then
			flatternArray(CPV_verts_all) --return
		else
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
--
		--while mesh_verts.numberSet < map_verts.numberSet do
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
		--format "3) --------------- MESH VERT TO COLOR VERTEX CONVERTOR\n"
		----for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
