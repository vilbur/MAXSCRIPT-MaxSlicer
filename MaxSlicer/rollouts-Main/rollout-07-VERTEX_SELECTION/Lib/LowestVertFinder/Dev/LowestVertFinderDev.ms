clearListener(); print("Cleared in:\n"+getSourceFileName())

/** Create test object
 */
function createTestObject =
(
		--format "\n"; print ".createTestObject()"
	delete objects
	
	--Plane length:100 width:100 pos:[ 0, 0, 50] isSelected:on backfacecull:off lengthsegs:20 widthsegs:20
	Box length:100 width:100 height:10 pos:[ 0, 0, 50] isSelected:on backfacecull:off lengthsegs:20 widthsegs:20 heightsegs:1
	--Plane length:100 width:100 pos:[ 0, 0, 50] isSelected:on backfacecull:off lengthsegs:2 widthsegs:2
	
	
	
	rotate $ ( AngleAxis 180 [1,0,0] )
	
	
	modPanel.addModToSelection (Noisemodifier scale:30 strength:[0,0,20] ) ui:on
	
	convertTo $ PolyMeshObject

)
/* 
Search verts lower than all adjacent verts on editable poly
This function checks each vertex in given BitArray on Editable Poly object and
adds it to result BitArray if it is lower than all its connected (adjacent) vertices.
*/

function getLowestVerts obj search_verts =
(
	result = #{}
	
	if classof obj == Editable_Poly or (isProperty obj #baseObject and classof obj.baseObject == Editable_Poly) then
	(
		subObjectLevel = 1

		PolyToolsSelect.Normal 3 140 true
		
		bottom_verts = obj.getSelection #Vertex 
		
		verts_to_process = bottom_verts * search_verts
		
		vertex_count = getNumVerts obj.mesh
		verts_all = #{1..vertex_count}
		
		verts_pos = in coordsys world meshop.getVerts obj.mesh verts_all node:obj
		
		
		for v in verts_to_process do
		(
			if mod v 100 == 0 then
			(
				format "\n"
				format "v: %\n" v
				format "verts_to_process.numberSet: %\n" verts_to_process.numberSet
			)

			verts_to_process[v] = false
			
			adj_verts = #{}

			v_pos = verts_pos[v]
			--edges = polyop.getEdgesUsingVert obj v
			--for e in edges do
			----	adj_verts += ( polyop.getEdgeVerts obj e) as BitArray
		
			faces = polyop.getFacesUsingVert obj v
			for f in faces do
				adj_verts += ( polyop.getFaceVerts obj f) as BitArray
			
			is_lowest = true
			
			for adj in adj_verts while is_lowest do
			(
				adj_pos = verts_pos[adj]
			
				if adj_pos.z < v_pos.z then is_lowest = false
				
				verts_to_process[adj] = false
			)
			
			if is_lowest then result[v] = true
		)
	)
	
	result -- return
)

--createTestObject()

obj = selection[1]
 
verts_to_check = #{1..(polyop.getNumVerts obj)}

lowest_verts = getLowestVerts obj verts_to_check


format "lowest_verts: %\n" lowest_verts

subObjectLevel = 1
obj.SetSelection #Vertex lowest_verts
