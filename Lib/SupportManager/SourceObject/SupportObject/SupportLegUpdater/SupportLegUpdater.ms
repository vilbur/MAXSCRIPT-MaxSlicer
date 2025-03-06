
/** Support leg updater
 */
struct SupportLegUpdater_v
(
	/* construct */
	support_obj,

	/* required */
	/* properties */
	base_height,
	normal_length,
	
	vertical_knots = #(),
	
	private

	spline_1 = 1, -- each support line has ony 1 spline

	minimal_support_height,
	minimal_leg_pos_z,
	
	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	public
	
	/** Update leg
	 */
	function updateLeg =
	(
		--format "\n"; print "SupportLegUpdater_v.updateLeg()"
		
		--if this.is_on_ground then
		foot_added = false
		
		chamfer_val = SUPPORT_OPTIONS.getOption #TOP_WIDTH
		bar_width   = SUPPORT_OPTIONS.getOption #BAR_WIDTH
			
			
		minimal_leg_pos_z      = SUPPORT_OPTIONS.base_height + chamfer_val + 0.1
		minimal_support_height = minimal_leg_pos_z + chamfer_val

		num_of_knots    = numKnots support_obj spline_1
		

		ground_knot	= num_of_knots
		base_knot	= num_of_knots - 1
		leg_knot    = num_of_knots - 2
		
		ground_knot_pos	= getKnotPoint support_obj spline_1 ground_knot
		base_knot_pos	= getKnotPoint support_obj spline_1 base_knot

		base_height	= getUserPropVal support_obj "BASE_HEIGHT"
		
		this._setVerticalKnots()
		
		
		/*==============================================================================
		
			IF HAS FOOT 
		
		================================================================================*/
		if this._footExists() then
		(
			format "FOOT EXISTS\n"
			leg_knot_pos = getKnotPoint support_obj spline_1 leg_knot
			
			is_space_for_foot = this._isSpaceForFoot leg_knot_pos_z:leg_knot_pos.z
			
			format "IS_SPACE_FOR_FOOT: %\n" is_space_for_foot

			/* SHIFT FOOT TO GROUND */ 
			if is_space_for_foot then
			(
				format "UPDATE FOOT\n"

				--/* UPDATE LEG POINT */ 
				--if this._getZposition leg_knot < minimal_support_height then
				--	this._setZposition (leg_knot) (minimal_leg_pos_z)
										
				/* UPDATE BASE POINT */ 
				this._setZposition (base_knot)(base_height)
		
			)
			/* REMOVE FOOT */ 
			else
				this._removeFoot()
				
			/* UPDATE GROUND POINT */ 
			this._setLastPointToGround()
		)
		
		/*==============================================================================
		
				IF HAS NOT FOOT
		
		================================================================================*/
		else 
		(
			format "\nFOOT NOT EXISTS\n"
			normal_length = getUserPropVal support_obj "NORMAL_LENGTH"
			format "normal_length: %\n" normal_length
			
			
			/* IF SKEWED SUPPORT  */
			if vertical_knots.count == 0 then
			(
				point_1_pos = getKnotPoint support_obj spline_1 1
				point_2_pos = getKnotPoint support_obj spline_1 2
				
				distance_of_points = distance point_1_pos point_2_pos
				format "distance_of_points: %\n" distance_of_points
				
				
				/* IF SUPPORT IS SHORTEN BY GROUND */
				if distance_of_points != normal_length then
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
				is_space_for_foot = this._isSpaceForFoot()
			
			
			/*------------------------------------------------------------------------------
			  
				ADD FOOT
				
			--------------------------------------------------------------------------------*/
			
			format "IS_SPACE_FOR_FOOT: %\n" is_space_for_foot
			if is_space_for_foot then
			(
				format "\nADD FOOT\n"

				/* SET FOOT TO VERTICAL SUPPORT */
				if vertical_knots.count > 0 then
				(
					/* UPDATE BASE POINT POSTION */ 
					this._setZposition (vertical_knots[1]) (base_height)
					
					if vertical_knots.count == 2 then
						this._addGroundPoint()					
				)
				
				/* ADD FOOT TO SKEWED SUPPORT */
				else
				(
					this._addBasePoint()
						
					this._addGroundPoint()
				)
			
				foot_added = true
			)
			
			/*------------------------------------------------------------------------------
			  
				UPDATE SUPPORT WITHOUT FOOT
				
			--------------------------------------------------------------------------------*/
			else
			(
				format "UPDATE SUPPORT WITHOUT FOOT\n"
				format "vertical_knots: %\n" vertical_knots
				
				/* IF VERTICAL SUPPORT  */
				if vertical_knots.count > 0 then
				(
					if this._getZposition vertical_knots[vertical_knots.count] < minimal_leg_pos_z then
						this._removeVerticalSegments()
	
					else if vertical_knots.count > 2 then
						this._deleteVerticalPointsBellowMinimalSpace(minimal_leg_pos_z)
					
					/* SET GROUND POINT */ 
					--this._setLastPointToGround()
				)
				
				/* IF SKEWED SUPPORT  */
				--else
				(
					if numKnots support_obj spline_1 == 2 then
						this._extendRaftKnotToGound()
					
					else /* SET GROUND POINT */ 
						this._setLastPointToGround()
				)
			)
		)
		
		SUPPORT_MANAGER.updateShapeAdd (support_obj)
		
		foot_added --return
	),
	
	
	private
	
	/** Test if foot exist - lat foot line segment has mat ID 4
	 */
	function _footExists =
	(
		--format "\n"; print "SupportLegUpdater_v._footExists()"
		num_of_segments = numSegments support_obj spline_1
		
		getMaterialID support_obj spline_1 num_of_segments == 4
	),
	
	/** Remove foot by deleting last knot of spline
	 */
	function _removeFoot =
	(
		format "\n"; print "SupportLegUpdater_v._removeFoot()"
		
		deleteKnot support_obj spline_1 ( numKnots support_obj spline_1)
	),
	
	/** Space for adding foot exists
	 */
	function _isSpaceForFoot leg_knot_pos_z: =
	(
		format "\n"; print "SupportLegUpdater_v._isSpaceForFoot()"
		format "vertical_knots.count: %\n" vertical_knots.count
		
		/* GET SPACE ON SKEWED SUPPORT */
		--if vertical_knots.count == 0 then
		if leg_knot_pos_z != unsupplied then
			leg_knot_pos_z > minimal_support_height
			--	leg_knot_pos_z = this._getZpositionByNormal normal_length
		
		/* GET SPACE ON VERTICAL SUPPORT */ 
		else
			( this._getZposition vertical_knots[vertical_knots.count]) > minimal_support_height
	),

	/** Get vertical knots
	 */
	function _setVerticalKnots =
	(
		format "\n"; print "SupportObject_v._setVerticalKnots()"
		/** Support is vertical
		 */
		function supportIsVertical knot =
		(
			--format "\n"; print "SupportObject_v.supportIsVertical()"
			fn roundFloat val  = ( local mult = 10.0 ^ 3; (floor ((val * mult) + 0.5)) / mult )
			
			knot_pos       = getKnotPoint support_obj spline_1 knot
			upper_knot_pos = getKnotPoint support_obj spline_1 (knot - 1)

			support_is_vertical = roundFloat knot_pos.x == roundFloat upper_knot_pos.x and roundFloat knot_pos.y == roundFloat upper_knot_pos.y

			support_is_vertical --return
		)
		
		--supportIsVertical( numKnots support_obj spline_1) 
		
	
		for knot = ( numKnots support_obj spline_1 ) to 2 by -1 while supportIsVertical(knot) do
		(
			appendIfUnique vertical_knots knot
			
			appendIfUnique vertical_knots (knot - 1)
		)				
		
	),
	
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
		--format "\n"; print "SupportObject_v._setZposition()"
		--format "knot:  %\n" knot
		--format "pos_z: %\n" pos_z
				
		knot_pos = getKnotPoint support_obj spline_1 knot
		
		knot_pos.z = pos_z
		
		setKnotPoint support_obj spline_1 knot knot_pos
	),
	
	/** Get zposition
	 */
	function _getZposition knot =
	(
		format "\n"; print "SupportObject_v._getZposition()"
		knot_pos = getKnotPoint support_obj spline_1 knot
		format "KNOT: % POS: %\n" knot knot_pos
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
		format "\n"; print "SupportObject_v._deleteVerticalPointsBellowMinimalSpace()"
		format "minimal_z_pos: %\n" minimal_z_pos
		

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
		--format "\n"; print "SupportLegUpdater_v._removeVerticalSegments()"
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
		knot_pos  = getKnotPoint support_obj spline_1 ( numKnots support_obj spline_1 )

		knot_pos.z  = z_pos

		addKnot support_obj spline_1 #corner #line knot_pos
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
		
	private

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportLegUpdater.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)
)
