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
	down_faces,

	Supports = Dictionary #INTEGER, -- KEY:vertex_index VALUE:SupportObject|RaftObject

	/* private */
	verts_process,

	verts_pos,

	obj_rotation, -- store object rotation to find if world normals needs to be recount

	--direction_down = [0,0,-1],
	exclude_vertex_colors = #( white as string , black as string ),
	
	/* dependency */
	VertexColors, --"./../../../content/rollouts-Main/rollout-06-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms"
	Normals,	--"./SourceObjectNormals/SourceObjectNormals.ms"

	/* reference */
	/* inhered */
	

	/** Generate supports
	 */
	function generateSupports obj_type:#SUPPORT =
	(
		--format "\n-------------------------------------\n"
		 --format "\n"; print "SourceObject_v.generateSupports()"
		 --format "SOURCE OBJECT: %\n" obj
		 
		 --macros.run "_3D-Print" "_print_reset_source_object_userprops"
		 
		 
		 --format "classOf obj: %\n" ( classOf obj )
		--format "OBJ_TYPE: %\n" obj_type
		
		NewSupportObjects = #()

		this.removeDeletedNodes()

		direction = if SUPPORT_OPTIONS.raft_direction == 2 then #NORMAL else #DOWN
		
		--setUserPropVal obj "ROTATION" (obj.rotation)
			
		/*------------------------------------------------------------------------------
			GET VERTS TO PROCESS by vertex color
		--------------------------------------------------------------------------------*/
		
		--format "classOf obj: %\n" ( classOf obj )
		verts_sel	= getVertSelection obj.mesh
		--format "verts_sel: %\n" verts_sel

 		supports_exists = Supports.keys as BitArray

		verts_by_colors = VertexColors.getVertsAndColors()
		
		colored_verts = this._getColoredVerts(verts_by_colors)
		
		verts_by_colors = this._replaceWhiteWithObjectColor(verts_by_colors)
		--format "verts_by_colors: %\n" verts_by_colors
		--format "verts_by_colors.keys: %\n" verts_by_colors.keys

		/* GEt SELECTED or COLORED verts */ 
		verts_process =  if verts_sel.isEmpty then colored_verts else verts_sel

		
		if verts_process.isEmpty then
		(
			messageBox "Selected or colored verts NOT FOUND" title:"MISSING VERTICES" 
			
			return #()
		)
		
		/* SAFE COMFIRM IF TOO MANY VERTICES ARE SELECTED */ 
		if verts_sel.numberSet > 500 and not queryBox ("PROCEED MORE THAN 500 vertices selected ?") title:"MANY VERTS SELECTED" then
			 return #()

		/*-----------------------------------------------------------------------------
			NORMALS OF VERTS
		--------------------------------------------------------------------------------*/
		Normals.setLocalVertexNormals(verts_process)
		
		Normals.saveNormalsToUserProps()

		Normals.setWorldSpaceVertexNormals(verts_process)
		
		Normals.setDownFaces()
		
		/* FILTER ONLY VERTS WHICH NORMAL IS POINTING DOWN OR TO SIDE - BUT NOT UP */
		--timer_verts_process = timeStamp()
		--normal_limit = if direction == #DOWN then -0.3 else -0.2
		normal_limit = 0.0
		
		
		verts_process = ( for vert in verts_process where Normals.isNormalValid(vert) limit:normal_limit collect vert ) as BitArray

		/*------------------------------------------------------------------------------
			POSITIONS OF VERTS
		--------------------------------------------------------------------------------*/
		verts_pos = this.getVertsPositions(verts_process)
		
		/*------------------------------------------------------------------------------
			SORT VERTS BY COLORS
		
		--------------------------------------------------------------------------------*/
		--if verts_by_colors[black as string ] != undefined then
			--verts_by_colors[black as string ] = undefined
			--RemoveDictValue verts_by_colors (black as string )

		/* USE ONLY VERTS TO PROCESS  */ 
		for vertex_color in verts_by_colors.keys do
			verts_by_colors[vertex_color] *= verts_process
			--verts_by_colors_process[vertex_color] = verts_by_colors[vertex_color] * verts_process
		
		--if not queryBox ("Create supports from "+verts_process.numberSet as string +" verts ?") then
			--return NewSupportObjects --return
			
		--format "Normals.down_faces: %\n" Normals.down_faces
		--format "Normals.down_verts: %\n" Normals.down_verts
		/*------------------------------------------------------------------------------
			CREATE SUPPORTS FOR EACH COLOR 
		--------------------------------------------------------------------------------*/
		timer_generate = timeStamp()
		
		for vertex_color in verts_by_colors.keys where not verts_by_colors[vertex_color].isEmpty do
			for vert in verts_by_colors[vertex_color] where not supports_exists[vert]  do
			(
				format "CREATE SUPPORT FOR VERT: % vertex_color: %\n" vert vertex_color
				
				if Normals.down_verts[vert] then
					direction = #DOWN
					
				--raft_vector = if direction == #NORMAL then Normals.normals_world[vert] else [0,0,-1]
				
				--wirecolor = if Normals.down_verts[vert] then black else (execute vertex_color)

				pin_vector = this._getPinVector direction vert
				--format "pin_vector: %\n" pin_vector
				
				/*------------------------------------------------------------------------------
					GENERATE SUPPORT OR RAFT
				--------------------------------------------------------------------------------*/
				SupportObject = SupportObject_v source_obj:obj obj_type:obj_type sync_key:sync_key

								--first_knot_pos:verts_pos[vert] \
				result = SupportObject.generateSupport vert \
								first_knot_pos:(this._getSupportPosition vert) \
								direction:direction \
								pin_vector:pin_vector \
								raft_vector:raft_vector \
								wirecolor: (execute vertex_color) --"./SupportObject/SupportObject.ms"
								--wirecolor: wirecolor --"./SupportObject/SupportObject.ms"
								--pin_vector:Normals.normals_world[vert] \
								--first_knot_pos:(this._getSupportPosition(vert)) \

				
				if result then
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
		
		--format "generate: % ms\n" (( timeStamp()) - timer_generate)
		/*------------------------------------------------------------------------------
		--------------------------------------------------------------------------------*/
		SOURCE_OBJECT_TRANSFORM.bindSourceObjectTransformEvent ( obj )
		
		/* RETURN */
		NewSupportObjects
	),
	
	/** Get support position
	 */
	function _getSupportPosition vert =
	(
		--format "\n"; print "SourceObject_v._getSupportPosition()"
		--format "%: %\n" vert (Normals.down_verts[vert])
		if Normals.down_verts[vert] then
		(
			sum_pos = [0,0,0]
			
			--faces_of_vert = polyop.getFacesUsingVert obj #{vert}
			faces_of_vert = meshop.getFacesUsingVert obj.mesh #{vert}
			--format "faces_of_vert: %\n" faces_of_vert
			down_faces_of_vert = faces_of_vert * Normals.down_faces
			--format "down_faces_of_vert: %\n" down_faces_of_vert
			down_faces_of_vert += meshop.getPolysUsingFace obj.mesh down_faces_of_vert

			
		--	face_centers = for down_face in down_faces_of_vert collect polyop.getFaceCenter obj down_face
			--face_centers = for down_face in down_faces_of_vert collect meshop.getFaceCenter obj.mesh down_face
			face_centers = for down_face in down_faces_of_vert collect (meshop.getFaceCenter obj.mesh down_face) * obj.transform
							
			for pos in face_centers do
				--format "pos: %\n" pos
				sum_pos += pos
		
			sum_pos / face_centers.count
		)
		else
			verts_pos[vert] --return
		
	),


	
	/*==============================================================================
	
		RESET
	
	================================================================================*/
	
	
	/** Reset supports
	 */
	function resetSupports support_nodes =
	(
		 format "\n"; print "SourceObject_v.resetSupports()"
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
			
		raft_vector = if SUPPORT_OPTIONS.raft_direction == 2 then Normals.normals_world[vert] else [0,0,-1] -- direction NORMAL|DOWN

		SupportObject.hit_raft	= undefined
		SupportObject.hit_leg	= undefined
		
		SupportObject.support_obj.wirecolor = VertexColors._getVertColor(vert)
		
		/* REBUILD SUPPORT */ 
		--SupportObject.generateSupport vert first_knot_pos:verts_pos[vert] raft_vector:raft_vector wirecolor:wirecolor normal_world:SupportObject.normal_world
		SupportObject.generateSupport vert first_knot_pos:(this._getSupportPosition vert) raft_vector:raft_vector wirecolor:wirecolor normal_world:SupportObject.normal_world
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
		--format "\n****************************************************\n"
		--format "\n"; print "SourceObject_v.updateSupports()"
		--format "support_nodes: %\n" support_nodes
		--format "update_normals: %\n" update_normals

		/* GET SUPPORTS TO UPDATE */ 
		SupportsToUpdate = this._getSupports support_nodes:support_nodes
		
		/* GET NORMALS */ 
		if update_normals or Normals.normals_world == undefined then
			this._updateNormals (SupportsToUpdate)
		
		/*------------------------------------------------------------------------------
		  
			UPDATE EACH SUPPORT
			
		--------------------------------------------------------------------------------*/
		for index in SupportsToUpdate.keys do
		(
			Support = SupportsToUpdate[index]
			
			/* SAVE #CUSTOM DIRECTION IF SUPPORT HAS BEEN MOVE ON ITS OWN */ 
			if direction == #CUSTOM then 
				setUserPropVal Support.support_obj "DIRECTION" #CUSTOM
				
						
			/* UPDATE SECOND POINT - to keep direction down */ 
			if direction == undefined then
				direction = getUserPropVal Support.support_obj "DIRECTION"
			
			
			/* GET VECTOR  */ 
			--pin_vector = this._getPinVector direction index
			pin_vector = this._getPinVector direction index
			

			/* UPDATE 1st POINT - if support has been moved on its own */ 
			--if update_knot_1 then
			--format "Normals.down_verts[index]: %\n" Normals.down_verts[index]
			--if update_knot_1 or Normals.down_verts[index] then
				first_knot_pos = this._getSupportPosition index
				--first_knot_pos = verts_pos[index]
			
			
			/* IF VECTOR IS VALID THEN UPDATE SUPPORT */ 
			if pin_vector == undefined or pin_vector.z < 0 then
			(
				/*------------------------------------------------------------------------------
					UPDATE SUPPORT
				--------------------------------------------------------------------------------*/
				if not Support.support_obj.boxmode then
					Support.updateSupport first_knot_pos:first_knot_pos update_raft:update_raft direction:direction pin_vector:pin_vector
					 
				/*------------------------------------------------------------------------------
					RESTORE FROM BOX MODE IF VECTOR BECOME VALID
				--------------------------------------------------------------------------------*/
				else
					Support.rebulidSupport pin_vector:pin_vector
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
		index = getUserPropVal support_node "INDEX"
		--Supports[index].updateSupport first_knot_pos:verts_pos[index] update_direction:update_direction
		
		Supports[index].updateSupport first_knot_pos:(this._getSupportPosition index) update_direction:update_direction
		
	),


	/** Update height of all supports which belongs to this source object 
	 */
	function updateSupportsHeight = 
	(
		  --format "\n****************************************************\n"
		  --format "\n"; print "SourceObject_v.updateSupportsHeight()"
		 --format "Normals.normals_world: %\n" Normals.normals_world
		--format "Supports.keys: %\n" Supports.keys
		--format "supports.count: %\n" (Supports.count)
		--for key in Supports.keys where not Supports[key].isRaft() and Supports[key].foot_enabled do
		/* GET SUPPORTS TO UPDATE */ 
		
		/* GET VECTOR  */
		--Normals.setWorldSpaceVertexNormals ( Supports.keys as BitArray )
		if Normals.normals_world == undefined then
			this._updateNormals (Supports)

		
		--for index in Supports.keys where not Supports[index].isRaft() and isValidNode Supports[index].support_obj do
		for index in Supports.keys where Supports[index].is_on_ground and isValidNode Supports[index].support_obj do
		(
			-- format "\n"
			-- format "index: %\n" index
			Support = Supports[index]
			 --format "SUPPORT: %\n" Support
			-- format "NORMAL: %\n" (Normals.normals_world[index].z)
			
			if Normals.normals_world[index].z < 0 then
			(
				direction = getUserPropVal Support.support_obj "DIRECTION"
				
				raft_vector = this._getPinVector direction index

				if not Support.isBoxMode() then
				(
					result = Support.updateSupportHeight()
	
					if result == false then
						Support.enableBoxMode()
				)
				else
					Support.rebulidSupport raft_vector:raft_vector
				
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

	
	/** Get raft vector
	 */
	function _getPinVector direction index =
	(
		-- format "\n"; print "SourceObject_v._getPinVector()"
		case direction of
			(
				(#DOWN):   [ 0, 0, -1 ]
				(#NORMAL): Normals.normals_world[index]
				--(#NORMAL): if Normals.down_verts[index] then [0,0,-1] else Normals.normals_world[index]
			)
	),
	--/** Get pin vector
	-- */
	--function _getPinVector vert =
	--(
	--	--format "\n"; print "SourceObject_v._getPinVector()"
	--	if Normals.down_verts[vert] then [0,0,-1] else Normals.normals_world[vert]		
	--),
	--
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
	function _replaceWhiteWithObjectColor verts_by_colors =
	(
		 --format "\n"; print "SourceObject_v._replaceWhiteWithObjectColor()"
		/** Shift wirecolor sligtly to +1 - Helper points are shifter -1
		  *
		  *
		  *
		  * Each level of points has different wirecolor for better selection
		  */
		function _shiftWirecolor wirecolor =
		(
			--format "\n"; print "PlatformGenerator_v.shiftWirecolor()"
			--format "WIRECOLOR:	% \n" wirecolor
			i = 1
	
			wirecolor_shifted = copy wirecolor
	
			if wirecolor_shifted.r <= 254 then wirecolor_shifted.r += i
			if wirecolor_shifted.g <= 254 then wirecolor_shifted.g += i
			if wirecolor_shifted.b <= 254 then wirecolor_shifted.b += i
			--format "WIRECOLOR_SHIFTED:	% \n" wirecolor_shifted
	
			wirecolor_shifted as string --return
		)

		/* REPLACE WHITE WITH OBJECT WIRECOLOR */
		
		
		verts_color_by_object = if verts_by_colors[ white as string ] != undefined then verts_by_colors[ white as string ] else all_verts
		
		verts_by_colors[ _shiftWirecolor obj.wirecolor ] = verts_color_by_object

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

		--for key in verts_by_colors.keys where key != white as string do flattern_dict += verts_by_colors[key]
		for key in verts_by_colors.keys where verts_by_colors[key] != undefined do
			if findItem exclude_vertex_colors key == 0 do flattern_dict += verts_by_colors[key]

		flattern_dict --return
	),

	
	/** Update normals
	 */
	function _updateNormals supports_to_update =
	(
		--format "\n"; print "SourceObject_v._updateNormals()"
		 
		supports_keys = supports_to_update.keys as BitArray
		 --format "supports_keys: %\n" supports_keys
		
		if Normals.normals_local == undefined then
			Normals.setLocalVertexNormals( supports_keys )

		Normals.setWorldSpaceVertexNormals ( supports_keys )
		
		Normals.setDownFaces()

		/* UPDATE WORLD NORMAL IN OBJECT PROPERTIES */ 
		--for vert in supports_keys do
		for vert in supports_keys where isValidNode Supports[vert].support_obj do
			setUserPropVal Supports[vert].support_obj "PIN_VECTOR" Normals.normals_world[vert]
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
		
		VertexColors = VertexColors_v(obj)
	)
)
