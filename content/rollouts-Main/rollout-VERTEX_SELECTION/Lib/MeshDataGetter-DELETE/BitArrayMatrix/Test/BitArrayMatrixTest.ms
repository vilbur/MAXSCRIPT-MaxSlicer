clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../BitArrayMatrix.ms" )	--"./../BitArrayMatrix.ms"

global max_count

--max_count = 10
--max_count = 1000
--max_count = 10000	-- 10.000
max_count = 4000	-- 10.000
--max_count = 100000	-- 100.000
--max_count = 100000	-- 1.000.000


/** Test other pes
 */
function testOtherTypes =
(
	--format "\n"; print ".testOtherPes()"
	dictionary_test = Dictionary #string
	array_test = #()
	bitarray_test = #()



	DICTIONARY_WRITE = timeStamp()
	for i = 1 to max_count do
		dictionary_test[i as string ] = i
	format "\n DICTIONARY_WRITE: % ms\n" (( timeStamp()) - DICTIONARY_WRITE)


	DICTIONARY_READ = timeStamp()
	for key in dictionary_test.keys do
		val = dictionary_test[key]
	format "\n DICTIONARY_READ: % ms\n" (( timeStamp()) - DICTIONARY_READ)


	ARRAY_WRITE = timeStamp()
	for i = 1 to max_count do
		array_test[i] = i
	format "\n ARRAY_WRITE: % ms\n" (( timeStamp()) - ARRAY_WRITE)


	ARRAY_READ = timeStamp()
	for i = 1 to max_count do
		val = array_test[i] = i
	format "\n ARRAY_READ: % ms\n" (( timeStamp()) - ARRAY_READ)



	BITARRAY_WRITE = timeStamp()
	for i = 1 to max_count do
		array_test[i] = true
	format "\n BITARRAY_WRITE: % ms\n" (( timeStamp()) - BITARRAY_WRITE)


	BITARRAY_READ = timeStamp()
	for i = 1 to max_count do
		val =  array_test[i]
	format "\n BITARRAY_READ: % ms\n" (( timeStamp()) - BITARRAY_READ)


)





--val = 25
----val = 15
--
--keys = #{1..3,5..10,20..50}
--
--format "WANTED keys val: %\n" (findItem (keys as Array ) val)
--
--
--missing = -keys - #{val..(keys.numberSet)} -- find how many indexes is false before vertex_index
--
--index =	val - missing.numberSet
--
--format "FIND: %\n" (findItem keys val )
--format "INDEX: %\n" index
--



testOtherTypes()

BitArrayMatrix 	= BitArrayMatrix_v()

BitArrayMatrix_WRITE = timeStamp()

for i = 1 to max_count do
(
	BitArrayMatrix.keys[i] = true




	BitArrayMatrix.val i i
)

format "\n BitArrayMatrix_WRITE: % ms\n" (( timeStamp()) - BitArrayMatrix_WRITE)


BitArrayMatrix_READ = timeStamp()

for i = 1 to max_count do
(
	val = BitArrayMatrix.get i

	--if val != i then
		--format "KEY AND VALUE DOES NOT MATCH: %\n" i

	--BitArrayMatrix.add i i
)

format "\n BitArrayMatrix_READ: % ms\n" (( timeStamp()) - BitArrayMatrix_READ)
