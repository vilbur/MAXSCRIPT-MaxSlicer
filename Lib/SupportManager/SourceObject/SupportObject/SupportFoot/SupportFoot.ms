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
		
		pos_ground = copy Support.points_positions[3]
		
		pos_ground.z = 0
		
		Support.points_positions[4] = pos_ground
		
		Support.foot_exists = true
	),
	
	/** Set foot to ground
	 */
	function setFootToGround =
	(
		--format "\n"; print "SupportLeg_v.setFootToGround()"
		format "Support.points_positions: %\n" Support.points_positions
		
		Support.points_positions[3].z = Support.base_height
		
		Support.points_positions[4].z = 0
		format "Support.points_positions: %\n" Support.points_positions
	),
	
	private


	/**
	 */
	on create do
	(
		--format "\n"; print "SupportFoot.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
