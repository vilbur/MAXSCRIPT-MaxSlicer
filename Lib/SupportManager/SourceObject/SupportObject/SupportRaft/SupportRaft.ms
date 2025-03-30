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

	points_positions,
	
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
		normal_length_option = SUPPORT_OPTIONS.normal_length

		SupportObject.points_positions[2] = first_knot_pos + ( normal_length_option * dir_vector )
	),

	/** Get secon point position
	 */
	function _getRaftHitPosition direction max_distance =
	(
		--format "\n"; print "SupportObject_v._getRaftHitPosition()"
		--format "points_positions[1]: %\n" points_positions[1]
		--format "max_distance: %\n" max_distance
		
		
		hit_raft = SupportObject.intersectRaySourceObject ( points_positions[1]) ( direction )
		
		
		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit_raft != undefined and distance points_positions[1] hit_raft.pos > max_distance then
			hit_raft = undefined


		 if hit_raft != undefined then
		 (
			--SupportRaftUpdater.foot_exists = false
			
			hit_raft.pos --return
		 )
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
