/** Point helper
 */
struct PointHelper_v
(
	/* construct */


	/* required */


	/* properties */

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate point helpers
	 */
	function generatePointHelpers vert pos: clr: nrml: =
	(
		format "\n"; print "PointHelper_v.generatePointHelpers()"



	),

	private


	/**
	 */
	on create do
	(
		--format "\n"; print "PointHelper.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
