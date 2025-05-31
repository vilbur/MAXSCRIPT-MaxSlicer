clearListener(); print("Cleared in:\n"+getSourceFileName())

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
)-- return

-- Example usage:
--createWaveBox width:200 height:150 length:100 width_segs:6 height_segs:4 length_segs:5
--obj = createWaveBox()

convex_down_verts = #{}

obj = selection[1] 

subObjectLevel = 1

PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex

convex_sel	= getVertSelection obj.mesh

PolyToolsSelect.ConvexConcave 0.0001 1 -- select concave

concave_sel	= getVertSelection obj.mesh

--PolyToolsSelect.Normal 3 90 true
PolyToolsSelect.Normal 3 120 true

normal_down	= getVertSelection obj.mesh

--convex_down_verts = convex_sel * normal_down
convex_down_verts = (convex_sel - concave_sel) * normal_down

--flat_verts = convex_sel * concave_sel
--
----$.modifiers[#Edit_Poly].SetSelection #Vertex #{}
--
--
--for vert in convex_sel where normal_down[vert] and not flat_verts[vert] do 
--(
--	--if normal_down[vert] and not flat_verts[vert] then
--		convex_down_verts[vert] = true
--	
--	
--)
--format "convex_down_verts: %\n" convex_down_verts
------corner_verts = convex_sel - concave_sel 
----
------concave_down_verts = ( convex_sel * normal_down ) - flat_verts
----
--------concave_down_verts = ( convex_sel * normal_down ) - flat_verts
------
------
------
----
------$.modifiers[#Edit_Poly].SetSelection #Vertex flat_verts
----$.modifiers[#Edit_Poly].SetSelection #Vertex convex_down_verts
obj.EditablePoly.SetSelection  #Vertex convex_down_verts