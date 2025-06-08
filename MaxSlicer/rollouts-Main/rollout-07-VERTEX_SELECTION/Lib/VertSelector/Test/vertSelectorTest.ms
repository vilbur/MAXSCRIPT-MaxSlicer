clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../VertSelector.ms" )	--"./../VertSelector.ms"

/**
  */
function createSourceMesh obj_type:#BOX segments:8 size:20 vertex_selection:#{}  add_edit_poly:false test_shifted_pivot:false obj:#PLANE vertex_color: =
(
	format "\n"; print "MeshVertexGetterTest.ms.createSourceMesh()"
	delete objects

	segment_size = 10

	--obj = Plane length:( segment_size * segments ) width:( segment_size * segments ) pos:[ 0, 0, 300 ] widthsegs:segments lengthsegs:segments backfacecull: off

	--obj = Sphere size:size pos:[0,0, 50 ] segments:segments --showVertexColors:true	vertexColorsShaded:true -- diameter 3 cm

	--obj = Plane width:20 length:20 pos:[ 50, 20, 50 ] widthsegs:4 lengthsegs:4

	--obj = Plane width:60 length:30 pos:[ 50, 20, 50 ] widthsegs:10 lengthsegs:10
	--obj = Plane width:40 length:30 pos:[ 50, 20, 50 ] widthsegs:40 lengthsegs:30
	--obj = Plane width:50 length:50 pos:[ 50, 20, 50 ] widthsegs:50 lengthsegs:50
	--obj = Box width:50 length:50 height:50 pos:[ 0, 0, 0 ] widthsegs:5 lengthsegs:5 heightsegs:5
	--obj = Box width:50 length:50 height:50 pos:[ 0, 0, 0 ] widthsegs:25 lengthsegs:25 heightsegs:25
	--obj = Box width:50 length:50 height:50 pos:[ 0, 0, 0 ] widthsegs:35 lengthsegs:35 heightsegs:35
	--obj = Box width:50 length:50 height:50 pos:[ 0, 0, 0 ] widthsegs:50 lengthsegs:50 heightsegs:50
	--obj = Box width:50 length:50 height:50 pos:[ 0, 0, 0 ] widthsegs:100 lengthsegs:100 heightsegs:100
	--obj = Box width:50 length:50 height:50 pos:[ 0, 0, 0 ] widthsegs:10 lengthsegs:10 heightsegs:1


	--obj = Plane width:30 length:30 pos:[ 50, 20, 50 ] widthsegs:10 lengthsegs:10
	--obj = Plane width:20 length:20 pos:[ 50, 20, 50 ] widthsegs:4 lengthsegs:4

	obj = case obj_type of
	(
		#SPHERE: Sphere pos:[ 0, 0, 50 ] size:size  segments:segments --showVertexColors:true	vertexColorsShaded:true -- diameter 3 cm
		#PLANE:  Plane  pos:[ 50,20,50 ] width:size length:size widthsegs:segments lengthsegs:segments
		#BOX:    Box    pos:[ 0, 0, 0  ] width:size length:size height:size widthsegs:segments lengthsegs:segments heightsegs:segments
	)
	
	
	select obj

	if classOf obj == Plane then
	(
		noise_val = size / 3

		modPanel.addModToSelection (Noisemodifier scale:8 strength:[ noise_val, noise_val, noise_val] ) ui:on

		Rotate obj ( AngleAxis 180 [1,0,0]) -- rotate object upside down

	)

	--modPanel.addModToSelection (smooth ()) ui:on

	macros.run "Modifier Stack" "Convert_to_Poly"

	if add_edit_poly then
		modPanel.addModToSelection (Edit_Poly ()) ui:on
	
	if vertex_selection.count > 0 and not add_edit_poly then
	(
		subObjectLevel = 1

		if vertex_color != unsupplied then
			polyop.setVertColor obj 0 vertex_selection vertex_color


		--polyop.setVertColor obj 0 vertex_selection.count red -- color last vertex in red color

		obj.EditablePoly.SetSelection #Vertex vertex_selection
	)

)



