

/*==============================================================================

		COTNROLS ROW 1

================================================================================*/



--/** CHECKBOX
-- */
--macroscript	_print_platform_generator_normals_up
--category:	"_3D-Print"
--buttontext:	"Normal Limit"
--icon:	"across:3|control:checkbox|offset:[ 16, 14]|tooltip:TRUE: Use all verts\n\nFALSE: Use only verts which normal is pointing down or side"
--
--(
--	format "EventFired:	% \n" EventFired
--)




--/** CHECKBOX
--  */
--macroscript	_print_platform_generator_normal_use
--category:	"_3D-Print"
--buttontext:	"Use Normals"
--tooltip:	"Use normals to get support direction.\n\nPoints direction is to ground if FALSE "
--icon:	"across:2|control:checkbox|range:[ 1, 999, 3 ]"
--(
--	format "EventFired:	% \n" EventFired
--)

/*==============================================================================

		COTNROLS ROW 2

================================================================================*/
--
--/** CHECKBOX
-- */
--macroscript	_print_platform_generator_normal_always_down
--category:	"_3D-Print"
--buttontext:	"Keep Down"
--icon:	"across:2|align:#CENTER|offset:[ 24, 8]|control:checkbox|tooltip:Keep secon helper point always lower then first.\n\nIt makes to part of support always pointing down printable."
--
--(
--	format "EventFired:	% \n" EventFired
--)
--/** SPINNER
--  */
--macroscript	_print_platform_generator_normal_always_down_limit
--category:	"_3D-Print"
--buttontext:	"Keep down Limit"
--tooltip:	"How much must be second point bellow first"
--icon:	"across:2|offset:[ 0, 8]|fieldwidth:24|control:spinner|type:#integer|range:[ 1, 99, 1 ]"
--(
--	format "EventFired:	% \n" EventFired
--)


/*==============================================================================

		COTNROLS ROW 3

================================================================================*/





/*==============================================================================

		GENERATE BUTTON

================================================================================*/
--/** GENERATE POINTS
-- */
--macroscript	_print_support_generate_points
--category:	"_3D-Print"
--buttontext:	"POINTS"
--tooltip:	"Generate Points"
--icon:	"across:3|offset:[ 16, 8 ]|height:32|width:128|align:#LEFT|tooltip:CTRL: RESET all points on object.\n\n\n\n\nLAST OBJECT IS USED IF NOTHING SELECTED.\n\nIMPORTANT: VERTEX MUST HAS SINGLE VERTEX COLOR,\notherwise then generator could not work properly."
--(
--	on execute do
--		undo "Generate Points" on
--		--undo off
--		(
--			clearListener(); print("Cleared in:\n"+getSourceFileName())
--
--			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-SUPPORTS\0-POINTS.mcr"
--
--			SUPPORT_MANAGER.generateSupports( selection[1] )
--
--		)
--)
--
--/** GENERATE POINTS
-- */
--macroscript	_print_support_generate_points_auto
--category:	"_3D-Print"
--buttontext:	"AUTO Points"
--tooltip:	"Generate Points"
--icon:	"across:3|offset:[ 16, 8 ]|height:32|width:128|align:#LEFT|tooltip:CTRL: RESET all points on object.\n\n\n\n\nLAST OBJECT IS USED IF NOTHING SELECTED.\n\nIMPORTANT: VERTEX MUST HAS SINGLE VERTEX COLOR,\notherwise then generator could not work properly."
--(
--	on execute do
--		undo "AUTO Points" on
--		--undo off
--		(
--			clearListener(); print("Cleared in:\n"+getSourceFileName())
--
--			obj	= selection[1]
--			VertSelector 	= VertSelector_v( obj )
--
--			VertIslandFinder = VertSelector.VertexLayers.VertIslandFinder
--
--
--			--polyop.unHideAllVerts obj
--			--
--			--PolyToolsSelect.Normal 3 120 true
--			--
--			--verts_sel	= getVertSelection obj.mesh
--			--
--			--polyop.setHiddenVerts  obj -verts_sel
--			--
--			--convex_verts = VertSelector.getConvexVerts mode:#CONVEX verts:verts_sel
--			--
--			--polyop.setHiddenVerts obj -convex_verts
--
--			--delete Helpers -- DEV
--
--			VertSelector.findIslandsPerLayer()
--
--			obj.showVertexColors	= true
--			obj.vertexColorsShaded	= true
--
--			polyop.setVertColor obj.baseobject 0 VertIslandFinder.verts_all white
--
--			format "VertexLayers: %\n" VertexLayers
--
--			for merged_island in VertIslandFinder.merged_islands  do
--			(
--				polyop.setVertColor obj.baseobject 0 (merged_island) green
--
--				--this._getCenterOfIsland (merged_island)
--			)
--
--			for new_island in VertIslandFinder.new_islands  do
--			--for new_island in this.new_islands  do
--			(
--				polyop.setVertColor obj.baseobject 0 (new_island) red
--
--				--this._getCenterOfIsland (new_island)
--			)
--
--
--
--		)
--)
--

--
--/** SPINNER
--  */
--macroscript	_print_platform_generator_use_every_vertex
--category:	"_3D-Print"
--buttontext:	"Use nth vertex"
--tooltip:	"Use every nth vertex of spline"
--icon:	"across:3|offset:[ 0, 12]|control:spinner|align:#RIGHT|fieldwidth:24|type:#integer|range:[ 1, 99,1 ]"
--(
--	format "EventFired:	% \n" EventFired
--)
