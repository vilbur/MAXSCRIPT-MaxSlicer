clearListener(); print("Cleared in:\n"+getSourceFileName())



/** Merge bit arrays with shared bits
 */
function mergeBitArraysTest1 bitarrays =
(
	--format "\n"; print ".mergeBitArraysTest1()"

	/** Merge bit arrays in bit array
	 */
	function mergeBitArraysInBitArray bit_array bitarrays_merged matches =
	(
		--format "\n"; print ".mergeBitArraysInBitArray()"
		for m = matches.count to 1 by -1 do
		(
			bit_array += bitarrays_merged[matches[m]]

			deleteItem bitarrays_merged matches[m]
		)

		append bitarrays_merged bit_array

		bitarrays_merged --return
	)

	bitarrays_merged = #(  )


	for bit_array in bitarrays do
	(
		format "\n--------------------\n"
		format "bit_array: %\n" bit_array

		matches =  for i = 1 to bitarrays_merged.count where not ( bit_array * bitarrays_merged[i] ).isEmpty collect i

		format "matches: %\n" matches

		case matches.count  of
		(
			/* ADD NEW BITARRAY */
			(0):	append bitarrays_merged bit_array

			/* JOIN TO EXISTING BITARRAY */
			(1): bitarrays_merged[matches[1]] += bit_array

			/*  (matches.count > 1)  MERGE MULTIPLE BITARRAYS if more than one amtch found */
			default: bitarrays_merged = mergeBitArraysInBitArray(bit_array)(bitarrays_merged)(matches)
		)


	)

	bitarrays_merged --return
)


/** Merge bit arrays test2
 */
function mergeBitArraysTest2 bitarrays =
(
	--format "\n"; print ".mergeBitArraysTest2()"

	for x = bitarrays.count to 1 by -1 do
	(
		merged = false

		for y = bitarrays.count to 1 by -1 where x != y and not ( bitarrays[x] * bitarrays[y] ).isEmpty do
		(
			bitarrays[y] += bitarrays[x]

			merged = true

		)

		if merged then
			deleteItem bitarrays x
	)


	bitarrays --return
)

--/** Merge bit arrays test2
-- */
--function mergeBitArraysTest3 bitarrays =
--(
--	--format "\n"; print ".mergeBitArraysTest2()"
--
--	merged_bitarrays = #()
--
--	if this.islands_all.count > 1 then
--	(
--		append merged_bitarrays this.islands_all[1]
--
--		deleteItem this.islands_all 1
--
--		for x = this.islands_all.count to 1 by -1 do
--		(
--
--			matches = for y = 1 to merged_bitarrays.count where ( this.islands_all[x] * bitarrays[y] ).isEmpty collect i
--
--
--
--		)
--
--
--
--	)
--
--
--
--)

bitarrays = #( #{1..3},  #{ 5..6, 8..9 },  #{3..5}, #{ 10..14 }, #{ 14..17 }, #{ 18..20 }  )
--bitarrays = #( #{1..3},  #{ 5..6, 8..9 },  #{3..5}, #{ 10..14 }, #{ 14..17 }, #{ 18..20 } , #{9..12}, #{17..18} )



--bitarrays_merged = mergeBitArraysTest1( bitarrays )
--bitarrays_merged = mergeBitArraysTest2( bitarrays )
bitarrays_merged = mergeBitArraysTest3( bitarrays )


format "bitarrays_merged: %\n" bitarrays_merged -- EXPECTED RESULT: #( #{ 1..6, 8..9 }, #{ 10..17 }, #{ 18..20 } )












