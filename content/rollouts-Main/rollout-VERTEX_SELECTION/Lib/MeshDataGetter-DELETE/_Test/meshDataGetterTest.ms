clearListener(); print("Cleared in:\n"+getSourceFileName())

filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-VERTEX-COLOR\Lib\meshVertToColorVertexConvertor\MeshVertToColorVertexConvertor.ms"

filein( getFilenamePath(getSourceFileName()) + "/../MeshDataGetter.ms" )	--"./../MeshDataGetter.ms"

/**
  */
function createSourceMesh obj: segments:8 vertex_selection:#{} vertex_color: =
(
	format "\n"; print "MeshVertexGetterTest.ms.createSourceMesh()"
	delete objects

	if  obj == unsupplied then
		obj = Sphere radius:15 pos:[0,0, 50 ] segments:segments isSelected:on --showVertexColors:true	vertexColorsShaded:true -- diameter 3 cm

	macros.run "Modifier Stack" "Convert_to_Poly"


	Rotate obj ( AngleAxis 180 [1,0,0]) -- rotate object upside down



	/* VERTEX COLORS */
	obj.showVertexColors	= vertex_color != unsupplied
	obj.vertexColorsShaded	= vertex_color != unsupplied


	if vertex_color != unsupplied then
		polyop.setVertColor obj 0 vertex_selection vertex_color

	/* VERTEX SELECTION */
	if vertex_selection.numberSet > 0 then
	(
		subObjectLevel = 1

		obj.EditablePoly.SetSelection #Vertex vertex_selection
	)

	obj --return
)



/*--------------------------------------------------------------------
	PREPARE TEST OBJECTS
--------------------------------------------------------------------------------*/
--createSourceMesh()
--createSourceMesh segments:64
--createSourceMesh segments:128
--createSourceMesh segments:1024

createSourceMesh segments:64 vertex_selection:#{1..32} vertex_color:red

--obj = selection[1]


/*------------------------------------------------------------------------------
	SET INSTANCE
-------------------------------------------------------------------------------*/
--global MeshDataGetter 	= MeshDataGetter_v( obj )


/*------------------------------------------------------------------------------
	SETUP
--------------------------------------------------------------------------------*/


--MeshDataGetter.VertNormalLimits.z = [ 80, 100 ] 	-- get side faces 80° - 100°

/*------------------------------------------------------------------------------
	RUN TEST
--------------------------------------------------------------------------------*/

/** Select verts on bottom
 */
function selectVertsOnBottom =
(
	obj = createSourceMesh segments:16

    MeshDataGetter 	= MeshDataGetter_v( obj )

	--format "\n"; print ".selectVertsOnBottom()"
    MeshDataGetter.VertNormalLimits.z = [ 135, 180 ]	-- get faces 0° - 20°

	/* TEST */
	verts_data = MeshDataGetter.getVertexData()

	subObjectLevel = 1

	obj.EditablePoly.SetSelection #Vertex verts_data[#VERTS]
)

selectVertsOnBottom()



/** SELECT FACES TOP AND BOTTOM
 */
function selectFacesTopAndBottom =
(
	obj = createSourceMesh segments:16

    MeshDataGetter = MeshDataGetter_v( obj )

    MeshDataGetter.FaceNormalLimits.z = 45	-- get faces 0° - 20°
	MeshDataGetter.FaceNormalLimits.absolute = true

	face_data = MeshDataGetter.getFacesData()
	format "FACE_DATA: %\n" face_data
	--format "\n test: % ms\n" (( timeStamp()) - timer_test)
	subObjectLevel = 4
	obj.EditablePoly.SetSelection #Face face_data[#FACES]
	--format "\n"; print ".selectFacesTopAndBottom()"
)

--selectFacesTopAndBottom()














--/*------------------------------------------------------------------------------
--	SELECT RESULT
----------------------------------------------------------------------------------*/
--subObjectLevel = 4
--obj.EditablePoly.SetSelection #Face verts_data[#FACES]
