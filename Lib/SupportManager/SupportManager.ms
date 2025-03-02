

filein( getFilenamePath(getSourceFileName()) + "/onEvents/onBeamDeletedCallback/onBeamDeletedCallback.ms" )	--"./onEvents/onBeamDeletedCallback/onBeamDeletedCallback.ms"
filein( getFilenamePath(getSourceFileName()) + "/onEvents/onSupportTransformCallback/onSupportTransformCallback.ms" )	--"./onEvents/onSupportTransformCallback/onSupportTransformCallback.ms"
filein( getFilenamePath(getSourceFileName()) + "/onEvents/onSourceObjectTransform/onSourceObjectTransform.ms" )	--"./onEvents/onSourceObjectTransform/onSourceObjectTransform.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/generateSupportsOrRafts.ms" )	--"./Lib/generateSupportsOrRafts.ms"

filein( getFilenamePath(getSourceFileName()) + "/SourceObject/SourceObjectTransformEventBinder/SourceObjectTransformEventBinder.ms" )	--"./SourceObject/SourceObjectTransformEventBinder/SourceObjectTransformEventBinder.ms"

filein( getFilenamePath(getSourceFileName()) + "/../SupportOptions/SupportOptions.ms" )	--"./../SupportOptions/SupportOptions.ms"

filein( getFilenamePath(getSourceFileName()) + "/SourceObject/SourceObject.ms" )	--"./SourceObject/SourceObject.ms"

filein( getFilenamePath(getSourceFileName()) + "/BeamObject/BeamObject.ms" )	--"./BeamObject/BeamObject.ms"

filein( getFilenamePath(getSourceFileName()) + "/BeamGenerator/BeamGenerator.ms" )	--"./BeamGenerator/BeamGenerator.ms"

filein( getFilenamePath(getSourceFileName()) + "/ModifiersManager/ModifiersManager.ms" )	--"./ModifiersManager/ModifiersManager.ms"

/** Support manager
  *
  *  DESCRIPTION OF SUPPORT SYSTEM:
  *			• Objects are linked for easy manipulation. LINK IS NOT REQUIRED
  *
  *			• Objects are linked via user data. Data are saved on: Source object, Master Point, Support|Raft,
  *					Master Point know source object
  *					Support|Raft know source object
  *					Beams knows his 2 supports
  *
  *
  *  HIERARCHY OF OBJECTS:
  *
  *		1) SOURCE OBJECT: Mesh object from which are support points generated. Parent of all objects:
  *					// Used vertices  1) SELECTED verts 2) ALL vertex with colors if nothing selected 3) ALL vertices if selection and colors not exists
  *
  * 			2) MASTER POINT ON TOP OF PLAFTORM - Dispalyed as: #BOX and #CROSS - Main point synced with source object by user prop data.
  *					//  Master poin knows which source object and vert has been used.
  *
  * 				3) NORMAL POINT - Dispalyed as: #BOX : Point aligned with source vertex normal
  *
  * 					3) OTHER POINTS - Dispalyed as: #CROSS - Points defining shape of support linked in chain to each other
  *						//  Support points straight to the ground from last point in chain
  *
  * 					4a) RAFT     Same as support obejct, but ends on last point in chain
  * 					4b) SUPPORT: Line connecting all points in chain.
  *
  *		 					5) BEAM: Cross lines between supports
  *
  *
  *
  *
  * NOTICES: Pointers of objects are changing throught sessions
  *
  * USER PROPS KEYS:
  *	#SOURCE_OBJECT	- Pointer of support source object saved into user props of sources object on first use of support system
  *
  *	#POINTER_SYNC	- #SOURCE_OBJECT Pointer saved to POINTS, SUPPORTS and BEAMS to keep connection with source object. #SOURCE_OBJECT==#POINTER_SYNC
  *
  *	#THIS        	- Pointer of object itself saved on object creation.
  *
  *	#SOURCE_VERT 	- Save index of vert of which was used as origin for point helper
  *
  *	#RAFT_MODE   	- Used on SUPPORTS and RAFTS - Differentiate types of objects
  *
  *	#BEAM_SUPPORTS	- Used on BEAMS - Array of supports pointers which beam connects E.G.: #( 1st_support, 2nd_pointer )
  *
  *
  *
  *
  *
 */
