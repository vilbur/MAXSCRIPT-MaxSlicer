/*
	USED:
		--"./../../../Lib/SupportManager/Lib/generateSupportsOrRafts.ms"

*/ 

/*------------------------------------------------------------------------------
	S U P P O R T S
--------------------------------------------------------------------------------*/
macroscript	_print_support_generator
category:	"_3D-Print"
buttontext:	"S U P P O R T S"
--tooltip:	""
icon:	"ACROSS:5|height:40|width:84|offset:[ 2, 6 ]|tooltip:• GEENERATE SUPPORTS.\n\n• RESET SELECTED SUPPORTS\n\n• CONVERT SELECTED RAFTS TO SUPPORTS.\n\nPriority o verts:\n  1) Selected Verts\n  2) Verts with vertex color"
(
	/* https://help.autodesk.com/view/MAXDEV/2021/ENU/?guid=GUID-5A4580C6-B5CF-4104-898B-9313D1AAECD4 */
	on isEnabled return selection.count > 0

	on execute do
		undo "Generate Supports" on
		(
			--clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\0-[SUPPORTS].mcr"
			generateSupportsOrRafts obj_type:#SUPPORT
		)
)


/*------------------------------------------------------------------------------
	R A F T S
--------------------------------------------------------------------------------*/
/*
*/
macroscript	_print_support_generator_rafts
category:	"_3D-Print"
buttontext:	"R A F T S"
icon:	"offset:[ 10, 6]|height:40|width:76|tooltip:GEENERATE RAFTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) SUPPORTS - Turn support into raft"
(
	on execute do
		undo "Generate Rafts" on
		(

			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-SUPPORTS\2-SUPPORTS.mcr"
			generateSupportsOrRafts obj_type:#RAFT
		)
)

/*------------------------------------------------------------------------------
	
	B E M A S
	
--------------------------------------------------------------------------------*/

/*

  IF SELECTED 1 support, then beam is generated to closest support
  IF SELECTED 2 supports, then beam is generated betweene thes supports if does not exists. Otherwise closest supports wil be connected



*/
macroscript	_print_support_generator_beams
category:	"_3D-Print"
buttontext:	"B E A M S"
tooltip:	"Connect closest supports\n\nCTRL: KEEP SELECTION ORDER\nSHIFT: USE ONLY SELECTED SUPPORTS."
icon:	"offset:[ 18, 6 ]|height:40|width:76|tooltip:GENERATE BEAMS for selected supports.\n\nIMPORTANT:\n\n  If 2 SUPPORTS SELECTED then\n    FORCE connect without max distance"
(
	on execute do
		undo "Generate Beams" on
		(
			--clearListener(); print("Cleared in:\n"+getSourceFileName())
			_selection = for obj in selection collect obj
		
			/* SEARCH FOR SOURCE OBJECTS IN SLECTION */ 
			source_objects = for obj in _selection where SUPPORT_MANAGER.isType #SOURCE obj != false collect obj

			supports_selection = if source_objects.count == _selection.count then
				SUPPORT_MANAGER.getObjectsByType ( _selection ) type:#SUPPORT
			else
				_selection
			
			/* GET SUPPORTS */ 
			supports =	SUPPORT_MANAGER.getSupportObjects( supports_selection ) get_nodes:true
			
				
			--format "supports: %\n" supports
			SUPPORT_MANAGER.BeamGenerator.use_only_selected_supports = (not keyboard.shiftPressed )

			SUPPORT_MANAGER.generateBeams supports sort_mode:( if not keyboard.controlPressed then #JOIN_CLOSE_SUPPORTS )
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

			Menu.item "Connect supports in CHAIN" ( "SUPPORT_MANAGER.generateBeams ( SUPPORT_MANAGER.getSupportObjects (SUPPORT_MANAGER.getObjectsByType ( selection as Array ) type:#SUPPORT) get_nodes:false  ) sort_mode:#JOIN_SUPPORTS_CHAIN")

			popUpMenu (Menu.create())
		)
)


/*------------------------------------------------------------------------------
	D R A I N S
--------------------------------------------------------------------------------*/

/*
*/
macroscript	_print_generator_holes
category:	"_3D-Print"
buttontext:	"D R A I N S"
icon:	"offset:[ 28, 6 ]|height:40|width:74|tooltip:GEENERATE PINS for selected verts"
(
	on execute do
		undo "Generate DRAINS" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\Lib\SupportManager\SupportManager.ms"
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-PINS_&_DRAINS\DRAINS.mcr"
			SUPPORT_MANAGER.generateDrainHoles()
		)
)

/*
*/
macroscript	_print_generator_holes_rcmenu
category:	"_3D-Print"
buttontext:	"D R A I N S"
(
	on execute do
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())

		/* DEFINE MAIN MENU */
		Menu = RcMenu_v name:"DrainsRcMenu"

		Menu.item "Set wirecolor by instance"	"wirecolorByModifierInstance #DRAIN_WIDTH"

		popUpMenu (Menu.create())
	)
)

/*------------------------------------------------------------------------------
	P I N S
--------------------------------------------------------------------------------*/
/*
*/
macroscript	_print_generator_pins
category:	"_3D-Print"
buttontext:	"P I N S"
icon:	"offset:[ 22, 6 ]|height:40|width:54|tooltip:GEENERATE PINS for selected verts"
(
	on execute do
		undo "Generate Pins" on
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-LAYERS\Lib\SceneLayers\SceneLayers.ms"
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\Lib\SupportManager\SupportManager.ms"
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\5-PINS.mcr"

			--(getSupportManagerInstance(ROLLOUT_pins)).createPins( selection as Array )
			(PinsGenerator_v(ROLLOUT_pins)).createPins( selection[1] )
		)
)
