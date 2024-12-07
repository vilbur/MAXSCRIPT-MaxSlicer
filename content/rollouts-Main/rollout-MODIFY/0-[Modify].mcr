
/** KEEP MODIFIERS UNIQUE
 */
macroscript	_print_modifiers_keep_unique
category:	"_3D-Print"
buttontext:	"K E E P   I N S T A N C E S"
icon:	"control:checkbutton|id:CBX_keep_instances|across:1|width:140|height:28"
(
	on execute do
	(
		--format "\n"
		format "EventFired:	% \n" EventFired
	)

)