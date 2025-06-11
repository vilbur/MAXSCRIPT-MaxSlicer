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
		this._objects =	_objects

		/*------------------------------------------------------------------------------
			CREATE NEW ISTANCES OF MODIFIERS
		--------------------------------------------------------------------------------*/
		if objects_exists.count == 0 then
		(
			--format "ADD NEW MODIFIERS\n"
			select _objects
		
			SupportModifiers[#DEFAULT] = SupportModifiers_v()
		
			modifiers = if obj_type == #SUPPORT then SupportModifiers[#DEFAULT].mods_support else SupportModifiers[#DEFAULT].mods_raft

			max modify mode
			--max create mode
		
			for i = modifiers.count to 1 by -1 do
				--addModifier _objects modifiers[i]
				modPanel.addModToSelection ( modifiers[i] ) --ui:on

			/* SET SWEEP VALUE WHEN MODIFIER IS ADDED */
			this._setSweepProperties (_objects[1] )
			
			this.connenctBarAndToprWidths _objects[1]
		)
		/*------------------------------------------------------------------------------
			COPY MODIFIERS
		--------------------------------------------------------------------------------*/
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

	/** Props of Sweep modifier which are driven by shape must set when modifier is added to objext
	 */
	function _setSweepProperties obj =
	(
		 --format "\n"; print "SupportModifiers_v.setSweepRadius()"
		--format "BAR_WIDTH: %\n" (SUPPORT_OPTIONS.getModVal #BAR_WIDTH)

		--format "obj.modifiers[#BAR_WIDTH]: %\n" obj.modifiers[#BAR_WIDTH]
		
		
		interpolation_Steps = 4
		
		max modify mode

		try(
			obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius = (SUPPORT_OPTIONS.getModVal #BAR_WIDTH / EXPORT_SIZE)
			
			obj.modifiers[#BAR_WIDTH][#Cylinder_Section].steps = interpolation_Steps
			--obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius = 5
		)catch(
			format "**********************************************\n"
			format "\n"; print "SupportModifiers_v.setSweepRadius()"
			format "ERROR: SET SWEEP RADIUS FAILED on obj: %\n" obj.name
		)
	),
	
	--/** Get sweep radius
	-- */
	--function getSweepRadius =
	--(
	--	--format "\n"; print "ModifiersManager_v.getSweepRadius()"
	--	SUPPORT_OPTIONS.getModVal #BAR_WIDTH / 2.0
	--),

	/** Update modifier by value in SUPPORT_OPTIONS
	 */
	function updateModifier _objects prop_key val: =
	(
		 -- format "\n"; print "ModifiersManager_v.updateModifier()"
		 --format "_objects: %\n" _objects
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
	
	--/** Udpate top width
	-- */
	--function udpateTopWidth _objects top_width =
	--(
	--	-- format "\n"; print "ModifiersManager_v.udpateTopWidth()"
	--	
	--	--top_width /= EXPORT_SIZE
	--	
	--	objs_by_bar_width	= Dictionary #STRING -- KEY:"Value of BAR_WIDTH" VALUE:#( objects )
	--	
	--	/* SORT OBJECTS BY BAR WIDTH */ 
	--	for obj in _objects do
	--	(
	--		sweep_radius = obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius as string
	--		
	--		if objs_by_bar_width[sweep_radius] == undefined then
	--			objs_by_bar_width[sweep_radius] = #(obj)
	--		else
	--			append objs_by_bar_width[sweep_radius] obj
	--	)
	--	
	--	/* UPDATE CHAMFER FOR EACH VALUE OF SWEEP RADIUS */ 
	--	for bar_width_key in objs_by_bar_width.keys do
	--	(
	--		--_objects = objs_by_bar_width[bar_width]
	--		
	--		bar_width = (bar_width_key as float * 2) * EXPORT_SIZE
	--		
	--		
	--		/* GET CHAMFER VALUE */
	--		--chamfer_val = SUPPORT_OPTIONS.ModifierValue.getChamferBarValue bar_width:(bar_width as float * 2) top_width:top_width
	--		chamfer_val = SUPPORT_OPTIONS.ModifierValue.getChamferBarValue bar_width:bar_width top_width:top_width
	--		-- format "chamfer_val: %\n" chamfer_val
	--
	--		/* UPDATE CHAMFER VALUE */ 
	--		this.updateModifier objs_by_bar_width[bar_width_key] #TOP_WIDTH val:chamfer_val
	--		
	--		
	--	)
	--),
	
	
	/** Convert obj type
	 */
	function convertSupportType _objects to_type:#RAFT modifiers:undefined =
	(
		-- format "\n"; print "ModifiersManager_v.convertSupportType()"
		--format "to_type: %\n" to_type
		--format "modifiers: %\n" modifiers
		--format "_objects: %\n" _objects
		--format "SupportModifiers[#DEFAULT]: %\n" SupportModifiers[#DEFAULT]

		modifiers_add = case of
		(
			(modifiers != undefined):	modifiers
			(to_type == #SUPPORT):	SupportModifiers[#DEFAULT].mods_support
			(to_type == #RAFT):	SupportModifiers[#DEFAULT].mods_raft
		)

		--format "MODIFIERS_ADD: %\n" modifiers_add
		--format "MODIFIERS_ADD: %\n" modifiers_add.count

		for obj in _objects do
		(
			
			for i = obj.modifiers.count to 1 by -1 do
				deleteModifier obj 1

			--
			--for i = modifiers_add.count to 1 by -1 do
			--		addModifier obj modifiers_add[i]
		)

		for i = modifiers_add.count to 1 by -1 do
				addModifier _objects modifiers_add[i]

		/* SET SWEEP VALUE WHEN MODIFIER IS ADDED */
		this._setSweepProperties (_objects[1])
	),



	/** Connenct bar and topr widths
	 */
	function connenctBarAndToprWidths obj =
	(
		--format "\n"; print "ModifiersManager_v.connenctBarAndToprWidths()"
		/** Add bar width variable
		 */
		--function addBarWidthVariable obj _float_script = _float_script.addTarget "bar_width" obj[#Modified_Object][#BAR_WIDTH][#Cylinder_Section]
		
		/* CONNECT MODIFIERS OF SUPPORT AND RAFT */ 
		top_width_script = float_script ()
		
		obj.modifiers[#TOP_WIDTH].amount.controller = top_width_script
		
		top_width_script.addTarget  "bar_width" obj[#Modified_Object][#BAR_WIDTH][#Cylinder_Section]
		
		top_width_script.addTarget "MaxSlicerParameters"  obj[#Modified_Object][#TOP_WIDTH].MaxSlicerParameters
		
		top_width_script.script  = "(((bar_width.radius * 2.0) - MaxSlicerParameters.top_width)    / 2.0 ) / (if EXPORT_SIZE != undefined then EXPORT_SIZE else 1)"
		
		
		/* CONNECT MODIFIERS ONLY OF SUPPORT */ 
		if obj.modifiers[#BASE_WIDTH] != undefined then
		(
			base_width_script = float_script ()
			
			obj.modifiers[#BASE_WIDTH].amount.controller = base_width_script
			
			base_width_script.addTarget "bar_width" obj[#Modified_Object][#BAR_WIDTH][#Cylinder_Section]
			
			base_width_script.addTarget "MaxSlicerParameters" obj[#Modified_Object][#BASE_WIDTH].MaxSlicerParameters
			
			base_width_script.script = "(( MaxSlicerParameters.base_width - (bar_width.radius * 2.0) ) / 2.0 ) / (if EXPORT_SIZE != undefined then EXPORT_SIZE else 1)"
		)
	),

	private
	
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
