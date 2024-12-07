clearListener(); print("Cleared in:\n"+getSourceFileName())

--filein( getFilenamePath(getSourceFileName()) + "/../meshDataGetter.ms" )	--"./../meshDataGetter.ms"



/** Prepre ene
 */
function prepareScene vertex_selection:false =
(
	--format "\n"; print ".prepreEne()"
	delete objects

	obj	= Teapot radius:10 segs:64  pos:[ 0, 0, 50 ]

	select obj

	macros.run "Modifier Stack" "Convert_to_Poly"
)


prepareScene()
--prepareScene vertex_selection:true


obj = objects[1]



timer_polyop = timeStamp()
face_normals = for i = 1 to polyop.getNumFaces obj  collect polyop.getFaceNormal obj i
format "face_normals: %\n" face_normals
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
--
--
--timer_polyop = timeStamp()
--verts_normals = for i = 1 to meshop.getNumVerts obj.mesh  collect getNormal obj.mesh i
--
--format "verts_normals: %\n" verts_normals.count
--
--format "\n polyop obj.mesh: % ms\n" (( timeStamp()) - timer_polyop)
--
