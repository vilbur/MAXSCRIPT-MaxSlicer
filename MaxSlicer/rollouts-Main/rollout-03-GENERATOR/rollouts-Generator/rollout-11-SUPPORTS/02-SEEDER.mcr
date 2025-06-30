filein( getFilenamePath(getSourceFileName()) + "/../../../../../Lib/SupportManager/GridSupportSeeder/GridSupportSeeder.ms" )	--"./../../../../../Lib/SupportManager/GridSupportSeeder/GridSupportSeeder.ms"


/** SUPPORT FOOT
 */
macroscript	_print_support_seeder
category:	"_3D-Print"
buttontext:	"S E E D E R"
tooltip:	"Seed Supports\n\nCTRL: DO NOT GENERATE SUPPORTS, Only select verts."
icon:	"ACROSS:4"
(
	on execute do
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-03-GENERATOR\rollouts-Generator\rollout-11-SUPPORTS\02-SEEDER.mcr"
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\Lib\SupportManager\GridSupportSeeder\GridSupportSeeder.ms"
		
		
		objects_by_visibility	= for obj in objects where obj.isHidden == false collect obj -- GET ONLY VISIBILITY OBJECTS - if select mode
			
		/* GET INPUT OBEJCTS - SELECTION or objects BY VISIBILITY */ 
		objs_input = if selection.count > 0 then selection as Array else objects_by_visibility
	
		/* GET INPUT SOURCE OBJECTS */ 
		source_objects = SUPPORT_MANAGER.getObjectsByType objs_input type:#SOURCE
		--format "SOURCE_OBJECTS: %\n" source_objects
		
		/* TEST IF SOURCE OBJECT IS SELECTED */ 
		select_by_source_objects = with PrintAllElements on ( sort ( for obj in selection collect getHandleByAnim obj ) ) as string == ( sort (for obj in source_objects collect getHandleByAnim obj ) ) as string
		
		/* USE SOURCE OBJECTS AS INPUT IF NOTHING SELECTED */ 
		if source_objects.count == 0 and selection.count > 0 then
			objs_input = source_objects = selection as Array
		
		/* GET OBJECTS BY TYPE */ 	
		supports = SUPPORT_MANAGER.getObjectsByType objs_input type:#SUPPORT --hierarchy:select_more
		
		format "SOURCE_OBJECTS: %\n" source_objects
		format "SUPPORTS:       %\n" supports
		
		if source_objects.count == 0 then
			return false
		
		GridSupportSeeder = GridSupportSeeder_v(source_objects)
		
		--GridSupportSeeder.cell_size = 30
		GridSupportSeeder.cell_size = SUPPORT_OPTIONS.base_width
		
		grid_type = #( #GRID, #CIRCLE )[ROLLOUT_SUPPORTS.RB_seeder_mode.state]
		
		/* IF SQUARE */ 
		if grid_type == #CIRCLE then
		(
			
			GridSupportSeeder.segments_count = ROLLOUT_SUPPORTS.SPIN_segments_count.value
					
			GridSupportSeeder.segments_count_keep = ROLLOUT_SUPPORTS.CBX_segments_count_keep.state
		)
		
		closest_verts = GridSupportSeeder.getClosestVertsOfEmptyCells(source_objects) #VERTS grid_type

		format "CLOSEST_VERTS: %\n" closest_verts
		
		/* SHOW RESULT */ 
		if closest_verts != undefined then
			for obj_pointer in closest_verts.keys do
			(
				obj = getAnimByHandle (obj_pointer as IntegerPtr )
				--format "closest_verts[obj_pointer]: %\n" closest_verts[obj_pointer]
				format "obj: %\n" obj
				format "classOf obj.modifiers[obj.modifiers.count]: %\n" (classOf obj.modifiers[obj.modifiers.count])
				--if classOf obj.modifiers[obj.modifiers.count] != Edit_Poly then
					--addModifier obj (Edit_Poly ())
				
				format "CLOSEST_VERTS PER OBJECT: %\n" closest_verts[obj_pointer]
				
				select obj

				subObjectLevel = 1
		
				(VertSelector_v(obj)).setSelection ( closest_verts[obj_pointer] ) --isolate:true
		
				VertexColorProcessor = VertexColorProcessor_v(obj)
				
				VertexColorProcessor.setVertexColor (closest_verts[obj_pointer]  as BitArray )orange
			)
		 
		
		select source_objects

		/* GENRATE SUPPORTS */ 		
		if not keyboard.controlPressed then
			generateSupportsOrRafts obj_type:#SUPPORT
	)
)


/**  RAFT DIRECTION RADIOBUTTONS
  *
 */
macroscript	_print_support_seeder_mode
category:	"_3D-Print"
buttontext:	"[Seeder mode]"
toolTip:	""
--icon:	"across:4|align:#LEFT|control:radiobuttons|unselect:false|items:#( 'Square', 'Circle' )|columns:3|offset:[ -2, 4 ]|offsets:#([0, 2], [ -4, 2 ] )"
icon:	"across:4|control:radiobuttons|unselect:false|items:#( 'GRID', 'CIRCLE' )|offset:[ 24, 4 ]|"
(
	on execute do
	(
		format "EventFired	= % \n" EventFired
		--SUPPORT_OPTIONS.raft_direction = EventFired.val
		--
		--_selection = for obj in selection collect obj
		--
		--/* GET SELECTED SUPPORTS & RAFTS */ 
		--selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		--selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		--
		--/* PAUSE CALLBACKS */ 
		--pauseSupportTransformEvent()
		--
		--/*------------------------------------------------------------------------------
		--	REBUILD SELECTED SUPPORTS & RAFTS
		----------------------------------------------------------------------------------*/
		--SUPPORT_MANAGER.updateSupports(selected_supports+selected_rafts) direction:(if EventFired.val == 1 then #DOWN else #NORMAL )
		--
		--/* ENABLE DISBALE DEPENDENT CONTROLS */ 
		ROLLOUT_SUPPORTS.SPIN_segments_count.enabled = EventFired.val == 2
		ROLLOUT_SUPPORTS.CBX_segments_count_keep.enabled = EventFired.val == 2
		--ROLLOUT_SUPPORTS.SPIN_normal_length.enabled = EventFired.val == 2 and ROLLOUT_generator.RB_raft_mode.state == 0
		--
		--/* RESUME CALLBACKS */ 
		--resumeSupportTransformEvent()
	)
)


/**  RAFT DIRECTION RADIOBUTTONS
  *
 */
macroscript	_print_support_seeder_mode_segments_count
category:	"_3D-Print"
buttontext:	"Segments"
toolTip:	""
--icon:	"across:4|align:#LEFT|control:radiobuttons|unselect:false|items:#( 'Square', 'Circle' )|columns:3|offset:[ -2, 4 ]|offsets:#([0, 2], [ -4, 2 ] )"
icon:	"across:4|control:spinner|id:SPIN_segments_count|fieldwidth:28|range:[ 3, 1024, 12 ]|type:#integer|width:64|offset:[ 64, 4 ]|tooltip:Xxx"
(
		format "EventFired	= % \n" EventFired

)


/**  RAFT DIRECTION RADIOBUTTONS
  *
 */
macroscript	_print_support_seeder_mode_segments_count_keep
category:	"_3D-Print"
buttontext:	"keep"
toolTip:	""
icon:	"ACROSS:4|control:checkbox|id:CBX_segments_count_keep|offset:[ 48, 4 ]"
(
		format "EventFired	= % \n" EventFired

)
