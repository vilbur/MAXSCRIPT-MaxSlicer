


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

	--format "\n"; print ".selectVertsByCavity()"
		obj	= selection[1]

		--ctrl	= keyboard.controlPressed
		--alt	= keyboard.altPressed
		--shift	= keyboard.shiftPressed

		--hidden_verts =	polyop.getHiddenVerts obj

		--if ctrl then
		--(
		--	--obj.EditablePoly.unhideAll subobject
		--
		--	--obj.EditablePoly.SetSelection subobject #{}
		--)

		max modify mode

		setSelectionLevel obj subobject

		sel_old = _getSelection obj subobject

		if mode == #BOTTOM or mode == #TOP then
		(
			--PolyToolsSelect.Normal 3 120 true
			--PolyToolsSelect.Normal 3 170 true
			if mode == #BOTTOM then
				PolyToolsSelect.Normal 3 150 true
			else /* TOP */
				PolyToolsSelect.Normal 3 15 false

			sel_new = _getSelection obj subobject
			--format "not (sel_old * sel_new).isEmpty: %\n" (not (sel_old * sel_new).isEmpty)
			if not sel_old.isEmpty then
				setSelection obj ( sel_new * sel_old ) subobject:subobject
		)
		else
		(
			--PolyToolsSelect.ConvexConcave 0.1 2 -- select convex and convex-concave
			--PolyToolsSelect.ConvexConcave 0.001 2 -- select convex and convex-concave
			PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex and convex-concave

			sel_new = _getSelection obj subobject
			--format "not (sel_old * sel_new).isEmpty: %\n" (not (sel_old * sel_new).isEmpty)
			--if not sel_old.isEmpty and not (sel_old - sel_new).isEmpty then
			if not sel_old.isEmpty then
				setSelection obj ( sel_new * sel_old) subobject:subobject
		)

		--if alt then
			--obj.EditablePoly.unhideAll subobject

		if keyboard.controlPressed and subobject != #FACE then
		(
			obj.EditablePoly.unhideAll subobject

			actionMan.executeAction 0 "40044"  -- Selection: Select Invert

			obj.EditablePoly.hide subobject

			actionMan.executeAction 0 "40021"  -- Selection: Select All
		)

	--if subobject == #FACE then polyop.getFaceSelection obj else polyop.getVertSelection obj -- return
)

/**
  */
macroscript	maxtoprint_get_convex_verts
category:	"maxtoprint"
buttontext:	"CONVEX"
toolTip:	"VERTS"
icon:	"across:4|tooltip:CTRL: Reset selection"
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
buttontext:	"BOTTOM\TOP"
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
buttontext:	"BOTTOM\TOP"
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
buttontext:	"INNER\OUTTER"
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
buttontext:	"INNER\OUTTER"
toolTip:	"TOP verts\n\nCTRL: ISOLATE selected verts"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"
		(VertSelector_v( selection[1] )).selectInnerOutterVerts #OUTTER

	)
)

/**
  */
function SelectVisiblePolys polysToUse: selVisiblePolys: =
(
	--Get the viewport TMatrix, invert to get the equivalent of a camera transformation
	poGetNumFaces = polyop.getNumFaces
	poGetFaceSelection = polyop.getFaceSelection
	poGetFaceNormal = polyop.getFaceNormal
	poSetFaceSelection = polyop.setFaceSelection

	--theTM = inverse (viewport.getTM())
	theTM = matrixFromNormal  [ 0, 0, 1 ]

	selObjsArr = selection as array
	--Loop through all geometry objects that have EPoly Base Object
	for theObj in selObjsArr where classof theObj.baseobject == Editable_Poly do
	(
		theFacesToSelect = #{} --ini. a bitArray to collect faces to select
		numFaces = if polysToUse == #all then
			(
				#{1..(poGetNumFaces theObj)}
			)
			else
			(
				poGetFaceSelection theObj
			)
		--loop from 1 to the number of polygons and set the corresponding bit in the bitArray
		--to true if the normal of the polygon as seen in camera space has a positive Z,
		--and false if it is negative or zero (facing away from the camera)
		if selVisiblePolys == #visible then
		(
			for f in numFaces do
			(
				theFacesToSelect[f] = (in coordsys theTM poGetFaceNormal theObj f).z > 0
			)
		)
		else
		(
			for f in numFaces do
			(
				theFacesToSelect[f] = (in coordsys theTM poGetFaceNormal theObj f).z < 0
			)
		)
		--finally, set the selection in the object
		poSetFaceSelection theObj theFacesToSelect
	)
	--when done with all, redraw the views - if a Poly SO level is selected,
	--the selection will be updated in the viewport...
	redrawViews()
)
/** Select
 *
 */
macroscript	maxtoprint_select_verts_by_z_axis
category:	"maxtoprint"
buttontext:	"BY CAMERA"
toolTip:	"TOP verts"
--icon:	"tooltip:CTRL: Reset selection"
(
	on execute do
	(
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\3-1-2-SELECT CONVEX - CONCAVE .mcr"

		--	"use all polys of the object and select the visible ones"
		SelectVisiblePolys polysToUse:#all selVisiblePolys:#visible

	-- 	--	"use all polys of the object and select the hidden ones"
	-- 	SelectVisiblePolys polysToUse:#all selVisiblePolys:#invisible

		--	"use selected polys of the object and select the visible ones"
	-- 	SelectVisiblePolys polysToUse:#selected selVisiblePolys:#visible

		--	"use all selected of the object and select the hidden ones"
	-- 	SelectVisiblePolys polysToUse:#selected selVisiblePolys:#invisible
	)
)


/*==============================================================================

	ROW 2

================================================================================*/

/**
  *
  */
macroscript	_print_select_single_vert_of_faces
category:	"_Print-Points-Tools"
buttonText:	"1 on island"
toolTip:	"Get only signlge vertex of each face island"
icon:	"MENU:true|across:4|height:24"
(
	on execute do
	if subObjectLevel == 1 then
	undo "Filter 1 vert per face" on
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\Lib\VertSelector\VertSelector.ms"

		VertSelector 	= VertSelector_v( selection[1] )

		VertSelector.selectSingleVertPerFaceIsland()
		--VertSelector.selectVerts()

		--free VertSelector
		--VertSelector = undefined

		--gc()
	)
)



/**  Checkerboard selection
  *
 */
macroscript	_print_select_verts_checker_pattern
category:	"_Print-Points-Tools"
buttonText:	"Checker"
toolTip:	"Get selection of selected vertices in cheker pattern"
icon:	"MENU:false|across:4|height:24"
(
	on execute do
	if selection.count > 0 then
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-Points\Lib\VertSelector\VertSelector.ms"

		obj	= selection[1]

		VertSelector 	= VertSelector_v( obj ) -- resolution:ROLLOUT_vertex_selection.SPIN_grid_step.value

		VertSelector.selectChecker resolution:ROLLOUT_vertex_selection.SPIN_grid_step.value invert_sel:( keyboard.controlPressed )

		--VertSelector.selectVerts()

	)
)
