filein( getFilenamePath(getSourceFileName()) + "/../VertexColorCopyPaster.ms" )	--"./../VertexColorCopyPaster.ms"

/**
  */
function createSourceMesh segments:8 add_modifiers:false break_map_faces:false =
(
	format "\n"; print "MeshVertexGetterTest.ms.createSourceMesh()"
	delete objects

	--if  obj == unsupplied then
	obj = Sphere radius:15 pos:[0,0, 50 ] segments:segments isSelected:on --showVertexColors:true	vertexColorsShaded:true -- diameter 3 cm

	macros.run "Modifier Stack" "Convert_to_Poly"

	vertex_count = getNumVerts obj.mesh

	--all_verts = #{1..(vertex_count)}

	--Rotate obj ( AngleAxis 180 [1,0,0]) -- rotate object upside down

	if break_map_faces then
		for face_id = 1 to polyop.getNumFaces obj.baseobject do
		(
			polyop.setFaceColor obj.baseobject 0 face_id black
			polyop.setFaceColor obj.baseobject 0 face_id white

		)

	/* VERTEX COLORS */
	obj.showVertexColors	= true
	obj.vertexColorsShaded	= true

	--if add_modifiers then
	--(
		--addModifier obj (meshsmooth())
	
		addModifier obj (Edit_Poly())
	--)


	obj --return
)
/** Set verts colors
 */
function setVertsColors obj =
(
	verts_colors = Dictionary #string

	--verts_colors[ "red" as string ]	= #{1..2}
	--verts_colors[ "green" as string ]	= #{3..4}

	verts_colors[ "red" as string ]	= #{1}
	verts_colors[ "green" as string ]	= #{4}

	for color_verts in verts_colors do
		polyop.setVertColor obj.baseobject 0 color_verts.value ( execute color_verts.key )

	--channelInfo.Dialog ()
	--channelInfo.Update ()
)
/*--------------------------------------------------------------------
  
	CREATE TEST OBJECTS
	
--------------------------------------------------------------------------------*/
--global obj

--obj = if selection.count != 0 then selection[1] else
obj =
(
	--createSourceMesh()
	createSourceMesh segments:4
	--createSourceMesh segments:4 break_map_faces:true
	----createSourceMesh segments:16 add_modifiers:true
	--createSourceMesh segments:16
	--createSourceMesh segments:64
	--createSourceMesh segments:128
	--createSourceMesh segments:128 break_map_faces:true
	--createSourceMesh segments:256
	--createSourceMesh segments:512
	--createSourceMesh segments:1024
	--
	--createSourceMesh segments:64 vertex_selection:#{1..32} vertex_color:red
	--createSourceMesh segments:8 vertex_selection:#{1..8} vertex_color:red
)

setVertsColors(obj)


--VertexColorCopyPaster = VertexColorCopyPaster_v(obj)