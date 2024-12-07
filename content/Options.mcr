

/**
 */
macroscript	_print_layer_height
category:	"_3D-Print"
buttontext:	"Layer Height"
tooltip:	"Height of printed layer in mm"
icon:	"across:4|control:spinner|fieldwidth:32|range:[ 0.03, 0.1, 0.05 ]|scale:0.01|offset:[ 8, 0 ]"
(
	--updateSlicePlaneSystem(undefined)
	on execute do
	(
		format "EventFired:	% \n" EventFired
		_spinner = EventFired.control

		/* RESET SPINNER TO VALUE HIGHER THEN MIN RANGE */
		if not EventFired.inSpin and EventFired.val == _spinner.range.x then
			EventFired.control.value = 0.05


	)
)

/**
 */
macroscript	_export_settings_size
category:	"_Export"
buttontext:	"Export Size"
toolTip:	"Export size"
icon:	"Control:spinner|range:[0.01,100,1]|offset:[16,0]|across:4|align:#left|width:64"
(
	format "eventFired	= % \n" eventFired
)

