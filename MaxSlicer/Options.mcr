

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
macroscript	_print_set_export_size
category:	"_Export"
buttontext:	"Export Size"
toolTip:	"Export size"
icon:	"Control:spinner|range:[0.01,100,1]|offset:[16,0]|across:4|align:#left|width:96"
(
	format "eventFired	= % \n" eventFired
	
	EXPORT_SIZE = eventFired.val


	/* FIRED BY MAXSCRIPT ON STARTUP */ 
	if eventFired == undefined then
	(
		if EXPORT_SIZE == undefined then 
			EXPORT_SIZE = DIALOG_maxslicer.SPIN_export_size.value
		else
			DIALOG_maxslicer.SPIN_export_size.value = EXPORT_SIZE
	)
	/* FIRED BY CONTROL EVENT  */ 
	else
		EXPORT_SIZE = eventFired.val

	/* SYNC WITH MaxSlicer */ 
	if DIALOG_nodeexporter != undefined then 
		DIALOG_nodeexporter.SPIN_export_size.value = DIALOG_maxslicer.SPIN_export_size.value


)

