--DEV
--filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/SupportManager.ms" )	--"./../../../Lib/SupportManager/SupportManager.ms"

/*------------------------------------------------------------------------------
	
	BEMAS BUTTON
	
--------------------------------------------------------------------------------*/

/*

  IF SELECTED 1 support, then beam is generated to closest support
  IF SELECTED 2 supports, then beam is generated betweene thes supports if does not exists. Otherwise closest supports wil be connected



*/
macroscript	_print_support_generator_beams
category:	"_3D-Print"
buttontext:	"B E A M S"
tooltip:	"CONNECT CLOSEST SUPPORTS\n\nCTRL: USE ONLY SELECTED SUPPORTS."
icon:	"across:4|offset:[ -6, 2 ]|width:96|height:32|tooltip:GENERATE BEAMS for selected supports.\n\nIMPORTANT - IF 2 SUPPORTS SELECTED THEN\n FORCE CONNECT WITHOUT MAX DISTANCE"
(
	on execute do
		undo "Generate Beams" on
		(
			SUPPORT_MANAGER.BeamGenerator.use_only_selected_supports	= (not keyboard.controlPressed)
			
			SUPPORT_MANAGER.generateBeams()
		)
)

/*
*/
macroscript	_print_support_generator_beams_max_distance_off
category:	"_3D-Print"
buttontext:	"B E A M S"
tooltip:	"OPEN MENU"
(
	on execute do
		undo "Generate Beams" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-GENERATOR\BEAMS.mcr"

			/* DEFINE MAIN MENU */
			Menu = RcMenu_v name:"GenerateBeamsMenu"

			Menu.item "Connect supports in CHAIN"	( "SUPPORT_MANAGER.generateBeams sort_mode:#JOIN_SUPPORTS_CHAIN"	)

			popUpMenu (Menu.create())
		)
)

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
icon:	"across:4|control:checkbox|offset:[ 12, 0 ]|tooltip:USE MAX DISTANCE between supports where beams will be generated"
(
	--on execute do
		--SUPPORT_MANAGER.BeamGenerator.use_max_distance	= EventFired.val

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
icon:	"across:4|control:spinner|id:#SPIN_max_distance|type:#integer|range:[ 1, 999, 5 ]|filedwidth:64|offset:[ -24, 0 ]|tooltip:Max distance between supports where beams can be created\n\nRMB: Get distance of 2 selected supports"
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
macroscript	_print_generator_beams_max_length
category:	"_3D-Print"
buttontext:	"Min Height"
--tooltip:	""
icon:	"across:4|control:spinner|type:#integer|range:[ 1, 999, 5 ]|width:72|offset:[ 0, 0 ]|tooltip:MIN HEIGHT OF SUPPORT LEG where beam is created|align:#RIGHT"
(
	/** Get size
	 */
	function getSize obj = (bbox	= nodeGetBoundingBox obj ( Matrix3 1))[2].z - bbox[1].z


	--bbox	= nodeGetBoundingBox obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z

	on execute do
		if EventFired.inSpin and EventFired.Control.value == EventFired.Control.range[1] and selection.count > 0 then
		(
			sizes = for obj in selection collect  getSize obj

			EventFired.Control.value = SUPPORT_OPTIONS.getMilimeterValue(amax sizes)
		)
		else
			SUPPORT_MANAGER.updateModifiers (EventFired)

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
icon:	"across:4|control:checkbox|id:CBX_only_ground|offset:[ 100, -10 ]|tooltip:Connect only SUPPORTS with foot|checked:true"
(

)


/**
  *
 */
macroscript	_print_generator_beams_count_per_support
category:	"_Export"
--buttontext:	"[Connections count]"
buttontext:	"Density"
--buttontext:	"Max Beams"
icon:	"control:dropdownlist|id:DL_max_connections|across:4|offset:[ 104, -12 ]|width:42|items:#( '1', '2', '3')|unselect:true|tooltip:Max count of beams connected to support"
(
	--format "EventFired	= % \n" EventFired
	--SUPPORT_MANAGER.updateModifiers ( EventFired )
)

--/**
--  *
-- */
--macroscript	_print_generator_beams_count
--category:	"_Export"
--buttontext:	"[Beams Count]"
----toolTip:	"Beams Count"
--icon:	"control:radiobuttons|across:4|align:#CENTER|items:#('1', '2')|offset:[ 102, -10 ]|tooltip:Number of bars on beam"
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
buttontext:	"Split"
--buttontext:	"Max Beams"
icon:	"control:dropdownlist|id:DL_beams_split|across:4|offset:[ 100, -12 ]|width:80|items:#( 'Square', 'Rectangle')|tooltip:Pattern of spliting beams along support"
(
	on execute do
		SUPPORT_OPTIONS.beams_split = EventFired.val
	
	--format "EventFired	= % \n" EventFired
	--SUPPORT_MANAGER.updateModifiers ( EventFired )
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
