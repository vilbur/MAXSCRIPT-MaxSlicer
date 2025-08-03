filein( getFilenamePath(getSourceFileName()) + "/Lib/getInternalVertsOfObject/getInternalVertsOfObject.ms" )	--"./Lib/getInternalVertsOfObject/getInternalVertsOfObject.ms"
filein( getFilenamePath(getSourceFileName()) + "/Lib/selectConcexOrBottomFacesOrVers/selectConcexOrBottomFacesOrVers.ms" )	--"./Lib/selectConcexOrBottomFacesOrVers/selectConcexOrBottomFacesOrVers.ms"
/**
  */
macroscript	maxtoprint_get_convex_verts
category:	"maxtoprint"
buttontext:	"CONVEX"
toolTip:	"VERTS"
icon:	"across:2|width:96|height:32|tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #CONVEX
	)
)

/**
  */
macroscript	maxtoprint_get_convex_faces
category:	"maxtoprint"
buttontext:	"CONVEX"
toolTip:	"FACES"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #CONVEX subobject:#FACE
	)
)

/**
  */
macroscript	maxtoprint_get_bottom_verts
category:	"maxtoprint"
buttontext:	"D O W N \ U P"
toolTip:	"BOTTOM verts"
icon:	"tooltip:Select bottom or top verts of all or selected verts."
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #BOTTOM
	)
)

/**
  */
macroscript	maxtoprint_get_top_verts
category:	"maxtoprint"
buttontext:	"D O W N \ U P"
toolTip:	"TOP verts\n\nCTRL: ISOLATE selected verts"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		selectConcexOrBottomFacesOrVers #TOP
	)
)


/**
  */
macroscript	maxtoprint_inner_verts_select
category:	"maxtoprint"
buttontext:	"I N N E R"
toolTip:	"Select verts which are inside object.\n\nE.G: If objects or elements intersect"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-02-ISLANDS\Lib\getInternalVertsOfObject\getInternalVertsOfObject.ms"

		if selection.count > 0 then
		(
			_selection = for o in selection collect o
			inside_verts_all = #()
			
			
			for obj in _selection do 
			(
				inside_verts = getInternalVertsOfObject obj _selection
				
				append inside_verts_all inside_verts
			)
				--select _selection[1]
		
			if _selection.count == 1 then
			(
				select _selection[1]
					
				(VertSelector_v( _selection[1])).selectVerts inside_verts_all[1] 
			)
			else
			(
				for i = 1 to _selection.count do
				(
					select _selection[i]
					
					(VertSelector_v( _selection[i])).selectVerts inside_verts_all[i] 
				)
				
				select _selection
			)
		)
	)
)



/**
  */
macroscript	maxtoprint_get_top_verts_inner
category:	"maxtoprint"
buttontext:	"TOP I N \ O U T"
toolTip:	"BOTTOM verts"
icon:	"tooltip:"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		(VertSelector_v( selection[1] )).selectInnerOutterVerts #INNER
	)
)

/**
  */
macroscript	maxtoprint_get_top_verts_outer
category:	"maxtoprint"
buttontext:	"TOP I N \ O U T"
toolTip:	"TOP verts\n\nCTRL: ISOLATE selected verts"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"
		(VertSelector_v( selection[1] )).selectInnerOutterVerts #OUTTER

	)
)
