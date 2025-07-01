filein( getFilenamePath(getSourceFileName()) + "/../../../../../Lib/SupportManager/GridSupportSeeder/GridSupportSeeder.ms" )	--"./../../../../../Lib/SupportManager/GridSupportSeeder/GridSupportSeeder.ms"

/** Seed supports bellow selection
 */
function seedSupportsBellowSelection grid_type debug:false =
(
	--format "\n"; print ".seedSupportsBellowSelection()"
	clearListener(); print("Cleared in:\n"+getSourceFileName())
	--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-03-GENERATOR\rollouts-Generator\rollout-11-SUPPORTS\02-SEEDER.mcr"
	--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\Lib\SupportManager\Seeder\Seeder.ms"
	
	
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
	
	
	--for obj in source_objects do
	--(
	--	if ( _mod = obj.modifiers[#VertexPaint] ) != undefined then
	--			deleteModifier obj _mod
	--			
	--	if ( _mod = obj.modifiers[#VERTEX_PAINT_SELECT] ) != undefined then
	--			deleteModifier obj _mod
	--)

	
	
	Seeder = GridSupportSeeder_v(source_objects)
	
	--Seeder.cell_size = 30
	Seeder.cell_size = ROLLOUT_SUPPORTS.SPIN_cell_size.value
	
	Seeder.debug = debug
	
	--grid_type = if ROLLOUT_SUPPORTS.RB_seeder_mode.state then #RADIAL else #GRID
	
	/* IF SQUARE */ 
	if grid_type == #RADIAL then
	(
		
		Seeder.segments_count = ROLLOUT_SUPPORTS.SPIN_segments_count.value
				
		Seeder.segments_count_keep = ROLLOUT_SUPPORTS.CBX_segments_count_keep.state
	)
	
	closest_verts = Seeder.getClosestVertsOfEmptyCells(supports) #VERTS grid_type

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
			
			--VertexColorProcessor = VertexColorProcessor_v(obj)
			
			--VertexColorProcessor.setVertexColor (closest_verts[obj_pointer]  as BitArray )orange
	
			(VertSelector_v(obj)).setSelection ( closest_verts[obj_pointer] ) --isolate:true
		)
	 
	
	select source_objects

	/* GENRATE SUPPORTS */ 		
	if not keyboard.controlPressed and not debug then
		generateSupportsOrRafts obj_type:#SUPPORT
	
	
)

/*------------------------------------------------------------------------------
	GRID BUTTON 
--------------------------------------------------------------------------------*/
/** SUPPORT FOOT
 */
macroscript	_print_support_seeder_grid
category:	"_3D-Print"
buttontext:	"G R I D"
tooltip:	"Seed Supports\n\nCTRL: DO NOT GENERATE SUPPORTS, Only select verts."
icon:	"ACROSS:5|width:80|height:32|offset:[ -2, 0 ]"
(
	on execute do
		seedSupportsBellowSelection #GRID
)
/** SUPPORT FOOT
 */
macroscript	_print_support_seeder_grid_debug
category:	"_3D-Print"
buttontext:	"G R I D"
tooltip:	"DEBUG MODE: SHOW \ HIDE GRID AND HITS"
icon:	"ACROSS:5|width:80|height:32|offset:[ -4, 0 ]"
(
	on execute do
	(
		if ( seeder_helpers = $'GRID-SEEDER-HELPER*' ) != undefined then 
			delete seeder_helpers
		
		else
			seedSupportsBellowSelection #GRID debug:true
	)
)

/*------------------------------------------------------------------------------
	SPINNED GRID
--------------------------------------------------------------------------------*/
/**
 */
macroscript	_print_support_seeder_cell_size
category:	"_3D-Print"
buttontext:	"Grid"
toolTip:	"SQUARE GRID: Cell size of grid.\n\nRADIAL GRID: Distance between circles."
icon:	"ACROSS:5|control:spinner|id:SPIN_cell_size|fieldwidth:28|range:[ 1, 1024, 10 ]|type:#integer|width:64|offset:[ -6, 10 ]"
(
	on execute do
		format "EventFired: %\n" EventFired
)

/*------------------------------------------------------------------------------
	RADIAL BUTTON
--------------------------------------------------------------------------------*/

/** 
 */
macroscript	_print_support_seeder_radial
category:	"_3D-Print"
buttontext:	"R A D I A L"
tooltip:	"Seed Supports\n\nCTRL: DO NOT GENERATE SUPPORTS, Only select verts."
icon:	"ACROSS:5|width:80|height:32|offset:[ 2, 0 ]"
(
	on execute do
		seedSupportsBellowSelection #RADIAL
)


/**  
  *
 */
macroscript	_print_support_seeder_mode_segments_count
category:	"_3D-Print"
buttontext:	"Sec"
toolTip:	""
icon:	"ACROSS:5|control:spinner|id:SPIN_segments_count|fieldwidth:28|range:[ 3, 1024, 12 ]|type:#integer|width:64|offset:[ 10, 10 ]|tooltip:Count of radial steps.\n\nHow many times is circle divided"
(
		format "EventFired	= % \n" EventFired

)

/**  
  *
 */
macroscript	_print_support_seeder_mode_segments_count_keep
category:	"_3D-Print"
buttontext:	"Fix"
toolTip:	"TRUE: Produce \"RAYS OF SUN\" pattern\n\nFALSE:  Produce \"SUNFLOWER\" pattern"
icon:	"ACROSS:5|control:checkbox|id:CBX_segments_count_keep|offset:[ 28, 10 ]|checked:true"
(
		format "EventFired	= % \n" EventFired

)





