
/** Support leg updater
 */
struct SupportRaftUpdater_v
(
	/* CONSTRUCT */
	SupportObject, -- parent class
	support_obj = SupportObject.support_obj,

	/* REQUIRED */
	foot_mat_id,
	
	/* user properties */
	base_height,
	raft_length,
	foot_enabled = true,

	/* modifier values */ 	
	--bar_width,
	chamfer_val,
	
	/* PROPERTIES */
	foot_exists = true,

	vertical_knots = #(),
	
	direction_is_down   = false,
	direction_is_normal = false,
	has_vertical_points = false,
	not_vertical_points = false,
	
	--private

	num_of_knots,
	
	ground_knot,
	base_knot,
	leg_knot,
	
	
	--min_leg_pos  = SupportObject.min_leg_pos,  -- minimal z position of leg knot WHERE LEG WITHOUT FOOT CAN BE CREATED
	--min_foot_pos = SupportObject.min_foot_pos, -- minimal z position of leg knot WHERE FOOT CAN BE CREATED	 -- NOTICE:value is varied by angle of support
	--min_length   = SupportObject.min_length,
	--min_leg_pos,
	--min_foot_pos,
	--min_length,
	
	
	is_space_for_foot = true,
	
	/* STATIC */
	spline_1 = 1, -- each support line has ony 1 spline
	
	/* dependency */
	/* reference */
	/* inhered */

	public
	
	/** Update leg
	 *	
	 *	1) Test if space for foot exists
	 *	 A) IF FOOT EXIST - try remove foot
	 *	 B) IF FOOT NOT EXIST - try add foot
	 *	
	 *	2) UPDATE SUPPORT WITH FOOT 
	 *	
	 *	3) UPDATE SUPPORT WITHOUT FOOT
	 *	
	 *	@return boolean if foot exists or not
		
		
		
	 */
	function updateFoot =
	(
		--format "\n=======================================================================\n"
		--format "\n"; print "SupportRaftUpdater_v.updateFoot()"
		--format "foot_exists: %\n" foot_exists

		chamfer_val = SUPPORT_OPTIONS.getModVal #TOP_WIDTH

		foot_just_added = false
			
		this._setKnotsByNumKnots()
		
		this._setVerticalKnots()
		
		this._getUserProperties()

		this._footExists()
		
		
		/*------------------------------------------------------------------------------
			ADD FOOT
		--------------------------------------------------------------------------------*/
		if foot_enabled and not foot_exists and this._canBeFootAdded() then
		(
			this.addFoot()
			
			foot_just_added = true
		)
		/*------------------------------------------------------------------------------
			REMOVE FOOT
		--------------------------------------------------------------------------------*/
		else if foot_exists and this._mustBeFootRemoved() then
			this.removeFoot()
		
		
		
		/*------------------------------------------------------------------------------
			UPDATE
		--------------------------------------------------------------------------------*/
		if not foot_just_added then
		(
			/*------------------------------------------------------------------------------
				UPDATE LEG WITH FOOT
			--------------------------------------------------------------------------------*/
			if foot_exists then
				this.updateLegWithFoot()
			
			/*------------------------------------------------------------------------------
				UPDATE LEG WITHOUT FOOT
			--------------------------------------------------------------------------------*/
			else
				this.updateLegWithoutFoot()
		)
		
		foot_exists --return
	),

	private
	
	/** Get node user properties
	 */
	function _getUserProperties =
	(
		--format "\n"; print "SupportRaftUpdater_v._getNodeUserProperties()"
		for prop in #( "BASE_HEIGHT", "RAFT_LENGTH", "FOOT_ENABLED" ) where getProperty this ( prop as name ) == undefined do
			setProperty this prop ( getUserPropVal support_obj prop )
	),

	/*ECK IF SPACE FOR FOOT EXISTS
	 */
	function _mustBeFootRemoved =
	(
		--format "\n---------------------------------\n"
		--format "\n"; print "SupportRaftUpdater_v._mustBeFootRemoved()"
		min_foot_pos = SupportObject.min_foot_pos
		
		ground_knot_pos = getKnotPoint support_obj spline_1 ground_knot
		base_knot_pos   = getKnotPoint support_obj spline_1 base_knot
		
		/* SUPPORT DIRECTION IS DOWN */
		if direction_is_down then
		(
			/* KEEP LEG KNOT ABOVE BASE KNOT */ 
			if this._getZposition leg_knot < min_foot_pos then
				this._setKnotToZposition (leg_knot) (min_foot_pos)
			
			/* CHECK SPACE ABOVE 2nd KNOT */ 
			if not this._isSpaceForTopChamfer() then
				is_space_for_foot = false
		)
		/* IF NORMAL DIRECTION SUPPORT  */
		else
			--is_space_for_foot = not this._getZposition leg_knot <= min_foot_pos 
			is_space_for_foot = not this._getZposition leg_knot <= min_foot_pos 

		not is_space_for_foot --return
	),
	
	/** IFfootOT N EXISTS
	 */
	function _canBeFootAdded =
	(
		--format "\n---------------------------------\n"
		--format "\n"; print "SupportRaftUpdater_v._canBeFootAdded()"
		--format "num_of_knots: %\n" num_of_knots
		
		/* IF NORMAL DIRECTION SUPPORT  */
		if direction_is_normal then
		(
			point_2_pos = getKnotPoint support_obj spline_1 2
			
			--format "point_2_pos: %\n" point_2_pos.z
		    --format "min_foot_pos: %\n" min_foot_pos

			if num_of_knots == 2 then
			(
				/* IF SUPPORT IS SHORTEN BY GROUND */
				if this._getDistanceOfKnots 1 2 < raft_length then
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

			is_space_for_foot = point_2_pos.z > SupportObject.min_foot_pos
			
		)
		else
			is_space_for_foot = this._getZposition 1 > SupportObject.min_foot_pos + chamfer_val
		
		--format "IS_SPACE_FOR_FOOT: %\n" is_space_for_foot
		is_space_for_foot --return
	),

	/** ADD FOOT
	*/
	function addFoot =
	(
		--format "\n"; print "SupportRaftUpdater_v.addFoot()"

		/* DOWN DIRECTION */
		if direction_is_down then
		(
			if num_of_knots == 2 then
				this._addBasePoint()
				
			this._addGroundPoint()

			if this._getZposition leg_knot < SupportObject.min_foot_pos then
				this._setZposition (leg_knot) (SupportObject.min_foot_pos)
			
		)
		/* NORMAL DIRECTION */
		else
		(
			--format "\nNORMAL DIRECTION\n"
			
			if num_of_knots == 2 then
				this._addBasePoint()
			
			/* SHIFT GROUNT POINT TO BASE POINT*/ 
			else
				this._alignKnotToPreviousKnot(ground_knot)(base_height)

			
			this._addGroundPoint()
		)
		
		this._setMaterialToFoot()

		this.foot_exists = true --return
	),

	/** Remove foot by deleting last knot of spline
	 */
	function removeFoot =
	(
		--format "\n"; print "SupportRaftUpdater_v.removeFoot()"

		/* DELETE GROUND POINT */ 
		deleteKnot support_obj spline_1 ( numKnots support_obj spline_1)
		
		this._setKnotsByNumKnots()
		
		/*  */
		if direction_is_down and num_of_knots > 2 then
			for knot = 2 to num_of_knots - 1 do 
				deleteKnot support_obj spline_1 knot
				
		this.foot_exists = false --return
	),
	
	/** UPfootE LEWHEN FOOT EXISTS
	 */
	function updateLegWithFoot =
	(
		--format "\n"; print "SupportRaftUpdater_v.updateLegWithFoot()"
		--format "direction_is_down: %\n" direction_is_down

		point_1_pos  = getKnotPoint support_obj spline_1 1

		if direction_is_down then
		(
			--format "DISTANCE: %\n" (this._getDistanceOfKnots 1 3)
			--format "NORMAL:   %\n" (this._getDistanceOfKnots 1 2)
			--format "raft_length: %\n" raft_length
			

			
			space_for_normal    = point_1_pos.z - SupportObject.min_foot_pos
			is_space_for_normal = space_for_normal > raft_length --+ min_height_offset 
			--format "space_for_normal: %\n" space_for_normal
			
			--format "IS SPACE FOR NORMAL: %\n" is_space_for_normal
			--format "IS NORMAL SHORT: %\n" (this._getDistanceOfKnots 1 2 < raft_length)
			
			
			if is_space_for_normal and this._getDistanceOfKnots 1 2 < raft_length then
			(
				--format "SET NORMAL LENGTH\n"
				
				this._setKnotToZposition (2) (point_1_pos.z - raft_length)
			)
			else if not is_space_for_normal then
			(
				--format "UPDATE LEG KNOT\n"

				this._setKnotToZposition (2) (SupportObject.min_foot_pos)
			)
		)
		
		
		/* UPDATE BASE POINT */ 
		this._alignKnotToPreviousKnot(base_knot)(base_height)

		/* UPDATE GROUND POINT */ 
		this._alignKnotToPreviousKnot(ground_knot)(0)
	),
	
	/** UPDATE LEG WITHOUT FOOT
	 */
	function updateLegWithoutFoot =
	(
		--format "\n"; print "SupportRaftUpdater_v.updateLegWithoutFoot()"
		
		--format "num_of_knots: %\n" num_of_knots
		
		/*------------------------------------------------------------------------------
			UPDATE DOWN DIRECTION
		--------------------------------------------------------------------------------*/
		if direction_is_down then
		(
			--format "\nUPDATE DOWN DIRECTION\n"
			--if this._getZposition ( this._getLastKnot() ) > 0 then
				this._setLastPointToGround()
			--else
			--	this._extendRaftKnotToGound() 
		)
		
		/*------------------------------------------------------------------------------
			UPDATE NORMAL DIRECTION
		--------------------------------------------------------------------------------*/
		else 
		(
			/*------------------------------------------------------------------------------
				UPDATE SUPPORT WITH LEG
			--------------------------------------------------------------------------------*/
			if num_of_knots > 2 then
			(
				
				/*------------------------------------------------------------------------------
					IF NOT SPACE FOR LEG
				--------------------------------------------------------------------------------*/
				if this._getZposition leg_knot < SupportObject.min_leg_pos then
				(
		
					this._shortenNormalAndKeepLeg()
					
					first_knot_pos  = getKnotPoint support_obj spline_1 1
					
					second_knot_pos  = getKnotPoint support_obj spline_1 2
					
					distance_of_points = distance first_knot_pos second_knot_pos
					
					--format "DISTANCE:   %\n" ( distance_of_points )
					--format "MIN_LENGTH: %\n" SupportObject.min_length
					--format "TEST: %\n" ( distance_of_points > SupportObject.min_length )
					
					
				)
				/*------------------------------------------------------------------------------
					IF SPACE FOR LEG EXISTS
				--------------------------------------------------------------------------------*/
				else
					this._alignKnotToPreviousKnot(ground_knot)(0)
			)
			
			/*------------------------------------------------------------------------------
				UPDATE SUPPORT WITHOUT LEG
			--------------------------------------------------------------------------------*/
			else
			(
				--format "\nWITHOUT LEG\n"
				is_space_for_leg = this._getZposition ground_knot > SupportObject.min_leg_pos
				--format "IS_SPACE_FOR_LEG: %\n" is_space_for_leg

				/* ADD 3rd KNOT */ 
				if is_space_for_leg then
					this._addGroundPoint()
					
				else  /* UPDATE 3rd KNOT */ 
					this._shortenNormalAndKeepLeg()
			)
		)
	),
		
	/*------------------------------------------------------------------------------
	  
		HELPERS
		
	--------------------------------------------------------------------------------*/
	
	/** Test if foot exist - lat foot line segment has mat ID 4
	 */
	function _footExists =
	(
		--format "\n"; print "SupportRaftUpdater_v._footExists()"

		num_of_segments = numSegments support_obj spline_1
		--format "num_of_segments: %\n" num_of_segments
		--format "num_of_segments: %\n" ( numSegments support_obj spline_1)
		--format "getMaterialID: %\n" (getMaterialID support_obj spline_1 num_of_segments)
		this.foot_exists = ( getMaterialID support_obj spline_1 num_of_segments ) == 4
		--format "FOOT_EXISTS: %\n" foot_exists
		this.foot_exists --return
	),

	/** Is space for leg
	 */
	function _isSpaceForFoot knot =
	(
		--format "\n"; print "SupportRaftUpdater_v._isSpaceForFoot()"
		--format "min_foot_pos: %\n" min_foot_pos
		--format "is_space_for_leg: %\n" (this._getZposition knot > min_foot_pos)

		this._getZposition knot > SupportObject.min_foot_pos
	),

	/** Isfootace r top chamfer
	 */
	function _isSpaceForTopChamfer =
	(
		--format "\n"; print "SupportRaftUpdater_v._isSpaceForTopChamfer()"
		this._setKnotsByNumKnots()
		
		
		leg_knot    = num_of_knots - 2

		leg_knot_pos     =  getKnotPoint support_obj spline_1 leg_knot
		support_knot_pos =  getKnotPoint support_obj spline_1 (leg_knot - 1)

		distance support_knot_pos leg_knot_pos > chamfer_val-- + 0.1
	),

	/** Get vertical knots
	 */
	function _setVerticalKnots =
	(
		--format "\n"; print "SupportRaftUpdater_v._setVerticalKnots()"
		/** Support is vertical
		 */
		function supportIsVertical knot =
		(
			--format "\n"; print "SupportRaftUpdater_v.supportIsVertical()"
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
	
	/** Set knot ground
	 */
	function _setLastPointToGround =
	(
		--format "\n"; print "SupportRaftUpdater_v.setKnotGround()"
		ground_knot     = numKnots support_obj spline_1
		ground_knot_pos = getKnotPoint support_obj spline_1 ground_knot
		
		ground_knot_pos.z = 0
		
		
		setKnotPoint support_obj spline_1 ground_knot ground_knot_pos
	),
	
	/** Set zposition
	 */
	function _setKnotToZposition knot pos_z =
	(
		--format "\n"; print "SupportRaftUpdater_v._setKnotToZposition()"
		--format "KNOT: % POS_Z: %\n" knot pos_z
				
		knot_pos = getKnotPoint support_obj spline_1 knot
		
		knot_pos.z = pos_z
		
		setKnotPoint support_obj spline_1 knot knot_pos
	),
	
	/** Get zposition
	 */
	function _getZposition knot =
	(
		--format "\n"; print "SupportRaftUpdater_v._getZposition()"
		knot_pos = getKnotPoint support_obj spline_1 knot
		--format "KNOT: % POS: %\n" knot knot_pos
		--format "Z_POS: %\n" knot_pos.z
		knot_pos.z --return
	),
	
	/** Set zposition
	 */
	function _setZposition knot pos_z =
	(
		--format "\n"; print "SupportRaftUpdater_v._setZposition()"
		--format "KNOT: % POS_Z: %\n" knot pos_z
				
		knot_pos = getKnotPoint support_obj spline_1 knot
		
		knot_pos.z = pos_z
		
		setKnotPoint support_obj spline_1 knot knot_pos
	),
	
	/** Align next knot bellow
	 */
	function _alignKnotToPreviousKnot knot pos_z =
	(
		--format "\n"; print "SupportRaftUpdater_v._alignKnotToPreviousKnot()"
		knot_pos = getKnotPoint support_obj spline_1 (knot - 1)

		knot_pos.z = pos_z
		
		setKnotPoint support_obj spline_1 knot knot_pos
	),

	/** Extend raft knot to normal lenght
	  * 
	  * @return point3 coordinates of point extended to normal length
	 */
	function _extendSecondPointToNormalLenght =
	(
		--formats "\n"; print "SupportRaftUpdater_v._extendSecondPointToNormalLenght()"
		point_1_pos = getKnotPoint support_obj spline_1 1
		point_2_pos = getKnotPoint support_obj spline_1 2

		line_vector = normalize ( point_2_pos - point_1_pos )
		
		point_1_pos + ( raft_length * line_vector ) -- return
	),
	
	--/** Extend second point to gound
	-- */
	--function _extendRaftKnotToGound =
	--(
	--	--format "\n"; print "SupportRaftUpdater_v._extendRaftKnotToGound()"
	--	first_knot_pos  = getKnotPoint support_obj spline_1 1
	--	second_knot_pos = getKnotPoint support_obj spline_1 2
	--	
	--	triangle_height = first_knot_pos.z
	--	
	--	line_vector = normalize ( first_knot_pos - second_knot_pos )
	--
	--	angle_angle = acos (dot [0,0,-1] line_vector) -- get angle between
	--	
	--	line_length = triangle_height / cos angle_angle
	--	
	--	second_knot_pos = first_knot_pos + ( line_length * line_vector )
	--	
	--	setKnotPoint support_obj spline_1 2 second_knot_pos
	--),
	
	--/** Get second point position above ground using angle of support
	-- */
	--function _getSecondPointPosOnNormal =
	--(
	--	--format "\n"; print "SupportRaftUpdater_v._getSecondPointPosOnNormal()"
	--	first_knot_pos  = getKnotPoint support_obj spline_1 1
	--	second_knot_pos = getKnotPoint support_obj spline_1 2
	--	
	--	triangle_height = first_knot_pos.z - 0.1
	--	triangle_height = first_knot_pos.z - SupportObject.min_leg_pos
	--	
	--	line_vector = normalize ( first_knot_pos - second_knot_pos )
	--	
	--	angle_angle = acos (dot [0,0,-1] line_vector) -- get angle between
	--	
	--	line_length = triangle_height / cos angle_angle
	--	
	--	first_knot_pos + ( line_length * line_vector )
	--),

	/** Make raft part shorter if there is no space for leg
	 */
	function _shortenNormalAndKeepLeg =
	(
		--format "\n"; print "SupportRaftUpdater_v._shortenNormalAndKeepLeg()"
		
		/** Get second point position above ground using angle of support
		 */
		function getSecondPointPosition =
		(
			--format "\n"; print "SupportRaftUpdater_v.getSecondPointPosition()"
			first_knot_pos  = getKnotPoint support_obj spline_1 1
			second_knot_pos = getKnotPoint support_obj spline_1 2
			
			triangle_height = first_knot_pos.z - 0.1
			triangle_height = first_knot_pos.z - SupportObject.min_leg_pos
			
			line_vector = normalize ( first_knot_pos - second_knot_pos )
			
			angle_angle = acos (dot [0,0,-1] line_vector) -- get angle between
			
			line_length = triangle_height / cos angle_angle
			
			first_knot_pos + ( line_length * line_vector )
		)
		
		second_knot_pos = getSecondPointPosition()
		
		setKnotPoint support_obj spline_1 2 second_knot_pos
		
		this._alignKnotToPreviousKnot(ground_knot)(0)

		--second_knot_pos.z = 0
		--
		--setKnotPoint support_obj spline_1 3 second_knot_pos
	),
	

	
	/** Add base point
	  */
	function _addBasePoint =
	(
		--format "\n"; print "SupportRaftUpdater_v._addBasePoint()"
		this._addKnot (base_height)
	),
	
	/** Add ground point
	  */
	function _addGroundPoint =
	(
		--format "\n"; print "SupportRaftUpdater_v._addGroundPoint()"
		this._addKnot (0)
	),
	
	/** Add point on same coordinates but diferent Z axis
	 */
	function _addKnot z_pos =
	(
		--format "\n"; print "SupportRaftUpdater_v.addPoint()"
		--format "z_pos: %\n" z_pos
		knot_pos  = getKnotPoint support_obj spline_1 ( this._getLastKnot() )

		knot_pos.z  = z_pos

		addKnot support_obj spline_1 #corner #line knot_pos

		this._setKnotsByNumKnots()
	),

	/** Get last knot
	 */
	function _getLastKnot =
	(
		numKnots support_obj spline_1
	),

	--/** Get top vertical knot
	-- */
	--function _getTopVerticalKnot =
	--(
	--	--format "\n"; print "SupportRaftUpdater_v._getTopVerticalKnot()"
	--	--format "VERTICAL_KNOTS: %\n" vertical_knots
	--	vertical_knots[vertical_knots.count]
	--),

	/**  set material to foot
	 */
	function _setMaterialToFoot =
	(
		--format "\n"; print "SupportRaftUpdater_v._setMaterialToFoot()"
		
		num_of_segments = numSegments support_obj spline_1
		
		for segment_i = 1 to num_of_segments - 1 do
			setMaterialID support_obj spline_1 segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
		
		setMaterialID support_obj spline_1 num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE]
	),

	/** Set pivot to position
	 */
	function _setPivotToSecondPoint =
	(
		--format "\n"; print "SupportRaftUpdater_v._setPivotToSecondPoint()"
		--support_obj.pivot = getKnotPoint support_obj spline_1 2
		support_obj.pivot = getKnotPoint support_obj spline_1 2
	),

	/** Get distance of knots
	 */
	function _getDistanceOfKnots knot_A knot_B =
	(
		--format "\n"; print "SupportRaftUpdater_v._getDistanceOfKnots()"
		point_1_pos = getKnotPoint support_obj spline_1 knot_A
		point_2_pos = getKnotPoint support_obj spline_1 knot_B
		
		distance point_1_pos point_2_pos
	),

	/** Get num of knots
	 */
	function _setKnotsByNumKnots =
	(
		--format "\n"; print "SupportRaftUpdater_v._setKnotsByNumKnots()"
        num_of_knots = numKnots support_obj spline_1

        ground_knot  = num_of_knots

        --/* GET BASE KNOT IF EXISTS */
        --base_knot	=  if num_of_knots > 3 then num_of_knots - 1
        --
        --/* GET LEG KNOT ON SPLINE WITH 3 OR 4 KNOTS */
        --leg_knot	= if num_of_knots > 3 then num_of_knots - 2 else num_of_knots - 1

		if num_of_knots == 4 then
		(
			base_knot = num_of_knots - 1
			
			leg_knot = num_of_knots - 2
		)
		else if num_of_knots == 3 then
			leg_knot = num_of_knots - 1
		
		
		this._updateVerticalKnots()

		num_of_knots --return
	),
	
	/** Remove vertical knot indexes higher then number of knots
	 */
	function _updateVerticalKnots =
	(
		--format "\n"; print "SupportRaftUpdater_v._updateVerticalKnots()"
		num_knots = numKnots support_obj spline_1
		
		for i = vertical_knots.count to 1 by -1 where vertical_knots[i] > num_knots do
			deleteItem vertical_knots i
	),
	
	/**
	 */
	on create do
	(
		--format "\n"; print "SupportRaftUpdater.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)
)
