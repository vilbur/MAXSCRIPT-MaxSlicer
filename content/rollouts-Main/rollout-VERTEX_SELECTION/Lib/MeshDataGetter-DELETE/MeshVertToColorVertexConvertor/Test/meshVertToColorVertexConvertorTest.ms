clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../MeshVertToColorVertexConvertor.ms" )	--"./../MeshVertToColorVertexConvertor.ms"


/** Prepare scene
 */
function prepareScene verts _vertex_color segments:4 break_map_faces:true =
(
	--format "\n"; print ".prepareScene()"
	clearListener(); print("Cleared in:\n"+getSourceFileName())

	if superClassOf verts == Number then
			verts = #{verts}

	delete objects


	--obj = Box showVertexColors:true	vertexColorsShaded:true alledges:true -- isSelected:on
	--obj = Plane showVertexColors:true vertexColorsShaded:true alledges:true widthsegs:2 lengthsegs:2

	obj = Sphere radius:50  isSelected:on segs:segments showVertexColors:true	vertexColorsShaded:true
	--obj = Sphere radius:50  isSelected:on segs:16 showVertexColors:true	vertexColorsShaded:true
	--obj = Sphere radius:50  isSelected:on segs:32 showVertexColors:true	vertexColorsShaded:true
	--obj = Sphere radius:50  isSelected:on segs:64 showVertexColors:true	vertexColorsShaded:true


	convertTo obj Editable_Poly
	convertTo obj Editable_Patch -- conect triangled mesh
	convertTo obj Editable_Poly


	/*
		IMPORTANT:
			THIS  WILL DETACH ONE-PER-ONE relationship between verts

		more colored faces == more datached map faces

	*/
	if break_map_faces then
		for face_id = 1 to polyop.getNumFaces obj.baseobject do
		(
			polyop.setFaceColor obj.baseobject 0 face_id _vertex_color
			polyop.setFaceColor obj.baseobject 0 face_id white

		)


	/* SET COLOR FOR TESED VERTEX */
	for vet in verts do
		polyop.setVertColor obj.baseobject 0 verts _vertex_color



	format "NumCPVVerts = % \n" (getNumCPVVerts obj.mesh )

	vertex_count = getNumVerts obj.mesh

)

/*==============================================================================

		TEST CONFIGURATION

================================================================================*/


get_single_vert = false
--get_single_vert = true

break_map_faces = true
--break_map_faces = false

verts	= #{1}
verts	= #{2}
--verts	= #{1..2,5}
verts	= #{32, 54, 60..65}
--verts	= #{1..6}

/*==============================================================================

		PREPARE SCENE

================================================================================*/

_vertex_color	= color 0 80 200

prepareScene verts _vertex_color break_map_faces:break_map_faces segments:16

obj	= objects[1]
vertex_count	= getNumVerts obj.mesh
format "vertex_count = % \n" vertex_count



/*==============================================================================

		DEFINE INSTANCE


================================================================================*/
MeshVertToColorVertexConvertor = MeshVertToColorVertexConvertor_v( obj ) get_single_vert:get_single_vert



/*==============================================================================

		MESH VERTEX TO MAP VERTEX

================================================================================*/
timer_start = timeStamp()

CPV_verts_all = MeshVertToColorVertexConvertor.meshVertsToMapVerts (verts)



/* PRINT RESULTS */
format "\n\n\n==============================================================================\n\n"
format "MESH VERTEX TO MAP VERTEX:\n\n"

format "IN MESH:  % \n" verts
format "OUT MAP: % \n" CPV_verts_all
format "\n"
format "INPUT COUNT:  % \n" verts.numberSet
format "OUTPUT COUNT: % \n" CPV_verts_all.count

format "\nGet % verts takes % ms\n" vertex_count (( timeStamp()) - timer_start)



--for CPV_verts in CPV_verts_all as Array do
--(
--	--format "CPV_verts	= % \n" CPV_verts
--	vert = if classOf CPV_verts == Array then CPV_verts[1] else CPV_verts
--
--	vertex_color_get = getvertcolor obj.mesh vert
--
--	format "TEST PASSED: %  >>> vert: %	color:%	CPV_verts:%\n" (vertex_color_get as string ==_vertex_color as string ) vert vertex_color_get CPV_verts
--)





/*==============================================================================
		MAP VERTEX TO MESH VERTEX

================================================================================*/

/* GET ONLY FIRST MAP VERT OF EACH MAP VERT (flatter 2d matrix) */
if classOf CPV_verts_all[1] == BitArray then
	CPV_verts_all = for CPV_verts in CPV_verts_all collect (CPV_verts as Array )[1]



/*------ RUN TEST ------*/
format "\n\n\n==============================================================================\n\n"
format "MAP VERTEX TO MESH VERTEX:\n\n"


mesh_verts = MeshVertToColorVertexConvertor.mapVertsToMeshVerts (CPV_verts_all) flat:true

/* PRINT RESULTS */
format "\n -------------------  RESULTS ------------------- \n\n"
format "IN MAP:   % \n" CPV_verts_all
format "OUT MESH: % \n" mesh_verts
format "\n"
format "INPUT COUNT:  % \n" verts.numberSet
format "OUTPUT COUNT: % \n" CPV_verts_all.count

format "\nTEST PASSED: %\n" ( mesh_verts - verts ).isEmpty
