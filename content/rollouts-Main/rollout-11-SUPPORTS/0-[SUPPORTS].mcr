
--DEV

--print("DEV IMPORT in:\n"+getSourceFileName());filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/SupportManager.ms" )	--"./../../../Lib/SupportManager/SupportManager.ms"

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

	if source_objects.count > 0 then
		new_nodes = SUPPORT_MANAGER.generateSupports source_objects[1] obj_type:obj_type


	(
		--selected_supports_and_rafts = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		--format "SELECTED_SUPPORTS_AND_RAFTS: %\n" selected_supports_and_rafts

		selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		format "SELECTED_SUPPORTS: %\n" selected_supports
		format "SELECTED_RAFTS:    %\n" selected_rafts
		--format "raft_mode: %\n" raft_mode

		/* CONVERT SELECTED SUPPORTS TO RAFTS */
		if obj_type == #RAFT and selected_supports.count > 0 then
			SUPPORT_MANAGER.convert(selected_supports) obj_type:#RAFT

		/* CONVERT SELECTED RAFTS TO SUPPORTS */
		if obj_type == #SUPPORT and selected_rafts.count > 0 then
			SUPPORT_MANAGER.convert(selected_rafts) obj_type:#SUPPORT

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





/*==============================================================================

		COTNROLS ROW 1

================================================================================*/


/** BAR WIDTH
 */
macroscript	_print_platform_generator_bar_width
category:	"_3D-Print"
buttontext:	"WIDTH"
tooltip:	"Bar width in mm of printed model.\n\nExported scale is used"
icon:	"control:spinner|id:SPIN_bar_width|across:3|range:[ 0.8, 3, 1.0 ]|width:64|offset:[ 0, 0 ]"
(
		--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)

/**
 */
macroscript	_print_platform_generator_bar_chamfer
category:	"_3D-Print"
buttontext:	"CHAMFER"
tooltip:	"Chamfer of support`s top.\n\n\nCHAMFER MIN: 0\nCHAMFER MAX: 10\n\nValue is portion of bar radius.\n\nE.EG: 5 == 50% use of radius"
icon:	"control:spinner|id:SPIN_chamfer_bar|across:3|type:#integer|range:[ 0, 10, 5 ]|width:64|offset:[ 0, 0 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)

/** EXTRUDE TOP
 */
macroscript	_print_platform_generator_extrude_top
category:	"_3D-Print"
buttontext:	"EXTEND"
tooltip:	"Extrude end part in mm of printed model.\n\nExported scale is used"
icon:	"control:spinner|id:SPIN_extend_top|across:3|width:64|range:[ 0, 99, 0.5 ]|offset:[ 0, 0 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)




/*==============================================================================

		COTNROLS ROW 2

================================================================================*/


/*------------------------------------------------------------------------------
	GENERATE SUPPORT BUTTON
--------------------------------------------------------------------------------*/
macroscript	_print_support_generator
category:	"_3D-Print"
buttontext:	"S U P P O R T"
icon:	"across:3|height:32|width:96|offset:[ -16, 0 ]"
(
	/* https://help.autodesk.com/view/MAXDEV/2021/ENU/?guid=GUID-5A4580C6-B5CF-4104-898B-9313D1AAECD4 */
	on isEnabled return selection.count > 0

	on execute do
		undo "Generate Supports" on
		(
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\0-[SUPPORTS].mcr"
			generateSupportsOrRafts obj_type:#SUPPORT
		)
)




/**
 */
macroscript	_print_platform_generator_base_width
category:	"_3D-Print"
buttontext:	"BASE width"
tooltip:	"Width of base part\n\nRECOMENDED: 10"
icon:	"across:3|control:spinner|range:[ 0.1, 999, 10 ]|width:90|offset:[ -10, 12 ]"
(
	on execute do
	(
		format "EventFired:	% \n" EventFired
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\0-[SUPPORTS].mcr"
		SUPPORT_MANAGER.updateModifiers ( EventFired )
	)
)

/**
 */
macroscript	_print_platform_generator_base_height
category:	"_3D-Print"
buttontext:	"BASE Height"
tooltip:	"Height of support base"
icon:	"across:3|control:spinner|range:[ 0.1, 999, 1 ]|width:72|offset:[ 30, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)
