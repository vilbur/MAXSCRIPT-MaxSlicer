clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../EpolyVertsSelector.ms" )	--"./../EpolyVertsSelector.ms"


/**
  */
function createTestMesh add_edit_poly:false =
(
	format "\n"; print "MeshVertexGetterTest.ms.createTestMesh()"
	delete objects

	obj = Plane width:20 length:20 widthsegs:3 lengthsegs:3

	select obj

	macros.run "Modifier Stack" "Convert_to_Poly"

	if add_edit_poly then
		modPanel.addModToSelection (Edit_Poly ()) ui:on
	
)


if selection.count == 0 then
(
	createTestMesh()

	createTestMesh add_edit_poly:true
	
)

verts = #{1..4}

obj	= selection[1]

EpolyVertsSelector = EpolyVertsSelector_v( obj )

/* UNHIDE ALL */ 
EpolyVertsSelector.unhideVerts #ALL

/* HIDE ALL */ 
EpolyVertsSelector.hideVerts #ALL

/* GET HIDDEN VERTS */ 
hidden_verts = EpolyVertsSelector.getHiddenVerts()
format "hidden_verts: %\n" hidden_verts

/* UNHIDE */ 
EpolyVertsSelector.unhideVerts #{1..8}


/* ISOLATE */ 
EpolyVertsSelector.isolateVerts #{1..4}

/* SELECT */ 
EpolyVertsSelector.setSelection #{1..2}
