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
	VertexColors, --"./../../../content/rollouts-Main/rollout-06-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms"
	Normals,	--"./SourceObjectNormals/SourceObjectNormals.ms"

	/* reference */
	/* inhered */

	/** Generate supports
	 */
	function generateSupports obj_type:#SUPPORT =
	(
		 format "\n"; print "SourceObject_v.generateSupports()"
		-- format "obj: %\n" obj
		--format "OBJ_TYPE: %\n" obj_type
		
		NewSupportObjects = #()

		this.removeDeletedNodes()

		direction = if SUPPORT_OPTIONS.second_point_direction == 1 then #NORMAL else #DOWN
		
		--setUserPropVal obj "ROTATION" (obj.rotation)
			
		/*------------------------------------------------------------------------------
			GET VERTS TO PROCESS by vertex color
		--------------------------------------------------------------------------------*/

		verts_sel	= getVertSelection obj.mesh
		
 		supports_exists = Supports.keys as BitArray
		timer_color = timeStamp()

		verts_by_colors = this._getVertsByColors()
		--format "VERTS_BY_COLORS: %\n" verts_by_colors
		colored_verts = this._getColoredVerts(verts_by_colors)
		format "color: % ms\n" (( timeStamp()) - timer_color)
		--format "COLORED_VERTS: %\n" colored_verts

		/* GEt SELECTED or COLORED verts */ 
		verts_process =  if verts_sel.numberSet > 0 then verts_sel else colored_verts
		
		
		if verts_process.isEmpty then
		(
			messageBox "Selected or colored verts NOT FOUND" title:"MISSING VERTICES" 
			
			return #()
		)
		
		/*------------------------------------------------------------------------------
			NORMALS OF VERTS
		--------------------------------------------------------------------------------*/
		timer_Normals = timeStamp()
		format "setLocalVertexNormals() "
		Normals.setLocalVertexNormals(verts_process)
		format "TIME: % ms\n" (( timeStamp()) - timer_Normals)
		
		timer_Normals = timeStamp()
		format "saveNormalsToUserProps() "
		Normals.saveNormalsToUserProps()
		format "TIME: % ms\n" (( timeStamp()) - timer_Normals)

		timer_Normals = timeStamp()
		format "setWorldSpaceVertexNormals() "
		Normals.setWorldSpaceVertexNormals(verts_process)
		format "TIME: % ms\n" (( timeStamp()) - timer_Normals)
		
		/* FILTER ONLY VERTS WHICH NORMAL IS POINTING DOWN OR TO SIDE - BUT NOT UP */
		timer_verts_process = timeStamp()
		verts_process = ( for vert in verts_process where Normals.isNormalValid(vert) collect vert ) as BitArray
		format "verts_process: % ms\n" (( timeStamp()) - timer_verts_process)
		
			
		/*------------------------------------------------------------------------------
			POSITIONS OF VERTS
		--------------------------------------------------------------------------------*/
		timer_verts_pos = timeStamp()
		verts_pos = this.getVertsPositions(verts_process)
		format "verts_pos: % ms\n" (( timeStamp()) - timer_verts_pos)
		
		
		
		/*------------------------------------------------------------------------------
			SORT VERTS BY COLORS
		--------------------------------------------------------------------------------*/
		
		--verts_by_colors_process = Dictionary #STRING
		
		for vertex_color in verts_by_colors.keys do
			verts_by_colors[vertex_color] *= verts_process
			--verts_by_colors_process[vertex_color] = verts_by_colors[vertex_color] * verts_process
		
		/*------------------------------------------------------------------------------
			CREATE SUPPORTS FOR EACH COLOR 
		--------------------------------------------------------------------------------*/
		timer_generate = timeStamp()
		for vertex_color in verts_by_colors.keys do
			for vert in verts_by_colors[vertex_color] where not supports_exists[vert]  do
			(
				--format "CREATE SUPPORT FOR VERT: % vertex_color: %\n" vert vertex_color
				SupportObject = SupportObject_v source_obj:obj obj_type:obj_type sync_key:sync_key
		
				/*------------------------------------------------------------------------------
					GENERATE SUPPORT OR RAFT
				--------------------------------------------------------------------------------*/
				dir_vector = if direction == #NORMAL then Normals.normals_world[vert] else [0,0,-1]

				success = SupportObject.generateSupport vert first_knot_pos:verts_pos[vert] direction:direction dir_vector:dir_vector normal_world:Normals.normals_world[vert] wirecolor:(execute vertex_color) --"./SupportObject/SupportObject.ms"

				if success then
				(
					/* ADD TO ARRAYS */
					this.Supports[vert] = SupportObject
		
					/* LINK SUPPORT TO SOURCE OBJECT */ 
					SupportObject.support_obj.parent = obj
		
					/* ADD TO SUPPORTS */ 
					append NewSupportObjects SupportObject
				)
				else
					(format "\n";	print ("! VERTEX "+vert as string +" IS BELLOW GROUND - SUPPORT IS NOT CREATED"))
			)
		
		format "generate: % ms\n" (( timeStamp()) - timer_generate)
		/*------------------------------------------------------------------------------
		--------------------------------------------------------------------------------*/
		SOURCE_OBJECT_TRANSFORM.bindSourceObjectTransformEvent ( obj )
		
		/* RETURN */
		NewSupportObjects
	),

	/** Reset supports
	 */
	function resetSupports support_nodes =
	(
		-- format "\n"; print "SourceObject_v.resetSupports()"
		--format "support_nodes: %\n" support_nodes


		/* GET SUPPORTS TO RESET */ 
		SupportsToReset = this._getSupports support_nodes:support_nodes
		
		/* GET VERTS OF SUPPORTS */ 
		verts = SupportsToReset.keys as BitArray
		
		
		if Normals.normals_local == undefined then
			Normals.setLocalVertexNormals(verts)
		
		
		----if Normals.normals_world == undefined then
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
		if VertexColors == undefined then 
			VertexColors = VertexColors_v(obj)
			
		dir_vector = if SUPPORT_OPTIONS.second_point_direction == 1 then Normals.normals_world[vert] else [0,0,-1] -- direction NORMAL|DOWN

		SupportObject.hit_raft	= undefined
		SupportObject.hit_leg	= undefined
		
		SupportObject.support_obj.wirecolor = VertexColors._getVertColor(vert)
		
		/* REBUILD SUPPORT */ 
		SupportObject.generateSupport vert first_knot_pos:verts_pos[vert] dir_vector:dir_vector wirecolor:wirecolor normal_world:SupportObject.normal_world
 	),

	/** Convert support to raft or vice versa
	  *
	  * @param #SUPPORT|#RAFT obj_type of obejct to covert
	  *
	 */
	function convertType support_nodes to_type:#RAFT  =
	(
		--format "\n"; print "SourceObject_v.convert()"

		from_type =  if to_type == #RAFT then #SUPPORT else #RAFT
		
		this.removeDeletedNodes()

		for support_node in support_nodes do
			(this._getSupportByNode (support_node)).convertType(to_type)


		--MODIFIERS_MANAGER.switchSupportType( SourceObjects[sync_key].getSupportNodes to_type:obj_type ) obj_type:obj_type

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
	function updateSupports support_nodes: update_knot_1:true update_raft:true direction:undefined update_normals:false =
	(
		   -- format "\n****************************************************\n"
		   -- format "\n"; print "SourceObject_v.updateSupports()"
		--format "support_nodes: %\n" support_nodes
		  -- format "update_normals: %\n" update_normals

		/* GET SUPPORTS TO UPDATE */ 
		SupportsToUpdate = this._getSupports support_nodes:support_nodes
		
		/* GET NORMALS */ 
		if update_normals or Normals.normals_world == undefined then
			this.updateNormals (SupportsToUpdate)
		
		/*------------------------------------------------------------------------------
		  
			UPDATE EACH SUPPORT
			
		--------------------------------------------------------------------------------*/
		for index in SupportsToUpdate.keys do
		(
			Support = SupportsToUpdate[index]

			/* UPDATE SECOND POINT - to keep direction down */ 
			if direction == undefined then
				direction = getUserPropVal Support.support_obj "DIRECTION"

			/* GET VECTOR  */ 
			dir_vector = this._getDirVector direction index

			/* SAVE #CUSTOM DIRECTION IF SUPPORT HAS BEEN MOVE ON ITS OWN */ 
			if direction == #CUSTOM then 
				setUserPropVal Support.support_obj "DIRECTION" #CUSTOM
				
			
			/* UPDATE 1st POINT - if support has been moved on its own */ 
			if update_knot_1 then
				first_knot_pos = verts_pos[index]

			/* IF VECTOR IS VALID THEN UPDATE SUPPORT */ 
			if dir_vector == undefined or dir_vector.z < 0 then
			(
				/*------------------------------------------------------------------------------
					UPDATE SUPPORT
				--------------------------------------------------------------------------------*/
				if not Support.support_obj.boxmode then
					Support.updateSupport first_knot_pos:first_knot_pos update_raft:update_raft direction:direction dir_vector:dir_vector
					 
				/*------------------------------------------------------------------------------
					RESTORE FROM BOX MODE IF VECTOR BECOME VALID
				--------------------------------------------------------------------------------*/
				else
					Support.rebulidSupport dir_vector:dir_vector
			)
			/*------------------------------------------------------------------------------
				DISABLE SUPPORT IF NOT VALID
			--------------------------------------------------------------------------------*/
			else 
				Support.enableBoxMode()
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


	/** Update height of all supports which belongs to this source object 
	 */
	function updateSupportsHeight = 
	(
		 -- format "\n****************************************************\n"
		 -- format "\n"; print "SourceObject_v.updateSupportsHeight()"
		 --format "Normals.normals_world: %\n" Normals.normals_world
		--format "supports.count: %\n" (Supports.count)
		--for key in Supports.keys where not Supports[key].isRaft() and Supports[key].foot_enabled do
		/* GET SUPPORTS TO UPDATE */ 
		
		/* GET VECTOR  */
		--Normals.setWorldSpaceVertexNormals ( Supports.keys as BitArray )
		if Normals.normals_world == undefined then
			this.updateNormals (Supports)

		
		for index in Supports.keys where not Supports[index].isRaft() and isValidNode Supports[index].support_obj do
		(
			-- format "\n"
			-- format "index: %\n" index
			Support = Supports[index]
			-- format "Support: %\n" Support
			-- format "NORMAL: %\n" (Normals.normals_world[index].z)
			
			if Normals.normals_world[index].z < 0 then
			(
				direction = getUserPropVal Support.support_obj "DIRECTION"
				
				dir_vector = this._getDirVector direction index

				if not Support.isBoxMode() then
				(
					result = Support.updateSupportHeight()
	
					if result == false then
						Support.enableBoxMode()
				)
				else
					Support.rebulidSupport dir_vector:dir_vector
				
			)
			else
				Support.enableBoxMode()
		)
	),
	
	/** Update base height
	 */
	function updateBaseHeight support_nodes =
	(
		--format "\n"; print "SourceObject_v.updateBaseHeight()"
		
		SupportsToUpdate = this._getSupports support_nodes:support_nodes
		
		--for key in SupportsToUpdate.keys where SupportsToUpdate[key].is_on_ground do
		for key in SupportsToUpdate.keys do
		(
			SupportsToUpdate[key].base_height = SUPPORT_OPTIONS.base_height
			
			SupportsToUpdate[key].updateSupport update_raft:false update_leg:true
		)
			--SupportsToUpdate[key].updateBaseHeight()
			
		free SupportsToUpdate
	),

	
	/** Get support nodes of given type
	  * isValidNode is check beacuse of deleted nodes stays in script for case of undo action and objects reappears.
	  *
	  * @param #SUPPORT|#RAFT Get only supports or rafts. Get both if unsupplied
	  *
	  * @return array of nodes
	 */
	function getSupportNodes obj_type: =
	(
		--format "\n"; print "SourceObject_v.getSupportNodes()"
		if obj_type == unsupplied then
			for key in Supports.keys where isValidNode Supports[key].support_obj collect Supports[key].support_obj

		else
			for key in Supports.keys where Supports[key].obj_type == obj_type and isValidNode Supports[key].support_obj collect Supports[key].support_obj
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
	
	/** Get min z pos of world boungingBox 
	 */
	function getMinZ =
	(
		--format "\n"; print "SourceObject_v.getMinZ()"
		bbox	= nodeGetBoundingBox obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z

		bbox[1].z --return
	),
	
	/** Remove deleted nodes
	 */
	function removeDeletedNodes =
	(
		--format "\n"; print "SourceObject_v.removeDeletedNodes()"
		for key in Supports.keys where not isValidNode Supports[key].support_obj do removeDictValue Supports key
	),
	
	private

	
	/** Get dir vector
	 */
	function _getDirVector direction index =
	(
		-- format "\n"; print "SourceObject_v._getDirVector()"
		case direction of
			(
				(#DOWN):   [ 0, 0, -1 ]
				(#NORMAL): Normals.normals_world[index]
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


	/** Get Supports 
	  * 
	  * @param Array support_nodes return only Supports from this array
	  * 
	  * @return Dictionary if support_nodes:unsupplied then return all supports
	 */
	function _getSupports support_nodes: =
	(
		--format "\n"; print "SourceObject_v._getSupports()"
		SupportsFiltered = Dictionary #INTEGER
		
		if support_nodes != unsupplied then
		(
			
			/* LOOP SUPPORTS OF SOURCE OBJECTS AND GET ONLY SUPPORTS IN support_nodes ARRAY */ 
			for index in Supports.keys where isValidNode Supports[index].support_obj and findItem support_nodes Supports[index].support_obj > 0 do
				SupportsFiltered[index] = Supports[index]
			
		)
		else
			for index in Supports.keys where isValidNode Supports[index].support_obj do SupportsFiltered[index] = Supports[index]


		SupportsFiltered --return
	),
	
	/** Get verts by colors
	  
	  * @return Dictionary KEY:"color" VALUE:#{verts of color}
	  
	 */
	function _getVertsByColors =
	(
		 --format "\n"; print "SourceObject_v._getVertsByColors()"
		 
		if VertexColors == undefined then 
			VertexColors = VertexColors_v(obj)

		verts_by_colors = VertexColors.getVertsAndColors()
		
		/* REPLACE WHITE WITH OBJECT WIRECOLOR */
		verts_by_colors[ obj.wirecolor as string ] = if ( white_verts = verts_by_colors[ white as string ] ) != undefined then white_verts else all_verts

		/* REMOVE WHITE */ 
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

	
	/** Update normals
	 */
	function updateNormals supports_to_update =
	(
		-- format "\n"; print "SourceObject_v.updateNormals()"
		supports_keys = supports_to_update.keys as BitArray
		-- format "supports_keys: %\n" supports_keys
		
		if Normals.normals_local == undefined then
			Normals.setLocalVertexNormals( supports_keys )

		Normals.setWorldSpaceVertexNormals ( supports_keys )
		
		/* UPDATE WORLD NORMAL IN OBJECT PROPERTIES */ 
		--for vert in supports_keys do
		for vert in supports_keys where isValidNode Supports[vert].support_obj do
			setUserPropVal Supports[vert].support_obj "NORMAL_WORLD" Normals.normals_world[vert]
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
		
		--VertexColors = VertexColors_v(obj)

		all_verts = #{1..(getNumVerts obj.mesh)}

		this._saveObjectRotation()

		Normals = SourceObjectNormals_v(obj)

	)
)