/*--------------------------------------------------------------------
	PREPARE TEST OBJECTS
--------------------------------------------------------------------------------*/

if selection.count == 0 then
(
	--createSourceMesh()


	--createSourceMesh segments:4
	--createSourceMesh segments:8
	createSourceMesh segments:8 add_edit_poly:true
	
	--createSourceMesh vertex_color:orange segments:16
	--createSourceMesh vertex_color:orange segments:32
	--createSourceMesh vertex_color:orange segments:64

	--createSourceMesh vertex_color:orange segments:128
	--createSourceMesh vertex_color:orange segments:256
	--createSourceMesh vertex_color:orange segments:512
	--createSourceMesh vertex_color:orange segments:1024

	--createSourceMesh vertex_selection:#{1..100}

	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:16
	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:32
	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:64
	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:128
	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:256
)




/*==============================================================================
	SET CLASS INSTANCE
================================================================================*/
VertSelector 	= VertSelector_v( selection[1] ) --resolution:10


--VertSelector.resolution = 3
--VertSelector.resolution = 5
--VertSelector.resolution = 8
--VertSelector.resolution = 10
--VertSelector.resolution = 20

/*------------------------------------------------------------------------------
	SELECT VERS
--------------------------------------------------------------------------------*/

VertSelector.setSelection #{1..10} isolate:true
--VertSelector.setSelection #{1..10}

/*------------------------------------------------------------------------------
	ISLANDS
--------------------------------------------------------------------------------*/

--/* LOWEST VERTS - SELECT */
--VertSelector.findIslandsPerLayer(0.05)


/* SINGLE VERTICAL PER ISLAND - SELECT */
--VertSelector.selectSingleVertPerFaceIsland() -- LOW RESOLUTION FOR TEST THIS WORKS BETTER. VertSelector.resolution = 3


/*------------------------------------------------------------------------------
	CONVEXITY
--------------------------------------------------------------------------------*/
--timer_CONVEXITY = timeStamp()

/* GET CONVEX VERTICES - try find best points for 3D print support  */
--VertSelector.getConvexVerts()

--/* GET CONCAVE VERTICES */
--VertSelector.getConvexVerts mode:#CONCAVE

--/* GET MIXED VERTICES */
--VertSelector.getConvexVerts mode:#MIXED

/* GET CORNER VERTICES */
--VertSelector.getConvexVerts mode:#CORNER
--format "\n getConvexVerts: % ms\n" (( timeStamp()) - timer_CONVEXITY)


/*------------------------------------------------------------------------------
	GRID
--------------------------------------------------------------------------------*/

/*  */
-- VertSelector.selectMiddleVertsInGrid resolution:5


/* CHECKBOARD PATTERN - good method for testing of grid  */
--VertSelector.selectChecker --  mode:#2D is default

--VertSelector.selectChecker mode:#3D

/*------------------------------------------------------------------------------

	--TEST OF GETTING CELLS OF VERTS BY POSITION

------------------------------------------------------------------------------*/
--
--VertSelector.getVertsInGrid()
--
--format "points_grid: %\n"	VertSelector.points_grid
--format "CELLS ON X: %\n"	VertSelector.points_grid.count
--format "CELLS ON Y: %\n"	VertSelector.points_grid[1].count
--
--points_grid = VertSelector.points_grid
--
--
--format "points_grid[1][1]: %\n" points_grid[1][1]
--format "points_grid[1][2]: %\n" points_grid[1][2]
--
----format "points_grid[2][1]: %\n" points_grid[2][1]
----format "points_grid[2][2]: %\n" points_grid[2][2]
--
--
--
--_mod = modPanel.getCurrentObject()
--
--
--subObjectLevel = 1
--_mod.SetSelection #Vertex (points_grid[1][1])
--_mod.SetSelection #Vertex (points_grid[ 1 ][ 2 ])
--_mod.SetSelection #Vertex (points_grid[ 2 ][ 2 ])
--_mod.SetSelection #Vertex (points_grid[ 3 ][ 2 ])
