/** Select hide unhide supports


  @param name type of object #SOURCE|#SUPPORT|#RAFT|#BEAM|#DRAIN|#PIN


 */
function selectHideUnhideSupports type: state: select_mode:keyboard.controlPressed select_more:keyboard.shiftPressed =
(
	--clearListener(); print("Cleared in:\n"+getSourceFileName())
	format "\n"; print "selectHideUnhideSupports()"
	format "type:  %\n" type
	format "state: %\n" state
	format "SELECT_MODE: %\n" select_mode
	format "select_more: %\n" select_more
	format "\n"

	--fn arraysAreSame arr1 arr2 = with PrintAllElements on arr1 as string == arr2 as string
	
	/* CLOSE LAYER MANAGER BEFORE SELECTION */
	if (is_manager_open = LayerManager.isDialogOpen()) and select_mode then
		LayerManager.closeDialog()

		
	--select_by_source_objects = selection.count == 0

	
	objects_by_visibility	= if select_mode then
			  for obj in objects where obj.isHidden == false collect obj -- GET ONLY VISIBILITY OBJECTS - if select mode
		  else
		      for obj in objects where obj.isHidden == state collect obj -- GET HIDDEN for unhide OR GET VISIBLE for hide
		
	/* GET INPUT OBEJCTS - SELECTION or objects BY VISIBILITY */ 
	objs_input = if selection.count > 0 then selection as Array else objects_by_visibility

	/* GET INPUT SOURCE OBJECTS */ 
	source_objects = SUPPORT_MANAGER.getObjectsByType objs_input type:#SOURCE
	format "SOURCE_OBJECTS: %\n" source_objects
	
	
	select_by_source_objects = with PrintAllElements on ( sort ( for obj in selection collect obj.name ) ) as string == ( sort (for obj in source_objects collect obj.name) ) as string
	format "select_by_source_objects: %\n" select_by_source_objects
	/* USE SOURCE OBJECTS AS INPUT IF NOTHING SELECTED */ 
	if selection.count == 0 then
		objs_input = source_objects
	format "OBJS_INPUT: %\n" objs_input
		
	/* GET OBJECTS BY TYPE */ 	
	objs_by_type   = SUPPORT_MANAGER.getObjectsByType objs_input type:type hierarchy:select_more
	
	--source_objects_selected = for source_object in source_objects where source_object.isSelected collect source_object
 
	/* GET ALL OBEJCTS OF GIVEN TYPE - WORKS LIKE NOTHING SELECTED, IF SELECTION EXISTS BUT OBJECTS ARE NOT IN SUPPORT SYSTEM */ 
	if source_objects.count == 0 and objs_by_type.count == 0 then
		objs_by_type = SUPPORT_MANAGER.getObjectsByType objects_by_visibility type:type hierarchy:select_more
	

	/* SELECT|DESELECT SOURCE OBJECT */
	--if type == #SOURCE then
	--	objs_by_type = source_objects
	--format "TEST: %\n" (select_more and selection.count > 0)
	format "TEST: %\n" (select_more and selection.count > 0 and not select_by_source_objects )

	/* SELECT MORE - If shift key presssed*/
	if select_more and selection.count > 0 and not select_by_source_objects then
		objs_by_type += objs_input

	format "OBJS_BY_TYPE: %\n" objs_by_type
		
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
