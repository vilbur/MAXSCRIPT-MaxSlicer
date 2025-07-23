/** Smooth and keep vertex colors
 */
function smoothAndKeepVertexColors obj =
(
	--format "\n"; print ".smoothAndKeepVertexColors()"
	
	/** Flattern dictionary
	 */
	function getColoredVerts source_vertex_colors =
	(
		exclude_vertex_colors = #( white as string , black as string )
		
		verts_colored = #{}
	
		--for key in source_vertex_colors.keys where key != white as string do verts_colored += source_vertex_colors[key]
		for key in source_vertex_colors.keys do
			if findItem exclude_vertex_colors key == 0 do verts_colored += source_vertex_colors[key]
	
		verts_colored --return
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
	if not classof obj.baseobject == Editable_Poly then
	(
		messageBox ("Object "+obj.name+" is not Editable Poly") title:"smoothAndKeepVertexColors"
		return false
	)

	/* VARIABLES */ 
	msmooth = undefined

	verts_colored = #{}
	verts_black = #{}
	verts_white = #{}
	
	VertexColors = VertexColors_v(obj)
		
	source_vertex_colors = VertexColors.getVertsAndColors()
	
	colored_verts = getColoredVerts (source_vertex_colors)
	
	/* SEARCH FOR MESHMOOTH */ 
	for i = 1 to obj.modifiers.count while msmooth == undefined where classOf obj.modifiers[i] == meshsmooth do
		msmooth = obj.modifiers[i]
		
	/* ADD MESHMOOTH - if not found*/ 
	if msmooth == undefined then
	(
		select obj
		
		max modify mode
		
		current_mod = modPanel.getCurrentObject()
		format "current_mod: %\n" current_mod
		current_mod.GetSelection #Vertex
		
		select_faces = if classOf current_mod != Editable_Poly or classOf current_mod != Edit_Poly then
		(
			/* ADD EDIT POLY MODIFIER */ 
			modPanel.addModToSelection ( Edit_Poly  name:"EPOLY_SMOOTH_VERTEX_COLORS" ) --ui:on
		
			obj.modifiers[#EPOLY_SMOOTH_VERTEX_COLORS].getSelection #FACE
		)
		else
			current_mod.GetSelection #FACE
		
		/* APPLY ONLY ON SELECTED FACES */ 
		subObjectLevel = if not select_faces.isEmpty then 4 else 0 -- and ignoreSel:false MUST BE SET TO SMOOTH ONLY SELECTION
		
		/* SMOOTH OBJECT */ 
		msmooth	= meshsmooth name:"MESHSMOOTH_VERTEX_COLORS" oldMapping:true ignoreSel:select_faces.isEmpty
		
		modPanel.addModToSelection ( msmooth ) ui:on
	
		--obj.modifiers[#MESHSMOOTH_VERTEX_COLORS].ignoreSel = select_faces.isEmpty -- smooth only selected
	)
	
	
	/* COLLPASE STACK TO MESHMOOTH */ 
	smooth_mod_index	= modPanel.getModifierIndex obj msmooth
	
	maxOps.CollapseNodeTo obj (smooth_mod_index ) off
	
	verts_all_smoothed = #{1..(getNumVerts obj.baseobject.mesh)}

	VertexColors_smooth = VertexColors_v(obj)

	/* GET COLORS OF SMOOTHED OBJECT */ 
	verts_by_colors_smooth = VertexColors_smooth.getVertsAndColors()
		
	
	/*------------------------------------------------------------------------------
		RESET VERTEX COLORS
	--------------------------------------------------------------------------------*/
	for clr in verts_by_colors_smooth.keys do
	(
		format "COLOR: % is gray: %\n" clr (isColorNearGrey ( _color = execute clr ) )
		if isColorNearGrey ( _color = execute clr ) then
			case of
			(
				/* SET GREY TO BLACK */ 
				(_color.r <= 128): verts_black += verts_by_colors_smooth[clr]
				/* SET GREY TO WHITE */ 
				(_color.r >  128): verts_white += verts_by_colors_smooth[clr]
			)
			
		/* APPLY COLOR WHICH IS FOUND ON INSMOOTHED OBJECT - gradient colors are wanished to black\white */ 
		else if findItem source_vertex_colors.keys clr > 0 then
			verts_colored += verts_by_colors_smooth[clr]
	)
			
	/*------------------------------------------------------------------------------
		SET BLACK AND WHITE VERTS
	--------------------------------------------------------------------------------*/
	
	/* GET BLACK VERTS */ 
	black_faces	= polyop.getFacesUsingVert obj verts_black
	black_verts	= polyop.getVertsUsingFace obj black_faces
	black_verts_inv	= polyop.getVertsUsingFace obj -black_faces
	
	black_verts_outline = black_verts * black_verts_inv

	/* SET VERTEX COLOR */ 
	polyop.setVertColor obj.baseobject 0 (verts_all_smoothed - verts_colored) white
	polyop.setVertColor obj.baseobject 0 (black_verts - black_verts_outline) black
	--polyop.setVertColor obj.baseobject 0 (black_verts) black
	
	
)

