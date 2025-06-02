/** Support raft
 */
struct SupportFoot_v
(
	/* construct */
	Support, -- parent class


	/* required */
	

	/* properties */
	

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Create foot
	 */
	function createFoot =
	(
		--format "\n"; print "SupportFoot_v.createFoot()"
		--format "pos_z: %\n" (Support.base_height / EXPORT_SIZE )
		
		this._alignKnotToPreviousKnot index:3 pos_z:( Support.base_height / EXPORT_SIZE )

		this._alignKnotToPreviousKnot index:4 pos_z:0
		
		Support.foot_exists = true
	),
	
	--/** Set foot to ground
	-- */
	--function setFootToGround =
	--(
	--	--format "\n"; print "SupportLeg_v.setFootToGround()"
	--	--format "Support.points: %\n" Support.points
	--	--
	--	Support.points[3].z = Support.base_height
	--	
	--	Support.points[4].z = 0
	--	--format "Support.points: %\n" Support.points
	--),
	
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

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportFoot.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
