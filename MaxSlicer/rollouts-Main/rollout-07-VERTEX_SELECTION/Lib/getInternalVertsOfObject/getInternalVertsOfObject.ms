
/*
  Function to find vertices that are inside the mesh volume of their own object
*/
function getInternalVertsOfObject source_obj =
(
	mesh_obj = convertTo (copy source_obj) TriMeshGeometry

	rm = RayMeshGridIntersect()
	rm.Initialize 10
	rm.addNode  mesh_obj
	rm.buildGrid()

	inside_verts = #{}

	num_verts = getNumVerts mesh_obj

	for i = 1 to num_verts do
	(
		pos = getVert mesh_obj i

		dir = getNormal mesh_obj i

		pos += dir * 0.001
		
		hits_count = rm.intersectRay pos dir true

		if mod hits_count 2 == 1 then
			inside_verts [i] = true
	)
	
	delete mesh_obj

	inside_verts -- return
)


/* TEST

if selection.count == 1 then
(
	obj	= selection[1]
	inside_verts = getInternalVertsOfObject obj
	format "inside_verts.numberSet: %\n" inside_verts.numberSet
	format "Verts inside mesh: \n%\n" inside_verts

	subObjectLevel = 1

	obj.EditablePoly.SetSelection #Vertex inside_verts
	
)

*/ 