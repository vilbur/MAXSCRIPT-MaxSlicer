
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

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	public
	
	/** Update leg
	 */
	function updateLeg =
	(
		format "\n"; print "SupportLegUpdater_v.updateLeg()"
		
		--if this.is_on_ground then
		chamfer_val = SUPPORT_OPTIONS.getOption #TOP_WIDTH
			
			
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
			leg_knot_pos = getKnotPoint support_obj spline_1 leg_knot
			
			foot_space_exists =  if vertical_knots.count > 3 then this._getZposition vertical_knots[vertical_knots.count] >= minimal_support_height else leg_knot_pos.z >= minimal_support_height
			
		
			/* SHIFT FOOT TO GROUND */ 
			if foot_space_exists then
			(
				/* UPDATE LEG POINT */ 
				if this._getZposition leg_knot < minimal_support_height then
					this._setZposition (leg_knot) (minimal_leg_pos_z)
										
				/* UPDATE BASE POINT */ 
				this._setZposition (base_knot)(base_height)
		
			)
			/* REMOVE FOOT */ 
			else
				deleteKnot support_obj spline_1 ground_knot
				
			/* UPDATE GROUND POINT */ 
			this._setLastPointToGround()
		)
		
		/*==============================================================================
		
				IF HAS NOT FOOT
		
		================================================================================*/
		else 
		(
			normal_length = getUserPropVal support_obj "NORMAL_LENGTH"
			
			/*------------------------------------------------------------------------------
				ADD FOOT
			--------------------------------------------------------------------------------*/
			if this._isSpaceForFoot(minimal_support_height)(minimal_leg_pos_z) then
			(
				/* ADD BASE POINT TO SKEEWED SUPPORT */
				if vertical_knots.count == 0 then
				(
					ground_knot_pos = this._extendRaftKnotToNormalLenght(ground_knot)(base_knot_pos)(ground_knot_pos)(normal_length)
		
					this._addBasePoint(ground_knot_pos)
				)
				
				/* ADD BASE POINT TO VERTICAL SUPPORT */
				else
					this._setZposition (vertical_knots[1]) (base_height)
			
				
				/* ADD GROUND POINT */ 
				addKnot support_obj spline_1 #corner #line ground_knot_pos
				
				 /* SET GROUND POINT */ 
				this._setLastPointToGround()
				
			)
			
			/*------------------------------------------------------------------------------
				UPDATE SUPPORT WITHOUT FOOT
			--------------------------------------------------------------------------------*/
			else
			(
				/* DELETE VERTICAL POINTS BELOW BASE BUT NOT FIRST POINT  */ 
				if vertical_knots.count >= 2 then
					this._deleteVerticalPointsBellowMinimalSpace(vertical_knots)(chamfer_val)
				
				/*------------------------------------------------------------------------------
					UPDATE GROUND POINT WITHOUT FOOT
				--------------------------------------------------------------------------------*/
				--else if numKnots support_obj spline_1 == 2 then 
				if numKnots support_obj spline_1 == 2 then
					this._extendRaftKnotToGound()
				
				else /* SET GROUND POINT */ 
					this._setLastPointToGround()
		
			)
		)
		
		SUPPORT_MANAGER.updateShapeAdd (support_obj)
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
	
	/** Space for adding foot exists
	 */
	function _isSpaceForFoot minimal_support_height minimal_leg_pos_z =
	(
		--format "\n"; print "SupportLegUpdater_v.spaceForAddingFootExists()"
		if vertical_knots.count == 0 then
			/* GET SPACE ON SKEEWED SUPPORT */
			( this._getZpositionByNormal normal_length ) >= minimal_leg_pos_z

		else /* GET SPACE ON VERTICAL SUPPORT */ 
			( this._getZposition vertical_knots[vertical_knots.count]) >= minimal_support_height

		
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
				
		knot_pos = getKnotPoint support_obj spline_1 knot
		
		knot_pos.z = pos_z
		
		setKnotPoint support_obj spline_1 knot knot_pos
	),
	
	/** Get zposition
	 */
	function _getZposition knot =
	(
		(getKnotPoint support_obj spline_1 knot).z
	),
	
	/** Extend raft knot to normal lenght
	 */
	function _extendRaftKnotToNormalLenght ground_knot base_knot_pos ground_knot_pos normal_length =
	(
		--format "\n"; print "SupportObject_v._extendRaftKnotToNormalLenght()"
					
		line_vector = normalize ( ground_knot_pos - base_knot_pos)
		
		ground_knot_pos = base_knot_pos + ( normal_length * line_vector )
		
		setKnotPoint support_obj spline_1 ground_knot ground_knot_pos
		
		ground_knot_pos --return
	),
	
	/** Extend second point to gound
	 */
	function _extendRaftKnotToGound =
	(
		--format "\n"; print "SupportObject_v._extendRaftKnotToGound()"
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
	function _deleteVerticalPointsBellowMinimalSpace vertical_knots minimal_space =
	(
		--format "\n"; print "SupportObject_v._deleteVerticalPointsBellowMinimalSpace()"
		fn getKnotZposition knot = (getKnotPoint support_obj spline_1 knot).z
		
		--for index = 1 to vertical_knots.count - 1 where ( knot = vertical_knots[index] ) != 1 and getKnotZposition vertical_knots[index] < minimal_space do 
		for index = 1 to vertical_knots.count - 1 where ( knot = vertical_knots[index] ) != 1 and getKnotZposition vertical_knots[index] < minimal_space do 
			deleteKnot support_obj spline_1 knot
	),
	
	/** Add base point
	  */
	function _addBasePoint knot_pos =
	(
		--format "\n"; print "SupportObject_v._addBasePoint()"
		
		knot_pos.z  = base_height
		
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
