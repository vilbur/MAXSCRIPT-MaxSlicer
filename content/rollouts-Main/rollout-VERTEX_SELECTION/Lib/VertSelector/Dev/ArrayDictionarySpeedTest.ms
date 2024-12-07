clearListener(); print("Cleared in:\n"+getSourceFileName())




max_count = 5
--max_count = 1000
max_count = 4000
--max_count = 10000
--max_count = 100000	-- 100.000
--max_count = 100000	-- 1.000.000


dictionary_test = Dictionary #string
array_test = #()
bitarray_test = #()


--
--DICTIONARY_WRITE = timeStamp()
--for i = 1 to max_count do
--	dictionary_test[i as string ] = i
--format "\n DICTIONARY_WRITE: % ms\n" (( timeStamp()) - DICTIONARY_WRITE)
--
--
--DICTIONARY_READ = timeStamp()
--for key in dictionary_test.keys do
--	val = dictionary_test[key]
--format "\n DICTIONARY_READ: % ms\n" (( timeStamp()) - DICTIONARY_READ)
--





bit_arr = #{}

ARRAY_WRITE = timeStamp()
for i = 1 to max_count do
(
	bit_arr = #{(bit_arr.count + 1)..( 100 * (i) )}
	array_test[i] = bit_arr
)



format "\n ARRAY_WRITE: % ms\n" (( timeStamp()) - ARRAY_WRITE)


ARRAY_READ = timeStamp()
--for i = 1 to max_count do
	--format "array_test[i]: %\n" array_test[i]
--	--val = array_test[i] = i



format "array_test[100]: %\n" array_test[100]
format "array_test[3000]: %\n" array_test[3000]
for i = 1 to max_count where (found = array_test[i][150001] )==true do
	format "FOUND: %\n" array_test[i]
	--val = array_test[i] = i


format "\n ARRAY_READ: % ms\n" (( timeStamp()) - ARRAY_READ)





--BITARRAY_WRITE = timeStamp()
--for i = 1 to max_count do
--	array_test[i] = true
--format "\n BITARRAY_WRITE: % ms\n" (( timeStamp()) - BITARRAY_WRITE)
--
--
--BITARRAY_READ = timeStamp()
--for i = 1 to max_count do
--	val =  array_test[i]
--format "\n BITARRAY_READ: % ms\n" (( timeStamp()) - BITARRAY_READ)
