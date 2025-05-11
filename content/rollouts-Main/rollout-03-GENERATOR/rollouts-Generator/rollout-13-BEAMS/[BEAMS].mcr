/*
	--"./../../../Lib/SupportManager/SupportManager.ms"
	--"./../../../../../Lib/SupportOptions/SupportOptions.ms"
*/ 



/*------------------------------------------------------------------------------

	OPTIONS

--------------------------------------------------------------------------------*/


/** USE MAX DISTANCE CHECKBOX
  *
  */
macroscript	_print_generator_beams_max_distance_toggle
category:	"_3D-Print"
buttontext:	"Max Distance"
--tooltip:	"USE MAX DISTANCE between supports where beams will be generated"
icon:	"across:4|control:checkbox|id:#CBX_use_max_distance|tooltip:USE MAX DISTANCE between supports where beams will be generated"
(
	on execute do
		SUPPORT_OPTIONS.use_max_distance = EventFired.val

	--(
	--	--format "EventFired:	% \n" EventFired
	--	SUPPORT_OPTIONS.setOptionValue (#max_distance) EventFired.val
	--)
)


/**
  *
  */
macroscript	_print_generator_beams_max_distance
category:	"_3D-Print"
buttontext:	"[Max Distance Value]"
--tooltip:	"Max distance between supports"
icon:	"across:4|offset:[ -36, 0 ]|control:spinner|id:#SPIN_max_distance|type:#integer|range:[ 1, 999, 5 ]|filedwidth:64|tooltip:Max distance between supports where beams can be created\n\nRMB: Get distance of 2 selected supports"
(
	on execute do
	(
		--format "EventFired:	% \n" EventFired
		--format "EventFired.Control.value: %\n" EventFired.Control.value
		--format "EventFired.Control.range[1]: %\n" EventFired.Control.range[1]
		format "test: %\n" (EventFired.Control.value == EventFired.Control.range[1] )

		--EventFired.Control.tooltip = EventFired.Control.value as string + "mm is max distance between supports"
		--
		--/** Get size
		-- */
		--function getSize obj = (bbox	= nodeGetBoundingBox obj ( Matrix3 1))[2].z - bbox[1].z
		--
		--if not EventFired.inSpin and EventFired.Control.value == EventFired.Control.range[1] and selection.count >= 2 then
		--if not EventFired.inSpin and selection.count >= 2 then
		--(
			--sizes = for obj in selection collect  getSize obj

		/* RICKGLICK: RESET TO DISTANCE BETWEEN SELECTED SUPPORTS */ 
		if selection.count >= 2 and EventFired.val == (EventFired.control.range).x and not EventFired.inspin then
			EventFired.Control.value = SUPPORT_OPTIONS.getMilimeterValue( distance selection[1].pos selection[2].pos )
		--)
		--else
		--SUPPORT_OPTIONS.setOptionValue (#max_distance) EventFired.val

			--SUPPORT_MANAGER.updateModifiers (EventFired)
	)
)


/**
  *
 */
macroscript	_print_generator_beams_count_per_support
category:	"_Export"
--buttontext:	"[Connections count]"
buttontext:	"Density"
--buttontext:	"Max Beams"
--icon:	"across:4|control:dropdownlist|id:DL_max_connections|width:42|items:#( '1', '2', '3')|unselect:true|tooltip:Max count of beams connected to support"
icon:	"across:4|control:dropdownlist|id:DL_max_connections|width:52|items:#( 'LOW', 'MID', 'HIGH')|unselect:true|tooltip:Max count of beams connected to support"
(
	on execute do
	(
		format "EventFired	= % \n" EventFired
		SUPPORT_OPTIONS.max_connections = EventFired.val
	)
)

--/**
--  *
-- */
--macroscript	_print_generator_beams_count
--category:	"_Export"
--buttontext:	"[Beams Count]"
----toolTip:	"Beams Count"
--icon:	"control:radiobuttons|across:3|align:#CENTER|items:#('1', '2')|tooltip:Number of bars on beam"
--(
--	--format "EventFired	= % \n" EventFired
--	--on execute do
--	--SUPPORT_MANAGER.updateModifiers ( EventFired )
--)


/**
  *
 */
macroscript	_print_generator_beams_split
category:	"_Export"
--buttontext:	"[Connections count]"
buttontext:	"Zig Zag"
--buttontext:	"Max Beams"
icon:	"across:4|control:dropdownlist|id:DL_beams_split|width:80|items:#( 'Square', 'Rectangle')|tooltip:Set shape of zig zag pattern of beams"
(
	on execute do
		SUPPORT_OPTIONS.beams_split = EventFired.val
	
	--format "EventFired	= % \n" EventFired
	--SUPPORT_MANAGER.updateModifiers ( EventFired )
)




/**
  *
  */
macroscript	_print_generator_beams_max_length
category:	"_3D-Print"
buttontext:	"Min Height            "
--tooltip:	""
icon:	"id:SPIN_min_height|across:1|align:#LEFT|offset:[ 4, -20 ]|control:spinner|type:#integer|range:[ 1, 999, 5 ]|width:128|fieldWidth:32|oltip:MIN HEIGHT OF SUPPORT LEG where beam is created"
(
	/** Get size
	 */
	function getSize obj = (bbox	= nodeGetBoundingBox obj ( Matrix3 1))[2].z - bbox[1].z


	--bbox	= nodeGetBoundingBox obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z

	on execute do
		--if EventFired.inSpin and EventFired.Control.value == EventFired.Control.range[1] and selection.count > 0 then
	--	(
	format "EventFired	= % \n" EventFired
	--
	--		sizes = for obj in selection collect  getSize obj
	--
	--		EventFired.Control.value = SUPPORT_OPTIONS.getMilimeterValue(amax sizes)
	--	)
	--	else
	--		SUPPORT_MANAGER.updateModifiers (EventFired)

		--print "\nSpinner test #rightclick or spinner RESETED\n\n3Ds Max BUG ?\n\nArgument inCancel DOESN'T WORK"
	--else
	--	print "Spinner test #entered"
)



/** USE MAX DISTANCE CHECKBOX
  *
  */
macroscript	_print_generator_beams_only_ground
category:	"_3D-Print"
buttontext:	"With Foot"
icon:	"across:1|offset:[ 0, 0 ]|control:checkbox|id:CBX_only_ground|tooltip:Connect only SUPPORTS with foot|checked:true"
(

)








--/**
--  *
--  */
--macroscript	_print_generator_beams_max_length
--category:	"_3D-Print"
--buttontext:	"Same Height"
--tooltip:	"Set height of beams on each support"
--icon:	"across:5|control:checkbox|offset:[ 0, 6 ]"
--(
--	format "EventFired:	% \n" EventFired
--)

/*==============================================================================

		GENERATE BUTTON

================================================================================*/



--/**  BEAM POSITION
--  *
-- */
--macroscript	_print_generator_beams_connect_increment
--category:	"_Export"
--buttontext:	"[Connect]"
--toolTip:	"Where support is connected to beam"
--icon:	"control:radiobuttons|across:5|align:#CENTER|items:#('END', 'MIDDLE', 'THIRD', 'QUATER')|columns:4|offset:[ -72, -12 ]"
--(
--	--export_dir = execute ("@"+ "\""+EventFired.Roll.export_dir.text +"\"")
--
--	--DosCommand ("explorer \""+export_dir+"\"")
--	--format "EventFired	= % \n" EventFired
--)
