
/** Generate support or raft
 */
function generateSupportsOrRafts obj_type: =
(
	--format "\n"; print ".generateSupportsOrRafts()"

	--format "obj_type: %\n" obj_type

	_selection = for obj in selection collect obj

	--source_objects  = SUPPORT_MANAGER.searchObjectsByType _selection type:#SOURCE
	source_objects = for obj in _selection where SUPPORT_MANAGER.isType #SOURCE obj != false collect obj

	if source_objects.count == 0 then
		source_objects = for obj in _selection where not SUPPORT_MANAGER.isManaged(obj) collect obj

	--supports_exists = for obj in _selection where findItem source_objects obj == 0 collect obj

	--existing_supports = SUPPORT_MANAGER.getObjectsByType _selection type:#SUPPORT --hierarchy:shift
	--existing_rafts     = SUPPORT_MANAGER.getObjectsByType _selection type:#RAFT --hierarchy:shift
	--
	--existing_nodes = existing_supports + existing_rafts
	--format "EXISTING_NODES: %\n" existing_nodes

	/*------------------------------------------------------------------------------
		GENERATE NEW OBEJCTS by source object
	--------------------------------------------------------------------------------*/
	if source_objects.count > 0 then
		new_nodes = SUPPORT_MANAGER.generateSupports source_objects[1] obj_type:obj_type

	else
	(
		--selected_supports_and_rafts = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		--format "SELECTED_SUPPORTS_AND_RAFTS: %\n" selected_supports_and_rafts

		selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		--format "SELECTED_SUPPORTS: %\n" selected_supports
		--format "SELECTED_RAFTS:    %\n" selected_rafts
		--format "raft_mode: %\n" raft_mode

		
		/* CONVERT SELECTED SUPPORTS TO RAFTS */
		if obj_type == #RAFT and selected_supports.count > 0 then
			SUPPORT_MANAGER.convert(selected_supports) obj_type:#RAFT

		
		/* CONVERT SELECTED RAFTS TO SUPPORTS */
		if obj_type == #SUPPORT and selected_rafts.count > 0 then
			SUPPORT_MANAGER.convert(selected_rafts) obj_type:#SUPPORT
		
		/* REBUILD SELECTED SUPPORTS */ 
		if obj_type == #SUPPORT and selected_supports.count > 0 then
		(
			pauseSupportToTransformEvent()

			SUPPORT_MANAGER.rebuildSupports(selected_supports) obj_type:#SUPPORT

			resumeSupportToTransformEvent()
		)

	)

	select (if new_nodes != undefined and new_nodes.count > 0 then new_nodes else _selection)

	--format "SOURCE_OBJECTS: %\n" source_objects
	----format "COUNT: %\n" source_objects.count
	--format "\n"
	--format "SELECTED_SUPPORTS: %\n" selected_supports
	--format "COUNT: %\n" selected_supports.count
	--format "\n"
	--format "SUPPORTS_EXISTS: %\n" supports_exists
	--format "COUNT: %\n" supports_exists.count


	--if _selection.count > 0 then
	--	new_nodes = SUPPORT_MANAGER.generateSupports( _selection[1] )
	--

)