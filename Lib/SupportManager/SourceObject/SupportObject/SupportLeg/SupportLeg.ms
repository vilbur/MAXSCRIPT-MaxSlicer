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

		if Support.points[3].z > 0 then
		(
			hit_leg = this._testHitOfSourceObject()
			
			if hit_leg != undefined then
				bottom_point_pos_z = hit_leg.pos.z
			
			
			Support.points[4] = this._alignKnotToPreviousKnot index:4 pos_z:bottom_point_pos_z
		)
	),

	private
	
	
	/** Align next knot bellow
	 */
	function _alignKnotToPreviousKnot index: pos_z: =
	(
		--format "\n"; print "SupportRaftUpdater_v._alignKnotToPreviousKnot()"
		pos = copy Support.points[index - 1]
		
		pos.z = pos_z
		
		Support.points[index] = pos
	),
	
	/** Get secon point position
	 */
	function _testHitOfSourceObject =
	(
		--format "\n"; print "SupportObject_v._testHitOfSourceObject()"
		--Point pos:Support.points[3] size:1
		hit = Support.intersectRaySourceObject ( Support.points[3] ) [0,0,-1]
		--format "hit: %\n" hit
		/*  */
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