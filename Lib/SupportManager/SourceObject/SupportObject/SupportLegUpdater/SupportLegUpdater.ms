
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

	spline_1 = 1, -- each support line has ony 1 spline

	num_of_knots,
	
	ground_knot,
	base_knot,
	leg_knot,
	
	--bar_width,
	chamfer_val,
	
	--minimal_support_height,
	minimal_leg_pos_z,
	
	is_space_for_foot = true,
	foot_just_added = false,
	update_shape = false,
	
	foot_exists,
	
	/* private */
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

		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--format "\n"; print "SupportLegUpdater_v.updateLeg()"
		--SUPPORT_MANAGER.updateShapeAdd (support_obj)

		foot_just_added = false
		
		chamfer_val = SUPPORT_OPTIONS.getOption #TOP_WIDTH
			
		--minimal_support_height = minimal_leg_pos_z + chamfer_val

		
		this._getNumOfKnots()
		
		this._setVerticalKnots()

		this._setMinimalLegPos()

		base_height   = getUserPropVal support_obj "BASE_HEIGHT"
		normal_length = getUserPropVal support_obj "NORMAL_LENGTH"
		
		--format "VERTICAL_KNOTS: %\n" vertical_knots

		/*==============================================================================
		  
			ADD OR REMOVE FOOT
			
		================================================================================*/

		if this._footExists() and this._mustBeFootRemoved() then
			this._removeFoot()
		
		else if not foot_exists and this._canBeFootAdded() then
			this._addFoot()
		
		/*==============================================================================
		  
			UPDATE LEG - IF FOOT WAS NOT ADDED
			
		================================================================================*/

		--updateShape support_obj
		
		if this._footExists() then
			this._updateLegWithFoot()
		
		else
			this._updateLegWithoutFoot()
			
		updateShape support_obj

		this._setPivotToSecondPoint()
		--SUPPORT_MANAGER.updateShapeAdd (support_obj)

	),
	
	
	private
	
	/** Set minimal leg pos
	 */
	function _setMinimalLegPos =
	(
		--format "\n"; print "SupportLegUpdater_v._setMinimalLegPos()"
		--format "leg_knot: %\n" leg_knot
		minimal_leg_pos_z = SUPPORT_OPTIONS.base_height + chamfer_val + 0.1
		
		/* TUNE MINIMAL FOOT HEIGHT BASED ON ANGLE OF SUPPORT -- to avoid corner artefact on sweep modifier
			
			support - 90°  > remove 90% of bar with
			support - 135° > remove 45% of bar with
			support - 180° > remove 0%  of bar with
		
		*/ 
		
		if direction_is_normal and num_of_knots > 2 then
		(
			bar_width = SUPPORT_OPTIONS.getOption #BAR_WIDTH
		
			angle_point = 2
		
			top_point_pos    =  getKnotPoint support_obj spline_1 (angle_point - 1)
			angle_point_pos  =  getKnotPoint support_obj spline_1  angle_point
			bottom_point_pos =  getKnotPoint support_obj spline_1 (angle_point + 1)

			vector_raft = normalize ( top_point_pos    - angle_point_pos )
			vector_leg  = normalize ( bottom_point_pos - angle_point_pos )
			
			angle_alpha = acos (dot vector_raft vector_leg) -- get angle between
			
			format "angle_alpha: %\n" angle_alpha
			angle_alpha -= 90
			minimal_leg_pos_z += bar_width - ( bar_width * (angle_alpha / 100) )
		)
		
		format "MINIMAL_LEG_POS_Z: %\n" minimal_leg_pos_z
	),
	
	/** IF FOOT EXISTS
	 */
	function _mustBeFootRemoved =
	(
		--format "\n---------------------------------\n"
		--format "\n"; print "SupportLegUpdater_v._mustBeFootRemoved()"

		ground_knot_pos	= getKnotPoint support_obj spline_1 ground_knot
		base_knot_pos	= getKnotPoint support_obj spline_1 base_knot
		
		--is_space_for_foot = true
		
		----/* KEEP LEG POINT ABOVE FOOT */
		--if direction_is_down and leg_knot < num_of_knots then
		if direction_is_down then
		(
			--format "\nSUPPORT DIRECTION IS DOWN\n"

			/* KEEP LEG KNOT ABOVE FOOT KNOT */ 
			if this._getZposition leg_knot < minimal_leg_pos_z then
				this._setZposition (leg_knot) (minimal_leg_pos_z )
			
			--format "is_space_for_foot A: %\n" is_space_for_foot

			if not this._isSpaceForTopChamfer() then
				is_space_for_foot = false
			--format "is_space_for_foot B: %\n" is_space_for_foot
			
			--if is_space_for_foot then
				--is_space_for_foot = this._getZposition leg_knot > minimal_leg_pos_z
			
			--format "IS_SPACE_FOR_FOOT C: %\n" is_space_for_foot
		)
		else
		(
			--format "\nSUPPORT DIRECTION IS NORMAL\n"

			must_be_removed = this._getZposition leg_knot <= minimal_leg_pos_z

			is_space_for_foot = not must_be_removed 
			
		)
		
		not is_space_for_foot --return
	),
	
	/** IF FOOT NOT EXISTS
	 */
	function _canBeFootAdded =
	(
		--format "\n---------------------------------\n"
		--format "\n"; print "SupportLegUpdater_v._canBeFootAdded()"
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
						--format "\nSET TO NORMAL LENGTH\n"
		
						setKnotPoint support_obj spline_1 2 point_2_pos_full_length
						
						point_2_pos = point_2_pos_full_length
					)
					

				)
				--else
				--(
				--	
				--	if not this._isSpaceForLeg(2) then
				--		is_space_for_foot = 
				--	
				--)
				
			)
			
			is_space_for_foot = point_2_pos.z > minimal_leg_pos_z
			
		)
		else
			is_space_for_foot = this._getZposition 1 > minimal_leg_pos_z + chamfer_val

		--format "IS_SPACE_FOR_FOOT: %\n" is_space_for_foot
		is_space_for_foot --return
	),

	/** Add foot
	 */
	function _addFoot =
	(
		--format "\n"; print "SupportLegUpdater_v._addFoot()"
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

			if this._getZposition leg_knot < minimal_leg_pos_z then
				this._setZposition (leg_knot) (minimal_leg_pos_z )
			
		)
		else
		(
			if num_of_knots == 2 then
				this._addBasePoint()
			
			this._addGroundPoint()
		)
				
		
		--updateShape support_obj
		
		this._setMaterialToFoot()
	),

	/** UPDATE LEG WHEN FOOT EXISTS
	 */
	function _updateLegWithFoot =
	(
		--format "\n"; print "SupportLegUpdater_v._updateLegWithFoot()"
		/* UPDATE BASE POINT */ 
		this._setZposition (base_knot)(base_height)
		
		/* UPDATE GROUND POINT */ 
		this._setLastPointToGround()
	),
	
	/** UPDATE LEG WITHOUT FOOT
	 */
	function _updateLegWithoutFoot =
	(
		--format "\n"; print "SupportLegUpdater_v._updateLegWithoutFoot()"
		--format "\nUPDATE FOOT NOT EXISTS\n"
		
		/* UPDATE DOWN DIRCTION */
		if direction_is_down then
		(
			--format "\nUPDATE DOWN DIRECTION\n"
			--updateShape support_obj
			--format "vertical_knots: %\n" vertical_knots
			
			if this._getZposition ( this._getLastKnot() ) > 0 then
			--if num_of_knots > 2 and this._isSpaceForLeg( vertical_knots[vertical_knots.count] ) then
				this._setLastPointToGround()
				--this._addGroundPoint()
			--else if num_of_knots == 2 then
			else
				this._extendRaftKnotToGound()
		)
		else /* UPDATE NORMAL DIRECTION */
		(
			--format "\nUPDATE NORMAL DIRECTION\n"

			--format "num_of_knots: %\n" num_of_knots
			--format "this._isSpaceForLeg(2): %\n" (this._isSpaceForLeg(2))
		--updateShape support_obj

            /* EXTEND 2nd POINT TO GROUND */ 			
			--if vertical_knots.count >= 2 and not this._isSpaceForLeg( this._getTopVerticalKnot() ) then
			
			--if num_of_knots > 2 and not this._isSpaceForLeg(2) then
				--this._removeVerticalSegments()

			
			if num_of_knots == 2 then
				this._extendRaftKnotToGound()

			else /* SET 2nd POINT TO GROUND - if support has vertical ponts */ 
				this._setLastPointToGround()
			
		)
	),
		
	/*------------------------------------------------------------------------------
	  
		HELPERS
		
	--------------------------------------------------------------------------------*/
	
	/** Test if foot exist - lat foot line segment has mat ID 4
	 */
	function _footExists =
	(
		--format "\n"; print "SupportLegUpdater_v._footExists()"
		num_of_segments = numSegments support_obj spline_1
		--format "num_of_segments: %\n" num_of_segments
		foot_exists = getMaterialID support_obj spline_1 num_of_segments == 4
		--format "FOOT_EXISTS: %\n" foot_exists
		foot_exists --returnw
	),

	/** Remove foot by deleting last knot of spline
	 */
	function _removeFoot =
	(
		--format "\n"; print "SupportLegUpdater_v._removeFoot()"
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

		--this._updateLegWithoutFoot()
		--update_shape = true
	),
	
	/** Is space for leg
	 */
	function _isSpaceForLeg knot =
	(
		--format "\n"; print "SupportLegUpdater_v._isSpaceForLeg()"
		--format "minimal_leg_pos_z: %\n" minimal_leg_pos_z
		--format "is_space_for_leg: %\n" (this._getZposition knot > minimal_leg_pos_z)

		this._getZposition knot > minimal_leg_pos_z
		--this._getZposition knot > 0
	),

	/** Is space for top chamfer
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
			
			knot_pos       = getKnotPoint support_obj spline_1 knot
			upper_knot_pos = getKnotPoint support_obj spline_1 (knot - 1)
			
			support_is_vertical = close_enough knot_pos.x upper_knot_pos.x 1000 and close_enough knot_pos.x upper_knot_pos.x 1000

			support_is_vertical --return
		)
		
		vertical_knots = #()

		
		for knot = num_of_knots to 2 by -1 while supportIsVertical(knot) do
		(
			appendIfUnique vertical_knots knot
			
			appendIfUnique vertical_knots (knot - 1)
		)
		
		
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
		--format "\n"; print "SupportLegUpdater_v._extendSecondPointToNormalLenght()"
					
		line_vector = normalize ( 1 - 2 )
		
		knot_1_pos + ( normal_length * line_vector ) -- return
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
		
		first_knot_pos  = getKnotPoint support_obj spline_1 1
		second_knot_pos = getKnotPoint support_obj spline_1 2
		
		line_vector = normalize ( second_knot_pos - first_knot_pos )

		angle_alpha = acos (dot [0,0,-1] line_vector) -- get angle between
		angle_beta  = 90 - angle_alpha

		line_length = normal_length * sin angle_beta

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
