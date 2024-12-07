 /*
 */
struct SupportCreator_v
(
	/* construct */


	/* required */


	/* properties */


	/* private */
	/* dependency */
	SupportVertexFinder = SupportVertexFinder_v(),

	/* reference */
	/* inhered */

	/** /** Create supports
	 */
	function createSupports =
	(
		--format "\n"; print "SupportCreator_v.createSupports()"
		/* Get verts to create supports */
		/* Create Supports */



	),


	private


	/**
	 */
	on create do
	(
		--format "\n"; print "SupportCreator.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
