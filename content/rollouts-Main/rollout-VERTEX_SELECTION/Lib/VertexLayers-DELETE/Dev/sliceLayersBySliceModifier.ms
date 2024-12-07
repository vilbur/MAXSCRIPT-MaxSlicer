clearListener(); print("Cleared in:\n"+getSourceFileName())

/** Merge bit arrays wich shared bits
  *
  * @param #( #{} ) bitarrays Array of bittarays
 */
function _mergeBitArraysbySharedBits bitarrays &bitarrays_merged =
(
	--format "\n"; print ".mergeBitArraysWithSharedBits()"
	--format "bitarrays: %\n" bitarrays
	--format "bitarrays_merged: %\n" bitarrays_merged

	/** Merge bit arrays in bit array
	 */
	function mergeBitArraysInBitArray bit_array matches &bitarrays_merged =
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

	for bit_array in bitarrays do
	(
		--format "\n--------------------\n"
		--format "bit_array: %\n" bit_array

		matches =  for i = 1 to bitarrays_merged.count where not ( bitarrays_merged[i] * bit_array ).isEmpty collect i
		--format "matches: %\n" matches
		--format "BITARRAYS_MERGED: %\n" bitarrays_merged
		--append bitarrays_merged bit_array

		--if matches.count == 0 then
		--	format "NEW ISLAND: %\n" bit_array

		case matches.count  of
		(
			/* ADD NEW BITARRAY */
			(0):	append bitarrays_merged bit_array

			/* JOIN TO EXISTING BITARRAY */
			(1): bitarrays_merged[matches[1]] += bit_array

			/*  (matches.count > 1)  MERGE MULTIPLE BITARRAYS if more than one amtch found */
			default: mergeBitArraysInBitArray(bit_array)(matches)(&bitarrays_merged)
		)
	)

	bitarrays_merged --return
)

/** Detach method
 */
function getElementsOfFaces obj =
(
	faces = #{1..( polyop.getNumFaces obj )}

	elements = #()

	while not faces.isEmpty do
    (
		face = (faces as array)[1]

		element = polyop.getElementsUsingFace obj #(face)

		if element != undefined then
		(
			append elements element

			faces -= element

		)
	)

	elements --return
)

/*------------------------------------------------------------------------------
	PREPARE SCENE
--------------------------------------------------------------------------------*/

--delete objects

segments = 5
--segments = 10
--segments = 20

--obj	= Plane width:100 length:100 pos:[ 0, 0, 20 ]  widthsegs:segments lengthsegs:segments
--
--select objects
--
--
--modPanel.addModToSelection (Noisemodifier scale:10 strength:[ 0, 0, 10 ] ) ui:on
--
--macros.run "Modifier Stack" "Convert_to_Poly"
--
--convertTo obj PolyMeshObject



obj = selection[1]

bbox	= ( nodeGetBoundingBox obj ( Matrix3 1) ) -- get bbox before slice

slice_mod = SliceModifier name:"SLICE_LAYERS" Slice_Type:2

addModifier obj slice_mod


format "bbox: %\n" bbox



size_z = bbox[2].z - bbox[1].z
format "size_z: %\n" size_z

--layer_height = 1
layer_height = 0.1

layers_count = (size_z / layer_height) as integer



layer_TM = Matrix3 1
layer_TM.position.z = bbox[1].z
layer_TM.position.z += layer_height -- set first layer


temp_TM =	layer_TM * ( Inverse obj.transform )

slice_mod.slice_plane.transform = temp_TM

format "layers_count: %\n" layers_count

elements_all = #()

loop_layers = timeStamp()
--format "\n loop_layers: % ms\n" (( timeStamp()) - loop_layers)
with redraw off
for layer = 1 to layers_count do
(
	layer_TM.position.z += layer_height

	--temp_TM =	temp_TM * ( Inverse obj.transform )
	if mod layer 100 == 0 then
		(format "layer: % of: %\n" layer layers_count)


	--temp_TM = getModContextTM obj slice_mod
	--temp_TM = slice_mod.slice_plane.transform
	--
	--slice_mod.slice_plane.transform.position.z += (layer_height * layer )
	--update obj
	--
	--format "slice_mod.slice_plane.transform.position.z: %\n" slice_mod.slice_plane.transform.position.z

	temp_TM =	layer_TM * ( Inverse obj.transform )

	slice_mod.slice_plane.transform = temp_TM


	elements = getElementsOfFaces (obj)

	_mergeBitArraysbySharedBits elements &elements_all


	--format "count: % elements: % elements_all: \n" elements.count elements elements_all
)

redrawViews()

format "\n loop_layers: % seconds\n" ((( timeStamp()) - loop_layers) / 1000.0)



