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

	/* private */
	/* dependency */
	/* reference */
	/* inhered */


	/** Add modifiers
	  *
	  */
	function addModifiers _objects obj_type:#SUPPORT objects_exists:#() =
	(
		format "\n-----------------------------------------\n"
		format "\n"; print "ModifiersManager_v.addModifiers()"
		format "_objects: %\n" _objects
		format "objects_exists: %\n" objects_exists
		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS.base_width
		
		this._objects =	_objects

		if SupportModifiers[#DEFAULT] == undefined then
			SupportModifiers[#DEFAULT] = SupportModifiers_v()

		
		--objects_exists = for obj in objects_exists where isValidNode obj collect obj

		
		--support_with_modifiers	= (this._getSupportsWithModfiers(objects_exists))[1]

		if objects_exists.count == 0 then
		(
			format "ADD NEW MODIFIERS\n"
			select _objects
		
			modifiers = if obj_type == #SUPPORT then SupportModifiers[#DEFAULT].mods_support else SupportModifiers[#DEFAULT].mods_raft
			--format "MODIFIERS: %\n" modifiers
			--format "selection: %\n" ( selection as Array ) 
			--format "selection.count: %\n" selection.count
			--max create mode
			max modify mode
		
			for i = modifiers.count to 1 by -1 do
			--for i = 1 to modifiers.count do 
			(
				--format "MODIFIER: %\n" (modifiers[i])
				--addModifier _objects modifiers[i]
				--
				--if classOf modifiers[i] == sweep then
				--	this._setSweepRadius (_objects[1])
				--	
				--else
					modPanel.addModToSelection ( modifiers[i] ) --ui:on
			)
		
			/* SET SWEEP VALUE WHEN MODIFIER IS ADDED */
			this._setSweepRadius (_objects[1])
		)
		else
			this._copyModifiers objects_exists[1] _objects ((this._getSupportsWithModfiers(objects_exists))[1].modifiers)
	),

	/** Sweep radius must be set when modifier is added to object
	 */
	function _setSweepRadius obj =
	(
		--format "\n"; print "SupportModifiers_v.setSweepRadius()"
		--format "obj.modifiers[#BAR_WIDTH]: %\n" obj.modifiers[#BAR_WIDTH]
		max modify mode

		try(
			obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius = SUPPORT_OPTIONS.getOption #BAR_WIDTH
			--obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius = 5
		)catch(
			--format "****************\n"
			
		)
	),

	/** Update modifier by value in SUPPORT_OPTIONS
	 */
	function updateModifier _objects prop_key =
	(
		format "\n"; print "ModifiersManager_v.updateModifier()"
		format "_objects: %\n" _objects
		format "prop_key: %\n" prop_key

		modifiers = #()

		mod_name = if prop_key == #RAFT_WIDTH then #BAR_WIDTH else prop_key
		format "mod_name: %\n" mod_name
		
		for obj in _objects where obj.modifiers[mod_name] != undefined do
			appendIfUnique modifiers obj.modifiers[mod_name]
		format "modifiers: %\n" modifiers


		if modifiers.count > 0 then
		(
			val = SUPPORT_OPTIONS.getOption prop_key

			classof_mod = classOf modifiers[1]

			for _mod in modifiers do
				case classof_mod of
				(
					(sweep):	_mod[#Cylinder_Section].radius	= val

					(Chamfer ):	_mod.amount	= val
					(Face_Extrude ):	_mod.amount	= val

					default: format "\nWARNING -- UPDATE OF UNSUPPORTED MODIER\n\nSupportModifiers_v.updateModifier(): %\n" prop_key -- this should never happen
				)
		)
	),

	/** Convert obj type
	 */
	function convertSupportType _objects to_type:#RAFT modifiers:undefined =
	(
		--format "\n"; print "ModifiersManager_v.convertSupportType()"
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
		this._setSweepRadius (_objects[1])
	),


	private

	/** Copy modifiers
	 */
	function _copyModifiers obj_source objects_target modifiers =
	(
		format "\n"; print "SupportModifiers_v._copyModifiers()"
		format "obj_source: %\n" obj_source
		format "objects_target: %\n" objects_target
		format "modifiers: %\n" modifiers

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
		--format "\n"; print "ModifiersManager.onCreate()"
		SupportModifiers[#DEFAULT] = SupportModifiers_v() -- INIT DEFAULT MODIFIERS
	)

)
