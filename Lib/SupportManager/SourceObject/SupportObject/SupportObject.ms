/** Support object
  
  USES: global SUPPORT_OPTIONS --"./../../../SupportOptions/SupportOptions.ms"
  
  
 */
struct SupportObject_v
(
	/* construct */
	source_obj,

	/* required on load from scene */
	obj_type = #SUPPORT, -- #SUPPORT|#RAFT
	support_obj,

	support_key, -- pointer of support when node is created
	sync_key,

	/* properties */

	points_positions = Array (2),

	--is_on_ground= true,
	foot_enabled = true,
	foot_exists = false,


	hit_raft,
	hit_leg,
	
	/* dependency */
	SupportLegUpdater,
	
	private

	spline_1 = 1, -- each support line has ony 1 spline
	minimal_length, -- cache value
	--direction_down = [0,0,-1],
	minimal_foot_pos_z,

	public


	/** Generate support
	  * 
	  * @param point3	first_knot_pos	top position of support
	  * @param #DOWN|point3	direction	dir_vector of direction from 1st to 2nd point
	  * @param color	wirecolor	of support object
	 */
	function generateSupport vertex_index first_knot_pos: direction:#DOWN dir_vector: wirecolor:( color ( random 100 255) ( random 100 255) ( random 100 255)) =
	(
		--format "\n"
		--format "\n"; print "SupportObject_v.generateSupport()"
		format "first_knot_pos: %\n" first_knot_pos
		
		/* CREATE NEW OBJECT */ 
		if support_obj == undefined then
			support_obj = SplineShape wirecolor:wirecolor

		else /* USE OLD OBEJCT - RESET SPLINE */ 
			deleteSpline support_obj spline_1
		
		this._setSupportLegUpdater()
			
		/* MAKE SURE THAT SUPPORT DIRECTION OF SUPPORT IS NOT HORIZONTAL */ 
		if dir_vector.z > -0.25 then dir_vector.z = -0.25

		
		/* ADD FIRST POINT */
		points_positions = #( first_knot_pos, undefined )
	

		/* SET RAFT PART of support */ 
		this._setSecondKnotPosition(first_knot_pos)(dir_vector)
		
		
		this._setMinimalFootPos (direction) 


		/* SET LEG AND FOOT */ 
		if obj_type == #SUPPORT and hit_raft == undefined then
			this._setLegAndFootKnotPositions()

		/*------------------------------------------------------------------------------
			CREATE SUPPORT
		--------------------------------------------------------------------------------*/
				
		this._setName(vertex_index)
		
		--this._isOnGround()

		this._drawLine()

		this._setMaterialsToLineSegments()

		this._setPivotToSecondPoint()

		this._alignPivotToSeconPoint()

		SUPPORT_MANAGER.addSupportObjects (this)
		
		SUPPORT_MANAGER.updateShapeAdd (support_obj)

		--setUserPropVal support_obj "NORMAL_LENGTH" ( distance points_positions[1] points_positions[2]  )

		/* RETURN */ 
		this
	),

	/** Convert SUPPORT to RAFT and vice versa
	  *
	  * @param #SUPPORT|#RAFT to_type type of obejct to covert
	  *
	 */
	function convertType to_type =
	(
		--format "\n"; print "SupportObject_v.convert()"
		--format "TO_TYPE: %\n" to_type

		function _getKey type = ( toUpper (type as string ) + "_KEY")
		
		/* SET PROPERTIES */ 
		this.obj_type = to_type
		
		this.hit_raft 	= undefined
		this.hit_leg	= undefined
		--this.is_on_ground	= false


		/* GET TYPE OF ORIGIN OBJECT */ 
		from_type =  if to_type == #RAFT then #SUPPORT else #RAFT

		
		/* REPLACE OBJECT PROPERTY DATA */ 
		deleteUserProp support_obj ( _getKey from_type  )
		
		setUserPropVal support_obj ( _getKey to_type  ) support_key

		
		/* IF TYPE IS CONVERTED */ 
		this._getPositionsFromLineOnConvert()
		
		
		/* UPDATE SUPPORT */ 
		this.updateSupport()
	),

	/** Update supports position
	  * 
	  *    UPDATE KNOT 2 IF:
	  *    • If source object ROTATED and support direction is #DOWN
	  *    • If Support was transformed
	  * 
	 */
	function updateSupport first_knot_pos: update_knot_2:true direction: dir_vector:undefined =
	(
		--format "\n"; print "SupportObject_v.updateSupport()"
		--format "first_knot_pos: %\n" first_knot_pos
		--format "update_knot_2: %\n" update_knot_2
		--format "direction: %\n" direction
		--format "dir_vector: %\n" dir_vector


		--/* GET 1st knot POSITION FROM LINE */ 
		num_knots = numKnots support_obj spline_1
		
		if classOf first_knot_pos != point3 then
			first_knot_pos = getKnotPoint support_obj spline_1 1

		
		/* ADD POINTS */
		points_positions = #( first_knot_pos, support_obj.pos )

		/* GET VECTOR OF RAFT */ 
		if dir_vector == undefined then 
			dir_vector = normalize ( points_positions[2] - points_positions[1] )
		
		
		/* 	UPDATE KNOT 2  */ 
		if update_knot_2 then
			this._updateSecondKnotPosition direction:direction dir_vector:dir_vector
		
		
		/* UPDATE MINIMAL FOOT Z POSITION */ 
		if minimal_foot_pos_z == undefined then 
			this._setMinimalFootPos (direction) 
		
		

		/* CHECK NORMAL LENGTH  */ 
		if first_knot_pos != unsupplied and num_knots> 2  then
		(
			current_length = distance points_positions[1] points_positions[2]
		
			/* PRECISE MINIMAL LENGTH BY ANGLE OF SUPPORT */ 
			--minimal_length = this.getNimalLenghtByAngle first_knot_pos:points_positions[1] second_knot_pos:points_positions[2] add_chamfer:true
			/* FAST MINIMAL LENGTH BY WIDTH OF BAR */ 
			minimal_length = SUPPORT_OPTIONS.getOption #BAR_WIDTH * 2
		
			/* SET MINIMAL NORMAL IF IT`S TOO SHOTRT */ 
			if current_length < minimal_length then
				points_positions[2] = first_knot_pos + ( (minimal_length + 0.1 ) * ( normalize ( points_positions[2] - points_positions[1] ) ) ) -- make raft longer by multiplying normal length 10x
		)
		
		

		
		/* UPDATE LEG IF SUPPORT TYPE AND NOT HIT */
		--force_update_leg = obj_type == #SUPPORT and hit_raft == undefined and hit_leg == undefined
		--format "num_knots: %\n" ( numKnots support_obj spline_1 )



		--this._setRightCountOfKnotsToSpline()
		--format "num_knots: %\n" ( numKnots support_obj spline_1 )
		--format "num_knots: %\n" ( numKnots support_obj spline_1 )
		

		--updateShape support_obj
		
		/* GENERATE LEG FOR SUPPORT */ 
		if obj_type == #SUPPORT and hit_raft == undefined then
			this.updateLeg points_positions:points_positions
			
		else if update_knot_2 then
			this._updateKnotsPositionByPoints()

		
		--this._setMaterialsToLineSegments()
		
		this._setPivotToSecondPoint()
		
		--if ( mod_extend_top = support_obj.modifiers[#EXTEND_TOP] ) != undefined then
		--(
		--	--format "CENTER\n"
		--	--mod_extend_top.extrude_center = support_obj.pivot
		--	mod_extend_top.extrude_center = [0,0,-100000]
		--)
		--
		--this._alignPivotToSeconPoint()
		
		--if numKnots support_obj spline_1 > 2 then
			--setUserPropVal support_obj "NORMAL_LENGTH" ( this._getNormalLenght() )

		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),

	/** Update leg position
	 */
	function updateLeg points_positions: =
	(
		--format "\n"; print "SupportObject_v.updateLeg()"
		
		/* IF ONLY LEG IS UPDATED */ 
		if points_positions == unsupplied then 
			this.points_positions = #( getKnotPoint support_obj spline_1 1 , support_obj.pos )

		/* TEST IF LEG HITS SOURCE OBJECT */ 
		hit_leg = this._intersectRaySourceObject (this.points_positions[2]) ([0,0,-1])
		
		/* IF LEG HIT SOURCE OBJECT */ 
		if hit_leg != undefined then
			this.points_positions[3] = hit_leg.pos --  SET HIT POSITON OF LEG 
		
		this._setRightCountOfKnotsToSpline()
		
		this._updateKnotsPositionByPoints()

		
		if hit_leg == undefined then
		(
			if minimal_foot_pos_z == undefined then
				this._setMinimalFootPos (getUserPropVal support_obj "DIRECTION") 

				
			SupportLegUpdater.minimal_foot_pos_z = minimal_foot_pos_z
			
			foot_exists = SupportLegUpdater.updateFoot()
		)


		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),
	
	/** Update base height
	 */
	function updateBaseHeight =
	(
		--format "\n"; print "SupportObject_v.updateBaseHeight()"
		--format "support_obj: %\n" support_obj.name
		if this.is_on_ground != undefined and this.is_on_ground then
		(
			ground_knot = numKnots support_obj spline_1
			base_knot   = ground_knot - 1
			
			base_knot_pos   = getKnotPoint support_obj spline_1 base_knot
			base_knot_pos.z = SUPPORT_OPTIONS.base_height
			
			setKnotPoint support_obj spline_1 base_knot base_knot_pos
			
			setUserPropVal support_obj "BASE_HEIGHT" SUPPORT_OPTIONS.base_height

			SUPPORT_MANAGER.updateShapeAdd (support_obj)
		)
	),
 
	/** Is raft
	 */
	function isRaft =
	(
		--format "\n"; print "SupportObject_v.isRaft()"
		getUserPropVal support_obj "RAFT_KEY" != undefined
	),

	
	/** Is vector pointing down
	 */
	function isVectorPointingDown =
	(
		--format "\n"; print "SupportObject_v.isVectorPointingDown()"
		fn round p3 =
		(
			local tempArr = #(p3.x,p3.y,p3.z)
			local mult = 10.00^(3 as float)
			local rp3Arr = for c in tempArr collect ((floor ((c * mult)+0.5)) / mult)
			point3 rp3Arr[1] rp3Arr[2] rp3Arr[3]
		)

		knot_1 = round (getKnotPoint support_obj spline_1 1)
		knot_2 = round (getKnotPoint support_obj spline_1 2)
		
		knot_1.x == knot_2.x and knot_1.y == knot_2.y and knot_1.z != knot_2.z
	),
	
	private
	
	/** ADD SECOND POINT of raft or support
	  
	 */
	function _setSecondKnotPosition first_knot_pos dir_vector =
	(
		--format "\n"; print "SupportObject_v._setSecondKnotPosition()"
		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS

		normal_length_option = SUPPORT_OPTIONS.normal_length

		length_multiplier = if obj_type == #SUPPORT then 1 else 10

			
		/*------  ------*/
		second_knot_pos = if ( hit_raft_pos = this._getRaftHitPosition dir_vector normal_length_option ) == undefined then 
		(
			second_knot_vec = first_knot_pos + ( dir_vector * length_multiplier ) -- make raft longer by multiplying normal length 10x
			
			/* PRECISE MINIMAL LENGTH BY ANGLE OF SUPPORT */ 
			--minimal_length = this.getNimalLenghtByAngle first_knot_pos:first_knot_pos second_knot_pos:second_knot_vec add_bar:false add_chamfer:true
			/* FAST MINIMAL LENGTH BY WIDTH OF BAR */ 
			minimal_length = SUPPORT_OPTIONS.getOption #BAR_WIDTH * 2
			
			--format "GEN_length: %\n" minimal_length
			/* KEEP MINIMAL LENGTH OF NORMLA */ 
			normal_length = if normal_length_option < minimal_length then minimal_length else normal_length_option
			
			first_knot_pos + ( normal_length * dir_vector * length_multiplier ) -- make raft longer by multiplying normal length 10x -- add 0.1mm just for sure
		)
		else
			hit_raft_pos


		/* KEEP SECOND POINT BELOW FIRST */
		--second_knot_pos = this._keepSecondPointBellowFirst first_knot_pos second_knot_pos

		/* KEEP SECOND POINT ABOVE GROUND */
		--second_knot_pos = this._keepSecondPointAboveGround first_knot_pos second_knot_pos dir_vector
		
		--second_knot_pos = this._checkMinimalNormalLenght (first_knot_pos) (second_knot_pos) (direction)

		/* ADD 2nd POINT */
		points_positions[2] = second_knot_pos
	),

	/** Get and UPDATE 2nd knot of support
	  * 
	  * Check if 2nd knot hits source object
	  * 
	 */
	--function _updateSecondKnotPosition keep_direction_down:false =
	function _updateSecondKnotPosition direction: dir_vector:undefined =
	(
		--format "\n"; print "SupportObject_v._updateSecondKnotPosition()"
		--format "DIRECTION: %\n" direction
		--format "dir_vector: %\n" dir_vector
		
		/** Get zposition down
		 */
		function getZpositionDown =
		(
			--format "\n"; print "SupportObject_v.getZpositionDown()"
			
			second_knot_pos = copy points_positions[1]
			
			second_knot_pos.z -= distance points_positions[1] points_positions[2]
			
			second_knot_pos --return
		)
		
		/** Get position down
		 */
		--function getPositionByVector dir_vector = points_positions[1] + ( (distance points_positions[1] points_positions[2]) * dir_vector ) -- make raft longer by multiplying normal length 10x
		/** Update normal length props
		 */
		function updateNormalLengthProps distance_of_points =
		(
			--format "\n"; print "SupportObject_v.updateNormalLengthProps()"
			this.SupportLegUpdater.normal_length = distance_of_points
			
			setUserPropVal support_obj "NORMAL_LENGTH" distance_of_points
		)
		
		
		if direction == #DOWN then
			points_positions[2] = getZpositionDown()

		
		--if direction != #CUSTOM then
		--	points_positions[2] = case direction of
		--	(
		--		(#DOWN):   getZpositionDown()
		--		(#NORMAL): getPositionByVector(dir_vector)
		--	)
			
								
								
		/* KEEP SECOND POINT BELOW FIRST */
		--second_knot_pos = this._keepSecondPointBellowFirst first_knot_pos second_knot_pos

		/* KEEP SECOND POINT ABOVE GROUND */
		--second_knot_pos = this._keepSecondPointAboveGround first_knot_pos second_knot_pos dir_vector

		
		distance_of_points = distance points_positions[1] points_positions[2]

		if ( hit_raft_pos = this._getRaftHitPosition dir_vector distance_of_points ) != undefined then 
			points_positions[2] = hit_raft_pos
			
		else
			updateNormalLengthProps(distance_of_points)


		--second_knot_pos = this._checkMinimalNormalLenght (first_knot_pos) (second_knot_pos) (dir_vector)
		
	),

	/** Get secon point position
	 */
	function _getRaftHitPosition direction max_distance =
	(
		--format "\n"; print "SupportObject_v._getRaftHitPosition()"
		--format "points_positions[1]: %\n" points_positions[1]
		--format "max_distance: %\n" max_distance
		
		
		hit_raft = this._intersectRaySourceObject ( points_positions[1]) ( direction )
		
		
		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit_raft != undefined and distance points_positions[1] hit_raft.pos > max_distance then
			hit_raft = undefined


		 if hit_raft != undefined then
		 (
			--SupportLegUpdater.foot_exists = false
			
			hit_raft.pos --return
		 )
	),

	/** Add knots
	 */
	function _addKnots =
	(
		--format "\n"; print "SupportObject_v._addKnots()"
		num_knots = numKnots support_obj spline_1

		for knot_i = num_knots + 1 to points_positions.count do
			addKnot support_obj spline_1 #corner #line points_positions[knot_i]
	),

	/** Remove redundant knots from line object
	  * 
	  * Used if updated shape has less knots then old shape
	  * 
	 */
	function _removeKnots =
	(
		--format "\n"; print "SupportObject_v._removeKnots()"
		num_knots = numKnots support_obj spline_1

		for knot_i = num_knots to points_positions.count + 1 by -1 do
			deleteKnot support_obj spline_1 knot_i
	),



	/** SET CORECT NUMBER OF KNOTS ON OBJECT
	 */
	function _setRightCountOfKnotsToSpline =
	(
		--format "\n"; print "SupportObject_v._setRightCountOfKnotsToSpline()"
		if (num_knots = numKnots support_obj spline_1) != points_positions.count then
		(
			case of
			(
				(num_knots < points_positions.count): this._addKnots()
				(num_knots > points_positions.count): this._removeKnots()
			)
			
			--this._updateKnotsPositionByPoints()
		)
	),

	/** Set knots of support`s leg part
	 */
	function _setLegAndFootKnotPositions =
	(
		
		/** Add foot
		 */
		function addFoot =
		(
			--format "\n"; print "SupportObject_v.addFoot()"
			pos = copy points_positions[2]
			/* BASE POINT - ABOVE GROUND */
			pos.z = SUPPORT_OPTIONS.base_height -- set knot above ground to set base height and keep last segment straight for extrude

			points_positions[3] = copy pos

			/* ADD GROUND POINT */
			pos.z = 0 -- set support_obj to ground

			points_positions[4] = copy pos
			
			foot_exists = true
			--setMaterialID support_obj spline_1 ( numSegments support_obj spline_1) SUPPORT_OPTIONS.mat_ids[#BASE]
		)
		
		/** Set leg to ground without foot
		 */
		function setLegToGroundWithoutFoot =
		(
			--format "\n"; print "SupportObject_v.setLegToGroundWithoutFoot()"
			points_positions[2].z = 0

			foot_exists = false
		)
		
		--format "\n"; print "SupportObject_v._setLegAndFootKnotPositions()"

		/* TEST IF HIT SOURCE OBJECT ON THE WAY TO GROUND */ 
		hit_leg = this._intersectRaySourceObject (points_positions[2]) ([0,0,-1])
		--format "HIT_SUPPORT: %\n" HIT_SUPPORT
		--pos = copy points_positions[2] -- copy to avoid modifing of value in array
		foot_exists = hit_leg == undefined

		if hit_leg == undefined then
		(
			if this.foot_enabled and points_positions[2].z > minimal_foot_pos_z then
				addFoot()
			else
				setLegToGroundWithoutFoot()
		)
		else /* IF SUPPORT IS INTERSECTING SOURCE OBJECT, THEN ADD POINT TO INETSECTION */
			points_positions[3] = hit_leg.pos
		
	),
	
	/** Keep second point bellow first
	 */
	function _keepSecondPointBellowFirst first_knot_pos second_knot_pos =
	(
		--format "\n"; print "SupportObject_v.keepSecondPointBellowFirst()"
		if second_knot_pos.z >= first_knot_pos.z then
			second_knot_pos.z = first_knot_pos.z -- SUPPORT_OPTIONS.bar_width
		
		second_knot_pos --return		
	),
	
	/** Keep second point above ground
	 */
	function _keepSecondPointAboveGround first_knot_pos second_knot_pos dir_vector =
	(
		--format "\n"; print "SupportObject_v.keepSecondPointAboveGround()"
		limit_height_to_base = SUPPORT_OPTIONS.base_height + 0.5 -- z pozition preserved for base points
		
		/* CHECK POSITION ABOVE GROUND, SET LAST KNOT ABOVE BASE */
		if obj_type == #SUPPORT and second_knot_pos.z < limit_height_to_base then
		(
			normal_length = abs ((first_knot_pos.z - limit_height_to_base ) / dir_vector.z)
		
			second_knot_pos = first_knot_pos + ( normal_length * dir_vector)
		)		
		
		second_knot_pos --return
	),
	
	/** Get knots postions from existing line
	  * 
	  * 1) SUPPORT > RAFT 
	  * 
	  *		A) Get 2nd point if support is on ground
	  * 		B) Get LAST knot if support is NOT on ground
	  * 
	  * 
	  *  2) RAFT > SUPPORT
	  * 
	  * 	 	Get LAST knot of raft
	 */
	function _getPositionsFromLineOnConvert =
	(
		--format "\n"; print "SupportObject_v._getPositionsFromLineOnConvert()"
		
		second_point = if obj_type == #RAFT and is_on_ground then 2 else numKnots support_obj spline_1
		
		
		points_positions = #(
			getKnotPoint support_obj spline_1 1,
			getKnotPoint support_obj spline_1 second_point
		)
	),


	/** Create line
	  */
	function _drawLine =
	(
		--format "\n"; print "SupportObject_v._drawRaftLine()"
		addNewSpline support_obj

		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for pos in points_positions do
			addKnot support_obj spline_1 #corner #line pos

		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),

	/** Update line
	 */
	function _updateKnotsPositionByPoints =
	(
		--format "\n"; print "SupportObject_v._updateKnotsPositionByPoints()"
		--format "points_positions.count: %\n" points_positions.count
		for knot_i = 1 to points_positions.count do
			setKnotPoint support_obj spline_1 knot_i points_positions[knot_i]
	),

	/** Set materials to line segments
	 */
	function _setMaterialsToLineSegments =
	(
		--format "\n"; print "SupportObject_v._setMaterialsToLineSegments()"
		--format "SupportLegUpdater.foot_exists: %\n" SupportLegUpdater.foot_exists
		num_of_segments = numSegments support_obj ( numSplines support_obj)
	
		for segment_i = 1 to num_of_segments do
			setMaterialID support_obj spline_1 segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
	
		/*------ SET MATERIAL TO GROUND SEGMENT ------*/
		--if is_on_ground != undefined and is_on_ground then
		if foot_exists then
			setMaterialID support_obj spline_1 num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
	),

	/** Align to ctor
	 */
	function _alignPivotToSeconPoint =
	(
		--format "\n"; print "SupportObject_v._alignPivotToSeconPoint()"

		--dir = normalize (support_obj.pos - points_positions[1])
		dir = normalize (points_positions[1] - support_obj.pos)

		axis = #z

		vec = case axis of
		(
			#x: support_obj.transform[1]
			#y: support_obj.transform[2]
			#z: support_obj.transform[3]
		)

		--tm  = Inverse support_obj.transform
		tm  = support_obj.transform
		vec = normalize vec
		dir = normalize dir
		
		angle_vectors = acos (dot vec dir) -- get angle between

		
		/**
			PROBLEM:
				sometimes acos() returns -nan(ind) 
		  
			IT CAUSES ERROR AND MAKES SUPPORT DISSAPEAR
		  
			WORKAROUND:
				Check if acos() returns number
		  
		*/
		
		if ( (angle_vectors as string ) as float ) != undefined then
		(
			axis_of_plane_defined_by_vectors = normalize (cross dir vec)
	
			rtm = AngleAxis (angle_vectors) ( axis_of_plane_defined_by_vectors )
	
			tempObjTM = Translate ( Rotate ( ScaleMatrix  tm.scale) (tm.rotation*rtm)) tm.pos
			--format "tempObjTM: %\n" tempObjTM
			WorldAlignPivot support_obj
	
			rot = Inverse tempObjTM.rotation
	
			in coordsys local support_obj.rotation *= rot
	
			support_obj.objectoffsetrot *= rot
			support_obj.objectoffsetpos *= rot
			
		)
		else
		(
			--format "\n"; format "SupportObject_v._alignPivotToSeconPoint() %" support_obj.name
			--format " ANGLE_VECTORS: %\n" angle_vectors
		)

		--support_obj.pivot = p1
	),

	/** Set pivot to position
	 */
	function _setPivotToSecondPoint =
	(
		--format "\n"; print "SupportObject_v._alignPivotToSeconPoint()"
		support_obj.pivot = getKnotPoint support_obj spline_1 2
	),

	/** Test collision with source object
	 */
	function _intersectRaySourceObject pos direction =
	(
		--format "\n"; print "SupportObject_v._intersectRaySourceObject()"
		--format "pos: %\n" pos
		--format "direction: %\n" direction
		
		/** Modify pos
		 */
		function modifyPos _pos axis val =
		(
			--format "\n"; print ".modifyPos()"
			_pos = copy _pos

			_pos[axis] += val

			_pos --return
		)

		local hit_result

		if source_obj != undefined then
		(
			half_of_bar_width = SUPPORT_OPTIONS.bar_width / 2
	
			pos += 0.1 * direction
	
			bar_bbox = #(
				modifyPos pos 1 half_of_bar_width,
				modifyPos pos 1 (half_of_bar_width * -1),
				modifyPos pos 2 half_of_bar_width,
				modifyPos pos 2 (half_of_bar_width * -1),
				pos
			)
	
			for pos in bar_bbox do
				if ( hit = intersectRay source_obj ( Ray pos direction) ) != undefined then
					hit_result = copy hit
		)

		hit_result --return
	),

	
	/** Set minimal foot pos
	 */
	function _setMinimalFootPos direction =
	(
		--format "\n"; print "SupportLegUpdater_v._setMinimalFootPos()"
		--format "leg_knot: %\n" leg_knot
	
		chamfer_val = SUPPORT_OPTIONS.getOption #TOP_WIDTH
		base_height = SUPPORT_OPTIONS.getOption #BASE_HEIGHT
		height_offset = 0.1
		
		minimal_foot_pos_z = base_height + chamfer_val + height_offset
		
		/* TUNE MINIMAL FOOT HEIGHT BASED ON ANGLE OF SUPPORT -- to avoid corner artefact on sweep modifier
			
			support - 90°  > remove 90% of bar with
			support - 135° > remove 45% of bar with
			support - 180° > remove 0%  of bar with
		
		*/ 
		if direction == #NORMAL then
		(
			add_by_angle = this.getNimalLenghtByAngle first_knot_pos:points_positions[1] second_knot_pos:points_positions[2]
			
			minimal_leg_pos = add_by_angle + chamfer_val --+ 0.1
			
			minimal_foot_pos_z += add_by_angle
		)
		--format "MINIMAL_LEG_POS_Z: %\n" minimal_foot_pos_z
	),
	
	/** Get minimal lenght of segment by angle to KEEP CLEAND CORNERS OF SWEEP MODIFIER 
	 */
	function getNimalLenghtByAngle first_knot_pos:undefined second_knot_pos:undefined add_bar:false add_chamfer:false =
	(
		--format "\n"; print "SupportLegUpdater_v.getNimalLenghtByAngle()"
		--format "first_knot_pos:  %\n" first_knot_pos
		--format "second_knot_pos: %\n" second_knot_pos
		
		/** Get percentage of bar with by angle of corner
		  *
		  *    • IF ANGLE is 180° then 0%   of bar with is added
		  *    • IF ANGLE is  90° then 100% of bar with is added
		  *
		  * @return integer % of bar with needed for clean corners of sweep modifier
		 */
		function getPercentageByAngle angle_of_leg =
		(
			--format "\n"; print "SupportObject_v.getPercentageByAngle()"
			angle_of_leg -= 90
			--format "angle_of_leg: %\n" angle_of_leg
			( angle_of_leg / 90 * 100.0 )
		)
	
		vector_leg = [ 0, 0, -1 ]
	
		if first_knot_pos == undefined then 
			first_knot_pos  = getKnotPoint support_obj spline_1 1
		
		if second_knot_pos == undefined then 
			second_knot_pos = getKnotPoint support_obj spline_1 2

		bar_width = SUPPORT_OPTIONS.getOption #BAR_WIDTH
		--format "bar_width: %\n" bar_width

		vector_raft = normalize ( first_knot_pos - second_knot_pos )
		
		angle_of_leg = acos (dot vector_raft vector_leg) -- get angle between
		--format "ANGLE_ALPHA: %\n" angle_of_leg

		percentage_by_angle = getPercentageByAngle(angle_of_leg)
		--format "percentage_by_angle: %\n" percentage_by_angle
		width_by_angle = bar_width * (percentage_by_angle / 100.0)
		--format "width_by_angle: %\n" width_by_angle

		length_by_angle = bar_width - width_by_angle
		--format "length_by_angle: %\n" length_by_angle
		
		if add_bar then
			length_by_angle += bar_width
		
		if add_chamfer then
			length_by_angle += SUPPORT_OPTIONS.getOption #TOP_WIDTH

		length_by_angle --return
	),
	
	--/** Reset knots
	-- */
	--function _resetThisObject =
	--(
	--	this.points_positions = Array (2)
	--
	--	this.is_on_ground = false
	--
	--	this.hit_leg = undefined
	--),

	/*------------------------------------------------------------------------------

		HELPERS

	--------------------------------------------------------------------------------*/
	/** Set nide name
	 */
	function _setName vertex_index =
	(
		--format "\n"; print "SupportObject_v._getName()"
		if source_obj != undefined then
		(
			support_name = substituteString source_obj.name "-source" ""
	
			if not matchPattern support_name pattern:("*-support*") then
				support_name += "-support"
			--support_name + "-support-" + vertex_index as string -- + "-" + index as string
			support_name += "-"+ vertex_index as string
	
			support_obj.name = support_name --return
		)
	),
	

	/** Shift wirecolor sligtly
	  * Each level of points has different wirecolor for better selection
	  */
	function _shiftWirecolor wirecolor i =
	(
		--format "\n"; print "SupportObject_v.shiftWirecolor()"
		--format "wirecolor:	% \n" wirecolor
		wirecolor_shifted = copy wirecolor


		if wirecolor_shifted.r >= abs i then wirecolor_shifted.r -= i
		if wirecolor_shifted.g >= abs i then wirecolor_shifted.g -= i
		if wirecolor_shifted.b >= abs i then wirecolor_shifted.b -= i
		--format "wirecolor_shifted:	% \n" wirecolor_shifted

		wirecolor_shifted --return
	),

	/** Get normal lenght
	 */
	function _getNormalLenght =
	(
		--format "\n"; print "SupportObject_v.getNormalLenght()"
		distance (getKnotPoint support_obj spline_1 1) (getKnotPoint support_obj spline_1 2)
	),
	
	/** Set support leg updater
	 */
	function _setSupportLegUpdater =
	(
		--format "\n"; print "SupportLegUpdater_v._setSupportLegUpdater()"
		if support_obj != undefined then 
			SupportLegUpdater = SupportLegUpdater_v (support_obj) foot_mat_id:(SUPPORT_OPTIONS.mat_ids[#BASE]) foot_enabled:foot_enabled
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportObject.onCreate()"
		this._setSupportLegUpdater()
	)

)
