
/** Select supports by beams count
 */
function selectSupportsByBeamsCount count =
(
	--format "\n"; print ".selectSupportsByBeamsCount()"
	_objects = (if selection.count > 0 then selection else objects) as Array

	--supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT
	supports = SUPPORT_MANAGER.getSupportAndRaftObjects ( selection as Array )

	bemas_of_supports = for support in supports collect SUPPORT_MANAGER.getObjectsByType support type:#BEAM

	supports_by_count = for i = 1 to bemas_of_supports.count where bemas_of_supports[i].count == count collect supports[i]

	if supports_by_count.count > 0 then
		select supports_by_count
)


/**
 *
 */
macroscript	maxtoprint_select_verts_by_supports
category:	"maxtoprint"
buttontext:	"SUPPORT ↔ VERT"
icon:	"across:4|tooltip:SELECT VERTS BY SUPPORTS & VICE VERSA"
(

	/** Select supports by vert
	 */
	function selectSupportsByVerts =
	(
		format "\n"; print ".selectSupportsByVert()"

		obj	= selection[1]

		--source_objects = SUPPORT_MANAGER.getObjectsByType ( obj ) type:#SOURCE -- hierarchy:shift
		--format "source_objects: %\n" source_objects
		vertex_sel	= getVertSelection obj.mesh

		SourceObjects = SUPPORT_MANAGER.getSourceObjects ( selection as Array )
		--format "SourceObjects: %\n" SourceObjects

		SourceObject = SourceObjects[1]

		supports = for index in SourceObject.Supports.keys where vertex_sel[index] collect SourceObject.Supports[index].support_obj

		if supports.count > 0 then
			select supports

	)

	/** Select verts by supports
	 */
	function selectVertsBySupports =
	(
		format "\n"; print ".selectVertsBySupports()"
		format "selection.count: %\n" selection.count
		
		_objects = selection as Array
		format "_objects.count: %\n" _objects.count
		source_objects = SUPPORT_MANAGER.getObjectsByType ( _objects ) type:#SOURCE -- hierarchy:shift
		
		format "source_objects: %\n" source_objects
		
		supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT
		
		format "\n"
		for support in supports do 
			format "support.name: %\n" support.name
		format "\n"
		
		format "supports: %\n" supports
		format "supports.count: %\n" supports.count
		
		SourceObjects = SUPPORT_MANAGER.getSourceObjects source_objects
		format "SourceObjects: %\n" SourceObjects
		for SourceObject in SourceObjects do
		(
			--format "SourceObject: %\n" SourceObject
			--indexes =( for index in SourceObject.Supports.keys where SourceObject.Supports[index].support_obj.isSelected collect index) as BitArray
			indexes =( for index in SourceObject.Supports.keys where isValidNode ( support_obj = SourceObject.Supports[index].support_obj) and support_obj.isSelected collect index) as BitArray
		
			--format "indexes: %\n" indexes
			epoly = SourceObject.obj.baseobject
		
			select SourceObject.obj


			verts_hidden = polyop.getHiddenVerts epoly
		
			polyop.unHideAllVerts epoly
		
			--polyop.setHiddenVerts epoly ( verts_hidden - indexes )
		
			epoly.SetSelection #VERTEX indexes
			max modify mode
			subObjectLevel = 1
		
		)

		--format "SourceObjects.count: %\n" SourceObjects.count
		--if SourceObjects.count == 1 then
		--(
		--	select SourceObjects[1].obj
		--	
		--	max modify mode
		--
		--	subObjectLevel = 1
		--)
		--else if SourceObjects.count > 1 then
		--	select ( 	for SourceObject in SourceObjects collect SourceObject.obj )
	)

	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-05-SELECTION\SUPPORTS and RAFTS.mcr"
		
		format "selection.count: %\n" selection.count
		
		--max modify mode
		format "selection.count: %\n" selection.count

		
		
		if GetCommandPanelTaskMode() == #MODIFY and subObjectLevel == 1 then
			selectSupportsByVerts()

		else
			selectVertsBySupports()
	)
)

/**
 *
 */
