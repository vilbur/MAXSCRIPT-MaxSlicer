clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../VertexLayers.ms" )	--"./../VertexLayers.ms"



/**
  */
function createSourceMesh segments:8 radius:20 vertex_selection:#{} test_shifted_pivot:false obj:#PLANE vertex_color: =
(
	--format "\n"; print "MeshVertexGetterTest.ms.createSourceMesh()"
	delete objects

	segment_size = 10

	--obj = Plane length:( segment_size * segments ) width:( segment_size * segments ) pos:[ 0, 0, 300 ] widthsegs:segments lengthsegs:segments backfacecull: off

	--obj = Sphere radius:radius pos:[0,0, 50 ] segments:segments --showVertexColors:true	vertexColorsShaded:true -- diameter 3 cm

	obj = Plane width:20 length:20 pos:[ 50, 20, 50 ] widthsegs:segments lengthsegs:segments

	--obj = Plane width:30 length:30 pos:[ 50, 20, 50 ] widthsegs:5 lengthsegs:5
	--obj = Plane width:30 length:30 pos:[ 50, 20, 50 ] widthsegs:10 lengthsegs:10
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

	select obj

	--noise_val = radius / 20
	--noise_val = radius / 10
	noise_val = radius / 4



	if classOf obj == plane then
		Rotate obj ( AngleAxis 180 [1,0,0]) -- rotate object upside down

	modPanel.addModToSelection (Noisemodifier scale:5 strength:[ noise_val, noise_val, noise_val] ) ui:on

	--modPanel.addModToSelection (Wave amplitude1:0.5 amplitude2:0 wavelength:5 ) ui:on


	--modPanel.addModToSelection (smooth ()) ui:on
	--modPanel.addModToSelection ( meshsmooth ()) ui:on


	macros.run "Modifier Stack" "Convert_to_Poly"

	obj.showVertexColors	= true
	obj.vertexColorsShaded	= true

	--if vertex_selection.count > 0 then
	--(
	--	subObjectLevel = 1
	--
	--	if vertex_color != unsupplied then
	--		polyop.setVertColor obj 0 vertex_selection vertex_color
	--
	--
	--	--polyop.setVertColor obj 0 vertex_selection.count red -- color last vertex in red color
	--
	--	obj.EditablePoly.SetSelection #Vertex vertex_selection
	--)

	--modPanel.addModToSelection (Edit_Poly ()) ui:on
)



/*--------------------------------------------------------------------
	PREPARE TEST OBJECTS
--------------------------------------------------------------------------------*/

if selection.count == 0 then
(
	--createSourceMesh()


	--createSourceMesh segments:4
	--createSourceMesh segments:8
	--createSourceMesh vertex_color:orange segments:16
	--createSourceMesh vertex_color:orange segments:32
	--createSourceMesh vertex_color:orange segments:64

	--createSourceMesh vertex_color:orange segments:128
	--createSourceMesh vertex_color:orange segments:256
	createSourceMesh vertex_color:orange segments:512
	--createSourceMesh vertex_color:orange segments:1024

	--createSourceMesh vertex_selection:#{1..100}

	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:16
	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:32
	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:64
	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:128
	--createSourceMesh vertex_selection:#{1..100}  vertex_color:orange segments:256
)


VertexLayers 	= VertexLayers_v( selection[1]  )

analyzeLayers = timeStamp()

VertexLayers.findVerts()

--format "\n analyzeLayers: % ms\n" (( timeStamp()) - analyzeLayers)
format "\n analyzeLayers: % seconds\n" ((( timeStamp()) - analyzeLayers) / 1000.0)
