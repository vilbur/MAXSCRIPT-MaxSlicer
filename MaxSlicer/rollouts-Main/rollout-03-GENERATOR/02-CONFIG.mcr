
/** Rebuild supports
 */
function resetSupports param: =
(
	--format "\n"; print ".resetSupports()"
	
	_selection = for obj in selection collect obj

	/* GET SELECTED SUPPORTS & RAFTS */ 
	selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
	selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
	

	pauseSupportTransformEvent()
	
	
	/*------------------------------------------------------------------------------
		REBUILD SELECTED SUPPORTS & RAFTS
	--------------------------------------------------------------------------------*/
	SUPPORT_MANAGER.resetSupports(selected_supports)

	resumeSupportTransformEvent()
)

/**  RAFT DIRECTION RADIOBUTTONS
  *
 */
macroscript	_print_generator_raft_length
category:	"_Export"
buttontext:	"Raft Direction"
toolTip:	"Direction of support top part"
icon:	"across:4|align:#LEFT|control:radiobuttons|unselect:false|items:#( 'DOWN', 'NORMAL' )|offset:[ -2, 2 ]|offsets:#([0, 4], [ -4, 4 ] )"
(
	on execute do
	(
		--format "EventFired	= % \n" EventFired
		SUPPORT_OPTIONS.raft_direction = EventFired.val
		
		_selection = for obj in selection collect obj

		/* GET SELECTED SUPPORTS & RAFTS */ 
		selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		
		/* PAUSE CALLBACKS */ 
		pauseSupportTransformEvent()
		
		/*------------------------------------------------------------------------------
			REBUILD SELECTED SUPPORTS & RAFTS
		--------------------------------------------------------------------------------*/
		SUPPORT_MANAGER.updateSupports(selected_supports+selected_rafts) direction:(if EventFired.val == 1 then #DOWN else #NORMAL )

		/* ENABLE DISBALE DEPENDENT CONTROLS */ 
		ROLLOUT_generator.RB_raft_mode.enabled = EventFired.val == 2
		
		ROLLOUT_generator.SPIN_normal_length.enabled = EventFired.val == 2 and ROLLOUT_generator.RB_raft_mode.state == 0
		
		/* RESUME CALLBACKS */ 
		resumeSupportTransformEvent()
	)
)
/** RAFT MODE RADIOBUTTONS
  *
 */
macroscript	_print_generator_raft_length_mode
category:	"_Export"
buttontext:	"Raft Mode"
toolTip:	"UNSELECTED: Use defined raft length\n\nMIN: Use minimal raft length\n\nAUTO: Extend raft to get support with leg"
icon:	"across:4|control:radiobuttons|unselect:true|items:#( 'MIN', 'AUTO' )|offset:[ 48, 2 ]|offsets:#([0, 4], [ -4, 4 ] )|tooltip:Set method of getting raft length of support."
(
	on execute do
	(
		--format "EventFired: %\n" EventFired
		/* ENABLE DISBALE DEPENDENT CONTROLS */ 
		ROLLOUT_generator.SPIN_normal_length.enabled = EventFired.val == 0
		
		SUPPORT_OPTIONS.raft_mode = EventFired.val
	)
)

/** RAFT LENGTH SPINNER
  */
macroscript	_print_platform_generator_normal_length
category:	"_3D-Print"
buttontext:	"Length"
tooltip:	"Length of raft part of support\n\nFOR AUTO LENGTH RESET TO 0.0"
icon:	"ACROSS:4|control:spinner|id:SPIN_raft_length|offset:[ 44, 22 ]|fieldwidth:24|range:[ 0.0, 999, 3 ]|fieldwidth:32"
(
	on execute do
	(
		format "EventFired	= % \n" EventFired
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\Lib\SupportManager\SupportManager.ms"
		
		
		/* RICKGLICK: RESET DO RECOEMNDED VALUE */ 
		--if EventFired.val == (EventFired.control.range).x and not EventFired.inspin then
			--EventFired.val = EventFired.control.value = ( SUPPORT_OPTIONS.getOption #BAR_WIDTH ) * 2


		SUPPORT_OPTIONS.normal_length = EventFired.val
		
		resetSupports()
	)
)

/*
*/ 
macroscript	_print_option_lock_normal
category:	"_3D-Print"
buttontext:	"LOCK"
tooltip:	"Lock length of support direction on move"
icon:	"ACROSS:4|control:checkbox|id:CBX_lock_raft_length|offset:[ 50, 22 ]"
(
	/* https://help.autodesk.com/view/MAXDEV/2021/ENU/?guid=GUID-5A4580C6-B5CF-12104-898B-9313D1AAECD4 */
	--on isEnabled return selection.count > 0

	on execute do
		SUPPORT_OPTIONS.lock_raft_length = EventFired.val
		--SUPPORT_MANAGER.updateModifiers ( EventFired )
)


--/* LIVE UPDATE
--*/
--macroscript	_print_support_generator_live_update
--category:	"_3D-Print"
--buttontext:	"LIVE UPDATE"
--tooltip:	"Live update supports on their transfrom"
--icon:	"across:4|control:#checkbutton|offset:[ 8, 6 ]|height:32|width:96|tooltip:"
--(
--	on execute do
--		--undo "Generate Rafts" on
--		(
--			SUPPORT_OPTIONS.live_update_supports = EventFired.val
--		)
--)


--
--/**
--  *
--  */
--macroscript	_print_support_generate_quet
--category:	"_3D-Print"
--buttontext:	"Quiet Mode"
----toolTip:	"For objects to keep position on export\n\n(Create boxes in corners of print plane to keep exported position)"
--icon:	"control:checkbox|across:4|offset:[ 12, 2 ]"
--(
--	--(PrinterVolume_v()).createVolume(#box)(ROLLOUT_export.SPIN_export_size.value)
--)


