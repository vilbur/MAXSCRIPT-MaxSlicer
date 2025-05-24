


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
icon:	"across:3|width:96|height:32"
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
icon:	"MENU:true"
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
icon:	"MENU:false"
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
