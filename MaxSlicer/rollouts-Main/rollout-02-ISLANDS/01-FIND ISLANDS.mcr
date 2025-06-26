
global ISLANDS_SYSTEM

/** Open island sdialog with VISIBLE islands
 *
 */
macroscript	maxtoprint_islands_dialog
category:	"_3D-Print"
buttontext:	"I S L A N D S  ☰"
toolTip:	"Open islands dialog with VISIBLE islands"
icon:	"across:3|height:32"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-02-ISLANDS\Lib\IslandsSystem\IslandsSystem.ms"
	
		undo off
		(
			obj	= selection[1]

            VertSelector = VertSelector_v(obj) --"./../rollout-07-VERTEX_SELECTION/Lib/VertSelector/VertSelector.ms"
            --IslandFInder = IslandFInder_v(obj)

			/* DISABLE SLICER MODIFIERS */
			SLICER_SYSTEM.toggleModifiers false

			layer_height = DIALOG_maxslicer.SPIN_layer_height.value

			/* LOAD DATA FROM OBJECT PROPERTIES */
			islands_data_loaded = getUserPropVal obj "ISLANDS_DATA"
			format "islands_data_loaded: %\n" islands_data_loaded

			/* SET ISLANDS DATA */
			ISLANDS_SYSTEM.islands_data = if islands_data_loaded != undefined then
					/*  */
					ISLANDS_SYSTEM.fitZpozitions( islands_data_loaded )(layer_height)
			
				else /* GET NEW ISALNDS DATA */
					(IslandFinder_v(obj)).findIslandsPerLayer(layer_height) #LowestVertIslandFinder
					
				format "ISLANDS_SYSTEM.islands_data: %\n" ISLANDS_SYSTEM.islands_data
			
			/* GET NEW ISALNDS DATA */
			--new_islands = for island_data in ISLANDS_SYSTEM.islands_data collect island_data[#NEW_ISLAND]
			
			lowest_verts = for island_data in ISLANDS_SYSTEM.islands_data collect island_data[#LOWEST_VERT]
			
			--lowest_verts = VertSelector.getLowestVerts ( new_islands )
			
			VertSelector.setSelection ( lowest_verts as BitArray )
			
			
			if ISLANDS_SYSTEM.islands_data.count > 0 then
			(
				/* RE ENABLE SLICER MODIFIERS */
				SLICER_SYSTEM.toggleModifiers true
			
				/* CREATE DIALOG */
				createIslandManagerDialog()
			)
			else
				messageBox "EMPTY ISLANDS DATA" title:"[FIND ISLANDS].mcr"

		)
	)
)


/** Open island sdialog with ALL islands
 *
 */
macroscript	maxtoprint_islands_dialog_show_all
category:	"_3D-Print"
buttontext:	"I S L A N D S  ☰"
toolTip:	"Open islands dialog with ALL islands"
icon:	"across:3|height:32"
(
	on execute do
	(
		undo off
		(
			if DIALOG_island_manager != undefined then
				createIslandManagerDialog islands_to_show:#{} --"./Lib/IslandManagerDialog/createIslandManagerDialog.ms"
		)
	)
)

/**
 *
 */
macroscript	maxtoprint_find_islands_lowest_vert
category:	"_3D-Print"
buttontext:	"LOWEST vert"
toolTip:	"Search islands"
icon:	"across:3"
(
	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-02-ISLANDS\Lib\IslandsSystem\IslandFInder\IslandFInder.ms"
		obj	= selection[1]

		deleteUserProp obj "ISLANDS_DATA"
		
		ISLANDS_SYSTEM = IslandsSystem_v(obj)

		ISLANDS_SYSTEM.islands_data = (IslandFInder_v(obj)).findIslandsPerLayer(layer_height) #LowestVertIslandFinder
		format "ISLANDS_SYSTEM.islands_data: %\n" ISLANDS_SYSTEM.islands_data
		/* SAVE ISlANDS DATA TO OBJECT */
		setUserPropVal obj "ISLANDS_DATA" ISLANDS_SYSTEM.islands_data
	

		macros.run "_3D-Print" "maxtoprint_islands_dialog"
	)
)
/**
 *
 */
macroscript	maxtoprint_find_islands_per_layer
category:	"_3D-Print"
buttontext:	"Island By LAYER"
icon:	"across:3"
(
	on execute do
	(
		obj	= selection[1]

		deleteUserProp obj "ISLANDS_DATA"
		
		ISLANDS_SYSTEM = IslandsSystem_v(obj)

		ISLANDS_SYSTEM.islands_data = (IslandFInder_v(obj)).findIslandsPerLayer(layer_height) #IslandPerLayerFinder
		
		/* SAVE ISlANDS DATA TO OBJECT */
		setUserPropVal obj "ISLANDS_DATA" ISLANDS_SYSTEM.islands_data
	
		--macros.run "_3D-Print" "maxtoprint_islands_dialog"
		
		
		
		
		
		
		
		
		
	)
)
