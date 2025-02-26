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

	VertexColors,	--"./../../VertexColors/VertexColors.ms"
	Normals,	--"./SourceObjectNormals/SourceObjectNormals.ms"

	/* reference */
	/* inhered */

	/** Generate supports
	 */
	function generateSupports obj_type:#SUPPORT =
	(
		format "\n"; print "SourceObject_v.generateSupports()"
		format "obj: %\n" obj
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
				format "CREATE SUPPORT FOR VERT: % vertex_color: %\n" vert vertex_color
				SupportObject = SupportObject_v source_obj:obj obj_type:obj_type sync_key:sync_key
		
				/*------------------------------------------------------------------------------
					GENERATE SUPPORT OR RAFT
				--------------------------------------------------------------------------------*/
				vector = if direction == #NORMAL then Normals.normals_world[vert] else [0,0,-1]

				SupportObject.generateSupport vert first_knot_pos:verts_pos[vert] direction:direction vector:vector wirecolor:(execute vertex_color) --"./SupportObject/SupportObject.ms"
		
				--format "SUPPORTOBJECT.SUPPORT_OBJ: %\n" SupportObject.support_obj
				if SupportObject.support_obj != undefined then
				(
					/* ADD TO ARRAYS */
					this.Supports[vert] = SupportObject
		
					/* LINK SUPPORT TO SOURCE OBJECT */ 
					SupportObject.support_obj.parent = obj
		
					/* SET USER DATA TO SUPPORT */
					this._saveUserPropsToSupport (SupportObject) (sync_key) (vert) (obj_type) (direction)

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
	
	/** Save user props to pport
	 */
	function _saveUserPropsToSupport SupportObject sync_key vert obj_type direction =
	(
		--format "\n"; print "SourceObject_v.saveUserPropsToPport()"
			setUserPropVal SupportObject.support_obj "SYNC_KEY"	sync_key
			setUserPropVal SupportObject.support_obj "INDEX"	vert
			
			
			/* SET USER DATA TO SUPPORT OBJECT */ 	
			support_key = (getHandleByAnim SupportObject.support_obj) as string
	
			setUserPropVal SupportObject.support_obj ( toUpper (obj_type as string ) + "_KEY") support_key
	
			setUserPropVal SupportObject.support_obj "DIRECTION" direction --asString:true
		
	),

	/** Rebuild support
	 */
	function resetSupport support_node =
	(
		format "\n"; print ("SourceObject_v.resetSupport( "+support_node.name+" )")
		--format "Normals.normals_local: %\n" Normals.normals_local
		--format "Normals.normals_world: %\n" Normals.normals_world
		--format "support_node.name: %\n" support_node.name
		vert = getUserPropVal support_node "INDEX"

		wirecolor = VertexColors._getVertColor(vert)
		--format "wirecolor: %\n" wirecolor
		verts_process = #{vert}

		
		if Normals.normals_local == undefined then
			Normals.setLocalVertexNormals(verts_process)
		
		--if Normals.normals_world == undefined then
			Normals.setWorldSpaceVertexNormals(verts_process)

		--format "normals_local[vert]: %\n" Normals.normals_local[vert]
		--format "normals_world[vert]: %\n" Normals.normals_world[vert]
		
		if verts_pos == undefined then
			verts_pos = this.getVertsPositions(#{vert})

		
		direction = this._getNormalOrDownDirection(vert) -- direction NORMAL|DOWN
		--format "direction: %\n" direction

		SupportObject = Supports[vert]
		
		SupportObject.hit_raft	= undefined
		SupportObject.hit_support	= undefined
		
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
	function updateSupports support_nodes: update_knot_1:true update_knot_2:true direction:undefined update_leg:true =
	(
		format "\n"; print "SourceObject_v.updateSupports()"
		--format "support_nodes: %\n" support_nodes
		--format "direction: %\n" direction

		--format "Supports.keys: %\n" Supports.keys
		--format "Supports: %\n" Supports

		SupportsToUpdate = this._getSupports support_nodes:support_nodes
		
		--format "SupportsToUpdate: %\n" SupportsToUpdate
		
		
		if direction != #DOWN then
		(
			--format "Normals.normals_local: %\n" Normals.normals_local
			if Normals.normals_local == undefined then
				--format "SupportsToUpdate.keys as BitArray: %\n" (SupportsToUpdate.keys as BitArray)
				Normals.setLocalVertexNormals ( SupportsToUpdate.keys as BitArray )
				
			Normals.setWorldSpaceVertexNormals ( SupportsToUpdate.keys as BitArray )
		)
		
		--for index in Supports.keys where not Supports[index].isRaft() do
		for index in SupportsToUpdate.keys do
		(
			/* UPDATE 1st POINT */ 
			if update_knot_1 then
				first_knot_pos = verts_pos[index]
			
			/* UPDATE SECOND POINT */ 
			--if direction != undefined and direction != SupportsToUpdate[index].getDirection() then
			--if direction != undefined and direction != direction_saved then
			--if direction == #NORMAL or (direction != undefined and direction != direction_saved) then
		
			
			if direction != undefined then 
				setUserPropVal SupportsToUpdate[index].support_obj "DIRECTION" direction
			else
				direction = getUserPropVal SupportsToUpdate[index].support_obj "DIRECTION"
			
			vector = if direction == #DOWN then [ 0, 0, -1] else Normals.normals_world[index]
	
			SupportsToUpdate[index].updateSupport first_knot_pos:first_knot_pos direction:direction vector:vector update_leg:update_leg update_knot_2:update_knot_2
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

	/** Update supports height
	 */
	function updateSupportsHeight =
	(
		--format "\n"; print "SourceObject_v.updateSupportsHeight()"
		--format "supports.count: %\n" (Supports.count)
		--this.removeDeletedNodes()
		
		--verts_pos = this.getVertsPositions( Supports.keys as BitArray )

		--for key in Supports.keys where not Supports[key].isRaft() do
		for key in Supports.keys where not Supports[key].isRaft() do
			Supports[key].updateLegPosition()

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
		--format "\n"; print "SourceObject_v.setVertsPosBySupports()"

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
	
	/** Set verts positions
	 */
	function getVertsPositions verts =
	(
		format "\n"; print "SourceObject_v.getVertsPositions()"
		--format "obj: %\n" obj
		--format "verts_process: %\n" verts_process
		--format "verts: %\n" verts
		--format "all_verts: %\n" all_verts
		--format "all_verts.numberSet: %\n" all_verts.numberSet
		--format "verts.numberSet: %\n" verts.numberSet
		timer__getVertsPositions = timeStamp()

		if verts_pos == undefined then
			this.verts_pos = all_verts as Array

		verts_process_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj
		--format "verts_process_pos: %\n" verts_process_pos

		for i = 1 to verts_process_pos.count do
		(
			vert = (verts  as Array )[i]
			--format "vert: %\n" vert

			verts_pos[vert] = verts_process_pos[i]
		)

		--format "getVertsPositions: % ms\n" (( timeStamp()) - timer__getVertsPositions)

		verts_pos --return

		--verts_pos = in coordsys world meshop.getVerts obj.mesh all_verts node:obj

		--verts_pos --return
	),
	
	/** Remove deleted nodes
	 */
	function removeDeletedNodes =
	(
		--format "\n"; print "SourceObject_v.removeDeletedNodes()"
		for key in Supports.keys where not isValidNode Supports[key].support_obj do removeDictValue Supports key
	),
	
	private

	/** Get supports
	 */
	function _getSupports support_nodes: =
	(
		format "\n"; print "SourceObject_v._getSupports ()"
		
		if support_nodes != unsupplied then
		(
			SupportsFiltered = Dictionary #INTEGER
			
			for index in Supports.keys where findItem support_nodes Supports[index].support_obj > 0 do
				SupportsFiltered[index] = Supports[index]
			
			SupportsFiltered --return
		)
		else
			deepCopy Supports --return
	),
	--
	--/** Get normal or down direction
	-- */
	--function _getNormalOrDownDirection vert =
	--(
	--	--format "\n"; print "SourceObject_v._getNormalOrDownDirection()"
	--	if SUPPORT_OPTIONS.second_point_direction == 1 then Normals.normals_world[vert] else [0,0,-1]
	--),
	--
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
