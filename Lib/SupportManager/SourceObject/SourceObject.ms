--filein( getFilenamePath(getSourceFileName()) + "/SupportObject/SupportLegUpdater/SupportLegUpdater.ms" )	--"./SupportObject/SupportLegUpdater/SupportLegUpdater.ms"
filein( getFilenamePath(getSourceFileName()) + "/SourceObjectNormals/SourceObjectNormals.ms" )	--"./SourceObjectNormals/SourceObjectNormals.ms"
filein( getFilenamePath(getSourceFileName()) + "/SupportObject/SupportObject.ms" )	--"./SupportObject/SupportObject.ms"
/** Source object
 */
struct SourceObject_v
(
	/* construct */
	obj,
	sync_key,

	/* required */
	/* properties */

	all_verts,

	Supports = Dictionary #INTEGER, -- KEY:vertex_index VALUE:SupportObject|RaftObject

	/* private */
	verts_process,

	verts_pos,

	obj_rotation, -- store object rotation to find if world normals needs to be recount

	--direction_down = [0,0,-1],

	/* dependency */
	VertexColors,	--"./../../../content/rollouts-Main/rollout-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms"
	Normals,	--"./SourceObjectNormals/SourceObjectNormals.ms"

	/* reference */
	/* inhered */

	/** Generate supports
	 */
	function generateSupports obj_type:#SUPPORT =
	(
		--format "\n"; print "SourceObject_v.generateSupports()"
		--format "obj: %\n" obj
		--format "OBJ_TYPE: %\n" obj_type

		new_nodes = #()

		this.removeDeletedNodes()

		direction = if SUPPORT_OPTIONS.second_point_direction == 1 then #NORMAL else #DOWN
					
		/*------------------------------------------------------------------------------
			GET VERTS TO PROCESS by vertex color
		--------------------------------------------------------------------------------*/

		verts_sel	= getVertSelection obj.mesh

		supports_exists = Supports.keys as BitArray

		verts_by_colors = this._getVertsByColors()

		colored_verts = this._getColoredVerts(verts_by_colors)
		--format "colored_verts: %\n" colored_verts

		verts_process =  if verts_sel.numberSet > 0 then verts_sel else colored_verts
		--format "VERTS_PROCESS: %\n" verts_process
		--format "VERTS_PROCESS: %\n" verts_process.numberSet
		
		/*------------------------------------------------------------------------------
			NORMALS OF VERTS
		--------------------------------------------------------------------------------*/
		Normals.setLocalVertexNormals(verts_process)
		--format "NORMALS_LOCAL: %\n" Normals.normals_local
		--format "NORMALS_LOCAL: %\n" Normals.normals_local.count
		
		Normals.saveNormalsToUserProps()

		Normals.setWorldSpaceVertexNormals(verts_process)
		
		/* FILTER ONLY VERTS WHICH NORMAL IS POINTING DOWN OR TO SIDE - BUT NOT UP */
		verts_process = ( for vert in verts_process where Normals.isNormalValid(vert) collect vert ) as BitArray
		--format "VERTS_PROCESS: %\n" verts_process
		
		
		/*------------------------------------------------------------------------------
			SORT VERTS BY COLORS
		--------------------------------------------------------------------------------*/
		
		verts_by_colors_process = Dictionary #STRING
		
		for vertex_color in verts_by_colors.keys do
			verts_by_colors_process[vertex_color] = verts_by_colors[vertex_color] * verts_process
		
		--format "verts_by_colors.keys: %\n" verts_by_colors.keys
		--format "verts_by_colors: %\n" verts_by_colors
			
		/*------------------------------------------------------------------------------
			POSITIONS OF VERTS
		--------------------------------------------------------------------------------*/
		
		verts_pos = this.getVertsPositions(verts_process)
		
		
		/*------------------------------------------------------------------------------
			CREATE SUPPORTS FOR EACH COLOR 
		--------------------------------------------------------------------------------*/
		
		for vertex_color in verts_by_colors_process.keys do
			for vert in verts_by_colors_process[vertex_color] where not supports_exists[vert]  do
			(
				--format "CREATE SUPPORT FOR VERT: % vertex_color: %\n" vert vertex_color
				SupportObject = SupportObject_v source_obj:obj obj_type:obj_type sync_key:sync_key
		
				/*------------------------------------------------------------------------------
					GENERATE SUPPORT OR RAFT
				--------------------------------------------------------------------------------*/
				dir_vector = if direction == #NORMAL then Normals.normals_world[vert] else [0,0,-1]

				SupportObject.generateSupport vert first_knot_pos:verts_pos[vert] direction:direction dir_vector:dir_vector wirecolor:(execute vertex_color) --"./SupportObject/SupportObject.ms"
		
				--format "SUPPORTOBJECT.SUPPORT_OBJ: %\n" SupportObject.support_obj
				if SupportObject.support_obj != undefined then
				(
					/* ADD TO ARRAYS */
					this.Supports[vert] = SupportObject
		
					/* LINK SUPPORT TO SOURCE OBJECT */ 
					SupportObject.support_obj.parent = obj
		
					/* SET USER DATA TO SUPPORT */
					this._saveUserPropsToSupport (SupportObject) (vert) (direction)

					append new_nodes SupportObject.support_obj
				)
			)
		
		/*------------------------------------------------------------------------------
			BIND EVENTS
		--------------------------------------------------------------------------------*/
		bindSupportToTransformEvent( this.getSupportNodes() )
		
		SOURCE_OBJECT_TRANSFORM.bindSourceObjectTransformEvent ( obj )
		
		
		
		/* RETURN */
		format "new_nodes: %\n" new_nodes
		new_nodes
	),
	
	/** SET USER DATA TO SUPPORT OBJECT
	 */
	function _saveUserPropsToSupport SupportObject vert direction =
	(
		support_obj = SupportObject.support_obj
		
		support_key_prop = toUpper (SupportObject.obj_type as string ) + "_KEY"
		support_key_val  = (getHandleByAnim support_obj) as string
		
		
		setUserPropVal support_obj "SYNC_KEY"	SupportObject.sync_key
		
		setUserPropVal support_obj support_key_prop support_key_val
		
		setUserPropVal support_obj "INDEX"	vert
		
		--setUserPropVal support_obj "IS_ON_GROUND"	SupportObject.is_on_ground

		setUserPropVal support_obj "FOOT_ENABLED"	SupportObject.foot_enabled
		setUserPropVal support_obj "FOOT_EXISTS"	SupportObject.foot_exists
		
		setUserPropVal support_obj "DIRECTION" direction --asString:true
		
		setUserPropVal support_obj "BASE_HEIGHT" SUPPORT_OPTIONS.base_height
		
		setUserPropVal support_obj "NORMAL_LENGTH" SUPPORT_OPTIONS.normal_length
	),

	/** Reset supports
	 */
	function resetSupports support_nodes =
	(
		--format "\n"; print "SourceObject_v.resetSupports()"
		--format "support_nodes: %\n" support_nodes
		

		/* GET SUPPORTS TO RESET */ 
		SupportsToReset = this._getSupports support_nodes:support_nodes
		
		verts = SupportsToReset.keys as BitArray
				
		--colors_by_verts = VertexColors.getVertsAndColors verts:( verts ) flat:true
		VertexColors.getVertsAndColors verts:( verts ) 

		if Normals.normals_local == undefined then
			Normals.setLocalVertexNormals(verts)
		
		--if Normals.normals_world == undefined then
			Normals.setWorldSpaceVertexNormals(verts)

		this.getVertsPositions(verts)
		
		for vert in SupportsToReset.keys do 
			this.resetSupport SupportsToReset[vert] vert
	),
	
	/** Re-generate support using (same) support node
	 */
	function resetSupport SupportObject vert =
	(
		--format "\n"; print ("SourceObject_v.resetSupport( "+SupportObject.support_obj.name+" )")
		--format "SupportObject: %\n" SupportObject
		--format "vert: %\n" vert
		
		--format "wirecolor: %\n" wirecolor
		
		dir_vector = if SUPPORT_OPTIONS.second_point_direction == 1 then Normals.normals_world[vert] else [0,0,-1] -- direction NORMAL|DOWN

		SupportObject.hit_raft	= undefined
		SupportObject.hit_leg	= undefined
		
		SupportObject.support_obj.wirecolor = VertexColors._getVertColor(vert)
		
		/* REBUILD SUPPORT */ 
		SupportObject.generateSupport vert first_knot_pos:verts_pos[vert] dir_vector:dir_vector wirecolor:wirecolor
 	),

	/** Convert support to raft or vice versa
	  *
	  * @param #SUPPORT|#RAFT obj_type of obejct to covert
	  *
	 */
	function convertType support_nodes obj_type:#RAFT  =
	(
		--format "\n"; print "SourceObject_v.convert()"

		from_type =  if obj_type == #RAFT then #SUPPORT else #RAFT
		
		this.removeDeletedNodes()

		for support_node in support_nodes do
			(this._getSupportByNode (support_node)).convertType(obj_type)


		--MODIFIERS_MANAGER.switchSupportType( SourceObjects[sync_key].getSupportNodes obj_type:obj_type ) obj_type:obj_type

		--for sync_key in supports_by_source.keys do
		--	for support_node in supports_by_source[sync_key] do
		--		SourceObjects[sync_key].convertToRaft(support_node)


		--resumeSupportToTransformEvent()
	),


	/*------------------------------------------------------------------------------
	
		UPDATE
	
	--------------------------------------------------------------------------------*/


	/** Update supports of source objects
	  * 
	 */
	function updateSupports support_nodes: update_knot_1:true update_raft:true update_leg:false direction:undefined what_to_update: =
	(
		format "\n"; print "SourceObject_v.updateSupports()"
		
		--format "DIRECTION: %\n" direction

		/* GET SUPPORTS TO UPDATE */ 
		SupportsToUpdate = this._getSupports support_nodes:support_nodes
		
		/* GET NORMALS */ 
		if direction == #NORMAL then
		(
			if Normals.normals_local == undefined then
				Normals.setLocalVertexNormals ( SupportsToUpdate.keys as BitArray )
				
			Normals.setWorldSpaceVertexNormals ( SupportsToUpdate.keys as BitArray )
		)
		
		
		/*------------------------------------------------------------------------------
			UPDATE EACH SUPPORT
		--------------------------------------------------------------------------------*/
		for index in SupportsToUpdate.keys do
		(
			Support = SupportsToUpdate[index]
			
			/* LAOD CURRENT DIRECTION */ 
			current_direction = getUserPropVal Support.support_obj "DIRECTION"
		
			/* SAVE CURRENT DIRECTION */
			--if direction != undefined then 
				--setUserPropVal SupportsToUpdate[index].support_obj "DIRECTION" direction
				
				
			/* UPDATE 1st POINT - if support has been moved on its own */ 
			if update_knot_1 then
				first_knot_pos = verts_pos[index]
			
			
			/* UPDATE SECOND POINT - to keep direction down */ 
			if direction == undefined and current_direction == #DOWN then
			(
				direction = #DOWN
				
				update_raft = true
			)
			
			/* GET VECTOR  */ 
			dir_vector = case direction of
			(
				(#DOWN):   [ 0, 0, -1 ]
				(#NORMAL): Normals.normals_world[index]
			)
			--format "DIR_VECTOR: %\n" dir_vector
			
			/* SAVE CURRENT DIRECTION */ 
			if not ( direction == #CUSTOM and current_direction == #DOWN and Support.isVectorPointingDown() ) then 
				setUserPropVal Support.support_obj "DIRECTION" direction
			

			/* UPDATE SUPPORT */ 
			Support.updateSupport first_knot_pos:first_knot_pos update_raft:update_raft update_leg:update_leg direction:(if direction != #CUSTOM then direction) dir_vector:dir_vector
			
			
		)
		
		free SupportsToUpdate
	),

	/** Update single support
	 */
	function updateSupport support_node update_direction: =
	(
		--format "\n"; print "SourceObject_v.updateSupport()"
		--format "support_node.name: %\n" support_node.name
		index = getUserPropVal support_node "INDEX"

		Supports[index].updateSupport first_knot_pos:verts_pos[index] update_direction:update_direction
	),

	/** Update base height
	 */
	function updateBaseHeight support_nodes =
	(
		--format "\n"; print "SourceObject_v.updateBaseHeight()"
		
		SupportsToUpdate = this._getSupports support_nodes:support_nodes
		
		for key in SupportsToUpdate.keys where SupportsToUpdate[key].is_on_ground do
			SupportsToUpdate[key].updateBaseHeight()
			
		free SupportsToUpdate
	),

	/** Update supports height
	 */
	function updateSupportsHeight =
	(
		format "\n"; print "SourceObject_v.updateSupportsHeight()" 
		--format "supports.count: %\n" (Supports.count)
		--this.removeDeletedNodes()

		--verts_pos = this.getVertsPositions( Supports.keys as BitArray )

		--for key in Supports.keys where not Supports[key].isRaft() do
		for key in Supports.keys where not Supports[key].isRaft() and Supports[key].foot_enabled do
			--Supports[key].SupportLegUpdater.updateLegHeight()
			--Supports[key].SupportLegUpdater.updateLegWithFoot()
		(
			Supports[key].updateSupportHeight()
			
			--Supports[key]._setPivotToSecondPoint()
			--
			--Supports[key]._alignPivotToSeconPoint()			
        )

	),

	/** Get support by node
	 */
	function _getSupportByNode support_node =
	(
		--format "\n"; print "SourceObject_v._getSupportByNode()"
		index = getUserPropVal support_node "INDEX"

		Supports[index] --return
	),

	/** Get support nodes of given type
	  *
	  * @param #SUPPORT|#RAFT Get only supports or rafts. Get both if unsupplied
	  *
	  * @return array of nodes
	 */
	function getSupportNodes obj_type: =
	(
		--format "\n"; print "SourceObject_v.getSupportNodes()"
		if obj_type != unsupplied then
			for SupportObjectData in Supports where SupportObjectData.value.obj_type == obj_type collect SupportObjectData.value.support_obj --return

		else
			for SupportObjectData in Supports collect SupportObjectData.value.support_obj --return
	),

	/** Set verts pos by supports
	 */
	function setVertsPosBySupports =
	(
		verts_pos = this.getVertsPositions( Supports.keys as BitArray )
	),

	/** Delete support
	  UNUSED
	 */
	function _deleteSupport key =
	(
		--format "\n"; print "SourceObject_v._deleteSupport()"

		delete Supports[key].support_obj

		removeDictValue Supports key

		/* TODO: DELETE BEAMS ? */
	),
	
	/** Get verts positions
	  * 
	  * NOTEICE: undefined item is returned if vert is not in verts param
	  * 
	  * @return array of verts positions where index of item is vert index
	 */
	function getVertsPositions verts =
	(
		--format "\n"; print "SourceObject_v.getVertsPositions()"
		--format "obj: %\n" obj
		--format "verts_process: %\n" verts_process
		--format "verts: %\n" verts
		--format "all_verts: %\n" all_verts
		--format "all_verts.numberSet: %\n" all_verts.numberSet
		--format "verts.numberSet: %\n" verts.numberSet

		if verts_pos == undefined then
		(
			this.verts_pos = #()
			
			this.verts_pos[all_verts.count] = undefined
		)
		
		verts_array = verts as Array

		verts_process_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj
		--format "verts_process_pos: %\n" verts_process_pos

		for i = 1 to verts_process_pos.count do
		(
			vert = verts_array[i]

			verts_pos[vert] = verts_process_pos[i]
		)

		verts_pos --return
	),
	
	/** Remove deleted nodes
	 */
	function removeDeletedNodes =
	(
		--format "\n"; print "SourceObject_v.removeDeletedNodes()"
		for key in Supports.keys where not isValidNode Supports[key].support_obj do removeDictValue Supports key
	),
	
	private

	/** Get Supports 
	  * 
	  * @param Array support_nodes return only Supports from this array
	  * 
	  * @return Dictionary if support_nodes:unsupplied then return all supports
	 */
	function _getSupports support_nodes: =
	(
		--format "\n"; print "SourceObject_v._getSupports()"
		
		if support_nodes != unsupplied then
		(
			SupportsFiltered = Dictionary #INTEGER
			
			/* LOOP SUPPORTS OF SOURCE OBJECTS AND GET ONLY SUPPORTS IN support_nodes ARRAY */ 
			for index in Supports.keys where findItem support_nodes Supports[index].support_obj > 0 do
				SupportsFiltered[index] = Supports[index]
			
			SupportsFiltered --return
		)
		else
			deepCopy Supports --return
	),
	
	/** Get verts by colors
	 */
	function _getVertsByColors =
	(
		--format "\n"; print "SourceObject_v._getVertsByColors()"
		verts_by_colors = VertexColors.getVertsAndColors()

		/* REPLACE WHITE WITH OBJECT WIRECOLOR */
		verts_by_colors[ obj.wirecolor as string ] = verts_by_colors[ white as string ]

		RemoveDictValue verts_by_colors ( white as string )

		verts_by_colors --return
	),

	/** Flattern dictionary
	 */
	function _getColoredVerts verts_by_colors =
	(
		--format "\n"; print "SourceObject_v._getColoredVerts()"
		flattern_dict = #{}

		for key in verts_by_colors.keys where key != obj.wirecolor as string do flattern_dict += verts_by_colors[key]

		flattern_dict --return
	),

	/** test if obj rotation changed in X and Y axises
	 */
	function _isObjRotationChanged =
	(
		--format "\n"; print "SourceObject_v._isObjRotationChanged()"

		current_rotation = this._getRoundedObjectRotation ( quatToEuler2 obj.rotation.controller.value )

		rotation_changed = current_rotation != obj_rotation

		obj_rotation = current_rotation

		rotation_changed --return
	),

	/** Get rounded object rotation
	 *
	 * Coordinates are changing little bit on unchaged axises beacause of "high precision" of Max values
	 */
	function _getRoundedObjectRotation rot =
	(
		--format "\n"; print "SourceObject_v._getRoundedObjectRotation()"
		/* Round number to 3 deciamls
		*/
		--fn roundFloat val = ( local mult = 10.0 ^ 3; (floor ((val * mult) + 0.5)) / mult )
		fn roundFloat val = ( local mult = 1000.0; (floor ((val * mult) + 0.5)) / mult )

		rounded_rotation = Point2 0 0

		rounded_rotation.x = roundFloat rot.x
		rounded_rotation.y = roundFloat rot.y

		rounded_rotation --return
	),


	/** Save object rounded rotation in X and Y axis
	 */
	function _saveObjectRotation =
	(
		--format "\n"; print "SourceObject_v._saveObjectRotation()"
		obj_rotation = this._getRoundedObjectRotation ( quatToEuler2 obj.rotation.controller.value )
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObject.onCreate()"
		--format "obj: %\n" obj
		VertexColors = VertexColors_v(obj)

		all_verts = #{1..(getNumVerts obj.mesh)}

		this._saveObjectRotation()

		Normals = SourceObjectNormals_v(obj)
		--this._initNormalsLocalArray()
	)
)
