
/** Support leg updater
 */
struct SupportLegUpdater_v
(
	/* construct */
	support_obj,

	/* required */
	foot_mat_id,
	
	/* user properties */
	base_height,
	normal_length,
	foot_enabled = true,

	/* modifier values */ 	
	--bar_width,
	chamfer_val,
	
	/* properties */
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
	
	
	minimal_foot_pos_z, -- minimal z position of leg knot where foot can be created, value is varied by angle of support
	
	is_space_for_foot = true,
	
	/* static */
	spline_1 = 1, -- each support line has ony 1 spline
	
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
	function updateFoot =
	(
		--format "\n=======================================================================\n"
		--format "\n"; print "SupportLegUpdater_v.updateFoot()"

		chamfer_val = SUPPORT_OPTIONS.getOption #TOP_WIDTH
			
		this._setKnotsByNumKnots()
		
		this._setVerticalKnots()
		
		this._getNodeUserProperties()


		--format "foot_enabled: %\n" foot_enabled
		foot_just_added = false
		/*==============================================================================
		  
			ADD OR REMOVE FOOT
			
		================================================================================*/

		if this.footExists() and foot_enabled and this._mustBeFootRemoved() then
			this.removeFoot()
		
		else if foot_enabled and not foot_exists and this._canBeFootAdded() then
			foot_just_added = this.addFoot()
			

		/*==============================================================================
		  
			UPDATE LEG - IF FOOT WAS NOT ADDED
			
		================================================================================*/
		if not foot_just_added then
		(
			if foot_exists = this.footExists() then
				this.updateLegWithFoot()
			
			else
				this.updateLegWithoutFoot()
		)
			
		--this._setPivotToSecondPoint()

		--SUPPORT_MANAGER.updateShapeAdd (support_obj)
		
		foot_exists --return
	),

	private
	
	/** Get node user properties
	 */
	function _getNodeUserProperties =
	(
		--format "\n"; print "SupportLegUpdater_v._getNodeUserProperties()"
		for prop in #( "BASE_HEIGHT", "NORMAL_LENGTH", "FOOT_ENABLED" ) where getProperty this ( prop as name ) == undefined do
			setProperty this prop ( getUserPropVal support_obj prop )
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
			if this._getZposition leg_knot < minimal_foot_pos_z then
				this._setKnotToZposition (leg_knot) (minimal_foot_pos_z )
			
			/* CHECK SPACE ABOVE 2nd KNOT */ 
			if not this._isSpaceForTopChamfer() then
				is_space_for_foot = false
		)
		/* IF NORMAL DIRECTION SUPPORT  */
		else
			is_space_for_foot = not this._getZposition leg_knot <= minimal_foot_pos_z 

		not is_space_for_foot --return
	),
	
	/** IFfootOT N EXISTS
	 */
	function _canBeFootAdded =
	(
		--format "\n---------------------------------\n"
		--format "\n"; print "SupportLegUpdater_v._canBeFootAdded()"
		
		/* IF NORMAL DIRCTION SUPPORT  */
		if direction_is_normal then
		(
			point_2_pos = getKnotPoint support_obj spline_1 2
			
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

			is_space_for_foot = point_2_pos.z > minimal_foot_pos_z
			
		)
		else
			is_space_for_foot = this._getZposition 1 > minimal_foot_pos_z + chamfer_val

		is_space_for_foot --return
	),

	/** ADfootOOT
	*/
	function addFoot =
	(
		--format "\n"; print "SupportLegUpdater_v.addFoot()"

		/* ADD FOOT TO DOWN DIRCTION */
		if direction_is_down then
		(
			if num_of_knots == 2 then
				this._addBasePoint()
				
			this._addGroundPoint()

			if this._getZposition leg_knot < minimal_foot_pos_z then
				this._setZposition (leg_knot) (minimal_foot_pos_z)
			
		)
		else
		(
			if num_of_knots == 2 then
				this._addBasePoint()
			
			this._addGroundPoint()
		)

		
		this._setMaterialToFoot()
		
		true --return
	),

	/** Remove foot by deleting last knot of spline
	 */
	function removeFoot =
	(
		--format "\n"; print "SupportLegUpdater_v.removeFoot()"

		/* DELETE GROUND POINT */ 
		deleteKnot support_obj spline_1 ( numKnots support_obj spline_1)
		
		this._setKnotsByNumKnots()
		
		/*  */
		if direction_is_down and num_of_knots > 2 then
			for knot = 2 to num_of_knots - 1 do 
				deleteKnot support_obj spline_1 knot
	),
	
	/** UPfootE LEWHEN FOOT EXISTS
	 */
	function updateLegWithFoot =
	(
		format "\n"; print "SupportLegUpdater_v.updateLegWithFoot()"
		--format "direction_is_down: %\n" direction_is_down

		point_1_pos  = getKnotPoint support_obj spline_1 1

		
		
		if direction_is_down then
		(
			--format "DISTANCE: %\n" (this._getDistanceOfKnots 1 3)
			--format "NORMAL:   %\n" (this._getDistanceOfKnots 1 2)
			--format "normal_length: %\n" normal_length
			

			
			space_for_normal    = point_1_pos.z - minimal_foot_pos_z
			is_space_for_normal = space_for_normal > normal_length --+ min_height_offset 
			--format "space_for_normal: %\n" space_for_normal
			
			--format "IS SPACE FOR NORMAL: %\n" is_space_for_normal
			--format "IS NORMAL SHORT: %\n" (this._getDistanceOfKnots 1 2 < normal_length)
			
			
			if is_space_for_normal and this._getDistanceOfKnots 1 2 < normal_length then
			(
				--format "SET NORMAL LENGTH\n"
				
				this._setKnotToZposition (2) (point_1_pos.z - normal_length)
			)
			else if not is_space_for_normal then
			(
				--format "UPDATE LEG KNOT\n"

				this._setKnotToZposition (2) (minimal_foot_pos_z)
			)
		)
		
		leg_knot_pos =  getKnotPoint support_obj spline_1 2
		
		leg_knot_pos.z = base_height
		
		setKnotPoint support_obj spline_1 base_knot leg_knot_pos
		
		leg_knot_pos.z = 0
		
		setKnotPoint support_obj spline_1 ground_knot leg_knot_pos
		

		/* UPDATE BASE POINT */ 
		--this._setKnotToZposition (base_knot)(base_height)
		
		/* UPDATE GROUND POINT */ 
		--this._setLastPointToGround()
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
			is_space_for_leg = this._getZposition 2 > minimal_foot_pos_z
			
			if num_of_knots > 2 then
			(
				/* DELETE 3rd KNOT */ 
				if not is_space_for_leg then
				(
					--this._removeVerticalSegments()
					deleteKnot support_obj spline_1 num_of_knots
	
					this._setKnotsByNumKnots()
					
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
		this.foot_exists = getMaterialID support_obj spline_1 num_of_segments == 4
		--format "FOOT_EXISTS: %\n" foot_exists
		this.foot_exists --return
	),

	/** Is space for leg
	 */
	function _isSpaceForFoot knot =
	(
		--format "\n"; print "SupportLegUpdater_v._isSpaceForFoot()"
		--format "minimal_foot_pos_z: %\n" minimal_foot_pos_z
		--format "is_space_for_leg: %\n" (this._getZposition knot > minimal_foot_pos_z)

		this._getZposition knot > minimal_foot_pos_z
	),

	/** Isfootace r top chamfer
	 */
	function _isSpaceForTopChamfer =
	(
		--format "\n"; print "SupportLegUpdater_v._isSpaceForTopChamfer()"
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
	function _setKnotToZposition knot pos_z =
	(
		--format "\n"; print "SupportLegUpdater_v._setKnotToZposition()"
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
	
	/** Extend raft knot to normal lenght
	  * 
	  * @return point3 coordinates of point extended to normal length
	 */
	function _extendSecondPointToNormalLenght =
	(
		--formats "\n"; print "SupportLegUpdater_v._extendSecondPointToNormalLenght()"
		
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

		this._setKnotsByNumKnots()
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

	/**  set material to foot
	 */
	function _setMaterialToFoot =
	(
		--format "\n"; print "SupportLegUpdater_v._setMaterialToFoot()"
		
		num_of_segments = numSegments support_obj spline_1
		
		for segment_i = 1 to num_of_segments - 1 do
			setMaterialID support_obj spline_1 segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
		
		setMaterialID support_obj spline_1 num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE]
	),

	/** Set pivot to position
	 */
	function _setPivotToSecondPoint =
	(
		--format "\n"; print "SupportLegUpdater_v._setPivotToSecondPoint()"
		--support_obj.pivot = getKnotPoint support_obj spline_1 2
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
	function _setKnotsByNumKnots =
	(
		--format "\n"; print "SupportLegUpdater_v._setKnotsByNumKnots()"
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
