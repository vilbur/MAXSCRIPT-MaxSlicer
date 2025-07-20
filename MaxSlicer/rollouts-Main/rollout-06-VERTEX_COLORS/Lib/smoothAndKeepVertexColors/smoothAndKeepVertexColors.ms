

/** Smooth and keep vertex colors
 */
function smoothAndKeepVertexColors obj =
(
	--format "\n"; print ".smoothAndKeepVertexColors()"
	
	/** Flattern dictionary
	 */
	function getColoredVerts verts_by_colors =
	(
		exclude_vertex_colors = #( white as string , black as string )
		
		format "\n"; print "SourceObject_v.getColoredVerts()"
		verts = #{}
	
		--for key in verts_by_colors.keys where key != white as string do verts += verts_by_colors[key]
		for key in verts_by_colors.keys do
			if findItem exclude_vertex_colors key == 0 do verts += verts_by_colors[key]
	
		verts --return
	)
		
	verts = #{}
	
	epoly	= Edit_Poly()
	msmooth	= meshsmooth oldMapping:true ignoreSel:false
	
	VertexColors = VertexColors_v(obj)
	
	verts_by_colors = VertexColors.getVertsAndColors()

	colored_verts = getColoredVerts (verts_by_colors)

	/* SMOOTH OBJECT */ 
	modPanel.addModToSelection ( msmooth ) ui:on
	
	/* COLLPASE STACK TO */ 
	smooth_mod_index	= modPanel.getModifierIndex obj msmooth
	
	maxOps.CollapseNodeTo obj (smooth_mod_index ) off
	
	
	VertexColors_smooth = VertexColors_v(obj)
	
	verts_by_colors_smooth = VertexColors_smooth.getVertsAndColors()

	
	for key in verts_by_colors_smooth.keys do
		if findItem verts_by_colors.keys key > 0 do verts += verts_by_colors_smooth[key]
	
	--format "verts: %\n" verts
	
	subObjectLevel = 1
	
	verts_all = #{1..(getNumVerts obj.baseobject.mesh)}
	
	
	polyop.setVertColor obj.baseobject 0 (verts_all - verts) white
)

