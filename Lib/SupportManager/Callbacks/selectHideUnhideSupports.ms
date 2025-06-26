/** Select hide unhide supports


  @param name type of object #SOURCE|#SUPPORT|#RAFT|#BEAM|#DRAIN|#PIN


 */
function selectHideUnhideSupports type: state: select_mode:keyboard.controlPressed select_more:keyboard.shiftPressed =
(
	--clearListener(); print("Cleared in:\n"+getSourceFileName())
	format "\n"; print "selectHideUnhideSupports()"
	format "type:  %\n" type
	--format "state: %\n" state
	--format "SELECT_MODE: %\n" select_mode
	--format "select_more: %\n" select_more
	--format "\n"
	if (is_selection_locked = SUPPORT_MANAGER.isSelectionLocked())then
		actionMan.executeAction 0 "59231"  -- Selection: Selection Lock Toggle

	/* CLOSE LAYER MANAGER BEFORE SELECTION */
	if (is_manager_open = LayerManager.isDialogOpen()) and select_mode then
		LayerManager.closeDialog()


	objects_by_visibility	= if select_mode then
			  for obj in objects where obj.isHidden == false collect obj -- GET ONLY VISIBILITY OBJECTS - if select mode
		  else
		      for obj in objects where obj.isHidden == state collect obj -- GET HIDDEN for unhide OR GET VISIBLE for hide
		
	/* GET INPUT OBEJCTS - SELECTION or objects BY VISIBILITY */ 
	objs_input = if selection.count > 0 then selection as Array else objects_by_visibility

	/* GET INPUT SOURCE OBJECTS */ 
	source_objects = SUPPORT_MANAGER.getObjectsByType objs_input type:#SOURCE
	
	/* TEST IF SOURCE OBJECT IS SELECTED */ 
	select_by_source_objects = with PrintAllElements on ( sort ( for obj in selection collect getHandleByAnim obj ) ) as string == ( sort (for obj in source_objects collect getHandleByAnim obj ) ) as string
	
	/* USE SOURCE OBJECTS AS INPUT IF NOTHING SELECTED */ 
	if selection.count == 0 then
		objs_input = source_objects
	
	/* GET OBJECTS BY TYPE */ 	
	objs_by_type = SUPPORT_MANAGER.getObjectsByType objs_input type:type hierarchy:select_more
	
	/* GET ALL OBEJCTS OF GIVEN TYPE - WORKS LIKE NOTHING SELECTED, IF SELECTION EXISTS BUT OBJECTS ARE NOT IN SUPPORT SYSTEM */ 
	if source_objects.count == 0 and objs_by_type.count == 0 then
		objs_by_type = SUPPORT_MANAGER.getObjectsByType objects_by_visibility type:type hierarchy:select_more
	

	/* SELECT|DESELECT SOURCE OBJECT */
	--------if type == #SOURCE then
	--------	objs_by_type = source_objects

	/* SELECT MORE - If shift key presssed*/
	if select_mode and select_more and selection.count > 0 then
		objs_by_type += objs_input

	--format "OBJS_BY_TYPE: %\n" objs_by_type
		
	with redraw off
	(
		max create mode

		case of
		(
			/* SELECT */
			(select_mode and state ): select ( for obj in objs_by_type where obj.isHidden == false collect obj )

			/* DESELECT */
			(select_mode and not state) : deselect objs_by_type

			/* SHOW \ HIDE */
			default: for obj in objs_by_type do obj.isHidden = not state
		)
	)
	
	if is_selection_locked then
		actionMan.executeAction 0 "59231"  -- Selection: Selection Lock Toggle
	
	redrawViews()

	/* REOPEN LAYER MANAGER */
	--if is_manager_open then
		--LayerManager.editLayerByName ""
)


/*------------------------------------------------------------------------------

	TEST - ONLY DEV - CAN BE DELETED


filein( getFilenamePath(getSourceFileName()) + "/../SupportManager.ms" )	--"./../SupportManager.ms"

/* UNHIDE RAFTS */ 
--selectHideUnhideSupports type:#RAFT state:true

--clearListener(); print("Cleared in:\n"+getSourceFileName())

/* HIDE\UNHIDE DRAINS */ 
--selectHideUnhideSupports type:#DRAIN state:false
--selectHideUnhideSupports type:#DRAIN state:true
--



--selectHideUnhideSupports type:#DRAIN state:true select_mode:true

/* HIDE\UNHIDE PINS */ 
--selectHideUnhideSupports type:#PIN state:false


--------------------------------------------------------------------------------*/
