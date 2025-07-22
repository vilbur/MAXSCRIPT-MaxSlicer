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
		
		verts = #{}
	
		--for key in verts_by_colors.keys where key != white as string do verts += verts_by_colors[key]
		for key in verts_by_colors.keys do
			if findItem exclude_vertex_colors key == 0 do verts += verts_by_colors[key]
	
		verts --return
	)
	/*
	  Function to test if a color is near to grey
	*/
	function isColorNearGrey clr tolerance:5 = 
	(
		diff_rg = abs( clr.r - clr.g )
		diff_gb = abs( clr.g - clr.b )
		diff_rb = abs( clr.r - clr.b )
	
		-- return true if all channel differences are below tolerance --	
		(diff_rg < tolerance) and (diff_gb < tolerance) and (diff_rb < tolerance)
	)
	
	
	/*------------------------------------------------------------------------------
		
	--------------------------------------------------------------------------------*/
	
	select obj
	
	verts = #{}
	verts_black = #{}
	verts_white = #{}
	
	
	epoly	= Edit_Poly  name:"EPOLY_SMOOTH_VERTEX_COLORS"
	msmooth	= meshsmooth name:"MESHSMOOTH_VERTEX_COLORS" oldMapping:true ignoreSel:false
	
	VertexColors = VertexColors_v(obj)
	
	verts_by_colors = VertexColors.getVertsAndColors()
	
	colored_verts = getColoredVerts (verts_by_colors)
	
	/* ADD EDIT POLY MODIFIER */ 
	modPanel.addModToSelection ( epoly ) --ui:on

	select_faces = obj.modifiers[#EPOLY_SMOOTH_VERTEX_COLORS].getSelection #FACE

	/* SMOOTH OBJECT */ 
	modPanel.addModToSelection ( msmooth ) ui:on
	
	obj.modifiers[#MESHSMOOTH_VERTEX_COLORS].ignoreSel = not select_faces.isEmpty -- smooth only selected
	
	
	/* COLLPASE STACK TO MESHMOOTH */ 
	smooth_mod_index	= modPanel.getModifierIndex obj msmooth
	
	maxOps.CollapseNodeTo obj (smooth_mod_index ) off
	
	verts_all_smoothed = #{1..(getNumVerts obj.baseobject.mesh)}

	VertexColors_smooth = VertexColors_v(obj)

	/* GET COLORS OF SMOOTHED OBJECT */ 
	verts_by_colors_smooth = VertexColors_smooth.getVertsAndColors()
		
	
	/* MODIFY VERTEX COLORS */ 
	for clr in verts_by_colors_smooth.keys do
		if isColorNearGrey ( _color = execute clr ) then
			case of
			(
				/* SET GREY TO BLACK */ 
				(_color.r < 128): verts_black += verts_by_colors_smooth[clr]
				/* SET GREY TO WHITE */ 
				(_color.r > 128): verts_white += verts_by_colors_smooth[clr]
			)
			
		/* APPLY COLOR WHICH IS FOUND ON INSMOOTHED OBJECT - gradient colors are wanished to black\white */ 
		else if findItem verts_by_colors.keys clr > 0 then
			verts += verts_by_colors_smooth[clr]
			
	
	
	/*------------------------------------------------------------------------------
		GET BLACK VERTS
	--------------------------------------------------------------------------------*/
	black_faces	= polyop.getFacesUsingVert obj verts_black
	black_verts	= polyop.getVertsUsingFace obj black_faces
	black_verts_inv	= polyop.getVertsUsingFace obj -black_faces
	
	black_verts_outline = black_verts * black_verts_inv

	/*------------------------------------------------------------------------------
		SET VERTEX COLORS
	--------------------------------------------------------------------------------*/
	polyop.setVertColor obj.baseobject 0 (verts_all_smoothed - verts) white
	polyop.setVertColor obj.baseobject 0 (black_verts - black_verts_outline) black
	
	
)

