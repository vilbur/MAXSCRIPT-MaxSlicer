clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../ConvexVertFinder.ms" )	--"./../ConvexVertFinder.ms"

test_scene = "convex-verts-test.max"

if maxFileName != test_scene then
	loadMaxFile ( getFilenamePath(getSourceFileName()) + "/" + test_scene ) quiet:true


obj = if selection.count > 0 then  selection[1] else objects[1]


ConvexVertFinder = ConvexVertFinder_v( obj )

/*------------------------------------------------------------------------------
	OPTIONS - which type of verts will be selected
--------------------------------------------------------------------------------*/
mode = #CONVEX
--mode = #CONCAVE
--mode = #MIXED
--mode = #CORNER


/*------------------------------------------------------------------------------
	RUN TEST
--------------------------------------------------------------------------------*/

verts     = #{1..( getNumVerts obj.mesh)}

--verts_by_type = ConvexVertFinder.getConvexityTypes (verts)
verts_by_type = ConvexVertFinder.getConvexityTypesByPolyTools (verts)

format "verts_by_type: %\n" verts_by_type

--verts_by_type = for i = 1 to verts_types.count where verts_types[i] == mode collect (verts as Array )[i]



/*------------------------------------------------------------------------------
	SELECT RESULT
--------------------------------------------------------------------------------*/



max modify mode
subObjectLevel = 1
obj.EditablePoly.SetSelection #Vertex #{}
obj.EditablePoly.SetSelection #Vertex verts_by_type[#CONVEX]
--obj.EditablePoly.SetSelection #Vertex verts_by_type[#CONCAVE]
--obj.EditablePoly.SetSelection #Vertex verts_by_type[#MIXED]
