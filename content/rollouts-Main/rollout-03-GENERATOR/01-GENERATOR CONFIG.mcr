
/** Rebuild supports
 */
function resetSupports param: =
(
	--format "\n"; print ".resetSupports()"
		
		_selection = for obj in selection collect obj

		/* GET SELECTED SUPPORTS & RAFTS */ 
		selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		

		pauseSupportToTransformEvent()
		
		
		/*------------------------------------------------------------------------------
			REBUILD SELECTED SUPPORTS & RAFTS
		--------------------------------------------------------------------------------*/
		
		
		--if param == #NORMAL_LENGTH then 
		--	SUPPORT_MANAGER.updateSupports(selected_supports)
		--
		--else
			SUPPORT_MANAGER.resetSupports(selected_supports)
		
		

		resumeSupportToTransformEvent()
		
		--if selected_supports.count > 0 then
		--(
		--	pauseSupportToTransformEvent()
		--
		--	SUPPORT_MANAGER.resetSupports(selected_supports)
		--
		--	resumeSupportToTransformEvent()
		--)
		--
		--if selected_rafts.count > 0 then
		--(
		--	pauseSupportToTransformEvent()
		--
		--	SUPPORT_MANAGER.resetSupports(selected_rafts)
		--
		--	resumeSupportToTransformEvent()
		--)
		
)



--/*
--*/
--macroscript	_print_support_generator_update
--category:	"_3D-Print"
--buttontext:	"LIVE UPDATE"
--tooltip:	"Update selected supports"
--icon:	"control:#checkbutton"
--(
--	on execute do
--		--undo "Generate Rafts" on
--		(
--			--SUPPORT_OPTIONS.live_update_supports = EventFired.val
--			print "update"
--		)
--)

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
		format "EventFired	= % \n" EventFired
	
		SUPPORT_OPTIONS.second_point_direction = EventFired.val
		
		resetSupports()
	)
)

/** SPINNER
  */
macroscript	_print_platform_generator_normal_length
category:	"_3D-Print"
buttontext:	"Normal Length"
tooltip:	"Length of first segment of platform facing to vertex normal"
icon:	"across:3|control:spinner|offset:[ 8, 20 ]|fieldwidth:24|range:[ 0.1, 999, 3 ]|fieldwidth:32"
(
	on execute do
	(
		--format "EventFired	= % \n" EventFired
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\Lib\SupportManager\SupportManager.ms"
		
		
		/* RICKGLICK: RESET DO RECOEMNDED VALUE */ 
		if EventFired.val == (EventFired.control.range).x and not EventFired.inspin then
			EventFired.val = EventFired.control.value = ( SUPPORT_OPTIONS.getOption #BAR_WIDTH ) * 2
			--EventFired.val = EventFired.control.value = (SupportOptions_v()).normal_length
		
		--bar_radius = SUPPORT_OPTIONS.getOption #BAR_WIDTH
		--
		--range = ROLLOUT_generator.SPIN_normal_length.range
		--
		--/* SET MIN VALUE */
		----if range.x > bar_radius then
		--
		--if EventFired.val < bar_radius then
		--(
		--	EventFired.val = bar_radius
		--
		--	range.x = bar_radius
		--	range.z = bar_radius
		--
		--	ROLLOUT_generator.SPIN_normal_length.range = range
		--)
		--
		SUPPORT_OPTIONS.normal_length = EventFired.val
		resetSupports()

		--resetSupports param:#NORMAL_LENGTH
	)
)

/*
*/
macroscript	_print_support_generator_live_update
category:	"_3D-Print"
buttontext:	"LIVE UPDATE"
tooltip:	"Live update supports on their transfrom"
icon:	"across:3|control:#checkbutton|offset:[ 8, 6 ]|height:32|width:96|tooltip:"
(
	on execute do
		--undo "Generate Rafts" on
		(
			SUPPORT_OPTIONS.live_update_supports = EventFired.val
		)
)
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


