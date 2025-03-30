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
		
		ground_point = copy Support.points_positions[3]
		
		ground_point.z = 0
		
		Support.points_positions[4] = ground_point
		
		Support.foot_exists = true
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
