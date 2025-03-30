/** Support raft
 */
struct SupportRaft_v
(
	/* construct */
	Support, -- parent class


	/* required */
	

	/* properties */
	--first_knot_pos,
	--dir_vector,

	--is_space_for_foot = true,
	hit_raft,
	raft_is_full = true,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate raft
	 */
	function createRaft =
	(
		--format "\n"; print "SupportRaft_v.createRaft()"
	
		--format "\n"; print "SupportRaft_v._setSecondPointPosition()"
		--second_knot_vec = first_knot_pos + ( dir_vector * length_multiplier ) -- make raft longer by multiplying normal length 10x
		--normal_length_option = Support.normal_length

		/* KEEP MINIMAL LENGTH OF RAFT */ 
		normal_length = Support.normal_length
		
		
	    this._testHitOfSourceObject( Support.normal_length )
		

		second_point = Support.points_positions[1] + ( Support.normal_length * Support.dir_vector )
		
		if second_point.z < Support.min_leg_length then
		(
			second_point.z = Support.min_leg_length
			
			raft_is_full = false
		)

		
		Support.points_positions[2] = if hit_raft == undefined then second_point else hit_raft

	),
	
	/** Update raft
	 */
	function updateRaft =
	(
		format "\n"; print "SupportRaft_v.updateRaft()"
		
		--raft_length = distance Support.points_positions[1] Support.source_obj.pos
		raft_length = distance Support.points_positions[1] Support.points_positions[2]

	    this._testHitOfSourceObject ( raft_length )
	
		if hit_raft != undefined then
			Support.points_positions[2] = hit_raft
			
	),
	

	/** Get secon point position
	 */
	function _testHitOfSourceObject max_distance =
	(
		format "\n"; print "SupportObject_v._testHitOfSourceObject()"
		
		ray_pos = Support.points_positions[1]
		
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
