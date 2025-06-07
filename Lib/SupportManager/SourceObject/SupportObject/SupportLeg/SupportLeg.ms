/** Support raft
 */
struct SupportLeg_v
(
	/* construct */
	Support, -- parent class

	/* required */

	/* properties */
	hit_leg,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate leg - Make lione between LEG and BASE knots
	  *
	 */
	function createLeg bottom_point_pos_z =
	(
		--format "\n"; print "SupportLeg_v.createLeg()"
		--format "bottom_point_pos_z: %\n" bottom_point_pos_z
		
		hit_leg = this._testHitOfSourceObject()
		
		Support.points[3] = if hit_leg != undefined then hit_leg.pos else this._getBasePointPos (bottom_point_pos_z)
	),

	private
	
	/** Get base point
	 */
	function _getBasePointPos bottom_point_pos_z =
	(
		--format "\n"; print "SupportLeg_v._getBasePointPos()"
		
		base_point_pos = copy Support.points[2]
		
		base_point_pos.z = bottom_point_pos_z
		
		base_point_pos --return
	),
	
	/** Align next knot bellow
	 */
	function _alignKnotToPreviousKnot index: bottom_point_pos_z: =
	(
		--format "\n"; print "SupportRaftUpdater_v._alignKnotToPreviousKnot()"
		pos = copy Support.points[index - 1]
		
		pos.z = bottom_point_pos_z
		
		Support.points[index] = pos
	),
	
	/** Get secon point position
	 */
	function _testHitOfSourceObject =
	(
		--format "\n"; print "SupportObject_v._testHitOfSourceObject()"
		hit = Support.intersectRaySourceObject ( Support.points[2] ) [0,0,-1]
		
		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit != undefined and hit.pos.z <= 0 then
			hit = undefined

		hit --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportLeg.onCreate()"
	)
)