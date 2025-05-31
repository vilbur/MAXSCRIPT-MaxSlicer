clearListener(); print("Cleared in:\n"+getSourceFileName())

--filein( getFilenamePath(getSourceFileName()) + "/../vertSelector.ms" )	--"./../vertSelector.ms"



/** Prepre ene
 */
function prepareScene vertex_selection:false =
(
	--format "\n"; print ".prepreEne()"
	delete objects

	--obj	= Sphere()
	--obj	= Teapot radius:10 segs:8  pos:[ 0, 0, 50 ]
	obj	= Teapot radius:10 segs:64  pos:[ 0, 0, 50 ]

	--obj = Plane width:20 length:20 pos:[ 50, 20, 50 ] widthsegs:4 lengthsegs:4

	--obj = Plane width:100 length:100 pos:[ 50, 20, 50 ] widthsegs:100 lengthsegs:100
	--obj = Plane width:50 length:50 pos:[ 50, 20, 50 ] widthsegs:50 lengthsegs:50
	--obj = Plane width:60 length:30 pos:[ 50, 20, 50 ] widthsegs:10 lengthsegs:10
	--obj = Plane width:40 length:30 pos:[ 50, 20, 50 ] widthsegs:40 lengthsegs:30


	--obj = Plane width:30 length:30 pos:[ 50, 20, 50 ] widthsegs:10 lengthsegs:10
	--obj = Plane width:20 length:20 pos:[ 50, 20, 50 ] widthsegs:4 lengthsegs:4

	select obj

	--modPanel.addModToSelection (Noisemodifier scale:5 strength:[0,0,10] ) ui:on

	--rotate obj ( angleaxis 180 [1,0,0])

	macros.run "Modifier Stack" "Convert_to_Poly"

	--if vertex_selection then
	--(
	--	subObjectLevel = 1
	--
	--	try( obj.EditablePoly.SetSelection #Vertex #{ 1..(getNumVerts obj.mesh/2)} )catch()
	--)

	--obj = selection[1]
)


prepareScene()
--prepareScene vertex_selection:true


obj = objects[1]



timer_polyop = timeStamp()
face_normals = for i = 1 to polyop.getNumFaces obj  collect polyop.getFaceNormal obj i
format "face_normals: %\n" face_normals.count
format "\n polyop: % ms\n" (( timeStamp()) - timer_polyop)


--/* THIS IS VERY SLOW
--
--*/
--timer_polyop = timeStamp()
--face_normals = for i = 1 to getNumFaces obj.mesh  collect getFaceNormal obj.mesh i
--format "face_normals: %\n" face_normals
--format "\n polyop obj.mesh: % ms\n" (( timeStamp()) - timer_polyop)


--
--timer_polyop = timeStamp()
--verts_normals = for i = 1 to meshop.getNumVerts obj.mesh  collect getNormal obj.mesh i
--
--format "verts_normals: %\n" verts_normals.count
--
--format "\n polyop obj.mesh: % ms\n" (( timeStamp()) - timer_polyop)
--
