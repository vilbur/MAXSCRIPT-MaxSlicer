
/** Toggle support foot
  * 
  * @params boolean state TRUE: Toggle curent state of foot 	|	FALSE: Disable foot always
  * 
 */
function toggleSupportFoot state =
(
	format "\n"; print ".toggleSupportFoot()"
	SupportObjects = SUPPORT_MANAGER.getSupportObjects ( selection as Array ) obj_type:#SUPPORT

	SupportObjects = for SupportObject in SupportObjects where SupportObject.is_on_ground collect SupportObject
	
	/* TOOGLE BY CURRENT STATE */ 
	if state then
	(
		enabled_foot  = for SupportObject in SupportObjects where SupportObject.foot_enabled == true  collect SupportObject
		disabled_foot = for SupportObject in SupportObjects where SupportObject.foot_enabled == false collect SupportObject
		format "enabled_foot.count:  %\n" enabled_foot.count
		format "disabled_foot.count: %\n" disabled_foot.count
		state = disabled_foot.count > enabled_foot.count 
	)
	format "state: %\n" state
	
	for SupportObject in SupportObjects where SupportObject.is_on_ground do
	(
		SupportObject.foot_enabled = state
		
		SupportObject.updateSupport()
	)

	SUPPORT_MANAGER.updateShapes()
)


/** SUPPORT FOOT
 */
macroscript	_print_support_toggle_foot_true
category:	"_3D-Print"
buttontext:	"FOOT Toggle"
tooltip:	"ENABLE Foot"
--icon:	"offset:[0,10]"
(
	on execute do
		toggleSupportFoot(true)

)

/** SUPPORT FOOT
 */
macroscript	_print_support_toggle_foot_false
category:	"_3D-Print"
buttontext:	"FOOT Toggle"
tooltip:	"DISABLE Foot"
icon:	""
(
	on execute do
		toggleSupportFoot(false)
)

/** SUPPORT FOOT
 */
macroscript	_print_support_toggle_foot_false
category:	"_3D-Print"
buttontext:	"FOOT Toggle"
tooltip:	"DISABLE Foot"
icon:	""
(
	on execute do
		toggleSupportFoot(false)
)

--/**
-- */
--macroscript	_print_support_straighten
--category:	"_3D-Print"
--buttontext:	"Straighten"
--tooltip:	"Make support straigh by removing all knots from line"
--icon:	""
--(
--	on execute do
--		if queryBox ("Convert support to straigt lines ?") title:"Straighten support" then
--		(
--			_objects = selection as Array
--	
--			supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT
--	
--			for support in supports where ( num_knots = numKnots support 1 ) > 2 do
--			(
--				for i = 2 to num_knots - 1 do
--					deleteKnot support 1 i
--	
--				updateShape support
--			)
--		)
--)
--
--/**
--  *
--  */
--macroscript	print_tools_connect_selected_poins
--category:	"_3D-Print"
--buttontext:	"Verts To Line"
--tooltip:	"Connect selected vers of Edit Poly object with line"
--(
--	on execute do
--	(
--		obj = selection[1]
--
--		vertex_sel = (getVertSelection obj.mesh) as Array
--
--		verts_pos = for vert in vertex_sel collect (getVert obj.mesh vert) * obj.transform
--		--format "verts_pos	= % \n" verts_pos
--
--		if verts_pos.count >= 2 then
--		(
--
--			_shape = SplineShape name:(obj.name + "-connect")
--
--			addNewSpline _shape
--
--			for vert_pos in verts_pos do
--				addKnot _shape 1 #corner #line vert_pos
--
--			updateShape _shape
--
--		)
--
--		select _shape
--	)
--)