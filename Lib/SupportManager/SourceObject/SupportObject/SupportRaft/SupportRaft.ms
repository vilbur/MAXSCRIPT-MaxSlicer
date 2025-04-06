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

	/** Generate raft
	 */
	function createRaft =
	(
		--format "\n----------------------------------------------\n"
		--format "\n"; print "SupportRaft_v.createRaft()"
		format "Support.dir_vector: %\n" Support.dir_vector

		/* FOR PRECISE COMPARSION OF FLOATS */ 
		function  _float val = ( val as string ) as float
		
		/** GET LENGHT OF RAFT */
		function raftLenght = _float( distance Support.points[1] Support.points[2] )

		function isSpaceForRaftAndLeg = _float( Support.points[1].z ) >= _float( Support.min_raft_length + Support.min_leg_pos )
		
		function isLegPointAboveMinLimit min_z_pos = _float(Support.points[2].z ) >= _float( min_z_pos )
		
		function raftHasNormalLenght = raftLenght() >= _float( Support.normal_length )
		
		function raftHasMinLenght = raftLenght() >= _float( Support.min_raft_length )

		function notSupportInMininmalMode = (Support.direction != #NORMAL or Support.direction != #CUSTOM ) and Support.dir_vector != [0,0,-1]
		
		--is_space_for_leg = false
		--foot_space_exists = false
		--format "Support.update_mode: %\n" Support.update_mode
		--format "TEST: %\n" (Support.update_mode and not SUPPORT_OPTIONS.lock_normal_length)
		--normal_length = Support.normal_length
		
		/* USE MODIFIED NORMAL LENGHT - 2nd point is PIVOT of support */ 
		if Support.update_mode and not SUPPORT_OPTIONS.lock_normal_length then
			Support.points[2] = Support.support_obj.pos
		
		else /* LOCK NORMAL LENGTH */ 
			Support.points[2] = Support.points[1] + ( Support.normal_length * Support.dir_vector )
		
		raft_length = distance Support.points[1] Support.points[2]
		--format "min_raft_length: %\n" Support.min_raft_length
		----format "raft_length:     %\n" raft_length
		--
		--format "\n"
		--format "Support.min_leg_pos:  %\n" Support.min_leg_pos
		--format "Support.min_foot_pos: %\n" Support.min_foot_pos
		--format "Support.points[1].z:  %\n" Support.points[1].z
		--format "Support.points[2].z:  %\n" Support.points[2].z
		--format "Support.points[1]:  %\n" Support.points[1]
		--format "Support.points[2]:  %\n" Support.points[2]		
		--format "\n"
	    this._testHitOfSourceObject( Support.normal_length )
		--has_leg_min_height = Support.points[1].z > Support.min_support_pos
		--leg_space_exists = isLegPointAboveMinLimit( Support.min_leg_pos )

		--format "SUPPORT_SPACE_EXISTS: %\n" (isSpaceForRaftAndLeg())
		--format "LEG_SPACE_EXISTS:     %\n" (isLegPointAboveMinLimit( Support.min_leg_pos ))
		--format "RAFT IS SHORT:        %\n" (raftHasMinLenght())
		--format "HAS NORMAL LENGHT:    %\n" (raftHasNormalLenght())
		
		if hit_raft == undefined then
		(
			if isSpaceForRaftAndLeg() then
			(
				--format "IS SPACE FOR RAFT AND LEG\n"
				/* EXTEND RAFT TO FULL LENGTH BEFORE UPDATE */ 
				if not raftHasNormalLenght() then
					this._extendSecondPoint( Support.normal_length )
				
				/* SHORTEN REAFT IF ITS TOO LONG and goes under min size of leg ( foot can not be created ) */ 
				if not isLegPointAboveMinLimit( Support.min_foot_pos ) then
					this._shortenRaftOnDirection( Support.min_foot_pos )

				/* MAKE SURE THAT RAFT HAS MINIMAL LENGTH ( at least ) */ 
				if not raftHasMinLenght() then
				(
					--format "RAFT IS SHORT\n"
					this._extendSecondPoint(Support.min_raft_length)
					
					/* SET RAFT POINT TO GROUND - if support is too low on the ground */ 
					if Support.points[2].z > Support.points[1].z then
						Support.points[2].z = 0
				)
				
				--format "notSupportInMininmalMode: %\n" notSupportInMininmalMode
				if notSupportInMininmalMode() then 
					setUserPropVal Support.support_obj "DIR_VECTOR" Support.dir_vector

				if raftHasNormalLenght() then
					setUserPropVal Support.support_obj "NORMAL_LENGTH" Support.normal_length
				
			)
			/* SUPPORT MINIMAL MODE - only 2 points straight to ground - if support has not minimla height */ 
			else
			(
				--format "NOT SPACE FOR RAFT AND LEG\n"
				pos = copy Support.points[1]
				
				pos.z = 0
				
				Support.points[2] = pos
			)
		)
		else
			Support.points[2] = hit_raft
	
		is_space_for_leg = isSpaceForRaftAndLeg()
		foot_space_exists = isLegPointAboveMinLimit( Support.min_foot_pos )  
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
		--format "\n"; print "SupportRaft_v._testHitOfSourceObject()"
		
		ray_pos = Support.points[1]
		 
		hit = Support.intersectRaySourceObject (ray_pos)  ( Support.dir_vector )

		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit != undefined and distance ray_pos hit.pos > max_distance then
			hit = undefined

		
		hit_raft = if hit != undefined then hit.pos else undefined --return
		
		hit_raft --return	
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
