--filein( getFilenamePath(getSourceFileName()) + "/Lib/PinsGenerator.ms" )	--"./Lib/PinsGenerator.ms"


--/*
--*/
--macroscript	_print_generator_pins
--category:	"_3D-Print"
--buttontext:	"PINS"
--icon:	"across:4|offset:[ 0, 0 ]|height:32|width:96|tooltip:GEENERATE PINS for selected verts"
--(
--	on execute do
--		undo "Generate Pins" on
--		(
--			clearListener(); print("Cleared in:\n"+getSourceFileName())
--			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-LAYERS\Lib\SceneLayers\SceneLayers.ms"
--			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\Lib\SupportManager\SupportManager.ms"
--			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\5-PINS.mcr"
--
--			--(getSupportManagerInstance(ROLLOUT_pins)).createPins( selection as Array )
--			(PinsGenerator_v(ROLLOUT_pins)).createPins( selection[1] )
--		)
--)



/**
  *
  */
macroscript	_print_generator_pins_width
category:	"_3D-Print"
buttontext:	"Pin Width"
tooltip:	"Diameter of inner pin"
icon:	"across:4|control:spinner|type:#float|range:[ 1, 999, 3 ]|width:72|offset:[ 24, 8 ]"
(
	format "EventFired:	% \n" EventFired
)

/**
  *
  */
macroscript	_print_generator_pins_height
category:	"_3D-Print"
buttontext:	"Pin Height"
tooltip:	"Height of inner pin"
icon:	"across:4|control:spinner|type:#float|range:[ 1, 999, 5 ]|width:72|offset:[ 36, 8 ]"
(
	format "EventFired:	% \n" EventFired
)
/**
  *
  */
macroscript	_print_generator_pins_gap
category:	"_3D-Print"
buttontext:	"Pin Gap"
tooltip:	"Size of gap between inner and outter pin"
icon:	"across:4|control:spinner|type:#float|range:[ 0.1, 999, 0.2 ]|width:72|offset:[ 16, 8 ]"
(
	format "EventFired:	% \n" EventFired
)


/*==============================================================================

		GENERATE BUTTON

================================================================================*/
