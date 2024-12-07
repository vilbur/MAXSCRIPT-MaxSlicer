/** Select hide unhide supports


  @param name type of object #SOURCE|#SUPPORT|#RAFT|#BEAM|#DRAIN|#PIN


 */
function selectHideUnhideSupports type: state: select_mode: keyboard.controlPressed select_more: keyboard.shiftPressed =
(
	clearListener(); print("Cleared in:\n"+getSourceFileName())
	format "\n"; print ".selectHideUnhideSupports()"
	--format "type:  %\n" type
	--format "state: %\n" state
	--format "\n"
	--format "select_mode: %\n" select_mode
	--format "select_more: %\n" select_more
	/* CLOSE LAYER MANAGER BEFORE SELECTION */

	if (is_manager_open = LayerManager.isDialogOpen()) and select_mode then
		LayerManager.closeDialog()

	timer_GETTING_OBJECTS = timeStamp()

	objs_input = if selection.count > 0 then selection as Array else objects as Array

	objs_by_type = SUPPORT_MANAGER.getObjectsByType objs_input type:type hierarchy:false

	source_objects = SUPPORT_MANAGER.getObjectsByType objs_input type:#SOURCE
	--format "SOURCE_OBJECTS: %\n" source_objects

	source_objects_selected = for source_object in source_objects where source_object.isSelected collect source_object

	format "GETTING_OBJECTS: % ms\n" (( timeStamp()) - timer_GETTING_OBJECTS)


	/* SELECT|DESELECT SOURCE OBJECT */
	if type == #SOURCE then
		objs_by_type = source_objects

	if select_more and not state then
		for obj in objs_by_type where (index = findItem objs_input obj) > 0 do
			deleteItem objs_input index


	timer_SELECTING = timeStamp()
	format "SELECTING START\n"

	with redraw off
	(
		max create mode

		case of
		(
			/* IF CTRL - SELECT MORE */
			--select_more: selectmore objs_by_type
			(select_more and    state ): select ( objs_input + objs_by_type )
			(select_more and not state ): select ( objs_input)


			/* SELECT */
			(select_mode and state ): select objs_by_type

			/* DESELECT */
			(select_mode and not state) : deselect objs_by_type


			/* SHOW \ HIDE */
			default: for obj in objs_by_type do obj.isHidden = not state
		)

	)
	--format "select: % ms\n" (( timeStamp()) - timer_select)
	redrawViews()
	format "SELECTING: % ms\n" (( timeStamp()) - timer_SELECTING)
	format "is_manager_open: %\n" is_manager_open
	/* REOPEN LAYER MANAGER */
	--if is_manager_open then
		--LayerManager.editLayerByName ""
)
