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
	is_space_for_leg = true,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate raft
	 */
	function createRaft =
	(
		format "\n"; print "SupportRaft_v.createRaft()"
		function isLegPointAboveMinimalLimit leg_point = ( leg_point as string ) as float >= ( Support.min_leg_length as string ) as float

		--format "\n"; print "SupportRaft_v._setSecondPointPosition()"
		--second_knot_vec = first_knot_pos + ( dir_vector * length_multiplier ) -- make raft longer by multiplying normal length 10x
		--normal_length_option = Support.normal_length

		/* KEEP MINIMAL LENGTH OF RAFT */ 
		normal_length = Support.normal_length
		
		Support.points[2] = Support.points[1] + ( Support.normal_length * Support.dir_vector )
		
		
	    this._testHitOfSourceObject( Support.normal_length )
		
		
		if hit_raft != undefined then
			Support.points[2] = hit_raft

		format "Support.points[2].z: %\n" Support.points[2].z
		if Support.points[1].z < Support.min_support_pos then
			Support.points[2].z = 0
		
		else
		if Support.points[2].z < Support.min_leg_length then
			Support.points[2] = this.shortenRaftOnDirection()
		
		
		is_space_for_leg = isLegPointAboveMinimalLimit(Support.points[2].z)

		
		--if second_point.z < Support.min_leg_length then
		--(
		--	
		--	second_point.z = Support.min_leg_length
		--	
		--	raft_is_full = false
		--)

		
		--Support.points[2] = if hit_raft == undefined then second_point else hit_raft

	),
	
	--/** Update raft
	-- */
	--function updateRaft =
	--(
	--	format "\n"; print "SupportRaft_v.updateRaft()"
	--	
	--	--raft_length = distance Support.points[1] Support.source_obj.pos
	--	raft_length = distance Support.points[1] Support.points[2]
	--
	--    this._testHitOfSourceObject ( raft_length )
	--
	--	format "TEST: %\n" (Support.points[2].z < Support.min_leg_length)
	--
	--
	--	if hit_raft != undefined then
	--		Support.points[2] = hit_raft
	--	
	--	/* KEEP MINIMAL LEG HEIGHT  */ 
	--	else if Support.points[2].z < Support.min_leg_length then
	--		Support.points[2].z = Support.min_leg_length
	--
	--),
	
	/** Make raft shorter
	 */
	function shortenRaftOnDirection =
	(
		format "\n"; print "SupportRaft_v._makeRaftShorter()"
		
		first_knot_pos  = Support.points[1]
		second_knot_pos = Support.points[2]
		
		--triangle_height = first_knot_pos.z - 0.1
		triangle_height = first_knot_pos.z - Support.min_leg_length
		
		line_vector = normalize ( first_knot_pos - second_knot_pos )
		
		angle_angle = acos (dot [0,0,-1] line_vector) -- get angle between
		
		raft_length = triangle_height / cos angle_angle
		
		first_knot_pos + ( raft_length * line_vector )
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
