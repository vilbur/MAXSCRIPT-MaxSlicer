
/** Support leg updater
 */
struct SupportLegUpdater_v
(
	/* construct */
	support_obj,

	foot_mat_id,
	
	/* required */
	/* properties */
	base_height,
	normal_length,
	
	vertical_knots = #(),
	
	direction_is_down   = false,
	direction_is_normal = false,
	has_vertical_points = false,
	not_vertical_points = false,
	
	private


	num_of_knots,
	
	ground_knot,
	base_knot,
	leg_knot,
	
	--bar_width,
	chamfer_val,
	
	--minimal_support_height,
	minimal_foot_pos, -- minimal z position of leg knot where foot can be created, value is varied by angle of support
	minimal_leg_pos,
	
	is_space_for_foot = true,
	foot_just_added = false,
	update_shape = false,
	
	foot_exists,
	
	/* static */
	spline_1 = 1, -- each support line has ony 1 spline
	
	min_height_offset = 0.1, 
	
	/* dependency */
	/* reference */
	/* inhered */

	public
	
	/** Update leg
	  
		1) Test if space for foot exists
		
			A) IF FOOT EXIST - try remove foot
		
			B) IF FOOT NOT EXIST - try add foot

		
		2) UPDATE SUPPORT WITH FOOT 
	
		3) UPDATE SUPPORT WITHOUT FOOT
			
	 */
	function updateLeg =
	(
		--format "\n=======================================================================\n"

		--format "\n"; print "SupportLegUpdater_v.updateLeg()"

		foot_just_added = false
		
		chamfer_val = SUPPORT_OPTIONS.getOption #TOP_WIDTH
			
		this._getNumOfKnots()
		
		this._setVerticalKnots()

		this._setMinimalLegPos()

		base_height   = getUserPropVal support_obj "BASE_HEIGHT"
		normal_length = getUserPropVal support_obj "NORMAL_LENGTH"
		
		has_foot = getUserPropVal support_obj "HAS_FOOT"

		/*==============================================================================
		  
			ADD OR REMOVE FOOT
			
		================================================================================*/

		if has_foot and this.footExists() and this._mustBeFootRemoved() then
			this.removeFoot()
		
		else if not has_foot and not foot_exists and this._canBeFootAdded() then
			this.addFoot()
			

		/*==============================================================================
		  
			UPDATE LEG - IF FOOT WAS NOT ADDED
			
		================================================================================*/

		--updateShape support_obj
		
		if this.footExists() then
			this.updateLegWithFoot()
		
		else
			this.updateLegWithoutFoot()
			
		updateShape support_obj

		this._setPivotToSecondPoint()

		--SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),
	
	
	--private
	
	/** Set minimal leg pos
	 */
	function _setMinimalLegPos =
	(
		--format "\n"; print "SupportLegUpdater_v._setMinimalLegPos()"
		--format "leg_knot: %\n" leg_knot
		minimal_foot_pos = SUPPORT_OPTIONS.base_height + chamfer_val + min_height_offset
		
		/* TUNE MINIMAL FOOT HEIGHT BASED ON ANGLE OF SUPPORT -- to avoid corner artefact on sweep modifier
			
			support - 90°  > remove 90% of bar with
			support - 135° > remove 45% of bar with
			support - 180° > remove 0%  of bar with
		
		*/ 
		
		if direction_is_normal then
		(
			add_by_angle = this.getNimalLenghtByAngle()
			
			minimal_leg_pos = add_by_angle + chamfer_val --+ 0.1
			
			minimal_foot_pos += add_by_angle
		)
		
		
		
		--format "MINIMAL_LEG_POS_Z: %\n" minimal_foot_pos
	),
	
	/** Get nimal lenght by angle
	 */
	function getNimalLenghtByAngle first_knot_pos: second_knot_pos: =
	(
		--format "\n"; print "SupportLegUpdater_v.getNimalLenghtByAngle()"
		
		bar_width = SUPPORT_OPTIONS.getOption #BAR_WIDTH
	
		--angle_point = 2
	
		if first_knot_pos == unsupplied then 
			first_knot_pos  = getKnotPoint support_obj spline_1 1
		
		if second_knot_pos == unsupplied then 
			second_knot_pos = getKnotPoint support_obj spline_1 2

		vector_raft = normalize ( first_knot_pos    - second_knot_pos )
		--vector_leg  = normalize ( bottom_point_pos - second_knot_pos )
		vector_leg = [ 0, 0, -1 ]
		
		angle_alpha = acos (dot vector_raft vector_leg) -- get angle between
		
		--format "angle_alpha: %\n" angle_alpha
		angle_alpha -= 90
		
		bar_width - ( bar_width * (angle_alpha / 100) )
		
	),
	
	/** CHECK IF SPACE FOR FOOT EXISTS
	 */
	function _mustBeFootRemoved =
	(
		--format "\n---------------------------------\n"
		--format "\n"; print "SupportLegUpdater_v._mustBeFootRemoved()"
		--format "direction_is_down: %\n" direction_is_down
		ground_knot_pos = getKnotPoint support_obj spline_1 ground_knot
		base_knot_pos   = getKnotPoint support_obj spline_1 base_knot

		
		/* SUPPORT DIRECTION IS DOWN */
		if direction_is_down then
		(
			/* KEEP LEG KNOT ABOVE BASE KNOT */ 
			if this._getZposition leg_knot < minimal_foot_pos then
				this._setZposition (leg_knot) (minimal_foot_pos )
			
			/* CHECK SPACE ABOVE 2nd KNOT */ 
			if not this._isSpaceForTopChamfer() then
				is_space_for_foot = false
		)
		else
		(
			--format "\nSUPPORT DIRECTION IS NORMAL\n"
			--format "minimal_foot_pos: %\n" minimal_foot_pos
			--format "leg_knot: %\n" leg_knot
			--format "KNOT Z: %\n" (this._getZposition leg_knot)
			must_be_removed = this._getZposition leg_knot <= minimal_foot_pos

			is_space_for_foot = not must_be_removed 
			
		)
		
		not is_space_for_foot --return
	),
	
	/** IFfootOT N EXISTS
	 */
	function _canBeFootAdded =
	(
		--format "\n---------------------------------\n"
		format "\n"; print "SupportLegUpdater_v._canBeFootAdded()"
		--format "\nFOOT NOT EXISTS\n"
		
		/* IF NORMAL DIRCTION SUPPORT  */
		if direction_is_normal then
		(
			--format "num_of_knots: %\n" num_of_knots
			--format "normal_length: %\n" normal_length
			--format "this._getDistanceOfKnots 1 2: %\n" (this._getDistanceOfKnots 1 2)
			point_2_pos = getKnotPoint support_obj spline_1 2
			
			--format "point_2_pos: %\n" point_2_pos
			if num_of_knots == 2 then
			(
				/* IF SUPPORT IS SHORTEN BY GROUND */
				if this._getDistanceOfKnots 1 2 < normal_length then
				(
					point_2_pos_full_length = this._extendSecondPointToNormalLenght()
				
					/* UPDATE 2nd POINT TO NORMAL LENGTH */ 
					if point_2_pos_full_length != undefined and point_2_pos_full_length.z > 0 then
					(
						setKnotPoint support_obj spline_1 2 point_2_pos_full_length
						
						point_2_pos = point_2_pos_full_length
					)
				)
				else
				(
					point_2_pos = this._extendSecondPointToNormalLenght()
						--is_space_for_foot =
					setKnotPoint support_obj spline_1 2 point_2_pos
				)
			)

			is_space_for_foot = point_2_pos.z > minimal_foot_pos
			
		)
		else
			is_space_for_foot = this._getZposition 1 > minimal_foot_pos + chamfer_val

		format "IS_SPACE_FOR_FOOT: %\n" is_space_for_foot
		is_space_for_foot --return
	),

	/** ADfootOOT
	*/
	function addFoot =
	(
		--format "\n"; print "SupportLegUpdater_v.addFoot()"
		--format "\nADD FOOT\n"
		--format "num_of_knots: %\n" num_of_knots
		--format "direction_is_down: %\n" direction_is_down
		--format "VERTICAL_KNOTS: %\n" vertical_knots
		--format "HAS_VERTICAL_POINTS: %\n" has_vertical_points

		/* ADD FOOT TO DOWN DIRCTION */
		if direction_is_down then
		(
			if num_of_knots == 2 then
				this._addBasePoint()
				
			this._addGroundPoint()

			if this._getZposition leg_knot < minimal_foot_pos then
				this._setZposition (leg_knot) (minimal_foot_pos)
			
		)
		else
		(
			if num_of_knots == 2 then
				this._addBasePoint()
			
			this._addGroundPoint()
		)

		setUserPropVal support_obj "HAS_FOOT" true

	 --updateShape support_obj
		
		this._setMaterialToFoot()
	),

	/** UPfootE LEWHEN FOOT EXISTS
	 */
	function updateLegWithFoot =
	(
		--format "\n"; print "SupportLegUpdater_v.updateLegWithFoot()"
		
		if direction_is_down then
		(
			--format "DISTANCE: %\n" (this._getDistanceOfKnots 1 3)
			--format "NORMAL:   %\n" (this._getDistanceOfKnots 1 2)
			--format "normal_length: %\n" normal_length
			
			point_1_pos = getKnotPoint support_obj spline_1 1
			point_2_pos = getKnotPoint support_obj spline_1 2
			
			space_for_normal    = point_1_pos.z - minimal_foot_pos
			is_space_for_normal = space_for_normal > normal_length --+ min_height_offset 
			--format "space_for_normal: %\n" space_for_normal
			
			--format "IS SPACE FOR NORMAL: %\n" is_space_for_normal
			--format "IS NORMAL SHORT: %\n" (this._getDistanceOfKnots 1 2 < normal_length)
			
			
			if is_space_for_normal and this._getDistanceOfKnots 1 2 < normal_length then
			(
				--format "SET NORMAL LENGTH\n"
				
				this._setZposition (2) (point_1_pos.z - normal_length)
			)
			else if not is_space_for_normal then
			(
				--format "UPDATE LEG KNOT\n"

				this._setZposition (2) (minimal_foot_pos)
			)


		)

		
		/* UPDATE BASE POINT */ 
		this._setZposition (base_knot)(base_height)
		
		/* UPDATE GROUND POINT */ 
		this._setLastPointToGround()
	),
	
	/** UPDATE LEG WITHOUT FOOT
	 */
	function updateLegWithoutFoot =
	(
		--format "\n"; print "SupportLegUpdater_v.updateLegWithoutFoot()"
		--format "\nUPDATE FOOT NOT EXISTS\n"
		
		/* UPDATE DOWN DIRCTION */
		if direction_is_down then
		(
			--format "\nUPDATE DOWN DIRECTION\n"
			if this._getZposition ( this._getLastKnot() ) > 0 then
				this._setLastPointToGround()
			else
				this._extendRaftKnotToGound() 
		)
		else /* UPDATE NORMAL DIRECTION */
		(
			--format "\nUPDATE NORMAL DIRECTION\n"
			is_space_for_leg = this._getZposition 2 > minimal_leg_pos
			
			if num_of_knots > 2 then
			(
				/* DELETE 3rd KNOT */ 
				if not is_space_for_leg then
				(
					--this._removeVerticalSegments()
					deleteKnot support_obj spline_1 num_of_knots
	
					this._getNumOfKnots()
					
					this._extendRaftKnotToGound()
				)
				else /* UPDATE 3rd KNOT */ 
					this._setLastPointToGround()
			)
			else
			(
				/* ADD 3rd KNOT */ 
				if is_space_for_leg then
					this._addGroundPoint()
					
				else  /* UPDATE 3rd KNOT */ 
					this._extendRaftKnotToGound()
			)
		)
	),
		
	/*------------------------------------------------------------------------------
	  
		HELPERS
		
	--------------------------------------------------------------------------------*/
	
	/** Test if foot exist - lat foot line segment has mat ID 4
	 */
	function footExists =
	(
		--format "\n"; print "SupportLegUpdater_v.footExists()"
		num_of_segments = numSegments support_obj spline_1
		--format "num_of_segments: %\n" num_of_segments
		foot_exists = getMaterialID support_obj spline_1 num_of_segments == 4
		--format "FOOT_EXISTS: %\n" foot_exists
		foot_exists --returnw
	),

	/** Remove foot by deleting last knot of spline
	 */
	function removeFoot =
	(
		format "\n"; print "SupportLegUpdater_v.removeFoot()"
		--format "\nREMOVE FOOT\n"
		--format "direction_is_down: %\n" direction_is_down

		/* DELETE GROUND POINT */ 
		deleteKnot support_obj spline_1 ( numKnots support_obj spline_1)
		
		--updateShape support_obj

		this._getNumOfKnots()
		
		/*  */
		if direction_is_down and num_of_knots > 2 then
			for knot = 2 to num_of_knots - 1 do 
				deleteKnot support_obj spline_1 knot
				
		--this._getNumOfKnots()
		setUserPropVal support_obj "HAS_FOOT" false

		--this.updateLegWithoutFoot()
		--update_shape = true
	),
	
	/** Is space for leg
	 */
	function _isSpaceForFoot knot =
	(
		--format "\n"; print "SupportLegUpdater_v._isSpaceForFoot()"
		--format "minimal_foot_pos: %\n" minimal_foot_pos
		--format "is_space_for_leg: %\n" (this._getZposition knot > minimal_foot_pos)

		this._getZposition knot > minimal_foot_pos
	),

	/** Isfootace r top chamfer
	 */
	function _isSpaceForTopChamfer =
	(
		--format "\n"; print "SupportLegUpdater_v._isSpaceForTopChamfer()"
		this._getNumOfKnots()
		
		
		leg_knot    = num_of_knots - 2

		leg_knot_pos     =  getKnotPoint support_obj spline_1 leg_knot
		support_knot_pos =  getKnotPoint support_obj spline_1 (leg_knot - 1)

		distance support_knot_pos leg_knot_pos > chamfer_val-- + 0.1
	),

	/** Get vertical knots
	 */
	function _setVerticalKnots =
	(
		--format "\n"; print "SupportLegUpdater_v._setVerticalKnots()"
		/** Support is vertical
		 */
		function supportIsVertical knot =
		(
			--format "\n"; print "SupportLegUpdater_v.supportIsVertical()"
			lower_knot_pos = getKnotPoint support_obj spline_1 knot
			upper_knot_pos = getKnotPoint support_obj spline_1 (knot - 1)

			support_is_vertical = close_enough lower_knot_pos.x upper_knot_pos.x 1000 and close_enough lower_knot_pos.y upper_knot_pos.y 1000

			support_is_vertical --return
		)
		
		vertical_knots = #()

		
		for knot = num_of_knots to 2 by -1 while supportIsVertical(knot) do
		(
			appendIfUnique vertical_knots knot
			
			appendIfUnique vertical_knots (knot - 1)
		)
		
		--format "VERTICAL_KNOTS: %\n" vertical_knots
		--format "num_of_knots: %\n" num_of_knots

		
		this.direction_is_down   = vertical_knots.count == num_of_knots
		
		this.direction_is_normal = not this.direction_is_down
		
		this.has_vertical_points = vertical_knots.count > 0
		
		this.not_vertical_points = not this.has_vertical_points
		
		/* REMOVE FIRST KNOT OF SUPPORT - point where support starts */ 
		if ( first_support_point = findItem vertical_knots 1 ) > 0 then
			deleteItem vertical_knots first_support_point
		
	),
	
	/** Remove vertical knot indexes higher then number of knots
	 */
	function _updateVerticalKnots =
	(
		--format "\n"; print "SupportLegUpdater_v._updateVerticalKnots()"
		num_knots = numKnots support_obj spline_1
		
		for i = vertical_knots.count to 1 by -1 where vertical_knots[i] > num_knots do
			deleteItem vertical_knots i
	),
	
	/** Set knot ground
	 */
	function _setLastPointToGround =
	(
		--format "\n"; print "SupportLegUpdater_v.setKnotGround()"
		ground_knot     = numKnots support_obj spline_1
		ground_knot_pos = getKnotPoint support_obj spline_1 ground_knot
		
		ground_knot_pos.z = 0
		
		
		setKnotPoint support_obj spline_1 ground_knot ground_knot_pos
	),
	
	/** Set zposition
	 */
	function _setZposition knot pos_z =
	(
		--format "\n"; print "SupportLegUpdater_v._setZposition()"
		--format "KNOT: % POS_Z: %\n" knot pos_z
				
		knot_pos = getKnotPoint support_obj spline_1 knot
		
		knot_pos.z = pos_z
		
		setKnotPoint support_obj spline_1 knot knot_pos
	),
	
	/** Get zposition
	 */
	function _getZposition knot =
	(
		--format "\n"; print "SupportLegUpdater_v._getZposition()"
		knot_pos = getKnotPoint support_obj spline_1 knot
		--format "KNOT: % POS: %\n" knot knot_pos
		--format "Z_POS: %\n" knot_pos.z
		knot_pos.z --return
	),
	
	/** Extend raft knot to normal lenght
	  * 
	  * @return point3 coordinates of point extended to normal length
	 */
	function _extendSecondPointToNormalLenght =
	(
		format "\n"; print "SupportLegUpdater_v._extendSecondPointToNormalLenght()"
		
		point_1_pos = getKnotPoint support_obj spline_1 1
		point_2_pos = getKnotPoint support_obj spline_1 2

		line_vector = normalize ( point_2_pos - point_1_pos )
		
		point_1_pos + ( normal_length * line_vector ) -- return
	),
	
	/** Extend second point to gound
	 */
	function _extendRaftKnotToGound =
	(
		--format "\n"; print "SupportLegUpdater_v._extendRaftKnotToGound()"
		first_knot_pos  = getKnotPoint support_obj spline_1 1
		second_knot_pos = getKnotPoint support_obj spline_1 2
		
		height_pos_1 = first_knot_pos.z
		
		line_vector = normalize ( first_knot_pos - second_knot_pos )

		angle_vectors = acos (dot [0,0,-1] line_vector) -- get angle between
		
		line_length = height_pos_1 / cos angle_vectors
		
		second_knot_pos = first_knot_pos + ( line_length * line_vector )
		
		setKnotPoint support_obj spline_1 2 second_knot_pos
	),
	
	/** Delete vertical points bellow minimal space
	 */
	function _deleteVerticalPointsBellowMinimalSpace minimal_z_pos =
	(
		--format "\n"; print "SupportLegUpdater_v._deleteVerticalPointsBellowMinimalSpace()"
		--format "minimal_z_pos: %\n" minimal_z_pos
		

		--for index = 1 to vertical_knots.count - 1 where ( knot = vertical_knots[index] ) != 1 and this._getZposition knot < minimal_z_pos do 
			--deleteKnot support_obj spline_1 knot
			
		for index = 2 to vertical_knots.count - 1 do 
		(
			knot = vertical_knots[index]
			
			knot_pos_z = this._getZposition knot
			
			--format "TEST: %\n" (knot_pos_z < minimal_z_pos)
			
			if knot_pos_z < minimal_z_pos then
				deleteKnot support_obj spline_1 knot
		)
		
	),
	
	/** Remove vertical segments
	 */
	function _removeVerticalSegments =
	(
		--format "\n"; print "SupportLegUpdater_v._removeVerticalSegments()"
		--format "VERTICAL_KNOTS: %\n" vertical_knots
		--format "NUM KNOTS: %\n" (numKnots support_obj spline_1)
		--format "\n"; print "SupportLegUpdater_v. REMOVE_VERTICAL_SEGMENTS ()"
		
		for index = 1 to vertical_knots.count - 1 do 
			deleteKnot support_obj spline_1 vertical_knots[index]
			
		this._getNumOfKnots()
	),
	
	/** Add base point
	  */
	function _addBasePoint =
	(
		--format "\n"; print "SupportLegUpdater_v._addBasePoint()"
		this._addPoint (base_height)
	),
	
	/** Add ground point
	  */
	function _addGroundPoint =
	(
		--format "\n"; print "SupportLegUpdater_v._addGroundPoint()"
		this._addPoint (0)
	),
	
	/** Add point on same coordinates but diferent Z axis
	 */
	function _addPoint z_pos =
	(
		--format "\n"; print "SupportLegUpdater_v.addPoint()"
		knot_pos  = getKnotPoint support_obj spline_1 ( this._getLastKnot() )

		knot_pos.z  = z_pos

		addKnot support_obj spline_1 #corner #line knot_pos
		
		this._getNumOfKnots()
	),
	
	/** Get last knot
	 */
	function _getLastKnot =
	(
		numKnots support_obj spline_1
	),
	
	/** Get top vertical knot
	 */
	function _getTopVerticalKnot =
	(
		--format "\n"; print "SupportLegUpdater_v._getTopVerticalKnot()"
		--format "VERTICAL_KNOTS: %\n" vertical_knots
		vertical_knots[vertical_knots.count]
	),
	
	/** Get zposition by normal
	 */
	function _getZpositionByNormal normal_length =
	(
		--format "\n"; print "SupportLegUpdater_v._getZpositionByNormal()"
		--format "GET FOOT SPACE\n"
		
		--first_knot_pos  = getKnotPoint support_obj spline_1 1
		--second_knot_pos = getKnotPoint support_obj spline_1 2
		--
		--line_vector = normalize ( second_knot_pos - first_knot_pos )
		--
		--angle_alpha = acos (dot [0,0,-1] line_vector) -- get angle between
		--angle_beta  = 90 - angle_alpha

		--line_length = normal_length * sin angle_beta
		line_length = this.getNimalLenghtByAngle()

		first_knot_pos.z - line_length
	),
		
		
	/**  set material to foot
	 */
	function _setMaterialToFoot =
	(
		--format "\n"; print "SupportLegUpdater_v._setMaterialToFoot()"
		
		num_of_segments = numSegments support_obj spline_1
		
		for segment_i = 1 to num_of_segments - 1 do
			setMaterialID support_obj spline_1 segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
		
		setMaterialID support_obj spline_1 num_of_segments this.foot_mat_id
	),
	
	/** Set pivot to position
	 */
	function _setPivotToSecondPoint =
	(
		--format "\n"; print "SupportLegUpdater_v._setPivotToSecondPoint()"
		support_obj.pivot = getKnotPoint support_obj spline_1 2
	),
	
	/** Get distance of knots
	 */
	function _getDistanceOfKnots knot_A knot_B =
	(
		--format "\n"; print "SupportLegUpdater_v._getDistanceOfKnots()"
		point_1_pos = getKnotPoint support_obj spline_1 knot_A
		point_2_pos = getKnotPoint support_obj spline_1 knot_B
		
		distance point_1_pos point_2_pos
	),
	
	/** Get num of knots
	 */
	function _getNumOfKnots =
	(
		--format "\n"; print "SupportLegUpdater_v._getNumOfKnots()"
		num_of_knots = numKnots support_obj spline_1
		
        ground_knot	= num_of_knots
        base_knot	   = num_of_knots - 1
        leg_knot	   = num_of_knots - 2

		this._updateVerticalKnots()

		num_of_knots --return
	),


	/**
	 */
	on create do
	(
		--format "\n"; print "SupportLegUpdater.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)
)
