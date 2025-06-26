filein( getFilenamePath(getSourceFileName()) + "/../../../../../Lib/SupportManager/GridSupportSeeder/GridSupportSeeder.ms" )	--"./../../../../../Lib/SupportManager/GridSupportSeeder/GridSupportSeeder.ms"


/** SUPPORT FOOT
 */
macroscript	_print_support_seeder
category:	"_3D-Print"
buttontext:	"S E E D E R"
tooltip:	"Seed Supports"
icon:	"ACROSS:4"
(
	on execute do
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-03-GENERATOR\rollouts-Generator\rollout-11-SUPPORTS\02-SEEDER.mcr"
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
		if selection.count == 0 then
			objs_input = source_objects
		
		/* GET OBJECTS BY TYPE */ 	
		supports = SUPPORT_MANAGER.getObjectsByType objs_input type:#SUPPORT --hierarchy:select_more
		
		format "SOURCE_OBJECTS: %\n" source_objects
		format "SUPPORTS:       %\n" supports
	
		GridSupportSeeder = GridSupportSeeder_v()
		
		--GridSupportSeeder.cell_size = 30
		GridSupportSeeder.cell_size = 15
		--GridSupportSeeder.cell_size = 5
		
		GridSupportSeeder.initGrid(source_objects)
		
		GridSupportSeeder.sortNodesToMatrix (supports)
		
		
		
		format "\n------------------------ PALCE OBJECTS TO POSITION OF CLOSEST VERT OF HIT -------------------------------\n"
		
		closest_verts    = GridSupportSeeder.getClosestVertsOfEmptyCells(source_objects) #VERTS
		--closest_verts    = GridSupportSeeder.getClosestVertsOfEmptyCells(source_objects) #HITS
		format "closest_verts: %\n" closest_verts
		/* SHOW RESULT */ 
		if closest_verts != undefined then
			for obj_pointer in closest_verts.keys do
			(
				obj = getAnimByHandle (obj_pointer as IntegerPtr )
				--format "closest_verts[obj_pointer]: %\n" closest_verts[obj_pointer]
				format "obj: %\n" obj
				format "classOf obj.modifiers[obj.modifiers.count]: %\n" (classOf obj.modifiers[obj.modifiers.count])
				if classOf obj.modifiers[obj.modifiers.count] != Edit_Poly then
					addModifier obj (Edit_Poly ())
				
				format "CLOSEST_VERTS: %\n" closest_verts[obj_pointer]
				
				select obj
				
				max modify mode
				
				subObjectLevel = 1
				
				obj.modifiers[#Edit_Poly].SetSelection #Vertex #{}
				
				obj.modifiers[#Edit_Poly].Select #Vertex closest_verts[obj_pointer]
				
				--for closest_vert_pos in closest_verts[obj_pointer] do
				--(
				--	
				--	
				--)
				
					--Sphere pos:closest_vert_pos radius:1 --wirecolor:(getAnimByHandle ( obj_pointer as IntegerPtr )).wirecolor
					--Sphere pos:closest_vert_pos radius:1 wirecolor:orange
			)
		 
		
				
		
	)
)