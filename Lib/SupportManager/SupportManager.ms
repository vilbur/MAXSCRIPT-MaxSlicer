--filein( getFilenamePath(getSourceFileName()) + "/../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-VERTEX COLORS/Lib/VertexColorProcessor.ms" )	--"./../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-VERTEX COLORS/Lib/VertexColorProcessor.ms"

filein( getFilenamePath(getSourceFileName()) + "/../../content/rollouts-Main/rollout-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms" )	--"./../../content/rollouts-Main/rollout-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms"
--filein( getFilenamePath(getSourceFileName()) + "/../VertexColors/VertexColors.ms" )	--"./../VertexColors/VertexColors.ms"

--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-VERTEX COLORS\Lib\VertexColorProcessor.ms"
filein( getFilenamePath(getSourceFileName()) + "/../../content/rollouts-Main/rollout-VERTEX_COLORS/Lib/VertexColorProcessor/VertexColorProcessor.ms" )	--"./../../content/rollouts-Main/rollout-VERTEX_COLORS/Lib/VertexColorProcessor/VertexColorProcessor.ms"

filein( getFilenamePath(getSourceFileName()) + "/onEvents/onBeamDeletedCallback/onBeamDeletedCallback.ms" )	--"./onEvents/onBeamDeletedCallback/onBeamDeletedCallback.ms"
filein( getFilenamePath(getSourceFileName()) + "/onEvents/onSupportTransformCallback/onSupportTransformCallback.ms" )	--"./onEvents/onSupportTransformCallback/onSupportTransformCallback.ms"
filein( getFilenamePath(getSourceFileName()) + "/onEvents/onSourceObjectTransform/onSourceObjectTransform.ms" )	--"./onEvents/onSourceObjectTransform/onSourceObjectTransform.ms"

