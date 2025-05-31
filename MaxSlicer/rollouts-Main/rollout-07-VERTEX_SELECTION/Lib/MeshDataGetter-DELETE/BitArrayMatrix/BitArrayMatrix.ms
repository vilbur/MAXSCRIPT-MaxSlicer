/** Bit array matrix
 */
struct BitArrayMatrix_v
(
	/* construct */


	/* required */


	/* properties */
	keys	= #{},
	--values	= #{},
	values	= #(),

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Val
	 */
	function val key val =
	(
		--format "\n"; print "BitArrayMatrix_v.val()"

		if (val_exists = keys[key]) then
		(
		    index = this.dataIndex (key)

			insertItem val values index

		)
		else
		(
			keys[key] = true

		    index = dataIndex (key)

			insertItem val values index
		)

	),

	/** Get
	 */
	function get key =
	(
		--format "\n"; print "BitArrayMatrix_v.get()"
		--index = dataIndex (key)

		values[this.dataIndex (key)] --return
	),

	private

	/* Get index of verts_data by vertex number in this.positions|normlas|colors|
	*
	* Bitarray way to accomplish : findItem (this.verts_arr) face_id
	*/
	function dataIndex key =
	(
		----format "\n"; print "VertDataGetter_v.dataIndexVert()"
		--missing = -keys - #{key..(keys.numberSet)} -- find how many indexes is false before vertex_index
		--
		--if ( index = findItem keys key ) > 0 then
		--(
		--	missing = -keys - #{key..10000000} -- find how many indexes is false before vertex_index
		--
		--	index = key - missing.numberSet
		--
		--)
		--else
		--(
			missing = -keys - #{key..10000000} -- find how many indexes is false before vertex_index
		--
			index = key - missing.numberSet
		--
		--)
		--
		--
		--
		index --return

		 --findItem (this.keys as Array) key
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "BitArrayMatrix.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)


