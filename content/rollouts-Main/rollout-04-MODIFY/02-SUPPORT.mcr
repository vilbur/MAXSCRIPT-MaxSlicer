
/** KEEP MODIFIERS UNIQUE
 */
macroscript	_print_modifiers_keep_unique
category:	"_3D-Print"
buttontext:	"K E E P   I N S T A N C E S"
icon:	"across:1|control:checkbox|id:CBX_keep_instances|height:28"
(
	on execute do
	(
		--format "\n"
		format "EventFired:	% \n" EventFired
	)

)

/** OFFSET SEEP MODIFIER
 */
macroscript	_print_platform_offset_x
category:	"_3D-Print"
buttontext:	"Offset Bar"
icon:	"across:1|align:#LEFT|control:spinner|range:[ -999, 100, 0 ]|width:78|offset:[ 0, 0 ]|ini:false|tooltip:Modify offset of sweep  modifier #BAR_WIDTH.\n\nWorks on SUPPORTS, RAFTS & BEAMS.\n\nCTRL: Modify Y offset"
(
	on execute do
	(
		--format "\n"
		--format "EventFired:	% \n" EventFired

		_selection = ( if selection.count > 0 then selection else geometry ) as Array

		prop_key =  if keyboard.controlPressed then #yOffset else #xOffset

		supports = SUPPORT_MANAGER.getObjectsByType _selection type:#SUPPORT
		rafts    = SUPPORT_MANAGER.getObjectsByType _selection type:#RAFT
		beams    = SUPPORT_MANAGER.getObjectsByType _selection type:#BEAM

		mods = #()

		/* GET MODIFOERS */
		for obj in supports do
			appendIfUnique mods obj.modifiers[#BAR_WIDTH]


		for _mod in mods do
		(

			if not ROLLOUT_modify.CBX_keep_instances.state then
			(
				objs_with_mod = #()
				mods_new = #()

				mod_name = _mod.name

				/* GET ALL OBJECTS WITH INSTANCE OF MODIFIER */
				for obj in objects do
					for _modifier in obj.modifiers where _mod == _modifier and ( refhierarchy.isRefTargetInstanced _modifier ) do
						append objs_with_mod obj

				format "objs_with_mod.count: %\n" objs_with_mod.count
				/* GET UNSELECTED OBEJCTS WOTH SAME ISNTANCE */
				instances_unselected = for obj in objs_with_mod where findItem _selection obj == 0 collect obj

				if instances_unselected.count > 0 then
				(
					/* MAKE MODIFIERS UNIQUE */
					InstanceMgr.MakeModifiersUnique supports _mod #GROUP

					/* GET NEW UNIQUE MODIFIERS */
					for obj in _selection do
						appendIfUnique mods_new obj.modifiers[#SWEEP]

					/* RESET NAME */
					for mod_new in mods_new do
						mod_new.name = mod_name
				)
			)

			/* SET VALUE TO MODIIFERS */
			for obj in supports do
				setProperty obj.modifiers[#BAR_WIDTH] prop_key EventFired.val
		)
	)
)