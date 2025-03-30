/** Support raft
 */
struct SupportLeg_v
(
	/* construct */
	SupportObject, -- parent class


	/* required */
	

	/* properties */
	

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate leg - Make lione between LEG and BASE knots
	  *
	 */
	function createLeg =
	(
		--format "\n"; print "SupportLeg_v.createLeg()"
		
		base_point = copy SupportObject.points_positions[2]
		
		base_point.z = SupportObject.base_height
		
		SupportObject.points_positions[3] = base_point
		
	),

	private


	/**
	 */
	on create do
	(
		--format "\n"; print "SupportLeg.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
