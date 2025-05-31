
/** KEEP MODIFIERS UNIQUE
 */
macroscript	_print_keep_source_obj_min_z_pos_toggle
category:	"_3D-Print"
buttontext:	"KEEP MIN Z POSITION"
icon:	"across:2|control:checkbox|id:CBX_keep_source_minz_z_pos|width:140|height:28|state:true|tooltip:LOCK source object Z position"
(
	on execute do
	(
		SUPPORT_OPTIONS.keep_source_minz_z_pos = EventFired.val
		
		if EventFired.val then
		(
			--SUPPORT_MANAGER.setMinZpos ( selection) ( SUPPORT_OPTIONS.base_to_support_gap )

			SourceObjects = SUPPORT_MANAGER.getSourceObjects ( selection as Array ) --get_nodes:true
			
			for SourceObject in SourceObjects do
				SOURCE_OBJECT_TRANSFORM.keepMinZposition(SourceObject.obj) use_current_z_pos:true

			redrawViews()

		)
		
	)
)

/**
 */
macroscript	_print_base_to_support_gap
category:	"_3D-Print"
buttontext:	"Layers above base"
tooltip:	""
icon:	"across:2|control:spinner|id:SPIN_z_pos_lock|type:#INTEGER|fieldwidth:24|range:[ 0, 999, 20 ]|scale:1|offset:[ -60, 8 ]|tooltip:Shift source object from along Z pos by layers"
(
	on execute do
	(
		
		SUPPORT_OPTIONS.z_pos_lock = EventFired.val
		
		--SUPPORT_MANAGER.setMinZpos ( selection) (EventFired.val)
		source_objects = SUPPORT_MANAGER.getSourceObjects ( selection as Array ) get_nodes:true

		for source_object in source_objects do
		(
			setUserPropVal source_object "Z_POS_LOCK" EventFired.val
			
			SOURCE_OBJECT_TRANSFORM.keepMinZposition(source_object)
		)
		
		redrawViews()
	)
)
