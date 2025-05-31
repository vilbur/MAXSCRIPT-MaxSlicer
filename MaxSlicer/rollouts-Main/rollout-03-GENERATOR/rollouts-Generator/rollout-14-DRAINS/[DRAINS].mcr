--filein( getFilenamePath(getSourceFileName()) + "/Lib/PinsGenerator.ms" )	--"./Lib/PinsGenerator.ms"
filein( getFilenamePath(getSourceFileName()) + "/Lib/wirecolorByModifierInstance.ms" )	--"./Lib/wirecolorByModifierInstance.ms"



/**
 */
macroscript	_print_platform_generator_drain_width
category:	"_3D-Print"
buttontext:	"WIDTH"
tooltip:	"Width of bar in mm.\n\nExported scale is used"
icon:	"control:spinner|across:5|id:SPIN_drain_width|range:[ 0.5, 10, 1.0 ]|width:80|offset:[ 26, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-14-DRAINS\[DRAINS].mcr"
		_selection = ( if selection.count > 0 then selection else objects ) as Array

		drains = SUPPORT_MANAGER.getObjectsByType ( _selection ) type:#DRAIN --hierarchy:false

		width = EventFired.val
		radius = width / 2
		steps = ROLLOUT_drains.SPIN_drain_interpolation.value
		--format "drains: %\n" drains

		if drains.count > 0 then
		(
			mods = #()

			select drains

			for drain in drains where drain.modifiers[#DRAIN_WIDTH] !=undefined do
				appendIfUnique mods drain.modifiers[#DRAIN_WIDTH]

			for _mod in mods do
			(
				_mod[#Cylinder_Section].radius = radius
					
				if steps == -1 then
				(
					
					_mod[#Cylinder_Section].steps = width as integer

					
				)
				
			)
		)

		SUPPORT_MANAGER.updateModifiers ( EventFired )
	)
)

/**
 */
macroscript	_print_platform_generator_drain_interpolation
category:	"_3D-Print"
buttontext:	"Int"
tooltip:	"Steps of interpolation of drain obejcts\n\nAUTO MODE if value is -1"
icon:	"control:spinner|id:SPIN_drain_interpolation|type:#INTEGER|range:[ -1, 32, 6 ]|width:42|offset:[ 20, 12 ]|val:-1"
(
	on execute do
	(
		format "EventFired:	% \n" EventFired
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-14-DRAINS\[DRAINS].mcr"
		_selection = ( if selection.count > 0 then selection else objects ) as Array

		drains = SUPPORT_MANAGER.getObjectsByType ( _selection ) type:#DRAIN --hierarchy:false

		steps = EventFired.val
		
		if drains.count > 0 and steps > -1 then
		(
			mods = #()

			select drains

			for drain in drains where drain.modifiers[#DRAIN_WIDTH] !=undefined do
				appendIfUnique mods drain.modifiers[#DRAIN_WIDTH]

			for _mod in mods do
				_mod[#Cylinder_Section].steps = EventFired.val
		)
	)
)

/**
 */
macroscript	_print_platform_generator_drain_bottom
category:	"_3D-Print"
buttontext:	"↓"
tooltip:	"How low is drain dummy is placed bellow vertex"
icon:	"control:spinner|id:SPIN_drain_bottom|range:[ 0, 10, 2 ]|width:52|offset:[ 12, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)

/**
 */
macroscript	_print_platform_generator_drain_top
category:	"_3D-Print"
buttontext:	"↑"
tooltip:	"How high is drain dummy is placed above vertex"
icon:	"control:spinner|id:SPIN_drain_top|range:[ 0, 10, 1 ]|width:52|offset:[ 0, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)


--/**
-- */
--macroscript	_print_platform_generator_drain_display_as_box
--category:	"_3D-Print"
--buttontext:	"Dsiplay as box"
--tooltip:	"Bar width in mm of printed model.\n\nExported scale is used"
--icon:	"control:spinner|id:SPIN_drain_width|across:3|range:[ 0.5, 10, 1.0 ]|width:64|offset:[ -8, 12 ]"
--(
--	--format "EventFired:	% \n" EventFired
--	on execute do
--		SUPPORT_MANAGER.updateModifiers ( EventFired )
--)
