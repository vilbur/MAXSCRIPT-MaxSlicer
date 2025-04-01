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
		format "\n"; print "SupportFoot_v.createFoot()"
		
		this._alignKnotToPreviousKnot index:3 pos_z:Support.base_height

		this._alignKnotToPreviousKnot index:4 pos_z:0
		
		Support.foot_exists = true
	),
	
	--/** Set foot to ground
	-- */
	--function setFootToGround =
	--(
	--	--format "\n"; print "SupportLeg_v.setFootToGround()"
	--	--format "Support.points_positions: %\n" Support.points_positions
	--	--
	--	Support.points_positions[3].z = Support.base_height
	--	
	--	Support.points_positions[4].z = 0
	--	--format "Support.points_positions: %\n" Support.points_positions
	--),
	
	private
	
	/** Align next knot bellow
	 */
	function _alignKnotToPreviousKnot index: pos_z: =
	(
		--format "\n"; print "SupportRaftUpdater_v._alignKnotToPreviousKnot()"
		pos = copy Support.points_positions[index - 1]
		
		pos.z = pos_z
		
		Support.points_positions[index] = pos
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
