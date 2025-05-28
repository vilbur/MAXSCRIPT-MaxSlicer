/* 
Create a box with given size and segments, 
apply MeshSmooth with separate by smoothing groups enabled.
*/

function createWaveBox width:100 height:20 length:100 width_segs:20 height_segs:4 length_segs:20 =
(
	delete objects

	obj = box width:width height:height length:length widthsegs:width_segs heightsegs:height_segs lengthsegs:length_segs pos:[0,0, height]
	
	-- Collapse to Editable Mesh to allow MeshSmooth
	
	addModifier obj ( Noisemodifier strength:[0,0, height/2 ] scale:10 )
	
	addModifier obj ( meshsmooth sepBySmGroups:true )

	convertTo obj PolyMeshObject

	select obj
)-- return

-- Example usage:
--createWaveBox width:200 height:150 length:100 width_segs:6 height_segs:4 length_segs:5
createWaveBox()
