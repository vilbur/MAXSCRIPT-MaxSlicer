
/** Generate support or raft
 */
function generateSupportsOrRafts obj_type: =
(
	 format "\n"; print ".generateSupportsOrRafts()"
	-- format "obj_type: %\n" obj_type
	 --format "generateSupportsOrRafts: %\n" obj_type
	new_nodes = #()
	
	_selection = for obj in selection collect obj

	/* SEARCH FOR SOURCE OBJECTS IN SLECTION */ 
	source_objects = for obj in _selection where SUPPORT_MANAGER.isType #SOURCE obj != false collect obj
	 format "source_objects.count: %\n" source_objects.count

	/* GET NEW OBJECT AS SOURCE OBJECT IF ANY OBJECT HAS NOT BEEN FOUND */ 
	if source_objects.count == 0 then
		source_objects = for obj in _selection where not SUPPORT_MANAGER.isManaged(obj) collect obj
	
	 format "SOURCE_OBJECTS: %\n" source_objects
	 format "source_objects.count: %\n" source_objects.count
		
	/*------------------------------------------------------------------------------
	  
		GENERATE NEW OBJECTS by source object
		
	------------------------------------------------------------------------------*/
	if source_objects.count > 0 then
		for source_object in source_objects do 
			new_nodes += SUPPORT_MANAGER.generateSupports source_object obj_type:obj_type
	
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
			SUPPORT_MANAGER.convertType(selected_supports) to_type:#RAFT
	
		/* RAFTS TO SUPPORTS */
		if obj_type == #SUPPORT and selected_rafts.count > 0 then
			SUPPORT_MANAGER.convertType(selected_rafts) to_type:#SUPPORT
		
		
		/*------------------------------------------------------------------------------
		  
			REBUILD SELECTED SUPPORTS & RAFTS
			
		--------------------------------------------------------------------------------*/
		
		if  obj_type == #SUPPORT and selected_supports.count > 0 \
		or obj_type == #RAFT    and selected_rafts.count    > 0 then
		(
			format "REBUILD SELECTED SUPPORTS & RAFTS\n"
			pauseSupportTransformEvent()
		
			SUPPORT_MANAGER.resetSupports(selected_supports) obj_type:obj_type
		
			resumeSupportTransformEvent()
		)
	)
	
	/* SELECT RESULT */ 
	select (if new_nodes != undefined and new_nodes.count > 0 then new_nodes else _selection)
)