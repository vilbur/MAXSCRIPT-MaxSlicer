
/** Open new islands menu
 */
function islandsRcMenu =
(
	--format "\n"; print ".openNewIslandsMenu()"

	/* DEFINE MAIN MENU */
	Menu = RcMenu_v name:"IslandsMenu"

	listbox_items_count = DIALOG_island_manager.ML_island_listbox.items.count
	listbox_selection = DIALOG_island_manager.ML_island_listbox.selection


	/*------------------------------------------------------------------------------
		SELECTIOJN
	--------------------------------------------------------------------------------*/


	if (verts_sel = getVertSelection selection[1].mesh ).numberSet > 0 then
		Menu.item "Select Islands by verts"	"::IslandsRcMenuCallbacks_v.selectIslandsByVerts()"

	--format "VERTS_SEL.numberSet: %\n" verts_sel.numberSet

	if DIALOG_slicer_slider != undefined then
	(
		Menu.separator()

		Menu.item "SLICE HERE"	"::IslandsRcMenuCallbacks_v.sliceAtIsland()"
	)


	/*------------------------------------------------------------------------------
		SELECT BY SIZE
	--------------------------------------------------------------------------------*/

	if Menu.items.count > 0 then
		Menu.separator()

	if listbox_selection.numberSet > 0 then
		--Menu.item "Show ONLY selected" "::IslandsRcMenuCallbacks_v.createIslandManagerDialogOnlySelectedIslands()"
		Menu.item "Show ONLY selected" "createIslandManagerDialog islands_to_show:(ISLANDS_SYSTEM.getIslandsToShowBySelection())"


	if listbox_items_count < ISLANDS_SYSTEM.islands_data.count then
		Menu.item "Show ALL" "createIslandManagerDialog islands_to_show:#{}"

	if Menu.items.count > 0 then
		Menu.separator()

	/* ADD ITEMS */
	if listbox_selection.numberSet != listbox_items_count then
		Menu.item "Select All"	"::IslandsRcMenuCallbacks_v.selectAllIslandsInListbox()"

	if listbox_selection.numberSet > 0 then
		Menu.item "Invert Selection"	"::IslandsRcMenuCallbacks_v.invertSelection()"

	Menu.item "Select single layer islands"	"::IslandsRcMenuCallbacks_v.selectSingleLayerIslands()"
	Menu.item "Select whole Islands"	"::IslandsRcMenuCallbacks_v.selectVertsOfIslands(#WHOLE_ISLAND)"



	/*------------------------------------------------------------------------------
		MANAGE ISALNDS
	--------------------------------------------------------------------------------*/

	Menu.separator()

	Menu.item "Remove selected islands"	"::IslandsRcMenuCallbacks_v.removeSelectedIslands()"

	Menu.separator()

	Menu.item "Select SMALL Islands"	"::IslandsRcMenuCallbacks_v.selectIslandsBySize(#SMALL)"
	Menu.item "Select MEDIUM Islands"	"::IslandsRcMenuCallbacks_v.selectIslandsBySize(#MEDIUM)"
	Menu.item "Select BIG Islands"	"::IslandsRcMenuCallbacks_v.selectIslandsBySize(#BIG)"

	--Menu.clearSeparators()

	popUpMenu (Menu.create())
)