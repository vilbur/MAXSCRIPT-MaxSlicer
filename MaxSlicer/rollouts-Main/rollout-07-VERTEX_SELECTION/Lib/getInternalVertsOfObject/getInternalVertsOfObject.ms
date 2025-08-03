--clearListener(); print("Cleared in:\n"+getSourceFileName())

/*
  Function to find vertices that are inside the mesh volume of their own object
*/
function getInternalVertsOfObject source_obj target_objects verts: =
(
	format "\n"; print "getInternalVertsOfObject()"
	
	if classOf target_objects != Array then
		target_objects = #(target_objects)
	
	source_obj_mesh = convertTo (copy source_obj) TriMeshGeometry

	if verts == unsupplied then 
		verts = #{1..(getNumVerts source_obj_mesh)}


	inside_verts = #{}
	
	/*------------------------------------------------------------------------------
		TEST EACH TARGET OBJECT
	--------------------------------------------------------------------------------*/
	for target_object in target_objects do 
	(
		rm = RayMeshGridIntersect()
		rm.Initialize 10
		--is_inside = undefined
		
		target_object_mesh = if source_obj != target_object then
				convertTo ( copy target_object ) TriMeshGeometry
			else
				source_obj_mesh
			
		
		rm.addNode  target_object_mesh
		rm.buildGrid()
		
		for v in verts where not inside_verts[v] do 
		(
			if mod v 1000 == 0 then
				format "vert: % of: %\n" v verts.count
			
			pos = getVert source_obj_mesh v

			dir = getNormal source_obj_mesh v

			pos += dir * 0.001
			
			hits_count = rm.intersectRay pos dir true

			if mod hits_count 2 == 1 then
				inside_verts[v] = true
		)
		
		if source_obj_mesh != target_object_mesh then
			delete target_object_mesh
	
	)
	
	
	delete source_obj_mesh

	
	inside_verts -- return
)


/* TEST SINGLE OBJECT
	
	if selection.count > 0 then
	(
		obj	= selection[1]
		inside_verts = getInternalVertsOfObject obj selection
		format "inside_verts.numberSet: %\n" inside_verts.numberSet
		format "Verts inside mesh: \n%\n" inside_verts
	
		subObjectLevel = 1
	
		obj.EditablePoly.SetSelection #Vertex inside_verts
		
	)

*/

/* TEST MULTIPLE OBJECTS

	
	if selection.count > 0 then
	(
		_selection = for o in selection collect o
		inside_verts_all = #()
		
		
		for obj in _selection do 
		(
			inside_verts = getInternalVertsOfObject obj _selection
			
			append inside_verts_all inside_verts
		)
			select _selection[1]
	
		if _selection.count == 1 then
		(
			subObjectLevel = 1
		
			_selection[1].EditablePoly.SetSelection #Vertex inside_verts_all[1]
		)
		else
		(
			select _selection
		
			modPanel.addModToSelection (Edit_Poly ()) ui:on
			
			for i = 1 to _selection.count do
			(
				format "inside_verts_all[i]: %\n" inside_verts_all[i]
				
				select _selection[i]
			
				subObjectLevel = 1
	
				_selection[i].modifiers[#Edit_Poly].select #Vertex #{} node:_selection[i]
				_selection[i].modifiers[#Edit_Poly].select #Vertex inside_verts_all[i] node:_selection[i]
			)
	
			select _selection
	
			subObjectLevel = 1
		)
	)
		
*/








