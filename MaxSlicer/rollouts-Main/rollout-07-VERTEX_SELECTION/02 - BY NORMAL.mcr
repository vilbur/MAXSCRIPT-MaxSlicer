
/** Select verts by cavity
	All verts are used if nothing selected

  @param #CONVEX|#CONCAVE|#MIXED|#CORNER


	CTRL:  Use all verts
	SHIFT: Select convex\concave and mixed
	ALT:	Hide other types of verts

 */
function selectConcexOrBottomFacesOrVers mode subobject:#VERTEX =
(

		fn _getSelection obj subobject = if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return

		/** Select final selection
		 */
		fn setSelection obj verts subobject:#VERTEX =
		(
			format "\n"; print "VertSelector_v.selectVerts()"
			--format "verts: %\n" verts

			max modify mode

			setSelectionLevel obj subobject

			_mod = modPanel.getCurrentObject()

			_mod.SetSelection subobject #{}

			if classOf _mod == Edit_Poly then
				_mod.Select subobject verts

			else if classOf _mod  == Editable_Poly then
				_mod.SetSelection subobject verts
		)

		
		obj	= selection[1]

		max modify mode

		setSelectionLevel obj subobject

		sel_old = _getSelection obj subobject

		if mode == #BOTTOM or mode == #TOP then
		(
			----PolyToolsSelect.Normal 3 120 true
			----PolyToolsSelect.Normal 3 170 true
			if mode == #BOTTOM then
				PolyToolsSelect.Normal 3 140 true
				--PolyToolsSelect.Normal 3 150 true
			else /* TOP */
				PolyToolsSelect.Normal 3 90 false
				--PolyToolsSelect.Normal 3 15 false

			sel_new = _getSelection obj subobject

			if not sel_old.isEmpty then
				setSelection obj ( sel_new * sel_old ) subobject:subobject
		)
		else
		(
			----PolyToolsSelect.ConvexConcave 0.1 2 -- select convex and convex-concave
			----PolyToolsSelect.ConvexConcave 0.001 2 -- select convex and convex-concave
			PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex and convex-concave

			sel_new = _getSelection obj subobject

			if not sel_old.isEmpty then
				setSelection obj ( sel_new * sel_old) subobject:subobject
		)

		/*------------------------------------------------------------------------------
			ISOLATE SELECION
		--------------------------------------------------------------------------------*/
		if keyboard.controlPressed and subobject != #FACE then
		(
			obj.EditablePoly.unhideAll subobject

			actionMan.executeAction 0 "40044"  -- Selection: Select Invert

			obj.EditablePoly.hide subobject

			actionMan.executeAction 0 "40021"  -- Selection: Select All
		)

)

/**
  */
macroscript	maxtoprint_get_convex_verts
category:	"maxtoprint"
buttontext:	"CONVEX"
toolTip:	"VERTS"
icon:	"across:3|width:96|height:32|tooltip:CTRL: Reset selection"
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
