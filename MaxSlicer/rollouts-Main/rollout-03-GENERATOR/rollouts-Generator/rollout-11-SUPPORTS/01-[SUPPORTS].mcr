
/*==============================================================================

		COTNROLS ROW 1

================================================================================*/

global SPIN_CHAMFER_BAR_LAST_VALUE

--/*------------------------------------------------------------------------------
--	GENERATE SUPPORT BUTTON
----------------------------------------------------------------------------------*/
--macroscript	_print_support_generator
--category:	"_3D-Print"
--buttontext:	"S U P P O R T"
--icon:	"ACROSS:4|height:32|width:96|offset:[ 0, 6 ]|tooltip:GEENERATE SUPPORTS"
--(
--	/* https://help.autodesk.com/view/MAXDEV/2021/ENU/?guid=GUID-5A4580C6-B5CF-4104-898B-9313D1AAECD4 */
--	on isEnabled return selection.count > 0
--
--	on execute do
--		undo "Generate Supports" on
--		(
--			clearListener(); print("Cleared in:\n"+getSourceFileName())
--			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\0-[SUPPORTS].mcr"
--			generateSupportsOrRafts obj_type:#SUPPORT
--		)
--)

/*
*/ 
macroscript	_print_support_foot_option
category:	"_3D-Print"
buttontext:	"Make Foot"
tooltip:	"Generate supports WITH\WITHOUT FOOT"
icon:	"ACROSS:4|control:checkbox|id:CBX_foot_enabled|offset:[ -2, 16 ]"
(
	/* https://help.autodesk.com/view/MAXDEV/2021/ENU/?guid=GUID-5A4580C6-B5CF-12104-898B-9313D1AAECD4 */
	--on isEnabled return selection.count > 0

	on execute do
		SUPPORT_OPTIONS.foot_enabled = EventFired.val
		--SUPPORT_MANAGER.updateModifiers ( EventFired )

)

/** BAR WIDTH
 */
macroscript	_print_platform_generator_set_bar_width
category:	"_3D-Print"
buttontext:	"WIDTH"
tooltip:	""
icon:	"control:spinner|id:SPIN_bar_width|fieldwidth:32|range:[ 0.4, 3, 1.4 ]|width:64|offset:[ 0, 16 ]|tooltip:WIDTH of support LEG\n\nrightclick: RESET TO RECOMENDED VALUE"
(
	on execute do
	(
		--format "EventFired: %\n" EventFired
		--format "(EventFired.control.range).z: %\n" (EventFired.control.range).z
		--format "EventFired.val == (EventFired.control.range).x: %\n" (EventFired.val == (EventFired.control.range).x)
		--format "not EventFired.inspin: %\n" (not EventFired.inspin)
		--
		/* RICKGLICK: RESET DO RECOEMNDED VALUE */ 
		if EventFired.val == (EventFired.control.range).x and not EventFired.inspin then
			EventFired.val = EventFired.control.value = (SupportOptions_v()).bar_width
		
		--else
		(
			/* BASE VALUE MUST BE HIGHER THEN WIDTH */ 
			if EventFired.val >= ROLLOUT_supports.SPIN_base_width.value or SPIN_CHAMFER_BAR_LAST_VALUE == ROLLOUT_supports.SPIN_base_width.value then
				ROLLOUT_supports.SPIN_base_width.value = EventFired.val + 1
			
			/* TOP VALUE MUST BE LESS THEN WIDTH */ 
			if EventFired.val <= ROLLOUT_supports.SPIN_top_width.value or SPIN_CHAMFER_BAR_LAST_VALUE == ROLLOUT_supports.SPIN_top_width.value then
				ROLLOUT_supports.SPIN_top_width.value = EventFired.val
		)
		
		/* STORE VALUE */ 
		SPIN_CHAMFER_BAR_LAST_VALUE = EventFired.val
		
		/* UPDATE VALUE */ 
		SUPPORT_MANAGER.updateModifiers ( EventFired )
		--SUPPORT_MANAGER.updateModifierCustomAttribute ( EventFired )
	)
)


/**
 */
macroscript	_print_platform_generator_base_width
category:	"_3D-Print"
buttontext:	"BASE"
tooltip:	""
icon:	"control:spinner|id:SPIN_base_width|fieldwidth:32|range:[ 1, 999, 10 ]|scale:1|width:90|offset:[ -10, 4 ]|tooltip:WIDTH of support BASE\n\nrightclick: RESET TO RECOMENDED VALUE"
(
	on execute do
	(
		--format "EventFired:	% \n" EventFired
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\0-[SUPPORTS].mcr"
		
		/* RICKGLICK: RESET DO RECOEMNDED VALUE */ 
		if EventFired.val == (EventFired.control.range).x and not EventFired.inspin then
			EventFired.val = EventFired.control.value = (SupportOptions_v()).base_width
	
		/* BASE VALUE MUST BE HIGHER THEN WIDTH */ 
		else if EventFired.val < (bar_width = ROLLOUT_supports.SPIN_bar_width.value) then
		(
			base_width = bar_width + 1
			
			EventFired.val = base_width
			
			EventFired.control.value = base_width
			
			format "BASE WITH MUST MORE THEN BAR WIDTH: %\n" base_width
		)
		
		SUPPORT_MANAGER.updateModifiers ( EventFired )
	)
)

/**
 */
macroscript	_print_platform_generator_bar_chamfer
category:	"_3D-Print"
buttontext:	"TOP"
tooltip:	""
icon:	"control:spinner|id:SPIN_top_width|fieldwidth:32|range:[ 0.1, 3, 0.5 ]|width:64|offset:[ 0, 4 ]|tooltip:WIDTH of support TOP\n\nrightclick: RESET TO RECOMENDED VALUE"
(
	on execute do
	(
		/* RICKGLICK: RESET DO RECOEMNDED VALUE */ 
		if EventFired.val == (EventFired.control.range).x and not EventFired.inspin then
			EventFired.val = EventFired.control.value = (SupportOptions_v()).top_width
		
		/* TOP VALUE MUST BE LESS THEN WIDTH */ 
		else if EventFired.val > (bar_width = ROLLOUT_supports.SPIN_bar_width.value) then
		(
			EventFired.val = bar_width
			
			EventFired.control.value = bar_width
			
			format "TOP WITH MUST BE LESS THEN BAR WIDTH: %\n" bar_width
		)
	
		SUPPORT_MANAGER.updateModifiers ( EventFired )
		--SUPPORT_MANAGER.udpateTopWidth ( EventFired )
	)
)



/*==============================================================================

		COTNROLS ROW 2

================================================================================*/


/**
 */
macroscript	_print_platform_generator_base_height
category:	"_3D-Print"
buttontext:	"HEIGHT"
tooltip:	"Height of support base"
icon:	"ACROSS:3|control:spinner|id:SPIN_base_height|fieldwidth:32|range:[ 0.5, 999, 1 ]|width:72|offset:[ 150, 0 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
	(
		SUPPORT_OPTIONS.base_height = EventFired.val
		
		SUPPORT_MANAGER.updateBaseHeight()
	)
)

/** EXTRUDE TOP
 */
macroscript	_print_platform_generator_extrude_top
category:	"_3D-Print"
buttontext:	"EXT"
tooltip:	"Extrude end part in mm of printed model.\n\nExported scale is used"
icon:	"control:spinner|id:SPIN_extend_top|fieldwidth:32|width:64|range:[ 0, 99, 0.05 ]|offset:[ 114, 0 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)
