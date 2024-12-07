
/** Toggle support foot
 */
function toggleSupportFoot state =
(
	--format "\n"; print ".toggleSupportFoot()"
	mods = #()

	_objects = selection as Array

	supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT

	for mod_name in #( #SELECT_BASE, #BASE_WIDTH, #CHAMFER_BASE ) do
		for obj in supports where obj.modifiers[mod_name] != undefined do
			appendIfUnique mods obj.modifiers[mod_name]

	with redraw off
		for _mod in mods do
			_mod.enabled = state

	redrawViews()
)

/** SUPPORT FOOT
 */
macroscript	_print_support_toggle_foot_true
category:	"_3D-Print"
buttontext:	"Toggle Foot"
tooltip:	""
--icon:	"offset:[0,10]"
(
	on execute do
		toggleSupportFoot true
)

/** SUPPORT FOOT
 */
macroscript	_print_support_toggle_foot_false
category:	"_3D-Print"
buttontext:	"Toggle Foot"
tooltip:	""
icon:	""
(
	on execute do
		toggleSupportFoot false
)

/**
 */
macroscript	_print_support_straighten
category:	"_3D-Print"
buttontext:	"Straighten"
tooltip:	"Make support straigh by removing all knots from line"
icon:	""
(
	on execute do
	if queryBox ("Convert support to straigt lines ?") title:"Straighten support" then

	(
		_objects = selection as Array

		supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT

		for support in supports where ( num_knots = numKnots support 1 ) > 2 do
		(
			for i = 2 to num_knots - 1 do
				deleteKnot support 1 i

			updateShape support
		)

	)
		--toggleSupportFoot false
)


