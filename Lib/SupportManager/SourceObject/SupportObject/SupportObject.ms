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

	knots_positions = Array (2),

	is_on_ground = true,


	hit_raft,
	hit_support,

	private

	spline_1 = 1, -- each support line has ony 1 spline

	--direction_down = [0,0,-1],


	public


	/** Generate support
	  * 
	  * @param point3	first_knot_pos	top position of support
	  * @param #DOWN|point3	direction	dir_vector of direction from 1st to 2nd point
	  * @param color	wirecolor	of support object
	 */
	function generateSupport vertex_index first_knot_pos: direction:#DOWN dir_vector: wirecolor:( color ( random 100 255) ( random 100 255) ( random 100 255)) =
	(
		--format "\n"; print "SupportObject_v.generateSupport()"
		--format "direction: %\n" direction
		--format "dir_vector: %\n" dir_vector
			
		
		/* CREATE NEW OBJECT */ 
		if support_obj == undefined then
			support_obj = SplineShape wirecolor:wirecolor

		else /* USE OLD OBEJCT - RESET SPLINE */ 
			deleteSpline support_obj spline_1
		
		
			
		/* MAKE SURE THAT SUPPORT DIRECTION OF SUPPORT IS NOT HORIZONTAL */ 
		if dir_vector.z > -0.25 then dir_vector.z = -0.25

		
		/* ADD FIRST POINT */
		knots_positions = #( first_knot_pos, undefined )
	

		/* SET RAFT PART of support */ 
		this._setSecondKnotPosition(first_knot_pos)(dir_vector)
		--format "first_knot_pos: %\n" first_knot_pos
		--format "HIT_RAFT: %\n" hit_raft

		/* SET LEG PART of support - if raft do not hit source object */ 
		if obj_type == #SUPPORT and hit_raft == undefined then
			this._setSupportLegKnotPositions()

		/*------------------------------------------------------------------------------
			CREATE SUPPORT
		--------------------------------------------------------------------------------*/
				
		this._setName(vertex_index)
		
		this._isOnGround()

		this._drawLine()

		this._setMaterialsToLineSegments()

		this._setPivotToSecondPoint()

		this._alignPivotToSeconPoint()

		SUPPORT_MANAGER.addSupportObjects (this)

		
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
		this.hit_support	= undefined
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
	  * first_knot_pos: update_first
	  * 
	  * 
	  * 
	 */
	function updateSupport first_knot_pos: update_knot_2:true direction: dir_vector:undefined =
	(
		format "\n"; print "SupportObject_v.updateSupport()"
		--format "obj_type: %\n" obj_type

		/* GET 1st knot POSITION FROM LINE */ 
		if classOf first_knot_pos != point3 then
			first_knot_pos = getKnotPoint support_obj spline_1 1
		
		

		/* ADD POINTS */
		knots_positions = #( first_knot_pos, support_obj.pos )
		
		
		/* 	UPDATE KNOT 2
		
			• If source object ROTATED and support direction is #DOWN
		
			• If Support was transformed
		
		*/ 
		if update_knot_2 and dir_vector != undefined then
			this._updateSecondKnotPosition direction:direction dir_vector:dir_vector
		
		--format "hit_raft: %\n" hit_raft
		/* GENERATE LEG FOR SUPPORT */ 
		if ( obj_type == #SUPPORT and hit_raft == undefined )  then
			this._setSupportLegKnotPositions()
		
		--else
			

		this._setRightCountOfKnotsToSpline()
		
		this._updateLine()
		
		this._isOnGround()
		
		this._setMaterialsToLineSegments()
		

		
		this.updateLegPosition()

		
		
		
		this._setPivotToSecondPoint()
		
		this._alignPivotToSeconPoint()

		if numKnots support_obj spline_1 > 2 then
			setUserPropVal support_obj "NORMAL_LENGTH" ( distance knots_positions[1] knots_positions[2] )

		--setUserPropVal support_obj "BASE_HEIGHT" SUPPORT_OPTIONS.base_height

		--updateShape support_obj

		--SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),

	/** Update leg position
	 */
	function updateLegPosition =
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--format "\n"; print "SupportObject_v.updateLegPosition()"
		--format "is_on_ground: %\n" this.is_on_ground

		if this.is_on_ground != undefined and this.is_on_ground then
		(
			SupportLegUpdater = SupportLegUpdater_v (support_obj) foot_mat_id:(SUPPORT_OPTIONS.mat_ids[#BASE])
	
			foot_added = SupportLegUpdater.updateLeg()
	
			/* SET MATERIALS */
			--if foot_added then
				--this._setMaterialsToLineSegments()
				
			SUPPORT_MANAGER.updateShapeAdd (support_obj)
		)
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

	--/** Get direction
	-- */
	--function getDirection =
	--(
	--	format "\n"; print "SupportObject_v.getDirection()"
	--	format "support_obj: %\n" support_obj
	--	format "TEST: %\n" (getUserPropVal support_obj "DIRECTION" asString:false )
	--	getUserPropVal support_obj "DIRECTION" --return
	--),

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

	/** Set knots positions of raft part of support
	  
	  
	 */
	function _setSecondKnotPosition first_knot_pos direction =
	(
		--format "\n"; print "SupportObject_v._setSecondKnotPosition()"
		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS

		length_multiplier = if obj_type == #SUPPORT then 1 else 10
		
		
		/* ADD SECOND POINT */
		second_knot_pos = if ( hit_raft_pos = this._getRaftHitPosition direction SUPPORT_OPTIONS.normal_length ) != undefined then 
			hit_raft_pos
		else
			first_knot_pos + ( SUPPORT_OPTIONS.normal_length * direction * length_multiplier ) -- make raft longer by multiplying normal length 10x


		/* KEEP SECOND POINT BELOW FIRST */
		--second_knot_pos = this._keepSecondPointBellowFirst first_knot_pos second_knot_pos

		/* KEEP SECOND POINT ABOVE GROUND */
		--second_knot_pos = this._keepSecondPointAboveGround first_knot_pos second_knot_pos dir_vector
		
		second_knot_pos = this._checkMinimalNormalLenght (first_knot_pos) (second_knot_pos) (direction)

		setUserPropVal support_obj "NORMAL_LENGTH" ( distance first_knot_pos second_knot_pos )

		/* ADD 2nd POINT */
		knots_positions[2] = second_knot_pos
	),

	/** Get and UPDATE 2nd knot of support
	  * 
	  * Check if 2nd knot hits source object
	  * 
	 */
	--function _updateSecondKnotPosition keep_direction_down:false =
	function _updateSecondKnotPosition direction: dir_vector:undefined =
	(
		format "\n"; print "SupportObject_v._updateSecondKnotPosition()"
		--format "direction: %\n" direction
		--format "dir_vector: %\n" dir_vector
		
		/** Get zposition down
		 */
		function getZpositionDown =
		(
			--format "\n"; print "SupportObject_v.getZpositionDown()"
			
			second_knot_pos = copy knots_positions[1]
			
			second_knot_pos.z -= distance knots_positions[1] knots_positions[2]
			
			second_knot_pos --return
		)
		
		/** Get position down
		 */
		function getPositionByVector dir_vector =
		(
			--format "\n"; print "SupportObject_v.getPositionByVector()"
			knots_positions[1] + ( (distance knots_positions[1] knots_positions[2]) * dir_vector ) -- make raft longer by multiplying normal length 10x
		)
		
		
		first_knot_pos  = knots_positions[1]
		
		second_knot_pos = if direction != undefined and dir_vector != undefined then
								case direction of
								(
									(#DOWN):   getZpositionDown()
									(#NORMAL): getPositionByVector(dir_vector)
								)
							else
								knots_positions[2]
								
								
		/* KEEP SECOND POINT BELOW FIRST */
		--second_knot_pos = this._keepSecondPointBellowFirst first_knot_pos second_knot_pos

		/* KEEP SECOND POINT ABOVE GROUND */
		--second_knot_pos = this._keepSecondPointAboveGround first_knot_pos second_knot_pos dir_vector

		
		distance_of_points = distance first_knot_pos second_knot_pos
		
		dir_vector = normalize (second_knot_pos - first_knot_pos)

		if ( hit_raft_pos = this._getRaftHitPosition dir_vector distance_of_points ) != undefined then 
			second_knot_pos = hit_raft_pos
		
		--second_knot_pos = this._checkMinimalNormalLenght (first_knot_pos) (second_knot_pos) (dir_vector)
		
		setUserPropVal support_obj "NORMAL_LENGTH" ( distance first_knot_pos second_knot_pos )

		/* ADD SECOND POINT */
		knots_positions[2] = second_knot_pos
	),

	/** Get secon point position
	 */
	function _getRaftHitPosition direction max_distance =
	(
		--format "\n"; print "SupportObject_v._getRaftHitPosition()"
		hit_raft = this._intersectRaySourceObject (knots_positions[1]) ( direction )
		
		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit_raft != undefined and distance knots_positions[1] hit_raft.pos > max_distance then
			hit_raft = undefined
		
		 if hit_raft != undefined then
			hit_raft.pos --return
	),
		
	/** Check minimal normal lenght
	 */
	function _checkMinimalNormalLenght first_knot_pos second_knot_pos direction =
	(
		--format "\n"; print "SupportObject_v._checkMinimalNormalLenght()"
		if distance knots_positions[1] second_knot_pos < SUPPORT_OPTIONS.bar_width * 2 then
			second_knot_pos = first_knot_pos + ( SUPPORT_OPTIONS.normal_length * direction ) -- make raft longer by multiplying normal length 10x

		second_knot_pos --return
	),
	
	--/** Check segments lenghts
	-- */
	--function _checkSegmentsLenghts vertex_index =
	--(
	--	--format "\n"; print "SupportObject_v._checkSegmentsLenghts()"
	--
	--	result = true
	--
	--	if ( dist = distance knots_positions[1] knots_positions[knots_positions.count] ) < SUPPORT_OPTIONS.getOption #TOP_WIDTH  then
	--	(
	--		format "SUPPORT OF VERT:% HAS NO LENGTH\n" vertex_index
	--
	--		result = false
	--	)
	--	else if knots_positions.count > 2 then
	--		for i = knots_positions.count to 2 by -1 do
	--		(
	--			if ( dist = distance knots_positions[i] knots_positions[i - 1] ) < SUPPORT_OPTIONS.getOption #BAR_WIDTH then
	--			(
	--				format "SUPPORT OF VERT:% IS TOO SHORT\n" vertex_index
	--
	--				deleteItem knots_positions (i - 1)
	--
	--				--result = false
	--			)
	--		)
	--
	--	result --return
	--),

	/** Add knots
	 */
	function _addKnots =
	(
		--format "\n"; print "SupportObject_v._addKnots()"
		num_knots = numKnots support_obj spline_1

		for knot_i = num_knots + 1 to knots_positions.count do
			addKnot support_obj spline_1 #corner #line knots_positions[knot_i]
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

		for knot_i = num_knots to knots_positions.count + 1 by -1 do
			deleteKnot support_obj spline_1 knot_i
	),



	/** SET CORECT NUMBER OF KNOTS ON OBJECT
	 */
	function _setRightCountOfKnotsToSpline =
	(
		--format "\n"; print "SupportObject_v._setRightCountOfKnotsToSpline()"
		if (num_knots = numKnots support_obj spline_1) != knots_positions.count then
			case of
			(
				(num_knots < knots_positions.count): this._addKnots()
				(num_knots > knots_positions.count): this._removeKnots()
			)
	),

	/** Set knots of support`s leg part
	 */
	function _setSupportLegKnotPositions =
	(
		--format "\n"; print "SupportObject_v._setSupportLegKnotPositions()"
		--format "knots_positions: %\n" knots_positions

		/* TEST IF HIT SOURCE OBJECT ON THE WAY TO GROUND */ 
		hit_support = this._intersectRaySourceObject (knots_positions[2]) ([0,0,-1])

		--format "HIT_SUPPORT: %\n" hit_support
		--is_on_ground = hit_support == undefined
		--hit_support == undefined
		--format "knots_positions[2].z: %\n" knots_positions[2].z
		pos = copy knots_positions[2] -- copy to avoid modifing of value in array

		if hit_support == undefined then
		(
			/* BASE POINT - ABOVE GROUND */
			pos.z = SUPPORT_OPTIONS.base_height -- set knot above ground to set base height and keep last segment straight for extrude

			knots_positions[3] = copy pos

			/* ADD GROUND POINT */
			pos.z = 0 -- set support_obj to ground

			knots_positions[4] = copy pos
		)
		else /* IF SUPPORT IS INTERSECTING SOURCE OBJECT, THEN ADD POINT TO INETSECTION */
			knots_positions[3] = hit_support.pos
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
		
		
		knots_positions = #(
			getKnotPoint support_obj spline_1 1,
			getKnotPoint support_obj spline_1 second_point
		)
	),

	/** Draw segments support
	 */
	function _createSupportLeg =
	(
		--format "\n"; print "SupportObject_v._createSupportLeg()"
		if knots_positions.count > 1 then
		(
			this._setPivotToSecondPoint()

			this._drawRaftLine()

			if obj_type = #SUPPORT and hit_support == undefined then
				this._drawSupportLine()

			this._setMaterialsToLineSegments()

			updateShape support_obj
		)
	),

	/** Update support leg
	 */
	function _updateSupportLeg =
	(
		--format "\n"; print "SupportObject_v._updateSupportLeg()"
			if update then
				deleteSpline support_obj 1

		ground_knot	= numKnots support_obj spline_1
		base_knot	= ground_knot - 1



		--ground_knot_pos	= getKnotPoint support_obj spline_1 ground_knot
		--base_knot_pos	= getKnotPoint support_obj spline_1 base_knot
		--
		--
		--ground_knot_pos.z	= 0
		--base_knot_pos.z	= SUPPORT_OPTIONS.base_height
		--
		--
		--setKnotPoint support_obj spline_1 ground_knot	ground_knot_pos
		--setKnotPoint support_obj spline_1 base_knot	base_knot_pos
		--
		--updateShape support_obj

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
		for pos in knots_positions do
			addKnot support_obj spline_1 #corner #line pos

		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),

	/** Update line
	 */
	function _updateLine =
	(
		--format "\n"; print "SupportObject_v._updateLine()"
		for knot_i = 1 to knots_positions.count do
			setKnotPoint support_obj spline_1 knot_i	knots_positions[knot_i]
	),

	/** Draw leg line
	 */
	function _drawSupportLine =
	(
		--format "\n"; print "SupportObject_v._drawSupportLine()"
		/*------------------------------------------------------------------------------
			GET POSITION OF SECOND POINT
		--------------------------------------------------------------------------------*/
		pos = copy knots_positions[2] -- copy to avoid modifing of value in array

		/*------------------------------------------------------------------------------
			TEST COLLISION WITH OBJECT on straight down direction
		--------------------------------------------------------------------------------*/
		this.hit_support = this._intersectRaySourceObject pos [0,0,-1]

		it_support == undefined

		/* IF SUPPORT IS GOING TO GROUND */
		if is_on_ground then
		(
			/*------------------------------------------------------------------------------
				POINT ABOVE GROUND - NOT IF RAFT MODE
			--------------------------------------------------------------------------------*/
			pos.z = SUPPORT_OPTIONS.base_height -- set knot above ground to set base height and keep last segment straight for extrude

			addKnot support_obj spline_1 #corner #line pos

			pos.z = 0 -- set support_obj to ground

			/*------------------------------------------------------------------------------
				ADD GROUND POINT
			--------------------------------------------------------------------------------*/
			addKnot support_obj spline_1 #corner #line pos
		)
		else /* IF SUPPORT IS INTERSECTING SOURCE OBJECT, THEN ADD POINT TO INETSECTION */
		(
			--format "hit_support: %\n" hit_support
			--pos.z = hit_support.pos.z -- set knot above ground to set base height and keep last segment straight for extrude

			--addKnot support_obj spline_1 #corner #line pos
			addKnot support_obj spline_1 #corner #line hit_support.pos
		)
	),

	/** Set materials to line segments
	 */
	function _setMaterialsToLineSegments =
	(
		--format "\n"; print "SupportObject_v._setMaterialsToLineSegments()"

		num_of_segments = numSegments support_obj ( numSplines support_obj)

		for segment_i = 1 to num_of_segments do
			setMaterialID support_obj spline_1 segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>

		/*------ SET MATERIAL TO GROUND SEGMENT ------*/
		--if is_on_ground != undefined and is_on_ground then
		if is_on_ground then
			setMaterialID support_obj spline_1 num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
	),

	/** Align to ctor
	 */
	function _alignPivotToSeconPoint =
	(
		--format "\n"; print "SupportObject_v._alignPivotToSeconPoint()"

		--dir = normalize (support_obj.pos - knots_positions[1])
		dir = normalize (knots_positions[1] - support_obj.pos)

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
		support_obj.pivot = knots_positions[2]
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

	/** Reset knots
	 */
	function _resetThisObject =
	(
		this.knots_positions = Array (2)

		this.is_on_ground = false

		this.hit_support = undefined
	),

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
	
	/** Is on ground
	 */
	function _isOnGround =
	(
		--format "\n"; print "SupportObject_v.isOnGround()"
		--is_on_ground = hit_raft == undefined and hit_support == undefined
		new_value = obj_type == #SUPPORT and hit_raft == undefined and hit_support == undefined
		
		if is_on_ground != new_value then
		(
			is_on_ground = new_value
			
			setUserPropVal support_obj "IS_ON_GROUND" is_on_ground
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

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportObject.onCreate()"
		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS		
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
