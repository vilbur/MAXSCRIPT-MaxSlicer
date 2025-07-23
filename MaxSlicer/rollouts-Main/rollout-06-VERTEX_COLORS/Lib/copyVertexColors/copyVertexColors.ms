/** Copy vertex colors
 */
function copyVertexColors obj_source target_objects =
(
	format "\n"; print ".copyVertexColors()"
	format "VERTEX COUNT: %\n" (getNumVerts obj_source.baseobject.mesh)
	
	if classOf target_objects != Array then target_objects = #(target_objects)
	
	VertexColors_source = VertexColors_v(obj_source)
	
	
	verts_by_colors = VertexColors_source.getVertsAndColors()
	--format "verts_by_colors.keys: %\n" verts_by_colors.keys
	format "Colors count: %\n" verts_by_colors.keys.count
	
	for target_object in target_objects do
	(
		format "COPY VERTEX COLORS TO: %\n" target_object.name
		for vertex_color in verts_by_colors.keys do
			polyop.setVertColor target_object.baseobject 0 verts_by_colors[vertex_color]  ( execute vertex_color )
	)
)
