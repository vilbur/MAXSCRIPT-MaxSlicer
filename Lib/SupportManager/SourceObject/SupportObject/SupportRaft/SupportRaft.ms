/** Support raft
 */
struct SupportRaft_v
(
	/* construct */
	SupportObject, -- parent class


	/* required */
	

	/* properties */
	first_knot_pos,
	dir_vector,

	--is_space_for_foot = true,
	hit_raft,
	raft_is_full = true,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate raft
	 */
	function createRaft first_knot_pos dir_vector =
	(
		--format "\n"; print "SupportRaft_v.createRaft()"
		
		this.dir_vector	= dir_vector
		this.first_knot_pos	= first_knot_pos
		
		/* ADD FIRST POINT */
		SupportObject.points_positions = #( first_knot_pos, undefined )
		
		
		/* ADD 2nd POINT */
		this._setSecondPointPosition()
		
		
	),

	private
	
	/** Get second point position
	 */
	function _setSecondPointPosition =
	(
		--format "\n"; print "SupportRaft_v._setSecondPointPosition()"
		--second_knot_vec = first_knot_pos + ( dir_vector * length_multiplier ) -- make raft longer by multiplying normal length 10x
		normal_length_option = SupportObject.normal_length

	    this._testHitOfSourceObject (normal_length_option)
		
		
		/* KEEP MINIMAL LENGTH OF RAFT */ 
		normal_length = normal_length_option

		second_point = first_knot_pos + ( normal_length * dir_vector )
		
		if second_point.z < SupportObject.min_leg_length then
		(
			second_point.z = SupportObject.min_leg_length
			
			raft_is_full = false
		)

		
		SupportObject.points_positions[2] = if hit_raft == undefined then second_point else hit_raft
		

	),

	/** Get secon point position
	 */
	function _testHitOfSourceObject max_distance =
	(
		--format "\n"; print "SupportObject_v._testHitOfSourceObject()"
		hit = SupportObject.intersectRaySourceObject ( SupportObject.points_positions[1]) ( dir_vector )
		
		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit != undefined and distance SupportObject.points_positions[1] hit.pos > max_distance then
			hit = undefined

			
		 if hit != undefined then
			hit_raft = hit.pos --return
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