--filein( getFilenamePath(getSourceFileName()) + "/../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-PINS/Lib/PinsGenerator.ms" )	--"./../../../MAXSCRIPT-MaxToPrint/content/rollouts-Main/rollout-PINS/Lib/PinsGenerator.ms"

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

	/** Generate points
	 */
	function generateSupports source_obj obj_type:#SUPPORT =
	(
		format "\n"; print "SupportManager_v.generateSupports()"
		--format "obj_type: %\n" obj_type
		SourceObject = this._getSourceObject(source_obj)

		supports_exists  = SourceObject.getSupportNodes obj_type:obj_type
		format "supports_exists: %\n" supports_exists

		new_nodes = SourceObject.generateSupports obj_type:obj_type
		format "NEW SUPPORTS: %\n" new_nodes
		format "COUNT: %\n" new_nodes.count

		if new_nodes.count > 0 then
		(
			MODIFIERS_MANAGER.addModifiers( new_nodes ) obj_type:obj_type supports_exists:supports_exists

			bindSupportToTransformEvent( SourceObject.getSupportNodes() )

			bindBeamOnDeleteCallback( SourceObject.getSupportNodes() )

			this.updateShapes()
		)

		new_nodes --return
	),

	/** Generate beams
	 */
	function generateBeams sort_mode:#JOIN_CLOSE_SUPPORTS auto_sort:true max_distance: use_max_distance:false use_only_selected_supports:false max_connections: =
	(
		format "\n"; print "SupportManager_v.generateBeams()"
		--format "supports: %\n" supports
		format "max_connections: %\n" max_connections
		--format "use_only_selected_supports: %\n" use_only_selected_supports

		/** if support height is greater then min height option
		 */
		function isTallEnough obj = obj.max.z - obj.min.z > SUPPORT_OPTIONS.min_height

		--/* GET ONLY SUPPORTS FROM OBJECTS */
		--supports = for obj in selection as Array where this.isType #SUPPORT obj != false collect obj

		_selection = selection as Array

		selected_supports = for obj in _selection where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		format "selected_supports: %\n" selected_supports
		selected_rafts    = for obj in _selection where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		format "selected_rafts: %\n" selected_rafts
		supports = selected_supports + selected_rafts

		format "supports: %\n" supports

		/* DO NOT USE MAX DISTANCE IF ONLY 1 or 2 supports are selected */
		max_distance = if not use_max_distance or supports.count <= 2 then 999999999 else SUPPORT_OPTIONS.max_distance

		new_beams = if supports.count == 2 and not BeamGenerator.beamExists supports[1] supports[2] then
			#(BeamGenerator.generateBeam (supports[1]) (supports[2]))

		else
		(
			supports = for support in supports where isTallEnough support collect support

			case sort_mode of
			(
				(#JOIN_CLOSE_SUPPORTS): BeamGenerator.generateBeamsToClosestSupports supports use_only_selected_supports:use_only_selected_supports max_distance:max_distance max_connections:max_connections
				(#JOIN_SUPPORTS_CHAIN): BeamGenerator.generateBeamsChain (supports) (max_distance)
				--default:
			)

		)

		format "NEW_BEAMS: %\n" new_beams
		if new_beams.count > 0 then
		(
			this.updateShapes()

			select new_beams
		)
	),

	/** Generate drain holes

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

	/** Update supports
	 */
	function updateSupportsBySourceObject source_objects only_height:false =
	(
		format "\n"; print "SupportManager_v.updateSupportsBySourceObject()"

		sync_keys = for obj in source_objects where (sync_key = this._getSyncSourceKey (obj) ) != undefined collect sync_key

		/* UPDATE SUPPORTS */
		for sync_key in sync_keys do
			if only_height then
				SourceObjects[sync_key].updateSupportsHeight()

			else
				SourceObjects[sync_key].updateSupports()

		/* UPDATE ALL BEAMS OF SOURCE OBEJCTS */
		for key in BeamObjects.keys where findItem sync_keys (this._getSyncKey (BeamObjects[key].beam)) > 0 do
			BeamObjects[key].updateBeam()

		this.updateShapes()
	),


	/** Update supports
	 */
	function updateSupports support_nodes =
	(
		--format "\n"; print "SupportManager_v.updateSupportPosition()"
		--format "support_nodes: %\n" support_nodes

		supports_by_source = this._sortObjectsBySourceObject (support_nodes)

		for sync_key in supports_by_source.keys do
			for support_node in supports_by_source[sync_key] do
				SourceObjects[sync_key].updateSupport(support_node)

		/* UPDATE ALL BEAMS OF SELECTED SUPPORTS */
		/* !!!!!!!!!!!!! TODO UPDATE ONLY BEAMS OF UPDATED SUPPORTS */
		for key in BeamObjects.keys where findItem supports_by_source.keys (this._getSyncKey (BeamObjects[key].beam)) > 0 do
			BeamObjects[key].updateBeam()


		this.updateShapes()
	),

	/** Rebuild supports
	 */
	function rebuildSupports support_nodes =
	(
		format "\n"; print "SupportManager_v.updateSupports()"
		format "SUPPORT_NODES: %\n" support_nodes

		supports_by_source = this._sortObjectsBySourceObject (support_nodes)

		for sync_key in supports_by_source.keys do
			for support_node in supports_by_source[sync_key] do
				SourceObjects[sync_key].rebuildSupport(support_node)

		/* UPDATE ALL BEAMS OF SELECTED SUPPORTS */
		/* !!!!!!!!!!!!! TODO UPDATE ONLY BEAMS OF UPDATED SUPPORTS */
		for key in BeamObjects.keys where findItem supports_by_source.keys (this._getSyncKey (BeamObjects[key].beam)) > 0 do
			BeamObjects[key].updateBeam()


		this.updateShapes()
	),

	/** Convert support to raft or vice versa
	  *
	  * @param #SUPPORT|#RAFT obj_type of obejct to covert
	  *
	 */
	function convert support_nodes obj_type:#RAFT  =
	(
		format "\n"; print "SupportManager_v.convert()"

		--from_type =  if obj_type == #RAFT then #SUPPORT else #RAFT
		--format "SupportObjects: %\n" SupportObjects
		--format "from_type: %\n" from_type
		format "obj_type:   %\n" obj_type
		--format "supports_by_source.keys: %\n" supports_by_source.keys

		supports_by_source = this._sortObjectsBySourceObject (support_nodes)
		--format "supports_by_source: %\n" supports_by_source

		pauseSupportToTransformEvent()

		with redraw off
			for sync_key in supports_by_source.keys do
			(

				--format "sync_key: %\n" sync_key

				supports_to_convert = supports_by_source[sync_key]
				supports_exists = SourceObjects[sync_key].getSupportNodes obj_type:obj_type
				/* CONVERT TYPE */
				SourceObjects[sync_key].convert( supports_to_convert ) obj_type:obj_type

				--format "TEST supports_exists: %\n" (SourceObjects[sync_key].getSupportNodes obj_type:obj_type)
				/* CONVERT MODIFEIRS */
				if supports_exists.count > 0 then
					modifiers = supports_exists[1].modifiers
				--format "MODIFIERS: %\n" modifiers
				MODIFIERS_MANAGER.convertSupportType( supports_to_convert ) obj_type:obj_type modifiers:modifiers
			)

		redrawViews()


		--for sync_key in supports_by_source.keys do
		--	for support_node in supports_by_source[sync_key] do
		--		SourceObjects[sync_key].convertToRaft(support_node)

		this.updateShapes()

		resumeSupportToTransformEvent()
	),

	/** Update modifiers by control value
	 */
	function updateModifiers EventFired =
	(
		format "\n"; print "SupportManager_v.updateModifiers()"
		_selection = ( if selection.count > 0 then selection else objects ) as Array

		/* GET OBJECT TYPE BY ROLLOUT NAME  */
		obj_type = substring EventFired.Roll.name    ((findString EventFired.Roll.name "_")+1) -1
		/* GET PROPERTY KEY BY CONTROL NAME */
		prop_key = substring EventFired.control.name ((findString EventFired.control.name "_")+1) -1

		obj_type = trimRight obj_type "s"


		--format "obj_type: %\n" obj_type
		--format "prop_key: %\n" prop_key

		/* GET SOURCE OBJECTS */
		source_objects = this.getSourceObjects ( _selection )

		/* GET OBJECTS BY TYPE */
		objects_by_type = this.getObjectsByType ( _selection ) type:( obj_type )
		format "OBJECTS_BY_TYPE: %\n" OBJECTS_BY_TYPE
		format "OBJECTS_BY_TYPE.count: %\n" OBJECTS_BY_TYPE.count

		--for SourceObject in source_objects do
		--	join objects_by_type (SourceObject.getSupportNodes())
		--
		SUPPORT_OPTIONS.setOptionValue (prop_key) (EventFired.val)

		SUPPORT_OPTIONS.init()

		/* GET MODIFIER NAME -same as prop key, but change #RAFT_WIDTH > #BAR_WIDTH  */
		--mod_name = if obj_type == #RAFT and prop_key == #RAFT_WIDTH then #BAR_WIDTH else prop_key as name

		--SPIN_base_width
		MODIFIERS_MANAGER.updateModifier( makeUniqueArray objects_by_type )( prop_key as name )
	),


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
		else if (support_key = this.isType #SUPPORT obj) != false or (support_key = this.isType #RAFT obj) != false then
		(
			sync_key = this._getSyncKey obj
		    index    = getUserPropVal obj "INDEX"

			/* REMOVE FROM SOURCE OBJECT */
			RemoveDictValue SourceObjects[sync_key].Supports index

			/* REMOVE FROM THIS */
			RemoveDictValue SupportObjects support_key

			/*  DELETE BEAMS */
			for beam_key in BeamObjects.keys where matchPattern support_key pattern:("*"+beam_key+"*") do
				delete BeamObjects[beam_key].beam
		)

		/* IF BEAM DELETED */
		else if (beam_key = this.isType #BEAM obj) != false then
			RemoveDictValue BeamObjects beam_key

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

		with redraw off
			for _shape in shapes_to_update do
				updateShape _shape

		redrawViews()

		shapes_to_update = #()
	),




--	/** get objects by type
--	 */
--	function searchObjectsByType _objects type: hierarchy:false =
--	(
--		format "\n"; print "SupportManager_v.searchObjectsByType()"
--
--        source_keys = #()
--        supports	= #()
--        beams   	= #()
--
--        objects_to_process = #()
--
--
--		for obj in _objects do
--			case of
--			(
--                ((sync_key = this.isSourceObject obj) != false): append source_keys sync_key
--                --((this.isType #SOURCE  obj) != false): append source_keys obj
--                ((this.isType #SUPPORT obj) != false): append supports obj
--                ((this.isType #BEAM    obj) != false): append beams obj
--                --default:
--			)
--
--		format "source_keys: %\n" source_keys.count
--		format "supports: %\n" supports.count
--		format "beams: %\n" beams.count
--
--		if type == #SOURCE then
--		(
--			--for source_key in source_keys do append objects_to_process SourceObjects[source_key]
--			--if hierarchy then
--			--(
--				sync_keys_of_objs = for obj in supports + beams collect this._getSyncKey(obj)
--			--	format "sync_keys_of_objs: %\n" sync_keys_of_objs
--			--	format "source_keys: %\n" source_keys
--			--
--				source_keys = makeUniqueArray (source_keys + sync_keys_of_objs)
--			--	--objects_to_process = for key in  collect SourceObjects[key].obj
--			--
--			--	source_keys = makeUniqueArray (source_keys + sync_keys_of_objs)
--			--)
--
--
--			objects_to_process = for key in source_keys collect SourceObjects[key].obj
--		)
--
--		else if source_keys.count > 0 then
--		(
--
--			/* GET SUPPORTS OF SOURCE OBJECT */
--			if hierarchy or type == #SUPPORT  then
--				for key in SupportObjects.keys where findItem source_keys SupportObjects[key].sync_key > 0 do
--					append objects_to_process SupportObjects[key].support_obj
--
--			/* GET BEAMS OF SOURCE OBJECT */
--			if hierarchy or type == #BEAM  then
--				for key in BeamObjects.keys where findItem source_keys BeamObjects[key].sync_key > 0 do
--					append objects_to_process BeamObjects[key].beam
--
--		)
--		else if supports.count > 0 then
--		(
--
--			if  hierarchy or type == #SUPPORT then
--				objects_to_process += supports
--
--			/* GET BEAMS OF SOURCE OBJECT */
--				if hierarchy or type == #BEAM  then
--					for key in BeamObjects.keys where findItem supports BeamObjects[key].support_A > 0 or findItem supports BeamObjects[key].support_B > 0 do
--						append objects_to_process BeamObjects[key].beam
--
--		)
--		else if beams.count > 0 then
--		(
--
--			if type == #BEAM  then
--				objects_to_process = beams
--
--
--			else if type == #SUPPORT then
--				for beam in beams do(
--
--					appendIfUnique objects_to_process SupportObjects[getUserPropVal beam "SUPPORT_A"].support_obj
--					appendIfUnique objects_to_process SupportObjects[getUserPropVal beam "SUPPORT_B"].support_obj
--				)
--
--		)
--
--
--
--		format "OBJECTS_TO_PROCESS: %\n" OBJECTS_TO_PROCESS
--
--		objects_to_process --return
--	),

	/*------------------------------------------------------------------------------
		TEST OBEJCT TYPE
	--------------------------------------------------------------------------------*/

	/** Test if object is support|beam|raft
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


	/** get objects by type
	  *
	  * @param name type of object: #SOURCE|#SUPPORT|#BEAM|#RAFT
	 */
	function getObjectsByType _objects type: visibility:true hierarchy:false =
	(
		format "\n"; print "SupportManager_v.getObjectsByType()"
		--format "type: %\n" type
		--format "_objects: %\n" _objects
		--/** Is type support
		-- */
		--function isTypeSupport type =
		--(
		--	--format "\n"; print "SupportManager_v.isTypeSupport()"
		--	type == #SUPPORT or type == #RAFT
		--)

        source_keys = #()
        supports	= #()
        rafts		  = #()
        beams   	= #()
        drains   	= #()

        objects_by_type = #()


		for obj in _objects do
			case of
			(
                ((sync_key = this._getKey #SOURCE obj) != undefined ): append source_keys sync_key

                ((this._getKey #SUPPORT obj) != undefined ): append supports obj
                ((this._getKey #RAFT	obj) != undefined ): append rafts obj
                ((this._getKey #BEAM    obj) != undefined ): append beams obj
                ((this._getKey #DRAIN   obj) != undefined ): append drains obj
                --default:
			)

		--format "SOURCE_KEYS: %\n" source_keys.count
		--format "SUPPORTS: %\n" supports.count
		--format "RAFTS: %\n" rafts.count
		--format "BEAMS: %\n" beams.count
		--format "DRAINS: %\n" drains

		/*==============================================================================
			GET SOURCE OBJECTS
		================================================================================*/
		if type == #SOURCE then
		(
			--for source_key in source_keys do append objects_by_type SourceObjects[source_key]
			sync_keys_of_objs = for obj in supports + beams + rafts collect this._getSyncKey(obj)

			objects_by_type = for key in makeUniqueArray (source_keys + sync_keys_of_objs) where SourceObjects[key] != undefined collect SourceObjects[key].obj
		)

		/*==============================================================================
			GET DRAINS
		================================================================================*/
		else if type == #DRAIN then
		(
			--for source_key in source_keys do append objects_by_type SourceObjects[source_key]
			objects_by_type = drains --return

			if source_keys.count > 0 then
				for obj in objects where this._getKey #DRAIN obj != undefined and ( sync_key = this._getSyncKey obj) != undefined and findItem source_keys sync_key > 0 do
                    appendIfUnique objects_by_type obj

		)
		/*=
		  =============================================================================
			GET BY SOURCE OBEJCT
		================================================================================*/
		else if source_keys.count > 0 then
		(
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
			supports_or_rafts = if type == #SUPPORT then supports else rafts

			objects_by_type = deepCopy supports_or_rafts

			format "supports_or_rafts X: %\n" supports_or_rafts

			/* GET BEAMS OF SOURCE OBJECT */
			if hierarchy or type == #BEAM  then
				for key in BeamObjects.keys where findItem supports_or_rafts BeamObjects[key].support_A > 0 or findItem supports_or_rafts BeamObjects[key].support_B > 0 do
					append objects_by_type BeamObjects[key].beam

			/* add to current selection */
			--if hierarchy or type == #SUPPORT or type == #RAFT then
			if hierarchy then
				objects_by_type += _objects
		)

		/*==============================================================================
			GET BY BEAMS
		================================================================================*/
		else if beams.count > 0 then
		(
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

		--objects_by_type --return
		--format "objects_by_type: %\n" objects_by_type
		for obj in objects_by_type where isValidNode obj collect obj  --return

	),

	/** Get source object
	 */
	function getSourceObjects _objects =
	(
		--format "\n"; print "SupportManager_v._getSourceObject()"
		sync_keys = for obj in _objects where (sync_key = this._getSyncSourceKey (obj)) != undefined collect sync_key

		for sync_key in sync_keys collect SourceObjects[sync_key]
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


	--/** Get verts normals
	-- */
	--function _getVertsNormals =
	--(
	--	--format "\n"; print "MeshDataGetter_v._getVertsNormals()"
	--	obj_mesh = obj.mesh
	--
	--	vertex_normals = #{1..obj.numverts} as Array
	--
	--	for i = 1 to verts_data[#VERTS].count do
	--		vertex_normals[i] = point3 0 0 0
	--
	--	verts_process = verts_data[#VERTS]
	--
	--	faces_of_verts = meshop.getFacesUsingVert obj_mesh verts_process
	--
	--	for face_of_vert in faces_of_verts do
	--	(
	--		--face_verts = getFace obj_mesh face_of_vert
	--		--face_normal = getFaceNormal obj_mesh face_of_vert
	--		--
	--		--
	--		--vertex_normals[face_verts.x] += face_normal
	--		--vertex_normals[face_verts.y] += face_normal
	--		--vertex_normals[face_verts.z] += face_normal
	--
	--		face_verts = getFace obj_mesh face_of_vert
	--		face_normal = getFaceNormal obj_mesh face_of_vert
	--
	--		for vert in face_verts * verts_process do
	--			vertex_normals[vert] += face_normal
	--
	--	)
	--
	--	for vert in verts_data[#VERTS] collect normalize vertex_normals[vert]
	--),

	--/** Get existing support and rafts
	-- */
	--function _getExistingSupportAndRafts sync_key =
	--(
	--	--format "\n"; print "SupportManager_v.getExistingSupportAndRafts()"
	--	for obj in objects where superClassOf obj.baseobject == shape and getUserPropVal obj "SYNC_KEY" == sync_key collect obj
	--),

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

			--SourceObject.initObjectsFromScene()

			supports = SourceObject.getSupportNodes()

			/* BIND TO EVENTS */

			--bindSupportToTransformEvent( supports )

			--bindBeamOnDeleteCallback( supports )

			SourceObjects[sync_key] = SourceObject

		)

		bindSourceObjectTransformEvent ( for sync_key in SourceObjects.keys collect SourceObjects[sync_key].obj )

	),

	/** Load supports from scene
	 */
	function _loadSupportsFromScene =
	(
		--format "\n"; print "SupportManager_v.loadSupportsFromScene()"

		for obj_type in #( #SUPPORT, #RAFT ) do
			for obj_in_scene in objects where (support_key = this._getKey obj_type obj_in_scene) != undefined do
			(
				--format "SUPPORT_KEY: %\n" support_key
				index	 = getUserPropVal obj_in_scene "INDEX"
				sync_key = getUserPropVal obj_in_scene "SYNC_KEY"
				--is_raft	 = getUserPropVal obj_in_scene "IS_RAFT"

				if ( SourceObjects[sync_key] ) != undefined then
				(
					SupportObject = SupportObject_v source_obj:SourceObjects[sync_key].obj support_obj:obj_in_scene support_key:support_key sync_key:sync_key obj_type:obj_type

					SupportObjects[SupportObject.support_key] = SupportObject

					SourceObjects[sync_key].Supports[index] = SupportObject
				)
			)

		for SourceObjectData in SourceObjects do
			SourceObjectData.value.setVertsPosBySupports()

		bindSupportToTransformEvent( for key in SupportObjects.keys collect SupportObjects[key].support_obj )
	),

	/** Load beam objects from scene
	 */
	function _loadBeamsFromScene =
	(
		--format "\n"; print "SupportManager_v._loadBeamsFromScene()"

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


	/** Get sync key from source object
	 */
	function _getSyncSourceKey source_obj =
	(
		--format "\n"; print "SupportManager_v.getSyncKey()"
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

			bindSourceObjectTransformEvent (source_obj)
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
		SLICER_SYSTEM.toggleModifiers false

		this._loadSourceObjectsFromScene()

		this._loadSupportsFromScene()

		this._loadBeamsFromScene()


		SLICER_SYSTEM.toggleModifiers true
		--EnableSceneRedraw()

		--SUPPORT_OPTIONS.getValuesFroUi()

	)
)
