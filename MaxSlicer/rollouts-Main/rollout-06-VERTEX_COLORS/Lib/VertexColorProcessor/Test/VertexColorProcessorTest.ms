clearListener(); print("Cleared in:\n"+getSourceFileName())
filein( getFilenamePath(getSourceFileName()) + "/../VertexColorProcessor.ms" )	--"./../VertexColorProcessor.ms"



/**
  */
function createSourceMesh segments:8 =
(
	format "\n"; print "MeshVertexGetterTest.ms.createSourceMesh()"
	delete objects

	--if  obj == unsupplied then
	obj = Sphere radius:15 pos:[0,0, 50 ] segments:16 isSelected:on --showVertexColors:true	vertexColorsShaded:true -- diameter 3 cm

	/* VERTEX COLORS */
	obj.showVertexColors	= true
	obj.vertexColorsShaded	= false

	obj --return
)



/*--------------------------------------------------------------------
	CREATE TEST OBJECTS
--------------------------------------------------------------------------------*/
delete objects

--obj = if selection.count == 0 then
obj = 
(
	
	--createSourceMesh()
	--createSourceMesh segments:16
	--createSourceMesh segments:16 add_Edit_Poly:true
	createSourceMesh segments:16 add_vertex_paint:true
	--createSourceMesh segments:64
	--createSourceMesh segments:128
	--createSourceMesh segments:1024

	--createSourceMesh segments:64 vertex_selection:#{1..32} vertex_color:red
	--createSourceMesh segments:8 vertex_selection:#{1..8} vertex_color:red
)
--else
	--selection[1]


/*==============================================================================
	CONFIGURE OBJECT
================================================================================*/

--convertTo obj PolyMeshObject

/*------------------------------------------------------------------------------
	TEST DIFFERENT MODIFIERS TO STACK
--------------------------------------------------------------------------------*/

--addModifier obj (meshsmooth())
--addModifier obj (Edit_Poly())
--addModifier obj (PaintLayerMod())
--addModifier obj (Edit_Poly())
--addModifier obj (Poly_Select())


/*==============================================================================

		RUN VERTEX COLORS TEST

================================================================================*/

ColorProcessor = VertexColorProcessor_v(obj)
--
ColorProcessor.setVertexColor #{1..3} red
ColorProcessor.setVertexColor #{4..6} green
--ColorProcessor.setVertexColor #{7..9} blue
--
--
--/* SELECT VERTS */
ColorProcessor.byColor #SELECT #( red, green )
--ColorProcessor.byColor #SELECT blue
--ColorProcessor.byVerts #SELECT #{1,4,7}


/* HIDE VERTS */
--ColorProcessor.byColor #HIDE white
--ColorProcessor.byColor #HIDE #( red, green )
--ColorProcessor.byVerts #HIDE #{1,4,7}



/* UNHIDE VERTS */
--ColorProcessor.byColor #UNHIDE white
--ColorProcessor.byColor #UNHIDE #( red, blue )
--ColorProcessor.byVerts #UNHIDE #{1,4,7}




/* ISOLATE VERTS */
--ColorProcessor.byColor #ISOLATE white
--ColorProcessor.byColor #ISOLATE #( red, blue )
--ColorProcessor.byVerts #ISOLATE #{1,4,7}