macroscript	maxtoprint_select_supports_on_ground
category:	"maxtoprint"
buttontext:	"ON GROUND"
toolTip:	"Select supports which are on ground"
--icon:	"across:4"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-SELECTION-TOOLS\SUPPORT SELECTION.mcr"

		supports = SUPPORT_MANAGER.getObjectsByType ( selection as Array ) type:#SUPPORT -- hierarchy:shift

		supports_on_ground = for support in supports where support.min.z as integer == 0 collect support

		select supports_on_ground
	)
)

/**
 *
 */
macroscript	maxtoprint_select_supports_not_on_ground
category:	"maxtoprint"
buttontext:	"ON GROUND"
toolTip:	"Select supports which are NOT on ground"
--icon:	"across:4"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-SELECTION-TOOLS\SUPPORT SELECTION.mcr"

		--supports = SUPPORT_MANAGER.getObjectsByType ( selection as Array ) type:#SUPPORT -- hierarchy:shift
		
		supports_and_rafts = SUPPORT_MANAGER.getSupportAndRaftObjects ( selection as Array ) get_nodes:true

		supports_on_ground = for support in supports_and_rafts where support.min.z as integer != 0 collect support

		select supports_on_ground
	)
)



/**
 *
 */
macroscript	maxtoprint_select_by_direction_down
category:	"maxtoprint"
buttontext:	"BY DIRECTION"
toolTip:	"Direction DOWN"
icon:	"tooltip:SELECT SUPPORTS AND RAFTS BY DIRECTION.\nUse current selection, or all visible objects"

(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr"
	
        visible_objects = for obj in objects where obj.isHidden == false collect obj -- GET ONLY VISIBILITY OBJECTS - if select mode
                           
		/* GET INPUT OBEJCTS - SELECTION or objects BY VISIBILITY */ 
		objs_input = if selection.count > 0 then selection as Array else visible_objects
			
		
		supports_and_rafts = SUPPORT_MANAGER.getSupportAndRaftObjects ( objs_input) get_nodes:true

		filtered = for support in supports_and_rafts where getUserPropVal support "DIRECTION" == #DOWN collect support

		if filtered.count == 0 then
			messageBox "Supports or rafts with direction #DOWN does not exists" --title:"Title"  beep:false
		else
			select filtered
	)
)


/**
 *
 */
macroscript	maxtoprint_select_by_direction_not_down
category:	"maxtoprint"
buttontext:	"BY DIRECTION"
toolTip:	"Direction NORMAL & CUSTOM"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr"
	
        visible_objects = for obj in objects where obj.isHidden == false collect obj -- GET ONLY VISIBILITY OBJECTS - if select mode
                           
		/* GET INPUT OBEJCTS - SELECTION or objects BY VISIBILITY */ 
		objs_input = if selection.count > 0 then selection as Array else visible_objects
			
		
		supports_and_rafts = SUPPORT_MANAGER.getSupportAndRaftObjects ( objs_input) get_nodes:true

		filtered = for support in supports_and_rafts where getUserPropVal support "DIRECTION" != #DOWN collect support

		if filtered.count == 0 then
			messageBox "Supports or rafts with direction #DOWN does not exists" --title:"Title"  beep:false
		else
			select filtered
	)
)


/**
 *
 */
macroscript	maxtoprint_select_supports_with_beams
category:	"maxtoprint"
buttontext:	"BY BEAMS"
toolTip:	"Select supports without beams"
--icon:	"across:2"
(
	on execute do
		selectSupportsByBeamsCount 0
)

/**
 *
 */
macroscript	maxtoprint_select_supports_with_beams_by_count
category:	"maxtoprint"
buttontext:	"BY BEAMS"
toolTip:	"Select supports by beams count"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr"


		/* DEFINE MAIN MENU */
		Menu = RcMenu_v name:"GenerateBeamsMenu"

		Menu.item "With 1 beam" ( "selectSupportsByBeamsCount 1" )
		Menu.item "With 2 beam" ( "selectSupportsByBeamsCount 2" )
		Menu.item "With 3 beam" ( "selectSupportsByBeamsCount 3" )
		Menu.item "With 4 beam" ( "selectSupportsByBeamsCount 4" )

		popUpMenu (Menu.create())
	)
)