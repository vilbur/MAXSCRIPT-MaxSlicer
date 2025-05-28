clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../NewIslandFinder.ms" )	--"./../NewIslandFinder.ms"


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
	
	obj --return
)


--obj = createWaveBox()
obj = selection[1]

NewIslandFinder 	= NewIslandFinder_v(obj)

lowest_verts = NewIslandFinder.getVerts()

--lowest_verts = isVertexLowestOnZ obj -- select an Editable_Poly object and run this

format "lowest_verts: %\n" lowest_verts
subObjectLevel = 1

_mod	= modPanel.getCurrentObject()

if classof _mod == Edit_Poly then
(
	_mod.SetSelection #Vertex #{}
	
	_mod.Select #Vertex lowest_verts
)
else
	_mod.SetSelection #Vertex lowest_verts

