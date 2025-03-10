
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
	
	direction_is_down = false,
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
		format "\n=======================================================================\n"

		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		format "\n"; print "SupportLegUpdater_v.updateLeg()"
		SUPPORT_MANAGER.updateShapeAdd (support_obj)

		foot_just_added = false
		
		chamfer_val = SUPPORT_OPTIONS.getOption #TOP_WIDTH
			
			
		--minimal_leg_pos_z = SUPPORT_OPTIONS.base_height + chamfer_val
		minimal_leg_pos_z = SUPPORT_OPTIONS.base_height + chamfer_val
		--minimal_leg_pos_z *= 2
		minimal_support_height = minimal_leg_pos_z + chamfer_val

		this._getNumOfKnots()
		

		ground_knot	= num_of_knots
		base_knot	= num_of_knots - 1
		leg_knot    = num_of_knots - 2
		


		base_height   = getUserPropVal support_obj "BASE_HEIGHT"
		normal_length = getUserPropVal support_obj "NORMAL_LENGTH"
		
		this._setVerticalKnots()
		format "VERTICAL_KNOTS: %\n" vertical_knots

		/*==============================================================================
		  
			ADD OR REMOVE FOOT
			
		================================================================================*/

		if this._footExists() and this._mustBeFootRemoved() then
			this._removeFoot()
		
		else if not foot_exists and this._canBeFootAdded() then
			this._addFoot()
		
		--else if not foot_exists  then
		--	this._updateLegWithoutFoot()
		--	
		--else
		--	this._updateLegWithFoot()

		format "IS_SPACE_FOR_FOOT: %\n" is_space_for_foot
		
		/*==============================================================================
		  
			UPDATE LEG - IF FOOT WAS NOT ADDED
			
		================================================================================*/

		--this._setVerticalKnots()
		
		--if this._footExists() and not foot_just_added then
		
			updateShape support_obj
		
		if this._footExists() then
			this._updateLegWithFoot()
		
		else
			this._updateLegWithoutFoot()
			
		--	updateShape support_obj

		--
		--SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),
	
	
	private
	
	/** IF FOOT EXISTS
	 */
	function _mustBeFootRemoved =
	(
		format "\n---------------------------------\n"
		format "\n"; print "SupportLegUpdater_v._mustBeFootRemoved()"

		ground_knot_pos	= getKnotPoint support_obj spline_1 ground_knot
		base_knot_pos	= getKnotPoint support_obj spline_1 base_knot
		
		--is_space_for_foot = true
		
		----/* KEEP LEG POINT ABOVE FOOT */
		--if direction_is_down and leg_knot < num_of_knots then
		if direction_is_down then
		(
			format "\nSUPPORT DIRECTION IS DOWN\n"

			/* KEEP LEG KNOT ABOVE FOOT KNOT */ 
			if this._getZposition leg_knot < minimal_leg_pos_z then
				this._setZposition (leg_knot) (minimal_leg_pos_z + 0.1 )
			

			format "is_space_for_foot A: %\n" is_space_for_foot
			if not this._isSpaceForTopChamfer() then
				is_space_for_foot = false
			
			format "is_space_for_foot B: %\n" is_space_for_foot
			if is_space_for_foot then
				is_space_for_foot = this._getZposition leg_knot > minimal_leg_pos_z
			
			format "IS_SPACE_FOR_FOOT C: %\n" is_space_for_foot
		)
		else
		(
			format "\nSUPPORT DIRECTION IS NORMAL\n"
			bar_width = SUPPORT_OPTIONS.getOption #BAR_WIDTH

			--if leg_knot > 1 then
			--(
				/* TUNE MINIMAL FOOT HEIGHT BASED ON ANGLE OF SUPPORT -- to avoid corner artefact on sweep modifier
					
					support - 90°  > remove 90% of bar with
					support - 135° > remove 45% of bar with
					support - 180° > remove 0%  of bar with
				
				*/ 
				leg_knot_pos =  getKnotPoint support_obj spline_1 leg_knot
				prev_knot_pos =  getKnotPoint support_obj spline_1 (leg_knot - 1)
				
				vector_raft = normalize ( prev_knot_pos - leg_knot_pos )
				vector_leg  = normalize ( base_knot_pos - leg_knot_pos )
				
				angle_alpha = acos (dot vector_raft vector_leg) -- get angle between
				
				angle_alpha -= 90
				
				minimal_leg_pos_z += bar_width - ( bar_width * (angle_alpha / 100) )
			--)

			is_space_for_foot = this._getZposition leg_knot > minimal_leg_pos_z

		)
		
		not is_space_for_foot --return
	),
	
	/** IF FOOT NOT EXISTS
	 */
	function _canBeFootAdded =
	(
		format "\n---------------------------------\n"
		format "\n"; print "SupportLegUpdater_v._canBeFootAdded()"

		format "\nFOOT NOT EXISTS\n"
		
		/* IF SKEWED SUPPORT  */
		if not direction_is_down then
		(
			
			point_1_pos = getKnotPoint support_obj spline_1 1
			point_2_pos = getKnotPoint support_obj spline_1 2
			
			distance_of_points = distance point_1_pos point_2_pos
			--format "distance_of_points: %\n" distance_of_points
			
		
			/* IF SUPPORT IS SHORTEN BY GROUND */
			if not close_enough distance_of_points normal_length 10000 then
			(
				format "\nNORMAL IS NOT FULL\n"
				
				point_2_pos_full_length = this._extendRaftKnotToNormalLenght(point_1_pos)(point_2_pos)
			)
			
			/* UPDATE 2nd POINT TO NORMAL LENGTH */ 
			if point_2_pos_full_length != undefined and point_2_pos_full_length.z > 0 then
			(
				format "\nSET TO NORMAL LENGTH\n"

				setKnotPoint support_obj spline_1 2 point_2_pos_full_length
				
				point_2_pos = point_2_pos_full_length
			)
			
			is_space_for_foot = point_2_pos.z > minimal_leg_pos_z
		)
		else
			is_space_for_foot = this._getZposition 1 > minimal_leg_pos_z + chamfer_val

		format "IS_SPACE_FOR_FOOT: %\n" is_space_for_foot
		is_space_for_foot --return
	),

	/** UPDATE LEG WHEN FOOT EXISTS
	 */
	function _updateLegWithFoot =
	(
		format "\n"; print "SupportLegUpdater_v._updateLegWithFoot()"
		/* UPDATE BASE POINT */ 
		this._setZposition (base_knot)(base_height)
		
		/* UPDATE GROUND POINT */ 
		this._setLastPointToGround()
	),
	
	/** Add foot
	 */
	function _addFoot =
	(
		format "\n"; print "SupportLegUpdater_v._addFoot()"
		format "\nADD FOOT\n"
		--format "VERTICAL_KNOTS: %\n" vertical_knots
		--format "HAS_VERTICAL_POINTS: %\n" has_vertical_points

		/* SET FOOT TO VERTICAL SUPPORT */
		if direction_is_down then
		(
			if this._getNumOfKnots() == 2 then
				this._addBasePoint()
				
		)
		
		/* ADD FOOT TO SKEWED SUPPORT */
		else
			this._addBasePoint()
				
				
		if this._getZposition leg_knot < minimal_leg_pos_z then
			this._setZposition (leg_knot) (minimal_leg_pos_z + 0.1 )
				

		this._addGroundPoint()
		
		
		updateShape support_obj
		
		this._setMaterialToFoot()
	),
	
	/** UPDATE LEG WITHOUT FOOT
	 */
	function _updateLegWithoutFoot =
	(
		format "\n"; print "SupportLegUpdater_v._updateLegWithoutFoot()"
		format "\nUPDATE FOOT NOT EXISTS\n"
		
		/* UPDATE VERTICAL SUPPORT */
		if direction_is_down then
		(
			format "\nUPDATE VERTICAL SUPPORT\n"
			

			if not this._isSpaceForLeg( this._getTopVerticalKnot() ) then
			(
				if numKnots support_obj spline_1 > 2 then
					this._removeVerticalSegments()
				
				this._extendRaftKnotToGound()
			)
			else
				this._setLastPointToGround()
			
		)
		/* UPDATE SUPPORT WITHOUT VERTICAL POINTS */
		else
		(
			format "\nUPDATE SUPPORT WITHOUT VERTICAL POINTS\n"
			--updateShape support_obj

			if this._isSpaceForLeg( this._getLastKnot() ) then
				this._addGroundPoint()
			else
				this._extendRaftKnotToGound()
		)
	),
	
	/*------------------------------------------------------------------------------
	  
		HELPERS
		
	--------------------------------------------------------------------------------*/
	
	/** Test if foot exist - lat foot line segment has mat ID 4
	 */
	function _footExists =
	(
		format "\n"; print "SupportLegUpdater_v._footExists()"
		num_of_segments = numSegments support_obj spline_1
		--format "num_of_segments: %\n" num_of_segments
		foot_exists = getMaterialID support_obj spline_1 num_of_segments == 4
		format "FOOT_EXISTS: %\n" foot_exists
		foot_exists --return
	),

	/** Remove foot by deleting last knot of spline
	 */
	function _removeFoot =
	(
		format "\n"; print "SupportLegUpdater_v._removeFoot()"
		format "\nREMOVE FOOT\n"

		/* DELETE GROUND POINT */ 
		deleteKnot support_obj spline_1 ( numKnots support_obj spline_1)
		
		num_of_knots = numKnots support_obj spline_1

		if direction_is_down and num_of_knots > 2 then
			for knot = 2 to num_of_knots - 1 do 
				deleteKnot support_obj spline_1 knot
		
		--this._updateLegWithoutFoot()
		--update_shape = true
	),
	
	/** Is space for leg
	 */
	function _isSpaceForLeg knot =
	(
		format "\n"; print "SupportLegUpdater_v._isSpaceForLeg()"

		this._getZposition knot > minimal_leg_pos_z
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

		distance support_knot_pos leg_knot_pos > chamfer_val
	),

	/** Get vertical knots
	 */
	function _setVerticalKnots =
	(
		--format "\n"; print "SupportObject_v._setVerticalKnots()"
		/** Support is vertical
		 */
		function supportIsVertical knot =
		(
			--format "\n"; print "SupportObject_v.supportIsVertical()"
			
			knot_pos       = getKnotPoint support_obj spline_1 knot
			upper_knot_pos = getKnotPoint support_obj spline_1 (knot - 1)
			
			support_is_vertical = close_enough knot_pos.x upper_knot_pos.x 1000 and close_enough knot_pos.x upper_knot_pos.x 1000

			support_is_vertical --return
		)
		
		vertical_knots = #()

		
		for knot = ( numKnots support_obj spline_1 ) to 2 by -1 while supportIsVertical(knot) do
		(
			appendIfUnique vertical_knots knot
			
			appendIfUnique vertical_knots (knot - 1)
		)
		
		
		this.direction_is_down = vertical_knots.count == numKnots support_obj spline_1
		
		this.has_vertical_points = vertical_knots.count > 0
		
		this.not_vertical_points = not this.has_vertical_points
		
		/* REMOVE FIRST KNOT OF SUPPORT - point where support starts */ 
		if ( first_support_point = findItem vertical_knots 1 ) > 0 then
			deleteItem vertical_knots first_support_point
		
	),
	
	--/** Remove vertical knot indexes higher then number of knots
	-- */
	--function _updateVerticalKnots =
	--(
	--	--format "\n"; print "SupportLegUpdater_v._updateVerticalKnots()"
	--	num_knots = numKnots support_obj spline_1
	--	
	--	for i = vertical_knots.count to 1 by -1 where vertical_knots[i] > num_knots do
	--		deleteItem vertical_knots i
	--),
	
	/** Set knot ground
	 */
	function _setLastPointToGround =
	(
		--format "\n"; print "SupportObject_v.setKnotGround()"
		ground_knot     = numKnots support_obj spline_1
		ground_knot_pos = getKnotPoint support_obj spline_1 ground_knot
		
		ground_knot_pos.z = 0
		
		
		setKnotPoint support_obj spline_1 ground_knot ground_knot_pos
	),
	
	/** Set zposition
	 */
	function _setZposition knot pos_z =
	(
		format "\n"; print "SupportObject_v._setZposition()"
		format "KNOT: % POS_Z: %\n" knot pos_z
				
		knot_pos = getKnotPoint support_obj spline_1 knot
		
		knot_pos.z = pos_z
		
		setKnotPoint support_obj spline_1 knot knot_pos
	),
	
	/** Get zposition
	 */
	function _getZposition knot =
	(
		--format "\n"; print "SupportObject_v._getZposition()"
		knot_pos = getKnotPoint support_obj spline_1 knot
		--format "KNOT: % POS: %\n" knot knot_pos
		--format "Z_POS: %\n" knot_pos.z
		knot_pos.z --return
	),
	
	/** Extend raft knot to normal lenght
	  * 
	  * @return point3 coordinates of point extended to normal length
	 */
	function _extendRaftKnotToNormalLenght knot_1_pos knot_2_pos =
	(
		--format "\n"; print "SupportObject_v._extendRaftKnotToNormalLenght()"
					
		line_vector = normalize ( knot_2_pos - knot_1_pos)
		
		knot_1_pos + ( normal_length * line_vector ) -- return
	),
	
	/** Extend second point to gound
	 */
	function _extendRaftKnotToGound =
	(
		format "\n"; print "SupportObject_v._extendRaftKnotToGound()"
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
		--format "\n"; print "SupportObject_v._deleteVerticalPointsBellowMinimalSpace()"
		--format "minimal_z_pos: %\n" minimal_z_pos
		

		--for index = 1 to vertical_knots.count - 1 where ( knot = vertical_knots[index] ) != 1 and this._getZposition knot < minimal_z_pos do 
			--deleteKnot support_obj spline_1 knot
			
		for index = 2 to vertical_knots.count - 1 do 
		(
			knot = vertical_knots[index]
			
			knot_pos_z = this._getZposition knot
			
			format "TEST: %\n" (knot_pos_z < minimal_z_pos)
			
			if knot_pos_z < minimal_z_pos then
				deleteKnot support_obj spline_1 knot
		)
		
	),
	
	/** Remove vertical segments
	 */
	function _removeVerticalSegments =
	(
		format "\n"; print "SupportLegUpdater_v._removeVerticalSegments()"
		--format "VERTICAL_KNOTS: %\n" vertical_knots
		--format "NUM KNOTS: %\n" (numKnots support_obj spline_1)
		--format "\n"; print "SupportLegUpdater_v. REMOVE_VERTICAL_SEGMENTS ()"
		
		for index = 1 to vertical_knots.count - 1 do 
			deleteKnot support_obj spline_1 vertical_knots[index]
	),
	
	/** Add base point
	  */
	function _addBasePoint =
	(
		format "\n"; print "SupportObject_v._addBasePoint()"
		this._addPoint (base_height)
	),
	
	/** Add ground point
	  */
	function _addGroundPoint =
	(
		format "\n"; print "SupportObject_v._addGroundPoint()"
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
		
		num_of_knots += 1
		
        ground_knot	= num_of_knots
        base_knot	   = num_of_knots - 1
        leg_knot	   = num_of_knots - 2
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
		vertical_knots[vertical_knots.count]
	),
	
	/** Get zposition by normal
	 */
	function _getZpositionByNormal normal_length =
	(
		--format "\n"; print "SupportObject_v._getZpositionByNormal()"
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
		format "\n"; print "SupportLegUpdater_v._setMaterialToFoot()"
		
		num_of_segments = numSegments support_obj spline_1
		
		for segment_i = 1 to num_of_segments - 1 do
			setMaterialID support_obj spline_1 segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
		
		setMaterialID support_obj spline_1 num_of_segments this.foot_mat_id
	),
	

	/** Get num of knots
	 */
	function _getNumOfKnots =
	(
		--format "\n"; print "SupportLegUpdater_v._getNumOfKnots()"
		num_of_knots = numKnots support_obj spline_1
		
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
