/** RESET USER DATA
 */
macroscript	_print_reset_source_object_userprops_normals
category:	"_3D-Print"
buttontext:	"Reset Normals"
tooltip:	"Reset normals data in userprops of selected or visible source objects."
icon:	"ACROSS:2"
(
	on execute do
	(
		/* GET INPUT OBEJCTS - SELECTION or objects BY VISIBILITY */ 
		objs_input = if selection.count > 0 then selection as Array else for obj in objects where obj.isHidden == false collect obj 
	
		/* GET INPUT SOURCE OBJECTS */ 
		source_objects = SUPPORT_MANAGER.getObjectsByType objs_input type:#SOURCE
		
		if source_objects.count > 0 then
		(
			message = if source_objects.count > 1 then "OBJECTS ?\n" else "OBJECT ?\n"
			
			for source_object in source_objects do message += "\n" + source_object.name
			
			if queryBox ("Reset NORMLAS ON " + message ) title:"RESET NORMALS" beep:false then
				for source_object in source_objects do
					deleteUserProp source_object "normals_local"
		)
	)
)


/** RESET USER DATA
 */
macroscript	_print_reset_source_object_userprops
category:	"_3D-Print"
buttontext:	"Reset Props"
tooltip:	"Reset data in userprops of selected or visible source objects"
--icon:	"offset:[0,10]"
(
	on execute do
	(
		/* GET INPUT OBEJCTS - SELECTION or objects BY VISIBILITY */ 
		objs_input = if selection.count > 0 then selection as Array else for obj in objects where obj.isHidden == false collect obj 
		format "objs_input: %\n" objs_input
		/* GET INPUT SOURCE OBJECTS */ 
		source_objects = SUPPORT_MANAGER.getObjectsByType objs_input type:#SOURCE
		format "source_objects: %\n" source_objects
		if source_objects.count > 0 then
		(
			message = if source_objects.count > 1 then "OBJECTS ?\n" else "OBJECT ?\n"
			
			for source_object in source_objects do message += "\n" + source_object.name
			
			if queryBox ("Reset USER DATA ON " + message ) title:"RESET USER PROPS" beep:false then
				for source_object in source_objects do
					setUserPropBuffer source_object ""
		)
	)
)