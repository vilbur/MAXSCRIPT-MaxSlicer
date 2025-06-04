

/**
 */
macroscript	_print_layer_height
category:	"_3D-Print"
buttontext:	"Layer Height"
tooltip:	"Height of printed layer in mm"
icon:	"across:5|control:spinner|fieldwidth:32|range:[ 0.03, 0.1, 0.05 ]|scale:0.01|offset:[ 28, 4 ]"
(
	--updateSlicePlaneSystem(undefined)
	on execute do
	(
		-- format "EventFired:	% \n" EventFired
		_spinner = EventFired.control

		/* RESET SPINNER TO VALUE HIGHER THEN MIN RANGE */
		if not EventFired.inSpin and EventFired.val == _spinner.range.x then
			EventFired.control.value = 0.05


	)
)

/**
 */
macroscript	_print_set_export_size
category:	"_Export"
buttontext:	"Export Size"
toolTip:	"Export size"
icon:	"Control:spinner|range:[0.1,100,1]|across:5|offset:[ 56, 4 ]|width:96"
(
	-- format "_print_set_export_size()\n"
	-- format "eventFired	= % \n" eventFired
	
	--EXPORT_SIZE = eventFired.val


	/* FIRED BY MAXSCRIPT ON STARTUP */ 
	if eventFired == undefined then
	(
		if EXPORT_SIZE == undefined then 
			EXPORT_SIZE = DIALOG_maxslicer.SPIN_export_size.value
		else
			DIALOG_maxslicer.SPIN_export_size.value = EXPORT_SIZE
	)
	/* FIRED BY CONTROL EVENT  */ 
	else
		EXPORT_SIZE = eventFired.val

	/* SYNC WITH MaxSlicer */ 
	if DIALOG_nodeexporter != undefined then 
		DIALOG_nodeexporter.SPIN_export_size.value = DIALOG_maxslicer.SPIN_export_size.value


)

/**
 */
macroscript	_print_set_export_size_half
category:	"_Export"
buttontext:	"0.5"
toolTip:	"Export size"
icon:	"across:5|width:32|offset:[ 48, 0 ]"
(
	-- format "eventFired	= % \n" eventFired
	
	EXPORT_SIZE = 0.5

	eventFired = undefined
	
	macros.run "_Export" "_print_set_export_size"
)
/**
 */
macroscript	_print_set_export_size_1
category:	"_Export"
buttontext:	"1"
toolTip:	"Export size"
icon:	"width:32|offset:[ 8, 0 ]"
(
	-- format "eventFired	= % \n" eventFired
	
	EXPORT_SIZE = 1

	eventFired = undefined
	
	macros.run "_Export" "_print_set_export_size"
)

/** RESCALE SUPPORTS
 */
macroscript	_print_rescale_supports
category:	"_Export"
buttontext:	"Rescale"
toolTip:	"Rescale selected supports and rafts to export size"
icon:	"width:72|align:#RIGHT"
(
	
	on execute do
	(
		all_or_sel = if selection.count > 0 then "SELECTED" else "VISIBLE"
		
		if queryBox ("RESCALE "+all_or_sel+" SUPPORTS ?\n\nEXPORT_SIZE: "+EXPORT_SIZE as string ) title:"RESCALE SUPPORTS" then
		undo "RESCALE SUPPORTS" on
		(
			--clearListener(); print("Cleared in:\n"+getSourceFileName())
			-- format "eventFired	= % \n" eventFired
			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\Options.mcr"
			ModifierValue = ModifierValue_v()
			
			unique_mods = #()
			
			_objects = if selection.count > 0 then selection as Array else for obj in objects where not obj.isHidden collect obj 
		
			scalable_mods_classes = #( sweep, Face_Extrude, Chamfer )
			
			selected_supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT 
			selected_rafts    = SUPPORT_MANAGER.getObjectsByType _objects type:#RAFT    
			
			format "selected_supports: %\n" selected_supports
			format "selected_rafts: %\n" selected_rafts
			
			/* IF OBJECTS EXISTS */ 
			if (supports_and_rafts = selected_supports + selected_rafts).count > 0 then
			(
				/*------------------------------------------------------------------------------
					UPDATE SUPPORTS AND RAFTS OBEJCTS
				--------------------------------------------------------------------------------*/
				SUPPORT_MANAGER.updateSupports supports_and_rafts
				
				/* UPDATE USER PROPS */ 
				for obj in supports_and_rafts do 
					setUserPropVal obj "EXPORT_SIZE" (EXPORT_SIZE as float )    

				/*------------------------------------------------------------------------------
					GET UNIQUE MODIFIERS 
				--------------------------------------------------------------------------------*/
				for obj in supports_and_rafts do
					for _mod in obj.modifiers where findItem scalable_mods_classes ( classOf _mod ) > 0 do
						appendIfUnique unique_mods _mod
				
				
				--base_width = getUserPropVal obj "BASE_WIDTH"
				--bar_width = getUserPropVal obj  "BAR_WIDTH"
				
				/*------------------------------------------------------------------------------
					RESCALE EACH MODIFIER 
				--------------------------------------------------------------------------------*/
				
				for _mod in unique_mods do
				(
					format "\n"
					format "_mod: %\n" _mod
					/* GET OBJECT WITH MODIFIER */ 
					objects_with_modifier = for obj in refs.dependentNodes _mod collect obj
					
					obj = objects_with_modifier[1]
					
					/* GET MODIFIER VALUE FROM USER PROPS */ 
					--mod_value = case _mod.name as name of
					--(
					--	#EXTEND_TOP:   getUserPropVal obj "TOP_WIDTH"
					--	#CHAMFER_BASE: getUserPropVal obj "BASE_HEIGHT" / 2.0
					--	default:       getUserPropVal obj ( toUpper _mod.name ) 
					--)
					mod_value = case _mod.name as name of
					(
						#BAR_WIDTH:	getUserPropVal obj "BAR_WIDTH"  / 2.0
						#BASE_WIDTH:	getUserPropVal obj "BASE_WIDTH" / 2.0
						--#DRAIN_WIDTH:	ModifierValue.getDrainWidth()
						#CHAMFER_BASE:  getUserPropVal obj "BASE_HEIGHT" / 2.0
						#EXTEND_TOP:    getUserPropVal obj "EXTEND_TOP"
						#TOP_WIDTH:	    ModifierValue.getChamferBarValue bar_width:(getUserPropVal obj "BAR_WIDTH") base_width: (getUserPropVal obj "BASE_WIDTH")
					)
					
					/* FALLBACK IF USER PROP NOT EXISTS */ 
					if mod_value == undefined then 
						mod_value = SUPPORT_OPTIONS.getModVal (_mod.name as name )
					
					/* SCALE VALUE BY EXPORT SIZE */ 
					mod_value_scaled = mod_value / EXPORT_SIZE
					
					--format "EXPORT_SIZE:      %\n" EXPORT_SIZE
					--format "mod_value:        %\n" mod_value
					--format "mod_value_scaled: %\n" mod_value_scaled
					
					/* SET VALUE TO MODIFIER */ 
					case classOf _mod of
					(
						(sweep):  _mod[#Cylinder_Section].radius = mod_value_scaled
						default:  _mod.amount = mod_value_scaled
					)
				)
				
			)
		)
		
	)
)





