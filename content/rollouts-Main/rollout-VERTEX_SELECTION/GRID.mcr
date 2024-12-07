--filein( getFilenamePath(getSourceFileName()) + "/Lib/VertSelector/VertSelector.ms" )	--"./Lib/VertSelector/VertSelector.ms"


/**  Export format
  *
 */
macroscript	_print_select_vets_grid_resolution
category:	"_Print-Points-Tools"
buttonText:	"[GRID SIZE]"
toolTip:	"Size of grid cell in mm"
icon:	"MENU:false|id:#SPIN_grid_step|control:spinner|across:4|range:[ 1, 100, 3 ]|type:#float|height:24|offset:[ 12, 4]|align:#left|fieldwidth:32"
(
	on execute do
		format "EventFired	= % \n" EventFired

)
/**  Export format
  *
 */
macroscript	_print_select_middle_verts_in_grid
category:	"_Print-Points-Tools"
buttonText:	"Grid MIDDLE"
toolTip:	"SELECT LOWEST SINGLE VERTEX of each face island.\n\Vert with lowest position on Z axis is selected"
icon:	"MENU:true|across:4|height:24"
(
	on execute do
	if selection.count > 0 then
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"

		VertSelector 	= VertSelector_v( selection[1]  )

		VertSelector.selectMiddleVertsInGrid resolution:ROLLOUT_vertex_selection.SPIN_grid_step.value
		--VertexGridSelector.selectVerts()

		gc()
	)
)

/**  Export format
  *
 */
macroscript	_print_select_lowest_verts_in_grid
category:	"_Print-Points-Tools"
buttonText:	"Grid LOWEST"
toolTip:	"SELECT LOWEST SINGLE VERTEX of each face island.\n\Vert with lowest position on Z axis is selected"
icon:	"MENU:true|across:4|height:24"
(
	on execute do
	if selection.count > 0 then
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
	--	filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\3-1-3-VERTEX SELECTION TOOLS.mcr"

		VertSelector 	= VertSelector_v( selection[1]  )

		VertSelector.selectLowestVertsInGrid resolution:ROLLOUT_vertex_selection.SPIN_grid_step.value
		--VertexGridSelector.selectVerts()

		gc()
	)
)
