
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

/**  Export format
  *
 */
macroscript	_print_generator_normal_mode
category:	"_Export"
buttontext:	"Second Point Direction"
toolTip:	"Where support is connected to beam"
icon:	"across:3|align:#LEFT|control:radiobuttons|unselect:false|items:#( 'NORMAL', 'DOWN' )|columns:3|offset:[ 4, 2]"
(
	--export_dir = execute ("@"+ "\""+EventFired.Roll.export_dir.text +"\"")

	--DosCommand ("explorer \""+export_dir+"\"")
	--SUPPORT_MANAGER.updateModifiers ( EventFired )
	on execute do
	(
		--format "EventFired	= % \n" EventFired
		SUPPORT_OPTIONS.second_point_direction = EventFired.val
		
		_selection = for obj in selection collect obj

		/* GET SELECTED SUPPORTS & RAFTS */ 
		selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		

		pauseSupportTransformEvent()
		
		/*------------------------------------------------------------------------------
			REBUILD SELECTED SUPPORTS & RAFTS
		--------------------------------------------------------------------------------*/
		SUPPORT_MANAGER.updateSupports(selected_supports+selected_rafts) direction:(if EventFired.val == 1 then #NORMAL else #DOWN)

		
		resumeSupportTransformEvent()
	)
)

/** SPINNER
  */
macroscript	_print_platform_generator_normal_length
category:	"_3D-Print"
buttontext:	"Raft Length"
tooltip:	"Length of raft part of support\n\nFOR AUTO LENGTH RESET TO 0.0"
icon:	"ACROSS:3|control:spinner|id:SPIN_normal_length|offset:[ 12, 20 ]|fieldwidth:24|range:[ 0.0, 999, 3 ]|fieldwidth:32"
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
buttontext:	"LOCK DIRECTION"
tooltip:	"Lock length of support direction on move"
icon:	"ACROSS:3|control:checkbox|id:CBX_lock_normal_length|offset:[ 24, 20 ]|checked:true"
(
	/* https://help.autodesk.com/view/MAXDEV/2021/ENU/?guid=GUID-5A4580C6-B5CF-12104-898B-9313D1AAECD4 */
	--on isEnabled return selection.count > 0

	on execute do
		SUPPORT_OPTIONS.lock_normal_length = EventFired.val
		--SUPPORT_MANAGER.updateModifiers ( EventFired )
)


--/* LIVE UPDATE
--*/
--macroscript	_print_support_generator_live_update
--category:	"_3D-Print"
--buttontext:	"LIVE UPDATE"
--tooltip:	"Live update supports on their transfrom"
--icon:	"across:3|control:#checkbutton|offset:[ 8, 6 ]|height:32|width:96|tooltip:"
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
--icon:	"control:checkbox|across:3|offset:[ 12, 2 ]"
--(
--	--(PrinterVolume_v()).createVolume(#box)(ROLLOUT_export.SPIN_export_size.value)
--)


