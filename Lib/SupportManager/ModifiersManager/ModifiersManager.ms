filein( getFilenamePath(getSourceFileName()) + "/SupportModifiers/SupportModifiers.ms" )	--"./SupportModifiers/SupportModifiers.ms"

/** Modifiers manage
 */
struct ModifiersManager_v
(
	/* construct */


	/* required */
	_objects,
	--objects_exists,


	/* properties */
	SupportModifiers	= Dictionary(), -- KEY: VALUE:
	--SupportModifiers	= SupportModifiers_v(),

	/* private */
	/* dependency */
	/* reference */
	/* inhered */


	/** Add modifiers
	  *
	  */
	function addModifiers _objects obj_type:#SUPPORT objects_exists:#() =
	(
		 -- format "\n-----------------------------------------\n"
		 -- format "\n"; print "ModifiersManager_v.addModifiers()"
		 -- format "objects_exists: %\n" objects_exists
		 
		this._objects =	_objects

		/*==============================================================================
		  
			CREATE NEW ISTANCES OF MODIFIERS
			
		================================================================================*/
		if objects_exists.count == 0 then
		(
			--format "ADD NEW MODIFIERS\n"
			select _objects
		
			this._initDefaultModifiers()
		
			modifiers = if obj_type == #SUPPORT then SupportModifiers[#DEFAULT].mods_support else SupportModifiers[#DEFAULT].mods_raft

			for _mod in modifiers do
			-- format "_mod: %\n" _mod
			
			max modify mode
			--max create mode
		
			for i = modifiers.count to 1 by -1 do
				--addModifier _objects modifiers[i]
				modPanel.addModToSelection ( modifiers[i] ) --ui:on

			/* SET SWEEP VALUE WHEN MODIFIER IS ADDED */
			this._setSweepRadius (_objects[1] ) obj_type
			
			/* WIRE PARAMETERS */ 
			this._wireBarAndTopWidth _objects[1]
			
			if obj_type == #SUPPORT then
				this._wireBarWidthToBase _objects[1]
		)
		
		/*==============================================================================
		  
			COPY MODIFIERS
			
		================================================================================*/
		else
		(
			-- format "objects_exists: %\n" objects_exists
			
			export_size_new   = getUserPropVal _objects[1]       "EXPORT_SIZE"
			export_size_exist = getUserPropVal objects_exists[1] "EXPORT_SIZE"
			-- format "export_size_new: %\n" export_size_new
			-- format "export_size_exist: %\n" export_size_exist
			modifiers_of_first_object = (this._getSupportsWithModfiers(objects_exists))[1].modifiers
			
			this._copyModifiers objects_exists[1] _objects (modifiers_of_first_object)
			
			/*------------------------------------------------------------------------------
				RESCALE EXISTITNG SUPPORTS
			--------------------------------------------------------------------------------*/
			if export_size_new != export_size_exist then
			(
				this.rescaleModifeirsByExportSize(modifiers_of_first_object)( export_size_exist /EXPORT_SIZE )
				
				--SUPPORT_MANAGER.resetSupports (objects_exists)
				SUPPORT_MANAGER.updateSupports objects_exists update_raft:true
				
				for obj in objects_exists do 
					setUserPropVal obj "EXPORT_SIZE" (EXPORT_SIZE as float )
			)
		)
	),

	/** Rescale modifeirs by export size
	 */
	function rescaleModifeirsByExportSize mods multiplier =
	(
		-- format "\n"; print ".rescaleModifeirsByExportSize()"
		scalable_mods_classes = #( sweep, Face_Extrude, Chamfer )
		
		for _mod in mods where findItem scalable_mods_classes ( classOf _mod ) > 0 do
		(
			case classOf _mod of
			(
				--(sweep):  _mod[#Cylinder_Section].radius = _mod[#Cylinder_Section].radius * multiplier
				sweep:  _mod[#Cylinder_Section].radius *= multiplier
				default:  _mod.amount *= multiplier
				--default: _mod.amount = _mod.amount * multiplier
			)
		)
	),

	/** Update modifier by value in SUPPORT_OPTIONS
	 */
	function updateModifier _objects prop_key val: =
	(
		  -- format "\n"; print "ModifiersManager_v.updateModifier()"
		 -- format "_objects: %\n" _objects
		  -- format "prop_key: %\n" prop_key
		  -- format "val: %\n" val

		/* COMPARE ARRAYS
		*/ 
		fn areAllObjectsSelected arr1 arr2 = with PrintAllElements on ( sort(arr1) ) as string == ( sort(arr2) ) as string
		
		this._objects =	_objects

		current_panel = GetCommandPanelTaskMode()
		
		max create mode

		/* DEVELOPMENT:
			
			THREAD RAFTS AS SUPPORTS
		
		*/ 
		mod_name = if prop_key == #RAFT_WIDTH then #BAR_WIDTH else prop_key

		/* CHECK IF OBJECTS HAS MODIFIER */ 
		_objects =	for obj in _objects where obj.modifiers[mod_name] != undefined collect obj
		--format "this._objects: %\n" this._objects
		
		/* IF OBJECTS WITH MODIFIER EXISTS */ 
		if _objects.count > 0 then
		(			
			source_obj_mod	= _objects[1]
			
			for_replace = deleteItem _objects 1
			
			source_mod = source_obj_mod.modifiers[mod_name]
			
			/* POINTERS OF OBJECTS */ 
			pointers_objs =  (for obj in _objects collect (getHandleByAnim obj) as string )
			
			/* POINTERS OF OBJECTS WITH MODIFIER */ 
			pointers_mods = ( for obj in refs.dependentNodes(source_mod) where obj.modifiers[mod_name] == source_mod collect (getHandleByAnim obj) as string )
			
			
			/* CREATE UNIQUE GROUP OF MODIFIERS INSTANCES - if not */ 
			if not ( areAllObjectsSelected (pointers_objs) (pointers_mods) ) then
				source_mod = this._reinstanceModifier (source_obj_mod) (for_replace) (source_mod) 
			
			
			/* UPDATE MODIFIER VALUE */ 
			if val == unsupplied then
				val = SUPPORT_OPTIONS.getModVal prop_key
			
			val_scaled = val / EXPORT_SIZE
			
			case (classOf source_mod) of
			(
				(sweep):	source_mod[#Cylinder_Section].radius	= val_scaled
			
				(Chamfer ):	source_mod.amount	= val_scaled
				(Face_Extrude ):	source_mod.amount	= val_scaled
			
				default: format "\nWARNING -- UPDATE OF UNSUPPORTED MODIER\n\nSupportModifiers_v.updateModifier(): %\n" prop_key -- this should never happen
			)
			
	
		)
		--format "_objects: %\n" _objects
		
		/* UPDATE #TOP_WIDTH ALSO IF #BAR_WIDTH IS UPDATED */ 
		--if prop_key == #BAR_WIDTH then
			--this.updateModifier this._objects #TOP_WIDTH
		
		SetCommandPanelTaskMode mode:current_panel
	),
	
	/** Convert obj type
	 */
	function convertSupportType _objects to_type:#RAFT modifiers:undefined =
	(
		 format "\n"; print "ModifiersManager_v.convertSupportType()"
		format "to_type: %\n" to_type
		format "modifiers: %\n" modifiers
		format "_objects: %\n" _objects
		--format "SupportModifiers[#DEFAULT]: %\n" SupportModifiers[#DEFAULT]
		this._initDefaultModifiers()

		modifiers_add = case of
		(
			(modifiers != undefined):	modifiers
			(to_type == #SUPPORT):	SupportModifiers[#DEFAULT].mods_support
			(to_type == #RAFT):	SupportModifiers[#DEFAULT].mods_raft
		)

		format "MODIFIERS_ADD: %\n" modifiers_add
		format "MODIFIERS_ADD: %\n" modifiers_add.count

		/* DELETE OLD MODIFIERS */ 
		for obj in _objects do
			for i = obj.modifiers.count to 1 by -1 do
				deleteModifier obj 1

		/* ADD NEW MODIFIERS */ 
		for i = modifiers_add.count to 1 by -1 do
			addModifier _objects modifiers_add[i]

		/* SET SWEEP VALUE WHEN MODIFIER IS ADDED */
		this._setSweepRadius (_objects[1]) to_type

		/* REWIRE MODIFIER PARAMETERS */ 
		this._wireBarAndTopWidth _objects[1]
	),

	/*==============================================================================
		WIRE PARAMS
	================================================================================*/
	
	
	/** CHMAFER VALUE DEPENDS ON SWEEP RADIUS AND CUSTOM ATRRIBUTE
		
		CHANGE of bar width radius FIRES script to change chmafer to KEEP SAME ABSOLUTE SIZE of chamfered face
		
		
		1. Update of modifiers[#TOP_WIDTH].amount fires Param Wire script
		2. Param Wire script modifies BAR_WITH.radius and TOP_WIDTH.bar_width to get CHAMFER VALUE
		3. Update chamfer value
	  
	 */
	function _wireBarAndTopWidth obj =
	(
		--format "\n"; print "ModifiersManager_v._wireBarAndTopWidth()"
		/* CREATE SCRIPT */ 
		top_width_script = float_script ()
		
		/*------------------------------------------------------------------------------
			CONFIGURE SCRIPT
		--------------------------------------------------------------------------------*/
		
		/* BIND TO RADIUS OF SWEEP MODIFIER - */ 
		top_width_script.addTarget  "bar_width" obj[#Modified_Object][#BAR_WIDTH][#Cylinder_Section]
		
		/* BIND TO CUSTOM ATTRIBUTE OF CHAMFER MODIFIER */ 
		top_width_script.addTarget "MaxSlicer"  obj[#Modified_Object][#TOP_WIDTH].MaxSlicer
		1
		
		--top_width_script.script  = "format \"FLOAT SCRIPT\\n\"; (((bar_width.radius * 2.0) - MaxSlicer.top_width)    / 2.0 ) / (if EXPORT_SIZE != undefined then EXPORT_SIZE else 1)"
		--top_width_script.script  = "format \"FLOAT SCRIPT\\n\"; 0.25"
		
		top_width_script.script  = "(((bar_width.radius * 2.0) - MaxSlicer.top_width) / 2.0 ) / (if EXPORT_SIZE != undefined then EXPORT_SIZE else 1)"
		
		/* ADD SCRIPT */ 
		obj.modifiers[#TOP_WIDTH].amount.controller = top_width_script
	),
	
	/** CONNENCT BAR WIDTH TO BASE OF SUPPORT
	  
		CHANGE of bar with FIRES change of extrude to KEEP SAME ABSOLUTE SIZE of extruded
	  
		1. Update of modifiers[#TOP_WIDTH].amount fires Param Wire script
		2. Param Wire script modifies BAR_WITH.radius and TOP_WIDTH.bar_width to get CHAMFER VALUE
		3. Update chamfer value
	  
	 */
	function _wireBarWidthToBase obj =
	(
		--format "\n"; print "ModifiersManager_v._wireBarWidthToBase()"
		----if obj.modifiers[#BASE_WIDTH] != undefined then
		/* CREATE SCRIPT */ 
		base_width_script = float_script ()
		
		/* CONFIGURE SCRIPT */ 
		base_width_script.addTarget "bar_width" obj[#Modified_Object][#BAR_WIDTH][#Cylinder_Section]
		
		base_width_script.addTarget "MaxSlicer" obj[#Modified_Object][#BASE_WIDTH].MaxSlicer
		
		base_width_script.script = "(( MaxSlicer.base_width - (bar_width.radius * 2.0) ) / 2.0 ) / (if EXPORT_SIZE != undefined then EXPORT_SIZE else 1)"
		
		/* ADD SCRIPT */ 
		obj.modifiers[#BASE_WIDTH].amount.controller = base_width_script
	),

	private
	
	/** Init default modifiers
	 */
	function _initDefaultModifiers =
	(
		--format "\n"; print "ModifiersManager_v._initDefaultModifiers()"
		if SupportModifiers[#DEFAULT] == undefined then 
			SupportModifiers[#DEFAULT] = SupportModifiers_v()
	),
	
	
	/** Props of Sweep modifier which are driven by shape must set when modifier is added to objext
	 */
	function _setSweepRadius obj obj_type =
	(
		 --format "\n"; print "SupportModifiers_v.setSweepRadius()"
		mod_name = if obj_type == #RAFT then #RAFT_WIDTH else #BAR_WIDTH

		interpolation_Steps = 4
		
		max modify mode

		try(
			obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius = (SUPPORT_OPTIONS.getModVal mod_name / EXPORT_SIZE)
			
			obj.modifiers[#BAR_WIDTH][#Cylinder_Section].steps = interpolation_Steps
			--obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius = 5
		)catch(
			-- format "**********************************************\n"
			-- format "\n"; print "SupportModifiers_v.setSweepRadius()"
			-- format "ERROR: SET SWEEP RADIUS FAILED on obj: %\n" obj.name
		)
	),
	
	/** REINSTANCE MODIFIER
	 */
	function _reinstanceModifier source_obj for_replace source_mod =
	(
		--format "\n"; print "ModifiersManager_v._reinstanceModifier()"
		/** REINSTANCE SWEEP MODIFIER
		  
			USE CASES OF SWEEP MODIFIER ERROR:
				1) If sweep modifier is added more then once
				2) If sweep modifier is tried to add but modifiers above are enabled 
		  
			WORKAROUND:
				1) turn of all modifiers above sweep mod
				2) delete old sweep modifier
				3) add new sweep modifier
				4) reneable modifiers above
		  
		 */
		function reinstanceSweepModifier source_obj for_replace _modifier =
		(
			--format "\n"; print "ModifiersManager_v.reinstanceSweepModifier()"
			disbaled_mods	=  Dictionary #INTEGER -- KEY:modifier_index VALUE:#( modifiers )
			
			for target_obj in for_replace do 
			(
				--format "\n\n"
				local target_mod
				--local index_target
		
				/* DISABLE MODIIERS */ 
				for m = 1 to target_obj.modifiers.count where classOf (target_mod = target_obj.modifiers[m]) != sweep and target_mod.enabled do 
				(
					target_mod.enabled = false
					--format "m: %\n" m
					
					if disbaled_mods[m] == undefined then disbaled_mods[m] = #(target_mod) else appendIfUnique disbaled_mods[m] target_mod
				)
				
				index_target	= modPanel.getModifierIndex target_obj target_mod
		
				/* MAKE MODIFIERS UNIQUE */ 
				--InstanceMgr.MakeModifiersUnique target_obj target_mod #individual -- {#prompt|#individual|#group}
				if index_target != undefined then
				(
					--format "target_obj: %\n" target_obj
					--format "target_mod:  %\n" target_mod
					--format "index_target: %\n" index_target
				
					--try(
						/* DELETE OLD SWEEP MODIFEIR */ 
						deleteModifier target_obj index_target					
						
						/* ADD INSTANCED SWEEP MODIFEIR */ 
						addModifierWithLocalData target_obj _modifier source_obj _modifier before:(index_target - 1)
					--
					--)
					--catch
					--(
					--	format "\n************ EXCEPTION ************\n%\n***********************************\n" (getCurrentException())
					--	format "\n**************** EXCEPTION File: % ****************\n\n%\n\n**************************************************************************************************************************************\n" filein_path (getCurrentException())
					--)
					
				)
			)
			
			for mod_index in disbaled_mods.keys do
				for disbaled_mod in disbaled_mods[mod_index] do
					disbaled_mod.enabled = true
		)
		
		
		source_mod_name = source_mod.name
		
		index_source	= modPanel.getModifierIndex source_obj source_mod
		
		/* MAKE MODIFIERS UNIQUE */ 
		InstanceMgr.MakeModifiersUnique source_obj source_mod #individual -- {#prompt|#individual|#group}
		
		/* REDEFINE UNIQUED MODIFIER */ 
		source_mod = source_obj.modifiers[index_source]

		source_mod.name = source_mod_name
		
		/* REINSTANCE MODIIFER */
		if classOf source_mod != sweep then
		(
			--for i = 1 to for_replace.count do
			for target_obj in for_replace do 
			(
				target_mod	= target_obj.modifiers[source_mod_name]
				index_target	= modPanel.getModifierIndex target_obj target_mod
			
				try(
				
					addModifierWithLocalData target_obj source_mod source_obj source_mod before:index_target
					
					deleteModifier target_obj index_target					
				)
				catch
				(
					-- format "\n************ EXCEPTION ************\n%\n***********************************\n" (getCurrentException())
					-- format "\n**************** EXCEPTION File: % ****************\n\n%\n\n**************************************************************************************************************************************\n" filein_path (getCurrentException())
				)
			)
		)
		else /* REINSTANCE SWEEP MODIIFER */
			reinstanceSweepModifier source_obj for_replace source_mod
		
		source_mod --return
	),
	
	/** Copy modifiers
	 */
	function _copyModifiers obj_source objects_target modifiers =
	(
		-- format "\n"; print "SupportModifiers_v._copyModifiers()"
		-- format "obj_source: %\n" obj_source
		-- format "objects_target: %\n" objects_target
		-- format "modifiers: %\n" modifiers

		max create mode

		for obj_target in objects_target do
			for i = modifiers.count to 1 by -1 do
				addModifierWithLocalData obj_target modifiers[i] obj_source modifiers[i] -- instance the modifier
	),

	/** Modifiers exists
	 */
	function _modifiersAdded =
	(
		--format "\n"; print "SupportModifiers_v._modifiersAdded()"
		(this._getSupportsWithModfiers()).count > 0
	),

	/** Get obejcts with modfiers
	 */
	function _getSupportsWithModfiers nodes =
	(
		for obj in nodes where isValidNode obj and obj.modifiers.count > 0 collect obj
	),

	/** Get obejcts with modfiers
	 */
	function _getSupportsWithoutModfiers =
	(
		for obj in _objects where obj.modifiers.count == 0 collect obj
	),

	/**
	 */
	on create do
	(
		----format "\n"; print "ModifiersManager.onCreate()"
		--SUPPORT_OPTIONS.getValuesFromUi()
		
 	)

)
