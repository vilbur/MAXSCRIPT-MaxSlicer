clearListener(); print("Cleared in:\n"+getSourceFileName())



/*
  Function to find vertices that are inside the mesh volume of their own object
*/
function getInternalVertsOfObject source_obj =
(
	--mesh_obj = snapshotAsMesh source_obj
	mesh_obj = convertTo (copy source_obj) TriMeshGeometry
	--mesh_obj = convertTo (copy source_obj) PolyMeshObject
	

	rm = RayMeshGridIntersect()
	rm.Initialize 10
	--rm.Initialize 1000
	rm.addNode  mesh_obj
	rm.buildGrid()

	inside_verts = #{}

	num_verts = getNumVerts mesh_obj

	for i = 1 to num_verts do
	(
		pos = getVert mesh_obj i


		--dir = z_axis -- The arbitrary direction for our ray
		--pos.z  += 0.0001
		dir = getNormal mesh_obj i
		
		--pos = pos + (dir * 0.001 )
		pos += dir * 0.001
		
		--dir = -z_axis -- The arbitrary direction for our ray
		--pos.z  -= 0.0001
		--dir = x_axis -- The arbitrary direction for our ray

		--_ray = Ray pos dir
		hits_count = rm.intersectRay pos dir true
		
		
		if hits_count > 0 then
		(
		--format "\n---------------------------------------------\n"
		--format "i: %\n" i
		--format "hits_count: %\n" hits_count
			
			theIndex = rm.getClosestHit () --get the index of the closest hit by the ray
		
			theFace = rm.getHitFace theIndex --get the face index corresponding to that indexed hit
			
			theNormal = -(getFaceNormal mesh_obj theFace ) --get the normal of the vertex, reverse direction
		
			--format "theNormal: %\n" theNormal
		)
		
		
		--point pos:pos
		--format "hits_count: %\n" hits_count
		
		-- if vertex is strictly inside the mesh, number of hits should be odd
		if mod hits_count 2 == 1 then
		(
			--format "\n---------------------------------------------\n"
			--format "i: %\n" i
			--format "hits_count: %\n" hits_count
			
			inside_verts [i] = true
		)
			
	)
	
	delete mesh_obj
	--free mesh_obj
	inside_verts -- return
)

if selection.count == 1 then
(
	inside_verts = getInternalVertsOfObject selection[1] 
	format "inside_verts.numberSet: %\n" inside_verts.numberSet
	format "Verts inside mesh: \n%\n" inside_verts

	subObjectLevel = 1
	selection[1].EditablePoly.SetSelection #Vertex inside_verts
	
)
