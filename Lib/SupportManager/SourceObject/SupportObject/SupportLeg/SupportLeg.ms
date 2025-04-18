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
	function createLeg pos_z =
	(
		--format "\n"; print "SupportLeg_v.createLeg()"
		--format "pos_z: %\n" pos_z
		
		this._testHitOfSourceObject()
		
		Support.points[3] = if hit_leg != undefined then hit_leg else this._getBasePointPos (pos_z)
	),
	
	--/** Update leg
	-- */
	--function updateLeg =
	--(
	--	format "\n"; print "SupportLeg_v.updateLeg()"
	--	
	--	this._alignKnotToPreviousKnot index:3 pos_z:0
	--	--this._alignKnotToPreviousKnot(3)(Support.base_height)
	--	
	--	--this._alignKnotToPreviousKnot(4)(0)
	--),


	private
	
	/** Get base point
	 */
	function _getBasePointPos pos_z =
	(
		--format "\n"; print "SupportLeg_v._getBasePointPos()"
		
		base_point_pos = copy Support.points[2]
		
		base_point_pos.z = pos_z
		
		base_point_pos --return
	),
	
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
		hit = Support.intersectRaySourceObject ( Support.points[2]) [0,0,-1]
		
		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit != undefined and hit.pos.z <= 0 then
			hit = undefined

			
		hit_leg = if hit != undefined then hit.pos else undefined --return
		
		hit_leg --return	
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportLeg.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
