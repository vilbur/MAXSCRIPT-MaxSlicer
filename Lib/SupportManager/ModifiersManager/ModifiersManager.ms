filein( getFilenamePath(getSourceFileName()) + "/SupportModifiers/SupportModifiers.ms" )	--"./SupportModifiers/SupportModifiers.ms"

/** Modifiers manage
 */
struct ModifiersManager_v
(
	/* construct */


	/* required */
	_objects,
	--_objects_exists,


	/* properties */
	SupportModifiers	= Dictionary(), -- KEY: VALUE:

	/* private */
	/* dependency */
	/* reference */
	/* inhered */


	/** Add modifiers
	  *
	  */
	function addModifiers _objects obj_type:#SUPPORT _objects_exists:#() =
	(
		--format "\n-----------------------------------------\n"
		--format "\n"; print "ModifiersManager_v.addModifiers()"
		--format "_objects: %\n" _objects
		--format "_objects_exists: %\n" _objects_exists
		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS.base_width

		if SupportModifiers[#DEFAULT] == undefined then
			SupportModifiers[#DEFAULT] = SupportModifiers_v()

		--format "SupportModifiers: %\n" SupportModifiers[#DEFAULT]
		
		
		_objects_exists = for obj in _objects_exists where isValidNode obj collect obj
		--format "_objects_exists: %\n" _objects_exists

		this._objects =	_objects

		--support_with_modifiers	= (this._getSupportsWithModfiers(_objects_exists))[1]

		if _objects_exists.count == 0 then
		(
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
			this._copyModifiers _objects_exists[1] ((this._getSupportsWithModfiers(_objects_exists))[1].modifiers)
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
		--format "\n"; print "ModifiersManager_v.updateModifier()"
		--format "_objects: %\n" _objects
		--format "prop_key: %\n" prop_key

		mods = #()

		mod_name = if prop_key == #RAFT_WIDTH then #BAR_WIDTH else prop_key

		for obj in _objects where obj.modifiers[mod_name] != undefined do
			appendIfUnique mods obj.modifiers[mod_name]

		--format "mods.count: %\n" mods.count

		if mods.count > 0 then
		(
			val = SUPPORT_OPTIONS.getOption prop_key

			classof_mod = classOf mods[1]

			for _mod in mods do
				case classof_mod of
				(
					(sweep):	_mod[#Cylinder_Section].radius	= val

					--(Chamfer or Face_Extrude ):	_mod.amount	= val
					(Chamfer ):	_mod.amount	= val
					(Face_Extrude ):	_mod.amount	= val


					--#EXTEND_END:	_mod.amount	= SUPPORT_OPTIONS.extend_end
					--#EXTEND_TOP:	_mod.amount	= SUPPORT_OPTIONS.extend_top

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
	function _copyModifiers support_exists modifiers =
	(
		--format "\n"; print "SupportModifiers_v._copyModifiers()"

		/* DIRTY CODE - TIME RPOEASSURE */
		--support_with_modifiers	= (this._getSupportsWithModfiers(_objects_exists))[1]
		--_objects_no_modifiers	= this._getSupportsWithoutModfiers()

		--modifiers_of__objects	= support_with_modifiers.modifiers

		max create mode
		--
		--for obj in _objects do
		--	for _mod in modifiers do
		--		addModifierWithLocalData support_no_modifiers modifiers_of__objects[i] support_with_modifiers modifiers_of__objects[i] -- instance the modifier


		for obj in this._objects do
			for i = modifiers.count to 1 by -1 do
				addModifierWithLocalData obj modifiers[i] support_exists modifiers[i] -- instance the modifier

		--for i = modifiers_of__objects.count to 1 by -1 do
		--	try(
		--			addModifier _objects_no_modifiers modifiers_of__objects[i]
		--	)catch()

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
