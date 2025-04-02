/** Support raft
 */
struct SupportRaft_v
(
	/* construct */
	Support, -- parent class

	/* required */
	/* properties */
	hit_raft,
	is_space_for_foot = true,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate raft
	 */
	function createRaft =
	(
		--format "\n"; print "SupportRaft_v.createRaft()"

		function isLegPointAboveMinimalLimit leg_point = ( leg_point as string ) as float >= ( Support.min_leg_length as string ) as float
		
		function hasRaftMinimalLenght = ( (distance Support.points[1] Support.points[2]) as string ) as float > ( Support.min_raft_length as string ) as float

		
		/* KEEP MINIMAL LENGTH OF RAFT */ 
		normal_length = Support.normal_length
		
		Support.points[2] = Support.points[1] + ( Support.normal_length * Support.dir_vector )
		
		
	    this._testHitOfSourceObject( Support.normal_length )
		
		has_leg_min_height = Support.points[1].z > Support.min_support_pos
	
	
		if Support.points[2].z < Support.min_leg_length then
			this._shortenRaftOnDirection( if has_leg_min_height then Support.min_leg_length else Support.points[1].z - Support.min_raft_length )


		if not hasRaftMinimalLenght() then
			this._extendSecondPointToNormalLenght()
		

		is_space_for_foot = isLegPointAboveMinimalLimit( Support.points[2].z )
		--format "IS_SPACE_FOR_FOOT: %\n" is_space_for_foot
		
	),
	
	/** Make raft shorter
	 */
	function _shortenRaftOnDirection pos_z =
	(
		--format "\n"; print "SupportRaft_v._shortenRaftOnDirection()"

		triangle_height = Support.points[1].z - pos_z
		
		line_vector = normalize ( Support.points[1] - Support.points[2] )

		angle_angle = acos (dot [0,0,-1] line_vector) -- get angle between
		
		raft_length = triangle_height / cos angle_angle
		
		Support.points[2] = Support.points[1] + ( raft_length * line_vector )
	),
	
	/** Extend raft knot to normal lenght
	  * 
	  * @return point3 coordinates of point extended to normal length
	 */
	function _extendSecondPointToNormalLenght =
	(
		--format "\n"; print "SupportRaftUpdater_v._extendSecondPointToNormalLenght()"
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
