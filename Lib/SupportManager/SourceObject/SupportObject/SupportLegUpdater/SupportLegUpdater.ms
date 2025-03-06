
/** Support leg updater
 */
struct SupportLegUpdater_v
(
	/* construct */
	source_obj,
	is_on_ground,

	/* required */
	/* properties */
	
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
		--format "\n"; print "SupportLegUpdater_v.updateLeg()"
		
		--if this.is_on_ground then
		if this.is_on_ground != undefined and this.is_on_ground then
		(
			chamfer_val = SUPPORT_OPTIONS.getOption #TOP_WIDTH
			
			
			minimal_leg_pos_z      = SUPPORT_OPTIONS.base_height + chamfer_val + 0.1
			minimal_support_height = minimal_leg_pos_z + chamfer_val
	
	
	
			num_of_knots    = numKnots    support_obj spline_1
			num_of_segments = numSegments support_obj spline_1
			format "num_of_knots: %\n" num_of_knots
			format "minimal_support_height: %\n" minimal_support_height
			
			has_foot = getMaterialID support_obj spline_1 num_of_segments == 4
	
			ground_knot	= num_of_knots
			base_knot	= num_of_knots - 1
			leg_knot = num_of_knots - 2
			format "base_knot: %\n" base_knot
			
			ground_knot_pos	= getKnotPoint support_obj spline_1 ground_knot
			base_knot_pos	= getKnotPoint support_obj spline_1 base_knot
	
		base_height	= getUserPropVal support_obj "BASE_HEIGHT"
			format "BASE_HEIGHT: %\n" base_height
			
			--base_height = base_knot_pos.z - ground_knot_pos.z
			--base_height = SUPPORT_OPTIONS.base_height
			
			format "HAS_FOOT: %\n" has_foot
			--format "UPDATE SUPPORT\n"
			vertical_knots = getVerticalKnots()
			format "\nVERTICAL_KNOTS: %\n" vertical_knots
			
			
			/*==============================================================================
	
				IF HAS FOOT
			
			================================================================================*/
			if has_foot then
			(
				format "----------- HAS FOOT -----------\n"
				leg_knot_pos = getKnotPoint support_obj spline_1 leg_knot
				
				--foot_space_exists = leg_knot_pos.z >= minimal_support_height
				foot_space_exists =  if vertical_knots.count > 3 then getZposition vertical_knots[vertical_knots.count] >= minimal_support_height else leg_knot_pos.z >= minimal_support_height
				
				
				format "FOOT_SPACE_EXISTS: %\n" foot_space_exists
			
			
				/* SHIFT FOOT TO GROUND */ 
				if foot_space_exists then
				(
					format "SHIFT LEG KNOT %\n" leg_knot
					
					/* UPDATE LEG POINT */ 
					if getZposition leg_knot < minimal_support_height then
						setZposition leg_knot minimal_leg_pos_z
											
					/* UPDATE BASE POINT */ 
					setZposition base_knot base_height
	
				)
				/* REMOVE FOOT */ 
				else
		
					deleteKnot support_obj spline_1 ground_knot
					
				/* UPDATE GROUND POINT */ 
				setLastPointToGround()
			)
			
			/*==============================================================================
			
					IF HAS NOT FOOT
			
			================================================================================*/
			
			else 
			(
				format "----------- HAS NOT FOOT -----------\n"
			
				normal_length = getUserPropVal support_obj "NORMAL_LENGTH"
	
				/*------------------------------------------------------------------------------
					GET FOOT SPACE
				--------------------------------------------------------------------------------*/
				foot_space_exists = if vertical_knots.count == 0 then
					/* GET SPACE ON SKEEWED SUPPORT */
					( getZpositionByNormal normal_length ) >= minimal_leg_pos_z
	
				else /* GET SPACE ON VERTICAL SUPPORT */ 
					(getZposition vertical_knots[vertical_knots.count]) >= minimal_support_height
	
				--format "FOOT_SPACE_EXISTS: %\n" foot_space_exists
				
				
				/*------------------------------------------------------------------------------
					ADD FOOT
				--------------------------------------------------------------------------------*/
				if foot_space_exists then
				(
					/* ADD BASE POINT TO SKEEWED SUPPORT */
					if vertical_knots.count == 0 then
					(
						ground_knot_pos = extendRaftKnotToNormalLenght(base_knot_pos)(ground_knot_pos)(normal_length)
	
						addBasePoint(ground_knot_pos)(base_height) debug_message:"ADD BASE POINT %\n"
					)
					
					/* ADD BASE POINT TO VERTICAL SUPPORT */
					else
						setZposition vertical_knots[1] base_height debug_message:"SHIFT BASE KNOT %\n"
				
				
					
					/* ADD GROUND POINT */ 
					addKnot support_obj spline_1 #corner #line ground_knot_pos
					
					 /* SET GROUND POINT */ 
					setLastPointToGround()
					
					/* SET MATERIALS */ 
					this._setMaterialsToLineSegments()
				)
				
				/*------------------------------------------------------------------------------
					UPDATE SUPPORT WITHOUT FOOT
				--------------------------------------------------------------------------------*/
				else
				(
					/* DELETE VERTICAL POINTS BELOW BASE BUT NOT FIRST POINT  */ 
					if vertical_knots.count >= 2 then
						deleteVerticalPointsBellowMinimalSpace(vertical_knots)(chamfer_val)
					
					/*------------------------------------------------------------------------------
						UPDATE GROUND POINT WITHOUT FOOT
					--------------------------------------------------------------------------------*/
					--else if numKnots support_obj spline_1 == 2 then 
					if numKnots support_obj spline_1 == 2 then
						extendRaftKnotToGound()
					
					else /* SET GROUND POINT */ 
						setLastPointToGround()
	
				)
			)
			
			SUPPORT_MANAGER.updateShapeAdd (support_obj)
		)
		
	),
	
	
	private

	/** Get vertical knots
	 */
	function getVerticalKnots =
	(
			--format "\n"; print "SupportObject_v.getVerticalKnots()"
		/** Support is vertical
		 */
		function supportIsVertical knot =
		(
			--format "\n"; print "SupportObject_v.supportIsVertical()"
			fn roundFloat val  = ( local mult = 10.0 ^ 3; (floor ((val * mult) + 0.5)) / mult )
			
			knot_pos = getKnotPoint support_obj spline_1 knot
			upper_knot_pos = getKnotPoint support_obj spline_1 (knot - 1)
			--format "knot: %\n" knot
			--format "knot_pos:     %\n" knot_pos
			--format "upper_knot_pos: %\n" upper_knot_pos
			--format "\n"
			--format "roundFloat knot_pos.x:      %\n" (roundFloat knot_pos.x)
			--format "roundFloat upper_knot_pos.x: %\n" (roundFloat upper_knot_pos.x)
			--format "\n"
			--format "roundFloat knot_pos.y:      %\n" (roundFloat knot_pos.y)
			--format "roundFloat upper_knot_pos.y: %\n" (roundFloat upper_knot_pos.y)
			--
			support_is_vertical = roundFloat knot_pos.x == roundFloat upper_knot_pos.x and roundFloat knot_pos.y == roundFloat upper_knot_pos.y
			--format "support_is_vertical: %\n" support_is_vertical
			support_is_vertical --return
		)
		
		vertical_knots = #()
	
		for knot = ( numKnots support_obj spline_1 ) to 2 by -1 while supportIsVertical(knot) do
		(
			appendIfUnique vertical_knots knot
			
			appendIfUnique vertical_knots (knot - 1)
		)				
		
		vertical_knots --return
	),
	
	/** Set knot ground
	 */
	function setLastPointToGround =
	(
		--format "\n"; print "SupportObject_v.setKnotGround()"
		ground_knot     = numKnots support_obj spline_1
		ground_knot_pos = getKnotPoint support_obj spline_1 ground_knot
		
		ground_knot_pos.z = 0
		
		
		setKnotPoint support_obj spline_1 ground_knot ground_knot_pos
	),
	
	/** Set zposition
	 */
	function setZposition knot pos_z debug_message: =
	(
		--format "\n"; print "SupportObject_v.setZposition()"
		
		if debug_message != unsupplied then format debug_message knot
		
		knot_pos = getKnotPoint support_obj spline_1 knot
		
		knot_pos.z = pos_z
		
		setKnotPoint support_obj spline_1 knot knot_pos
	),
	
	/** Get zposition
	 */
	function getZposition knot = (getKnotPoint support_obj spline_1 knot).z
	
	/** Extend raft knot to normal lenght
	 */
	function extendRaftKnotToNormalLenght base_knot_pos ground_knot_pos normal_length =
	(
		--format "\n"; print "SupportObject_v.extendRaftKnotToNormalLenght()"
					
		line_vector = normalize ( ground_knot_pos - base_knot_pos)
		
		ground_knot_pos = base_knot_pos + ( normal_length * line_vector )
		
		setKnotPoint support_obj spline_1 ground_knot ground_knot_pos
	)
	
	/** Extend second point to gound
	 */
	function extendRaftKnotToGound =
	(
		--format "\n"; print "SupportObject_v.extendRaftKnotToGound()"
		first_knot_pos  = getKnotPoint support_obj spline_1 1
		second_knot_pos = getKnotPoint support_obj spline_1 2
		
		height_pos_1 = first_knot_pos.z
		
		line_vector = normalize ( first_knot_pos - second_knot_pos )

		angle_vectors = acos (dot [0,0,-1] line_vector) -- get angle between
		
		line_length = height_pos_1 / cos angle_vectors
		
		second_knot_pos = first_knot_pos + ( line_length * line_vector )
		
		setKnotPoint support_obj spline_1 2 second_knot_pos
	)
	
	/** Delete vertical points bellow minimal space
	 */
	function deleteVerticalPointsBellowMinimalSpace vertical_knots minimal_space =
	(
		--format "\n"; print "SupportObject_v.deleteVerticalPointsBellowMinimalSpace()"
		fn getKnotZposition knot = (getKnotPoint support_obj spline_1 knot).z
		
		--for index = 1 to vertical_knots.count - 1 where ( knot = vertical_knots[index] ) != 1 and getKnotZposition vertical_knots[index] < minimal_space do 
		for index = 1 to vertical_knots.count - 1 where ( knot = vertical_knots[index] ) != 1 and getKnotZposition vertical_knots[index] < minimal_space do 
			deleteKnot support_obj spline_1 knot
	)
	
	/** Add base point
	 */
	function addBasePoint knot_pos base_height debug_message: =
	(
		--format "\n"; print "SupportObject_v.addBasePoint()"
		if debug_message != unsupplied then format debug_message
		
		ground_knot_pos.z  = base_height
		
		addKnot support_obj spline_1 #corner #line ground_knot_pos
	),
	
	/** Get zposition by normal
	 */
	function getZpositionByNormal normal_length =
	(
		--format "\n"; print "SupportObject_v.getZpositionByNormal()"
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
