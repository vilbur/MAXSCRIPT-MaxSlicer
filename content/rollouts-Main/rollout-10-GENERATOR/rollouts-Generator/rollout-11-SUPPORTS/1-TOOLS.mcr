
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

/**
  *
  */
macroscript	print_tools_connect_selected_poins
category:	"_3D-Print"
buttontext:	"Verts To Line"
tooltip:	"Connect selected vers of Edit Poly object with line"
(
	on execute do
		(
			clearListener(); print("Cleared in:\n"+getSourceFileName())
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\PLATFORM-TOOLS.mcr"

			--createslicerSliderDialog()
			--verts_pos = #()

			obj = selection[1]

			vertex_sel = (getVertSelection obj.mesh) as Array

			verts_pos = for vert in vertex_sel collect (getVert obj.mesh vert) * obj.transform
			--format "verts_pos	= % \n" verts_pos

			if verts_pos.count >= 2 then
			(

				_shape = SplineShape name:(obj.name + "-connect")

				addNewSpline _shape

				for vert_pos in verts_pos do
					addKnot _shape 1 #corner #line vert_pos

				updateShape _shape

			)

			select _shape

		)
)