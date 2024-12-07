filein( getFilenamePath(getSourceFileName()) + "/../VertexLayers/VertexLayers.ms" )	--"./../VertexLayers/VertexLayers.ms"
filein( getFilenamePath(getSourceFileName()) + "/../VertexGridGetter/VertexGridGetter.ms" )	--"./../VertexGridGetter/VertexGridGetter.ms"

/** Grid layer manager
 */
struct GridLayerManager_v
(
	/* construct */
	obj,	-- editable poly object used to process

	/* required */


	/* properties */


	/* private */
	/* dependency */
	VertexLayers 	= VertexLayers_v(),
	VertexGrid 	= VertexGrid_v(),

	/* reference */
	/* inhered */



	private



	/** Set object
	 */
	function _setObject =
	(
		--format "\n"; print "GridLayerManager_v.setObject()"
		this.obj = this.obj_original

	),


	/**
	 */
	on create do
	(
		--format "\n"; print "GridLayerManager.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
		this._setObject()

	)





)
