/** Generate support or raft
 */
function generateSupportsOrRafts obj_type: =
(
	--format "\n"; print ".generateSupportsOrRafts()"

	_selection = for obj in selection collect obj

	/* SEARCH FOR SOURCE OBJECTS IN SLECTION */ 
	source_objects = for obj in _selection where SUPPORT_MANAGER.isType #SOURCE obj != false collect obj

	/* GET NEW SOURCE OBJECT IF ANY OBJECT HAS NOT BEEN FOUND */ 
	if source_objects.count == 0 then
		source_objects = for obj in _selection where not SUPPORT_MANAGER.isManaged(obj) collect obj

		
		
	/*------------------------------------------------------------------------------
		GENERATE NEW OBJECTS by source object
	--------------------------------------------------------------------------------*/
	if source_objects.count > 0 then
		new_nodes = SUPPORT_MANAGER.generateSupports source_objects[1] obj_type:obj_type

	else
	(
		/* GET SELECTED SUPPORTS & RAFTS */ 
		selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		
		/*------------------------------------------------------------------------------
			CONVERT SELECTED SUPPORTS & RAFTS
		--------------------------------------------------------------------------------*/
	
		/* SUPPORTS TO RAFTS */
		if obj_type == #RAFT and selected_supports.count > 0 then
			SUPPORT_MANAGER.convert(selected_supports) obj_type:#RAFT

		/* RAFTS TO SUPPORTS */
		if obj_type == #SUPPORT and selected_rafts.count > 0 then
			SUPPORT_MANAGER.convert(selected_rafts) obj_type:#SUPPORT
		
		
		/*------------------------------------------------------------------------------
			REBUILD SELECTED SUPPORTS & RAFTS
		--------------------------------------------------------------------------------*/
		
		if obj_type == #SUPPORT and selected_supports.count > 0 then
		(
			pauseSupportToTransformEvent()

			SUPPORT_MANAGER.rebuildSupports(selected_supports) obj_type:#SUPPORT

			resumeSupportToTransformEvent()
		)
	)

	
	
	/* SELECT RESULT */ 
	select (if new_nodes != undefined and new_nodes.count > 0 then new_nodes else _selection)
)