struct SupportManager_v
(
	/* construct */
	export_size,

	/* properties */
    SourceObjects	= Dictionary #STRING, --"./SourceObject/SourceObject.ms"
    SupportObjects	= Dictionary #STRING,
    BeamObjects 	= Dictionary #STRING, --KEY:#POINTER_SUPORT_AxPOINTER_SUPORT_B VALUE:BeamObject_v

	shapes_to_update = #(), -- sore shape for mass updating

	/* dependency */
	BeamGenerator = BeamGenerator_v(), --"./BeamGenerator/BeamGenerator.ms"

	/* reference */
	/* inhered */

	/*------------------------------------------------------------------------------
		GENERATE
	--------------------------------------------------------------------------------*/
	
	/** GENERATE SUPPORTS
	 */
	function generateSupports source_obj obj_type:#SUPPORT =
	(
		format "\n"; print "SupportManager_v.generateSupports()"
		--format "obj_type: %\n" obj_type
		max modify mode

		SUPPORT_OPTIONS.getValuesFromUi()

		SourceObject = this._getSourceObject(source_obj)

		/* GET SUPPORTS OF SOURCE OBJECT */ 
		supports_exists  = SourceObject.getSupportNodes obj_type:obj_type
		format "SUPPORTS_EXISTS: %\n" supports_exists

		/* GENERATE NEW SUPPORTS */ 
		new_nodes = SourceObject.generateSupports obj_type:obj_type

		
		if new_nodes.count > 0 then
		(
			/* ADD MODIFIERS */ 
			MODIFIERS_MANAGER.addModifiers( new_nodes ) obj_type:obj_type objects_exists:supports_exists
			
			/* BIND EVENTS */ 
			bindSupportToTransformEvent( SourceObject.getSupportNodes() )
		
			bindBeamOnDeleteCallback( SourceObject.getSupportNodes() )
		
			/* UPDATE SHAPES OF SUPPORTS */ 
			this.updateShapes()
		)

		new_nodes --return
	),

	/** GENERATE BEAMS
	 */
	function generateBeams sort_mode:#JOIN_CLOSE_SUPPORTS auto_sort:true max_distance: use_max_distance:false use_only_selected_supports:false max_connections: =
	(
		format "\n"; print "SupportManager_v.generateBeams()"
		--format "SORT_MODE: %\n" sort_mode
		--format "supports: %\n" supports
		--format "max_connections: %\n" max_connections
		--format "use_only_selected_supports: %\n" use_only_selected_supports

		/** if support height is greater then min height option
		 */
		function isTallEnough obj = obj.max.z - obj.min.z > SUPPORT_OPTIONS.min_height

		--/* GET ONLY SUPPORTS FROM OBJECTS */
		--supports = for obj in selection as Array where this.isType #SUPPORT obj != false collect obj

		_selection = selection as Array

		selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		--format "selected_supports: %\n" selected_supports
		selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		--format "selected_rafts: %\n" selected_rafts
		supports = selected_supports + selected_rafts


		/* DO NOT USE MAX DISTANCE IF ONLY 1 or 2 supports are selected */
		max_distance = if not use_max_distance or supports.count <= 2 then 999999999 else SUPPORT_OPTIONS.max_distance

		new_beams = if supports.count == 2 and not BeamGenerator.beamExists supports[1] supports[2]
					then /* CONNECT 2 SUPPORTS */ 
						#(BeamGenerator.generateBeam (supports[1]) (supports[2]))
			
					else /* CONNECT MORE 3 AND MORE SUPPORTS */ 
					(
						--supports = for support in supports where isTallEnough support collect support
			
						case sort_mode of
						(
							(#JOIN_CLOSE_SUPPORTS): BeamGenerator.generateBeamsToClosestSupports supports use_only_selected_supports:use_only_selected_supports max_distance:max_distance max_connections:max_connections
							(#JOIN_SUPPORTS_CHAIN): BeamGenerator.generateBeamsChain (supports) (max_distance)
							--default:
						)
					)

		--format "NEW_BEAMS: %\n" new_beams
		if new_beams.count > 0 then
		(
			this.updateShapes()

			select new_beams
		)
	),

	/** GENERATE DRAIN HOLES

	  TODO: move this method to its own file DrainGenerator.ms

	 */
	function generateDrainHoles =
	(
		--format "\n"; print "SupportManager_v.generateDrainHoles()"
		/** SWEEP Modifier
		  *
		  */
		function _sweepSetup sweep_mod diameter =
		(
			--format "\n"; print "SupportModifiers_v._sweep()"
			/** Reset mod propertis -- sweep mpdofoer keeps its settings if newly created, i dont know why.. oteh modifiers dont do that :D

				QUICK SOLUTION - FOR MORE MODIFIERS OR PROPERTIES SHOULD COMPLEX SOLUTUION EXISTS

			 */
			function resetSweepModProperties sweep_mod =
			(
				sweep_mod.MirrorXZPlane = off
				sweep_mod.MirrorXYPlane = off

				sweep_mod.XOffset = 0
				sweep_mod.yOffset = 0

				sweep_mod.angle = 0
				sweep_mod.SmoothSection = off
				sweep_mod.SmoothPath = off
				sweep_mod.PivotAlignment = 4


				sweep_mod.GenMatIDs = on
				sweep_mod.UseSectionIDs = off
				sweep_mod.UsePathIDs = off
			)

			resetSweepModProperties(sweep_mod)

			sweep_mod.CurrentBuiltInShape = 4 -- Set cylinder

			/* GENERATE MATERIAL ID */
            sweep_mod.UseSectionIDs	= false
            sweep_mod.UsePathIDs		= true

			sweep_mod[#Cylinder_Section].radius = diameter / 2

			sweep_mod.PivotAlignment = 6 -- align shape to corner

			sweep_mod --return
		)


		sweep_mod = sweep name:"DRAIN_WIDTH"

		shapes_to_update = #()

		source_obj = selection[1]

		verts	= getVertSelection source_obj.mesh

		verts_pos = in coordsys world meshop.getVerts source_obj.mesh verts node:source_obj

		direction = [ 0, 0, 1 ]

		knots = #()

		for i = 1 to verts.numberSet do
		(
			--format "knots: %\n" knots

			/* knots[1] is TOP knot */
			knots[1] = verts_pos[i] + ( SUPPORT_OPTIONS.drain_top * direction )
			knots[2] = verts_pos[i] + ( SUPPORT_OPTIONS.drain_bottom * (direction * -1 ) )

			drain_obj = SplineShape()

			--format "\n"; print "SupportObject_v._drawRaftLine()"
			addNewSpline drain_obj

			/*------------------------------------------------------------------------------
				ADD KNOTS BY POINTS FROM TOP TO BOTTOM
			--------------------------------------------------------------------------------*/
			for pos in knots do
				addKnot drain_obj 1 #corner #line pos



			drain_obj.pivot = knots[1]

			drain_obj.parent = source_obj

			setUserPropVal drain_obj "DRAIN_KEY" (getHandleByAnim drain_obj)

			setUserPropVal drain_obj "SYNC_KEY" (this._getSyncSourceKey(source_obj))

			append shapes_to_update drain_obj
		)

		with redraw off
			for _shape in shapes_to_update do
				updateShape _shape

		redrawViews()

		select shapes_to_update

		modPanel.addModToSelection sweep_mod ui:on

		_sweepSetup sweep_mod SUPPORT_OPTIONS.drain_width


	),


	/*------------------------------------------------------------------------------
		UPDATE & CONVERT
	--------------------------------------------------------------------------------*/


	/** Update all supports and rafts of given source
	  *  
	  *  This update is fired when source object is transformed
	  *  
      * @param #ROTATION|#POSITION_Z|#POSITION_XY what_to_update
	 */
	function updateBySourceObject source_objects what_to_update =
	(
		--format "\n"; print "SupportManager_v.updateSourceObject()"
		--format "what_to_update:    %\n" what_to_update

		sync_keys = for obj in source_objects where (sync_key = this._getSyncSourceKey (obj) ) != undefined collect sync_key
		--format "SYNC_KEYS: %\n" SYNC_KEYS
		
		/* UPDATE SUPPORTS - for each SourceObject */
		for sync_key in sync_keys do
		(
			SourceObject = SourceObjects[sync_key]
			
			SourceObject.removeDeletedNodes()
			--format "SOURCEOBJECT.SUPPORTS.KEYS: %\n" SourceObject.Supports.keys
			SourceObject.getVertsPositions( SourceObject.Supports.keys as BitArray )
			
			/* UPDATE SUPPORTS */
			if what_to_update != undefined then 
				case what_to_update of
				(
					#ROTATION:   SourceObject.updateSupports update_knot_1:false update_knot_2:false 
					#POSITION_Z: SourceObject.updateSupportsHeight()
				)
		)	
				

		/* UPDATE ALL BEAMS OF SUPPORTS */
		this._updateBeamsBySupports(sync_keys)
		
		this.updateShapes()
	),


	/** Update supports
	 */
	function updateSupports support_nodes update_knot_2:true direction:undefined =
	(
		--format "\n"; print "SupportManager_v.updateSupports()"
		--format "direction: %\n" direction
		--format "support_nodes: %\n" support_nodes

		supports_by_source = this._sortObjectsBySourceObject (support_nodes)

		--for sync_key in supports_by_source.keys do
		--	for support_node in supports_by_source[sync_key] do
		--		SourceObjects[sync_key].updateSupport(support_node) direction:direction

		for sync_key in supports_by_source.keys do
			SourceObjects[sync_key].updateSupports support_nodes:supports_by_source[sync_key] update_knot_2:update_knot_2 direction:direction
				
				
		/* UPDATE ALL BEAMS OF SUPPORTS */
		this._updateBeamsBySupports(supports_by_source.keys)

		this.updateShapes()
	),
 
	/** Update base height
	 */
	function updateBaseHeight =
	(
		--format "\n"; print "SupportManager_v.updateBaseHeight()"
		support_nodes = this._getObjectsForUpdate #SUPPORT
		--format "support_nodes: %\n" support_nodes.count

		supports_by_source = this._sortObjectsBySourceObject (support_nodes)

		for sync_key in supports_by_source.keys do
			SourceObjects[sync_key].updateBaseHeight(support_nodes)
		
		this.updateShapes()

		MODIFIERS_MANAGER.updateModifier( support_nodes )( #chamfer_base ) val:(SUPPORT_OPTIONS.getOption #CHAMFER_BASE )
	),

	/** Rebuild supports
	 */
	function resetSupports support_nodes =
	(
		format "\n"; print "SupportManager_v.resetSupports()"
		--format "SUPPORT_NODES: %\n" support_nodes
	
		supports_by_source = this._sortObjectsBySourceObject (support_nodes)
	
		for sync_key in supports_by_source.keys do
			--for support_node in supports_by_source[sync_key] do
				SourceObjects[sync_key].resetSupports(supports_by_source[sync_key])
	

		/* UPDATE ALL BEAMS OF SUPPORTS */
		this._updateBeamsBySupports(supports_by_source.keys)
	
		this.updateShapes()
	),

	/** Convert SUPPORTS to RAFTS or vice versa
	  *
	  * @param #SUPPORT|#RAFT obj_type of obejct to covert
	  *
	 */
	function convertType support_nodes to_type:#RAFT  =
	(
		--format "\n"; print "SupportManager_v.convert()"

		supports_by_source = this._sortObjectsBySourceObject(support_nodes)
		--format "supports_by_source: %\n" supports_by_source

		pauseSupportToTransformEvent()

		with redraw off
		
		/* FOR EACH SOURCE OBJECT */ 
		for sync_key in supports_by_source.keys do
		(
			supports_to_convert = supports_by_source[sync_key]
			--format "supports_exists.count: %\n" supports_exists.count
			supports_exists = SourceObjects[sync_key].getSupportNodes obj_type:to_type
			
			
			/* CONVERT TYPE */
			SourceObjects[sync_key].convertType( supports_to_convert ) obj_type:to_type

			
			/* GET EXISTING MODIFEIRS */
			if supports_exists.count > 0 then
				modifiers = supports_exists[1].modifiers
			
			
			/* CONVERT MODIFEIRS */
			MODIFIERS_MANAGER.convertSupportType( supports_to_convert ) obj_type:to_type modifiers:modifiers
		)

		redrawViews()

		this.updateShapes()

		resumeSupportToTransformEvent()
	),

	/** Update modifiers by control value
	 */
	function updateModifiers EventFired =
	(
		--format "\n"; print "SupportManager_v.updateModifiers()"
		--format "EventFired: %\n" EventFired
		
		/** Get string after underscore E.G.: "ROLLOUT_supports" >>> "supports"
		 */
		function splitString _string = substring _string ((findString _string "_")+1) -1 --return

		/* GET OBJECT TYPE BY ROLLOUT NAME  */
		obj_type = splitString (EventFired.Roll.name)
		
		/* GET PROPERTY KEY BY CONTROL NAME */
		prop_key = splitString (EventFired.control.name)

		/* REMOVE TRAILING "S" E.G.: "RAFTS" >>> "RAFT" */ 
		obj_type = ( trimRight obj_type "Ss" ) as name
		--format "OBJ_TYPE: %\n" obj_type
		--format "PROP_KEY: %\n" prop_key
		
		objects_by_type = this._getObjectsForUpdate obj_type


		SUPPORT_OPTIONS.setOptionValue (prop_key) (EventFired.val)
		
		SUPPORT_OPTIONS.init()
		
		/* UPDATE MODIFIER */ 
		MODIFIERS_MANAGER.updateModifier( makeUniqueArray objects_by_type )( prop_key as name )
	),

	/** Update shape add
	 */
	function updateShapeAdd _shape =
	(
		--format "\n"; print "SupportManager_v.updateShapeAdd()"
		appendIfUnique shapes_to_update _shape
	),

	/** Update shapes
	 */
	function updateShapes =
	(
		--format "\n"; print "SupportManager_v.updateShapes()"

		if shapes_to_update.count > 0 then
		(
			with redraw off
				for _shape in shapes_to_update do
					updateShape _shape
	
			redrawViews()
		)

		shapes_to_update = #()
	),

	/*------------------------------------------------------------------------------
		CALLBACK
	--------------------------------------------------------------------------------*/

	/** On beam deleted
	 */
	function onObjectDeleted obj =
	(
		--format "\n"; print "SupportManager_v.onObjectDeleted()"
		--format "obj: %\n" obj

		/* IF SOURCE OBJECT */
		if (sync_key = this.isSourceObject obj) != false then
		(
			RemoveDictValue SourceObjects sync_key

			/*  DELETE SUPPORTS */
			for support_key in SourceObjects[sync_key].Supports.keys do
				delete SourceObjects[sync_key].Supports[support_key].support_obj
		)

		/* IF SUPPORT DELETED */
		else if (support_key = this.isType #SUPPORT obj) != false or (raft_key = this.isType #RAFT obj) != false then
		(
			format "SUPPORT DELETED\n"
			if support_key == false then
				support_key = raft_key
			format "support_key: %\n" support_key
			sync_key = this._getSyncKey obj
		    index    = getUserPropVal obj "INDEX"

			/* REMOVE FROM SOURCE OBJECT */
			RemoveDictValue SourceObjects[sync_key].Supports index

			/* REMOVE FROM THIS */
			RemoveDictValue SupportObjects support_key

			/*  DELETE BEAMS */
			for beam_key in BeamObjects.keys where matchPattern beam_key pattern:("*"+support_key+"*") do
				delete BeamObjects[beam_key].beam
		)

		/* IF BEAM DELETED */
		else if (beam_key = this.isType #BEAM obj) != false then
			RemoveDictValue BeamObjects beam_key

	),

	/*------------------------------------------------------------------------------
		HELPERS
	--------------------------------------------------------------------------------*/
	
	/** Add SupportObject to this.SupportObjects Array
	 */
	function addSupportObjects SupportObject =
	(
		--format "\n"; print "SupportManager_v.addSupportObjects()"
		--format "SupportObject: %\n" SupportObject
		obj_pointer = (getHandleByAnim SupportObject.support_obj) as string 
		SupportObjects[obj_pointer] = SupportObject
	),
	
	/** Test if object is managed by SupportManager
	  *
	  * @return boolean
	 */
	function isManaged obj =
	(
		--format "\n"; print "SupportManager_v.isSourceObject()"
		getUserPropVal obj "SYNC_KEY" != undefined
	),

	/** Test if object is source object
	  *
	  * @return string|false
	 */
	function isSourceObject obj =
	(
		--format "\n"; print "SupportManager_v.isSourceObject()"
		if ( sync_key = getUserPropVal obj "SOURCE_KEY" ) != undefined then
			sync_key --return
		else
			false --return
	),

	/** Test if object is type of source|support|beam|raft
	  *
	  * @return string|false
	 */
	function isType type obj =
	(
		--format "\n"; print "SupportManager_v._isObjectType()"
		type_full = toUpper (type as string ) + "_KEY"
		--format "type_full: %\n" type_full

		--if superClassOf obj.baseobject == shape and ( object_key = getUserPropVal obj type_full ) != undefined then
		if ( object_key = getUserPropVal obj type_full ) != undefined then
			object_key --return
		else
			false --return
	),

	/** Get objects of give object type
	  * 
      * 1) IF NOTHING SELECTED:     	Get all objects of type from SCENE
      * 2) IF SOURCE SELECTED:    		Get all objects of type from SOURCE OBJECT
      * 3) IF SOME OBEJCTS SELECTED:	Get all objects of type from SELECTION
	 */
	function _getObjectsForUpdate obj_type =
	(
		--format "\n"; print "SupportManager_v.getObejctsForUpdate()"
        /* GET OBJECTS TO PROCESS */ 		
		_objects = ( if selection.count > 0 then selection else objects ) as Array
		--format "_OBJECTS: %\n" _objects

		/* GET SOURCE OBJECTS */
		source_objects = this.getSourceObjects ( _objects ) get_nodes:true
		--format "SOURCE_OBJECTS: %\n" source_objects
		
		/* GET OBJECTS BY TYPE */
		objects_by_type = this.getObjectsByType ( if source_objects.count > 0 then source_objects else _objects ) type:obj_type
		--objects_by_type = this.getObjectsByType ( _objects ) type:obj_type
		--format "OBJECTS_BY_TYPE: %\n" OBJECTS_BY_TYPE
		--format "OBJECTS_BY_TYPE.count: %\n" OBJECTS_BY_TYPE.count
		objects_by_type --return
	),
	
	/** get objects by type
	  *
	  * @param name type of object: #SOURCE|#SUPPORT|#BEAM|#RAFT|#DRAIN|#PIN
	 */
	function getObjectsByType _objects type: visibility:true hierarchy:false =
	(
		format "\n"; print "SupportManager_v.getObjectsByType()"
		format "type: %\n" type
		
        objects_by_type = #()

        source_keys = #()
        supports	= #()
        rafts		  = #()
        beams   	= #()
        drains   	= #()
        pins   		= #()

		/* SORT BY TYPE */ 
		for obj in _objects do
			case of
			(
				/* TODO NOTICES
				   
				   this._getKey() SHOULD MODIFIED BE PERFOMED ONLY ONCE
					
					it should return #( #TYPE, KEY )
					
					USE getUserPropBuffer TO PARSE USER PROPS
				
				*/ 
				
                ((sync_key = this._getKey #SOURCE obj) != undefined ): append source_keys sync_key

                ((this._getKey #SUPPORT obj) != undefined ): append supports obj
                ((this._getKey #RAFT	obj) != undefined ): append rafts obj
                ((this._getKey #BEAM    obj) != undefined ): append beams obj
                ((this._getKey #DRAIN   obj) != undefined ): append drains obj
                ((this._getKey #PIN     obj) != undefined ): append pins obj
			)

		--format "\n\n"
		--format "SOURCE_KEYS: %\n" source_keys
		--format "SUPPORTS: %\n" supports
		--format "RAFTS: %\n" rafts
		--format "BEAMS: %\n" beams
		--format "DRAINS: %\n" drains
		--format "PINS: %\n" pins

		/*==============================================================================
			GET SOURCE OBJECTS
		================================================================================*/
		if type == #SOURCE then
		(
			format "GET SOURCE OBJECTS\n"
			--for source_key in source_keys do append objects_by_type SourceObjects[source_key]
			
			sync_keys_of_objs = for obj in supports + beams + rafts collect this._getSyncKey(obj)

			objects_by_type = for key in makeUniqueArray ( source_keys + sync_keys_of_objs ) where SourceObjects[key] != undefined collect SourceObjects[key].obj
		)

		/*==============================================================================
			GET DRAINS
		================================================================================*/
		else if type == #DRAIN then
		(
			format "GET DRAINS\n"
			--for source_key in source_keys do append objects_by_type SourceObjects[source_key]
			objects_by_type = drains --return

			if source_keys.count > 0 then
				for obj in objects where this._getKey #DRAIN obj != undefined and ( sync_key = this._getSyncKey obj) != undefined and findItem source_keys sync_key > 0 do
                    appendIfUnique objects_by_type obj

		)
		else if type == #PIN then
		(
			--format "GET PINS\n"
			--for source_key in source_keys do append objects_by_type SourceObjects[source_key]
			objects_by_type = pins --return
		)
		
		/*==============================================================================
			GET BY SOURCE OBEJCT
		================================================================================*/
		else if source_keys.count > 0 then
		(
			format "GET BY SOURCE OBJECT\n"
			raft_test = type == #RAFT
			
			/* GET BEAMS OF SOURCE OBJECT */
			if hierarchy or type == #BEAM  then
				for key in BeamObjects.keys where findItem source_keys BeamObjects[key].sync_key > 0 do
					append objects_by_type BeamObjects[key].beam
			
			/* GET SUPPORTS OF SOURCE OBJECT */
			if hierarchy or type == #SUPPORT or type == #RAFT  then
				for key in SupportObjects.keys where findItem source_keys SupportObjects[key].sync_key > 0 and SupportObjects[key].isRaft() == raft_test do
					append objects_by_type SupportObjects[key].support_obj
		)

		/*==============================================================================
			GET BY SUPPORTS
		================================================================================*/
		else if supports.count > 0 or rafts.count > 0 then
		(
			--format "\n"
			format "GET BY SUPPORTS\n"
			--format "HIERARCHY: %\n" HIERARCHY

			--supports_and_rafts = if type == #SUPPORT then supports else rafts
			supports_and_rafts = supports + rafts

			--objects_by_type =  deepCopy supports_and_rafts
			
			/* GET BEAMS OF SUPPORTS OR RAFTS */
			if hierarchy or type == #BEAM  then
				for beam_key in BeamObjects.keys where findItem supports_and_rafts BeamObjects[beam_key].support_A > 0 or findItem supports_and_rafts BeamObjects[beam_key].support_B > 0 do
					append objects_by_type BeamObjects[beam_key].beam
			
			/* add to current selection */
			------if hierarchy or type == #SUPPORT or type == #RAFT then
			if hierarchy then
				objects_by_type += _objects
		)

		/*==============================================================================
			GET BY BEAMS
		================================================================================*/
		else if beams.count > 0 then
		(
			format "GET BY BEAMS\n"
			/* GET BEAMS */
			if type == #BEAM  then
				objects_by_type = beams

			/* GET SUPPORTS BY BEAMS */
			else if type == #SUPPORT then
				for beam in beams do(

					appendIfUnique objects_by_type SupportObjects[getUserPropVal beam "SUPPORT_A"].support_obj
					appendIfUnique objects_by_type SupportObjects[getUserPropVal beam "SUPPORT_B"].support_obj
				)
		)
		

		objects_by_type = for obj in objects_by_type where isValidNode obj collect obj  --return
		--format "OBJECTS_BY_TYPE: %\n" objects_by_type
		--format "OBJECTS_BY_TYPE.count: %\n" OBJECTS_BY_TYPE.count
		
		objects_by_type --return
	),

	/** Get source object
	 */
	function getSourceObjects _objects get_nodes:false =
	(
		--format "\n"; print "SupportManager_v.getSourceObjects()"
		sync_keys = for obj in _objects where (sync_key = this._getSyncSourceKey (obj)) != undefined collect sync_key
		--format "sync_keys: %\n" sync_keys
		
		source_objects = for sync_key in sync_keys collect SourceObjects[sync_key]
		
		if get_nodes then
			for source_object in source_objects collect source_object.obj --return
		
		else
			source_objects --return
	),
	
	/** Get supports and rafts
	 */
	function getSupportsAndRafts _objects =
	(
		--format "\n"; print "SupportManager_v.getSugetSupportsAndRaftspportsAndRaftsFromSelection()"
		
		supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT
		rafts	 = SUPPORT_MANAGER.getObjectsByType _objects type:#RAFTS

		supports + rafts --return
	),

	/*------------------------------------------------------------------------------*/

	private

	/*------------------------------------------------------------------------------*/

	/** Get supports
	 */
	function _getSupportNodes _objects =
	(
		--format "\n"; print "SupportManager_v._getSupports()"
		for obj in _objects where this.isType #SUPPORT obj != false or this.isType #RAFT obj != false collect obj
	),

	/** Sort obejcts by source object
	  *
	  * @return Dictionary #STRING -- KEY:"SYNC_KEY" VALUE:#( nodes of source objects )
	 */
	function _sortObjectsBySourceObject _objects =
	(
		--format "\n"; print "SupportManager_v.sortObejctsBySourceObject()"
		supports_by_source =  Dictionary #STRING

		for obj in _objects do
		(
			sync_key = this._getSyncKey (obj)

			if supports_by_source[sync_key] == undefined then
				supports_by_source[sync_key] = #()

			append supports_by_source[sync_key] obj
		)

		supports_by_source --return
	),
	
	/** Update beams by supports
	 */
	function _updateBeamsBySupports support_keys =
	(
		--format "\n"; print "SupportManager_v._updateBeamsBySupports()"
		for key in BeamObjects.keys where findItem support_keys (this._getSyncKey (BeamObjects[key].beam)) > 0 do
			BeamObjects[key].updateBeam()
	),
	
	/*------------------------------------------------------------------------------
	
		LOAD OBJECTS FROM SCENE
	
	--------------------------------------------------------------------------------*/
	
	/** Load source objects from scene
	 */
	function _loadSourceObjectsFromScene =
	(
		--format "\n"; print "SupportManager_v._loadSourceObjectsFromScene()"

		--unindSupportToTransformEvent()
		--for obj_in_scene in objects do
			--format "sync_key: %\n" (this.isType #SOURCE obj_in_scene)

		for obj_in_scene in objects where (sync_key = this.isSourceObject obj_in_scene) != false do
		(
			--format "obj_in_scene: %\n" obj_in_scene
			SourceObject = SourceObject_v(obj_in_scene) (sync_key)

			supports = SourceObject.getSupportNodes()

			SourceObjects[sync_key] = SourceObject
		)

		/* BIND TO EVENTS */
		SOURCE_OBJECT_TRANSFORM.bindSourceObjectTransformEvent ( for sync_key in SourceObjects.keys collect SourceObjects[sync_key].obj )

	),

	/** Load supports from scene
	 */
	function _loadSupportsFromScene =
	(
		--format "\n"; print "SupportManager_v.loadSupportsFromScene()"

		for obj_type in #( #SUPPORT, #RAFT ) do
			for obj_in_scene in objects where (support_key = this._getKey obj_type obj_in_scene) != undefined do
			(
				--format "OBJ_IN_SCENE: %\n" obj_in_scene
				--format "SUPPORT_KEY: %\n" support_key
				index	 = getUserPropVal obj_in_scene "INDEX"
				sync_key = getUserPropVal obj_in_scene "SYNC_KEY"
				is_on_ground = getUserPropVal obj_in_scene "IS_ON_GROUND"
				--format "index: %\n" index
				--format "sync_key: %\n" sync_key
				
				--format "IS_ON_GROUND: %\n" IS_ON_GROUND
				--is_raft	 = getUserPropVal obj_in_scene "IS_RAFT"
				if SourceObjects[sync_key] != undefined then 
				(
					source_obj = if sync_key != undefined then SourceObjects[sync_key].obj
					
					SupportObject = SupportObject_v source_obj:source_obj support_obj:obj_in_scene support_key:support_key sync_key:sync_key obj_type:obj_type is_on_ground:is_on_ground

					SupportObjects[SupportObject.support_key] = SupportObject
					
					if sync_key != undefined then 
						SourceObjects[sync_key].Supports[index] = SupportObject
				)
			)

		for SourceObjectData in SourceObjects do
			SourceObjectData.value.setVertsPosBySupports()

		bindSupportToTransformEvent( for key in SupportObjects.keys collect SupportObjects[key].support_obj )
		
		bindBeamOnDeleteCallback( for key in SupportObjects.keys collect SupportObjects[key].support_obj )
	),

	/** Load beam objects from scene
	 */
	function _loadBeamsFromScene =
	(
		--format "\n"; print "SupportManager_v._loadBeamsFromScene()"
		--if ( SourceObjects[sync_key] ) != undefined then

		/* REMOVE DELETE NODES */
		for key in BeamObjects.keys where not isValidNode BeamObject[key].beam do
			RemoveDictValue BeamObjects key

		for obj_in_scene in objects where (beam_key = this.isType #BEAM obj_in_scene) != false do
		(
			--format "beam_key: %\n" beam_key
			key_A = getUserPropVal obj_in_scene "SUPPORT_A"
			key_B = getUserPropVal obj_in_scene "SUPPORT_B"

		    sync_key = getUserPropVal obj_in_scene "SYNC_KEY"

			--format "key_A: %\n" key_A
			--format "key_B: %\n" key_B

			if SupportObjects[key_A] != undefined and SupportObjects[key_B] != undefiand then
			(
				support_A = SupportObjects[key_A].support_obj
				support_B = SupportObjects[key_B].support_obj

				BeamObject = BeamObject_v support_A:support_A support_B:support_B beam:obj_in_scene beam_key:beam_key sync_key:sync_key

				/* ADD TO BEAMS */
				BeamObjects[beam_key] = BeamObject
			)

		)

		bindBeamOnDeleteCallback( for key in BeamObjects.keys collect BeamObjects[key].beam )
	),


	/*------------------------------------------------------------------------------
	
		GETTERS
	
	--------------------------------------------------------------------------------*/

	/** Get sync key from source object
	 */
	function _getSyncSourceKey source_obj =
	(
		--format "\n"; print "SupportManager_v._getSyncSourceKey()"
		--format "source_obj: %\n" source_obj
		getUserPropVal source_obj "SOURCE_KEY" asString:true
	),

	/** Get sync key from object
	 */
	function _getSyncKey obj =
	(
		--format "\n"; print "SupportManager_v.getSyncKey()"
		getUserPropVal obj "SYNC_KEY" asString:true
	),

	/** Get "SOURCE_KEY|SUPPORT_KEY|BEAM_KEY|" keys from user object properties
	  *
	  * @return string|undefined
	 */
	function _getKey type obj =
	(
		--format "\n"; print "SupportManager_v._getKey()"
		--format "obj: %\n" obj.name
		
		type_full = toUpper (type as string ) + "_KEY"
		--format "type_full: %\n" type_full

		obj_key =  getUserPropVal obj type_full asString:true
		--format "OBJ_KEY: %\n" obj_key
		obj_key --return
	),


	/** Get source object
	 */
	function _getSourceObject source_obj =
	(
		--format "\n"; print "SupportManager_v._getSourceObject()"
		pointer = (getHandleByAnim source_obj) as string

		sync_key = getUserPropVal source_obj "SOURCE_KEY"

		if sync_key == undefined then
		(
			sync_key = pointer

			setUserPropVal source_obj "SOURCE_KEY" sync_key asString:true
		)


		if SourceObjects[sync_key] == undefined then
		(
			SourceObjects[sync_key] = SourceObject_v(source_obj) (sync_key)

			SOURCE_OBJECT_TRANSFORM.bindSourceObjectTransformEvent (source_obj)
		)

		--SourceObject = SourceObjects[sync_key]
		SourceObjects[sync_key] --return
	),

	/**
	*/
	on create do
	(
		--format "\n"; print "SupportManager_v.onCreate()"

		--DisableSceneRedraw()
		 if SLICER_SYSTEM != undefined then SLICER_SYSTEM.toggleModifiers false

		this._loadSourceObjectsFromScene()
		
		this._loadSupportsFromScene()
		
		this._loadBeamsFromScene()


		 if SLICER_SYSTEM != undefined then SLICER_SYSTEM.toggleModifiers true
		--EnableSceneRedraw()
	)
)
