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
		--format "Support.dir_vector: %\n" Support.dir_vector

		--function isSpaceForRaftAndLeg = ( Support.points[1].z as string ) as float >= ( Support.min_support_pos as string ) as float
		--function isSpaceForRaftAndLeg = ( Support.points[1].z as string ) as float >= ( Support.min_raft_length as string ) as float
		function isSpaceForRaftAndLeg = ( Support.points[1].z as string ) as float >= ( (Support.min_raft_length + Support.min_leg_pos ) as string ) as float
		
		function isLegPointAboveMinLimit min_z_pos = ( Support.points[2].z as string ) as float >= ( min_z_pos as string ) as float
		
		function raftIsShort = ( (distance Support.points[1] Support.points[2]) as string ) as float <= ( Support.min_raft_length as string ) as float
		
		function raftHasNormalLenght = ( (distance Support.points[1] Support.points[2]) as string ) as float >= ( Support.normal_length as string ) as float

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
		--format "RAFT IS SHORT:        %\n" (raftIsShort())
		--format "HAS NORMAL LENGHT:    %\n" (raftHasNormalLenght())
		
		if hit_raft == undefined then
		(
			if isSpaceForRaftAndLeg() then
			(
				--format "IS SPACE FOR RAFT AND LEG\n"
				--format "not raftHasNormalLenght(): %\n" (not raftHasNormalLenght())
				if not raftHasNormalLenght() then
				(
					
					this._extendSecondPoint(Support.normal_length)
				)
				
				--/* IF SPACE FOR LEG EXISTS */ 
				if not isLegPointAboveMinLimit( Support.min_foot_pos ) then
				(
					--format "SPACE FOR LEG EXISTS\n"
					
					this._shortenRaftOnDirection( Support.min_foot_pos )
				)
				----	--this._shortenRaftOnDirection( if has_leg_min_height then Support.min_leg_pos else Support.points[1].z - Support.min_raft_length )
				--
				if raftIsShort() then
				(
					--format "RAFT IS SHORT\n"
					this._extendSecondPoint(Support.min_raft_length)
					
					--format "Support.points[1].z:  %\n" Support.points[1].z
					--format "Support.points[2].z:  %\n" Support.points[2].z
					
					--format "TEST: %\n" (Support.points[2].z > Support.points[1].z)
					/* SET RAFT POINT TO GROUND - if support is too low on the ground */ 
					if Support.points[2].z > Support.points[1].z then
						Support.points[2].z = 0
				)
				
				setUserPropVal Support.support_obj "DIR_VECTOR" Support.dir_vector
				
			)
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
	
		--format "\n"
		--format "Support.min_foot_pos: %\n" Support.min_foot_pos
		--format "Support.points[2].z:  %\n" Support.points[2].z
		
		--format "RAFT IS SHORT:        %\n" (raftIsShort())
		is_space_for_leg = isSpaceForRaftAndLeg()
		foot_space_exists = isLegPointAboveMinLimit( Support.min_foot_pos )  
		--
		--format "IS_SPACE_FOR_RAFT_AND_LEG: %\n" (is_space_for_leg)
		--format "FOOT_SPACE_EXISTS:         %\n" (foot_space_exists )
		
		
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
