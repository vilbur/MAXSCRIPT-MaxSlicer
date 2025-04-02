/** Support raft
 */
struct SupportRaft_v
(
	/* construct */
	Support, -- parent class

	/* required */
	/* properties */
	hit_raft,
	foot_space_exists = true,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate raft
	 */
	function createRaft =
	(
		format "\n"; print "SupportRaft_v.createRaft()"

		function isLegPointAboveMinimalLimit leg_point = ( leg_point as string ) as float >= ( Support.min_foot_pos as string ) as float
		
		function hasRaftMinimalLenght = ( (distance Support.points[1] Support.points[2]) as string ) as float > ( Support.min_raft_length as string ) as float

		format "Support.update_mode: %\n" Support.update_mode
		format "TEST: %\n" (Support.update_mode and not SUPPORT_OPTIONS.lock_normal_length)
		--normal_length = Support.normal_length
		
		/* USE MODIFIED NORMAL LENGHT - 2nd point is PIVOT of support */ 
		if Support.update_mode and not SUPPORT_OPTIONS.lock_normal_length then
			Support.points[2] = Support.support_obj.pos
		
		else /* LOCK NORMAL LENGTH */ 
			Support.points[2] = Support.points[1] + ( Support.normal_length * Support.dir_vector )
		
		normal_length_current = distance Support.points[1] Support.points[2]
		format "normal_length_current: %\n" normal_length_current
		
		format "\n"
		format "Support.min_leg_pos: %\n" Support.min_leg_pos
		format "Support.min_foot_pos: %\n" Support.min_foot_pos
		format "Support.points[2].z:    %\n" Support.points[2].z
		format "\n"
		
	    this._testHitOfSourceObject( Support.normal_length )
		
		
		has_leg_min_height = Support.points[1].z > Support.min_support_pos
		
		leg_space_exists = Support.points[1].z > Support.min_support_pos
		
		format "LEG_SPACE_EXISTS: %\n" leg_space_exists
		
		if hit_raft != undefined then
			Support.points[2] = hit_raft
	
		--else 
		--if Support.points[2].z < Support.min_leg_pos then
		--	--this._shortenRaftOnDirection( if has_leg_min_height then Support.min_leg_pos else Support.points[1].z - Support.min_raft_length )
		--	this._shortenRaftOnDirection( Support.min_leg_pos )
		--
		--
		--if not hasRaftMinimalLenght() then
		--	this._extendSecondPointToNormalLenght()
		

		foot_space_exists = isLegPointAboveMinimalLimit( Support.points[2].z )
		format "FOOT_SPACE_EXISTS: %\n" foot_space_exists
		
	),
	
	/** Make raft shorter
	 */
	function _shortenRaftOnDirection pos_z =
	(
		format "\n"; print "SupportRaft_v._shortenRaftOnDirection()"
		format "pos_z: %\n" pos_z

		triangle_height = Support.points[1].z - pos_z
		format "triangle_height: %\n" triangle_height
		line_vector = normalize ( Support.points[1] - Support.points[2] )

		angle_of_leg = acos (dot [0,0,-1] line_vector) -- get angle between
		format "angle_of_leg: %\n" angle_of_leg

		raft_length = triangle_height / cos angle_of_leg
		format "raft_length:  %\n" raft_length
		Support.points[2] = Support.points[1] + ( raft_length * line_vector )
	),
	
	/** Extend raft knot to normal lenght
	  * 
	  * @return point3 coordinates of point extended to normal length
	 */
	function _extendSecondPointToNormalLenght =
	(
		format "\n"; print "SupportRaftUpdater_v._extendSecondPointToNormalLenght()"
		line_vector = normalize ( Support.points[2] - Support.points[1] )
		
		Support.points[2] = Support.points[1] + ( Support.min_raft_length * line_vector ) -- return
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
