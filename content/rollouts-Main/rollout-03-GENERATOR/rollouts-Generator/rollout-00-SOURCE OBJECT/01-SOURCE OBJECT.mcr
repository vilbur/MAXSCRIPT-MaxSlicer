
/** KEEP MODIFIERS UNIQUE
 */
macroscript	_print_keep_source_obj_min_z_pos_toggle
category:	"_3D-Print"
buttontext:	"KEEP MIN Z POSITION"
icon:	"across:2|control:checkbox|id:CBX_keep_source_minz_z_pos|width:140|height:28|state:true"
(
	on execute do
	(
		SUPPORT_OPTIONS.keep_source_minz_z_pos = EventFired.val
		
		if EventFired.val then
		(
			--source_objects = for obj in selection where SUPPORT_MANAGER.isType #SOURCE obj != false collect obj
			SourceObjects = SUPPORT_MANAGER.getSourceObjects (selection as Array )
			
			for SourceObject in SourceObjects do
			(
				SourceObject.setMinZpos(SUPPORT_OPTIONS.base_to_support_gap)
				
			)
			--format "source_object: %\n" source_object
				
		)
		
	)
)

/**
 */
macroscript	_print_base_to_support_gap
category:	"_3D-Print"
buttontext:	"Layers above base"
tooltip:	""
icon:	"across:2|control:spinner|id:SPIN_base_to_support_gap|type:#INTEGER|fieldwidth:24|range:[ 0, 999, 20 ]|scale:1|offset:[ -60, 8 ]|tooltip:how many layers is prented between support base and source object ( avoid glue of supports and printed object )"
(
	on execute do
		SUPPORT_OPTIONS.base_to_support_gap = EventFired.val

)
