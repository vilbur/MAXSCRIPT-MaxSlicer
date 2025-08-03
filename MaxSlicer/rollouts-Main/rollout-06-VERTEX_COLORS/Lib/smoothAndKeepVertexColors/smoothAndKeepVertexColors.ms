/** Smooth and keep vertex colors
 */
function smoothAndKeepVertexColors obj quiet:false =
(
	format "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
	
	format "\n"; print ".smoothAndKeepVertexColors()"
	format "obj: %\n" obj
	
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
	
	
	
	/** Get source vertex colors
	 */
	function getSourceVertexColors obj =
	(
		format "\n"; print ".getSourceVertexColors()"
		format "msmooth: %\n" msmooth
		format "\n"
		source_vertex_colors = undefined
		
		if not (classof obj == Editable_Poly and obj.modifiers.count == 0 ) then
		(
			snap = copy obj
			snap.name = "snap"
			last_meshmooth = 0
			
			
			/* SEARCH FOR MESHMOOTH MODIFIER */ 		
			for i = 1 to snap.modifiers.count where classOf snap.modifiers[i] == meshsmooth do 
				last_meshmooth = i
			
			/* DELETE ALL MODIFIER ABOVE MESHMOOTH MODIFIER */ 		
			if last_meshmooth > 0 then
				for i = 1 to last_meshmooth do
					deleteModifier snap 1
			
			/* COLLAPSE OBJECT */ 
			convertTo snap PolyMeshObject
			
			/* GET VERTEX COLORS */ 
			VertexColors = VertexColors_v(snap)
				
			source_vertex_colors = VertexColors.getVertsAndColors()
			
			delete snap
		)
		else
			source_vertex_colors = (VertexColors_v(obj)).getVertsAndColors()
		
		source_vertex_colors --return
	)
	
	/*------------------------------------------------------------------------------
		
	--------------------------------------------------------------------------------*/
	if not classof obj.baseobject == Editable_Poly then
	(
		if not quiet then
			messageBox ("Object "+obj.name+" is not Editable Poly") title:"smoothAndKeepVertexColors"
		
		return false
	)

	/* VARIABLES */ 
	msmooth = undefined

	verts_colored = #{}
	verts_black = #{}
	verts_white = #{}
	
	--snap = copy obj.baseobject

	source_vertex_colors = getSourceVertexColors(obj) 
	
	/* SEARCH FOR MESHMOOTH */ 
	for i = 1 to obj.modifiers.count while msmooth == undefined where classOf obj.modifiers[i] == meshsmooth do
	(
		msmooth = obj.modifiers[i]
		
		/*----------------------------------------------------------------------------------------------------------------------------
			IMPORTANT TO USE OLD STYLE MAPPING - it makes everything works - it will not wanish original vertex color to gradient
		------------------------------------------------------------------------------------------------------------------------------*/
		
		msmooth.oldMapping = true
		
	)
	
	
	format "source_vertex_colors: %\n" source_vertex_colors.keys
	format "source_vertex_colors: %\n" source_vertex_colors.keys.count
	
	
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
			current_mod = Edit_Poly name:"EPOLY_SMOOTH_VERTEX_COLORS"
		
			modPanel.addModToSelection ( current_mod ) --ui:on
		
			current_mod.getSelection #FACE
		)
		else
			current_mod.GetSelection #FACE
		
		/* APPLY ONLY ON SELECTED FACES */ 
		subObjectLevel = if not select_faces.isEmpty then 4 else 0 -- and ignoreSel:false MUST BE SET TO SMOOTH ONLY SELECTION
		
		/* SMOOTH OBJECT */ 
		msmooth	= meshsmooth name:"MESHSMOOTH_VERTEX_COLORS" oldMapping:true ignoreSel:select_faces.isEmpty
		
		modPanel.addModToSelection ( msmooth ) ui:on
	
		obj.modifiers[#MESHSMOOTH_VERTEX_COLORS].ignoreSel = select_faces.isEmpty -- smooth only selected
	)
	
	
	/* COLLPASE STACK TO MESHMOOTH */ 
	smooth_mod_index	= modPanel.getModifierIndex obj msmooth
	
	maxOps.CollapseNodeTo obj (smooth_mod_index ) off
	
	verts_all_smoothed = #{1..(getNumVerts obj.baseobject.mesh)}
	
	VertexColors_smooth = VertexColors_v(obj)
	
	/* GET COLORS OF SMOOTHED OBJECT */ 
	verts_by_colors_smooth = VertexColors_smooth.getVertsAndColors()
		
	vertex_colors_result	= Dictionary #STRING

	/*------------------------------------------------------------------------------
		RESET VERTEX COLORS
	--------------------------------------------------------------------------------*/
	for clr in verts_by_colors_smooth.keys do
	(
		--format "COLOR: % is gray: %\n" clr (isColorNearGrey ( _color = execute clr ) )
		if isColorNearGrey ( _color = execute clr ) then
			case of
			(
				/* SET GREY TO BLACK */ 
				(_color.r <= 128.0 ): verts_black += verts_by_colors_smooth[clr]
				/* SET GREY TO WHITE */ 
				(_color.r >  128.0 ): verts_white += verts_by_colors_smooth[clr]
			)
			
		/* APPLY COLOR WHICH IS FOUND ON INSMOOTHED OBJECT - gradient colors are wanished to black\white */ 
		else if findItem source_vertex_colors.keys clr > 0 then
		(
			verts_colored += verts_by_colors_smooth[clr]

			vertex_colors_result[clr] = verts_by_colors_smooth[clr]
		)
	)
			
	/*------------------------------------------------------------------------------
		SET BLACK AND WHITE VERTS
	--------------------------------------------------------------------------------*/
	
	/* GET BLACK VERTS */ 
	black_faces	= polyop.getFacesUsingVert obj verts_black
	black_verts_all	= polyop.getVertsUsingFace obj black_faces
	black_verts_inv	= polyop.getVertsUsingFace obj -black_faces
	
	black_verts_outline = black_verts_all * black_verts_inv 
	
	black_verts = black_verts_all - black_verts_outline - verts_colored
	
	
	white_verts = verts_all_smoothed - verts_colored - black_verts
	--format "VERTS_WHITE:\n%\n" VERTS_WHITE
	--format "\n"
	--format "VERTS_COLORED:\n%\n" verts_colored
	
	/* SET VERTEX COLOR */ 
	polyop.setVertColor obj.baseobject 0 white_verts  white
	polyop.setVertColor obj.baseobject 0 black_verts black
	--polyop.setVertColor obj.baseobject 0 (verts_white - verts_colored ) white
	--polyop.setVertColor obj.baseobject 0 (black_verts) black
	--format "vertex_colors_result: %\n" vertex_colors_resultvertex_colors_result
	format "---------------------------------------------------------------\n"
	format "white_verts.numberSet: %\n" white_verts.numberSet
	format "verts_all_smoothed.numberSet: %\n" verts_all_smoothed.numberSet
	format "TEST: %\n\n" (not white_verts.isEmpty and white_verts.numberSet != verts_all_smoothed.numberSet)
	
	
	if not white_verts.isEmpty and white_verts.numberSet != verts_all_smoothed.numberSet then
		vertex_colors_result[ white as string ] = white_verts
		
	if not black_verts.isEmpty then
		vertex_colors_result[ black as string ] = black_verts

	vertex_colors_result --return
)

