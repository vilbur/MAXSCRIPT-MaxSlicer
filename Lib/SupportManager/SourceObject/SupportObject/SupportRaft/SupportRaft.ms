/** Support raft
 */
struct SupportRaft_v
(
	/* construct */
	Support, -- parent class

	/* required */
	/* properties */
	hit_raft,
	is_space_for_leg = true,
	foot_space_exists = true,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	
	/* COMPARE FLOATS - is A >= B */ 
	function isMoreThen A B = (( A as string ) as float ) >= (( B as string ) as float ),
	
	function raftLenght = (distance this.Support.points[1] this.Support.points[2]),

	/** Generate raft
	 */
	function createRaft =
	(
		--format "\n----------------------------------------------\n"
		--format "\n"; print "SupportRaft_v.createRaft()"
		-- format "Support.dir_vector:    %\n" Support.dir_vector
		--format "Support.normal_length: %\n" Support.normal_length

		function raftHasMinLenght     = isMoreThen ( this.raftLenght() )  ( Support.min_raft_length )
		function raftHasFullLenght    = isMoreThen ( this.raftLenght() )  ( Support.normal_length )
		function isSpaceForRaftAndLeg = isMoreThen ( Support.points[1].z) ( Support.min_raft_length + Support.min_leg_pos + 0.2 )

		function isLegPointAboveMinLimit min_z_pos = isMoreThen ( Support.points[2].z ) ( min_z_pos )

		function notSupportInMininmalMode = Support.dir_vector != [0,0,-1] --and ( Support.direction != #NORMAL or Support.direction != #CUSTOM )
		
		/* IF RAFT LENGTH IS 0 THEN MIN RAFT LENGTH IS USED */ 
		normal_length = if Support.normal_length > 0 then Support.normal_length else Support.min_raft_length

		/* SET 2nd POINT */ 
		Support.points[2] = Support.points[1] + ( normal_length * Support.dir_vector )

		/* TEST HIT SOURCE OBJECT */ 
	    hit_raft = this._testHitOfSourceObject( normal_length )
		-- format "HIT_RAFT: %\n" hit_raft
		/*------------------------------------------------------------------------------
			MODIFY RAFT LENGHT ABOVE GROUND
		--------------------------------------------------------------------------------*/

		if hit_raft == undefined then
		(
			/* EXTEND RAFT TO FULL LENGTH BEFORE UPDATE */ 
			if not raftHasFullLenght() then
				this._extendSecondPoint( normal_length )
			
			/* SHORTEN REAFT IF ITS TOO LONG and goes under min size of leg ( foot can not be created ) */ 
			if not isLegPointAboveMinLimit( Support.min_foot_pos ) then
				this._shortenRaftOnDirection( Support.min_foot_pos )
				--this._shortenRaftOnDirection( Support.min_foot_pos + 0.1 )

			/* IF RAFT IS TOO SHORT ( small support without foot ) */ 
			if not raftHasMinLenght() then
			(
				/* MAKE SURE THAT RAFT HAS MINIMAL LENGTH ( at least ) */ 
				this._extendSecondPoint( normal_length )
				
				/* SET RAFT POINT TO GROUND - if support is too low on the ground */ 
				if Support.points[2].z < Support.min_leg_pos then
					this._shortenRaftOnDirection( Support.min_leg_pos )
			)
			
			/* SUPPORT MINIMAL MODE - only 2 points straight to ground - if support has not minimla height */ 
			if Support.points[2].z > Support.points[1].z then
			(
				--format "NOT SPACE FOR RAFT AND LEG\n"
				pos = copy Support.points[1]
				
				pos.z = 0
				
				Support.points[2] = pos
			)
		)
		/*------------------------------------------------------------------------------
			GET POSITION OF HIT
		--------------------------------------------------------------------------------*/
		else
			Support.points[2] = hit_raft.pos
	
	
		
		/*------------------------------------------------------------------------------
			GET DATA ABOUT STATE OF SUPPORTs
		--------------------------------------------------------------------------------*/
		is_space_for_leg = isSpaceForRaftAndLeg()
		foot_space_exists = isLegPointAboveMinLimit( Support.min_foot_pos )
		--format "FOOT_SPACE_EXISTS: %\n" foot_space_exists
		
		/* SAVE DIR VECTOR IF SUPPORT IS NOT MINIMAL */ 
		if notSupportInMininmalMode() then 
			setUserPropVal Support.support_obj "DIR_VECTOR" Support.dir_vector
		
		--if raftHasFullLenght() then
		/* SAVE RAFT LENGTH IF NOT LOCKED, AUTO OR NOT SHORTENED */ 
		if not SUPPORT_OPTIONS.lock_normal_length and Support.normal_length > 0 and raftHasFullLenght() then
			setUserPropVal Support.support_obj "NORMAL_LENGTH" normal_length

	),
	
	/** Make raft shorter
	 */
	function _shortenRaftOnDirection pos_z =
	(
		--format "\n"; print "SupportRaft_v._shortenRaftOnDirection()"
		--format "pos_z: %\n" pos_z

		triangle_height = Support.points[1].z - pos_z
		--format "triangle_height: %\n" triangle_height
		--line_vector = normalize ( Support.points[1] - Support.points[2] )
		line_vector = Support.dir_vector
		
		--format "line_vector: %\n" line_vector

		angle_of_leg = acos (dot [0,0,-1] line_vector) -- get angle between
		--format "angle_of_leg: %\n" angle_of_leg

		raft_length = triangle_height / cos angle_of_leg
		--format "raft_length:  %\n" raft_length
		
		--if line_vector.z < 0 then
			Support.points[2] = Support.points[1] + ( raft_length * line_vector )
	),
	
	/** Extend raft knot to normal lenght
	  * 
	  * @return point3 coordinates of point extended to normal length
	 */
	function _extendSecondPoint raft_length =
	(
		--format "\n"; print "SupportRaftUpdater_v._extendSecondPoint()"
		--format "Support.dir_vector: %\n" Support.dir_vector
		--line_vector = normalize ( Support.points[2] - Support.points[1] )
		line_vector = Support.dir_vector
		--format "line_vector.z: %\n" line_vector.z
		
		--if line_vector.z < 0 then
		Support.points[2] = Support.points[1] + ( raft_length * line_vector )
	),
	
	/** Get secon point position
	 */
	function _testHitOfSourceObject max_distance =
	(
		-- format "\n"; print "SupportRaft_v._testHitOfSourceObject()"
		-- format "max_distance: %\n" max_distance
		
		ray_pos = Support.points[1]
		 
		hit = Support.intersectRaySourceObject (ray_pos)  ( Support.dir_vector )
		-- format "hit: %\n" hit
		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit != undefined and Support.obj_type == #SUPPORT and distance ray_pos hit.pos > max_distance then
			hit = undefined
		
		hit --return
	),
	
	
	/**
	 */
	on create do
	(
		--format "\n"; print "SupportRaft.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
