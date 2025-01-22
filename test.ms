/* ISLANDS VIA VERTS */
clearListener(); print("Cleared in:\n"+getSourceFileName())
--
--
----try( destroyDialog testRollout )catch()
----
----rollout testRollout "Test"
----(
----  group "Test"
----  (
----    button btn_button "Press Me If You Can"  offset:[0,10] across:2
----  )--end group
----)--end rollout
----createDialog testRollout width:200
----
----testRollout.controls[1].pos.y  += 10
----testRollout.controls[3].pos.y  -= 10
----
----testRollout.controls[3].pos.x  -= 10
----
--
--
--	grid_sizes = #( 0.05, 1.0, 10.0, 100.0  ) -- SPACING OF GRID IN mm units
--
--
--	display_units = case units.SystemType of -- convert to milimeters
--	(
--		#millimeters:	1
--		#centimeters:	10
--		#meters:	1000
--		#kilometers:	1000000
--		default:	1 -- non metric units
--	)
--
--	next_index = if ( index = findItem grid_sizes (GetGridSpacing()) ) > 0 and index < grid_sizes.count then index + 1 else 1
--
--	SetGridSpacing ( grid_sizes[next_index] / display_units )
--
--	format "SetGridSpacing :%\n" ( grid_sizes[next_index] / display_units )
--
--	SetGridMajorLines 10
--
--	format "\nGRID SPACING: %mm" grid_sizes[next_index]
--
--
--ISLANDS_DATA = #(Dictionary #name bottom:201 lowest_vert:482 NEW_ISLAND:#{482} , Dictionary #name bottom:212 lowest_vert:408 NEW_ISLAND:#{408} , Dictionary #name bottom:233 lowest_vert:329 NEW_ISLAND:#{329} )


source_node = selection[1]
dest_node = selection[2]

current_panel = getCommandPanelTaskMode()

max create mode


--for m = source_node.modifiers.count to 1 by -1 where classOf (source_mod = source_node.modifiers[m]) != Edit_Poly do
--for m = source_node.modifiers.count to 1 by -1 where findItem mods (classOf (source_mod = source_node.modifiers[m] )) == 0 do
for m = source_node.modifiers.count to 1 by -1 do
(
	source_mod = source_node.modifiers[m]
	
	format "\n"
	format "m: %\n" m
	format "source_mod: %\n" (source_mod)
	--format "dest_mod: %\n" (dest_node.modifiers[m])
	
	
	deleteModifier dest_node m
	
	addModifierWithLocalData dest_node source_mod source_node source_mod before:(m - 1 ) -- instance the modifier
)

setCommandPanelTaskMode mode:current_panel

	--addModifierWithLocalData dest_node source_mod source_node source_mod -- instance the modifier
