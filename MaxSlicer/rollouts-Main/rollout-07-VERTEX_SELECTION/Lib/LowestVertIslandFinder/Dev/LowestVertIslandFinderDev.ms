clearListener(); print("Cleared in:\n"+getSourceFileName())

/** Create test object
 */
function createTestObject =
(
		--format "\n"; print ".createTestObject()"
	
	--Plane length:100 width:100 pos:[ 0, 0, 50] isSelected:on backfacecull:off lengthsegs:20 widthsegs:20
	Box length:100 width:100 height:10 pos:[ 0, 0, 50] isSelected:on backfacecull:off lengthsegs:50 widthsegs:50 heightsegs:1
	--Plane length:100 width:100 pos:[ 0, 0, 50] isSelected:on backfacecull:off lengthsegs:2 widthsegs:2
	
	
	
	rotate $ ( AngleAxis 180 [1,0,0] )
	
	
	modPanel.addModToSelection (Noisemodifier scale:30 strength:[0,0,20] ) ui:on
	

)
/* 
Finds lowest vertices within search_verts
*/
function getLowestVertsGPT obj search_verts =
(
	format "getLowestVertsGPT()\n"
	result = #{}

	
	
	if classof obj == Editable_Poly or (isProperty obj #baseObject and classof obj.baseObject == Editable_Poly) then
	(
		vertex_count = getNumVerts obj.mesh
		verts_all = #{1..vertex_count}
		
		timer_pos = timeStamp()
		verts_pos = in coordsys world meshop.getVerts obj.mesh verts_all node:obj
		format "pos: % ms\n" (( timeStamp()) - timer_pos)
		
		timer_modify = timeStamp()
		select obj
		
		max modify mode

		subObjectLevel = 1
		format "modify: % ms\n" (( timeStamp()) - timer_modify)

		timer_A = timeStamp()
		PolyToolsSelect.Normal 3 140 true
		
		verts_normal_down = obj.getSelection #Vertex
		format "A: % ms\n" (( timeStamp()) - timer_A)
		
		timer_B = timeStamp()
		PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex and convex-concave

		verts_convex = obj.getSelection #Vertex
		format "B: % ms\n" (( timeStamp()) - timer_B)

		
		--format "verts_normal_down: %\n" verts_normal_down
		verts_to_process = (verts_normal_down * verts_convex) * search_verts 
		--format "verts_to_process: %\n" verts_to_process
		mesh_obj = obj.mesh
		
		for v = 1 to mesh_obj.numverts where verts_to_process[v] do
		(
			if mod v 100 == 0 then
			(
				format "v: %\n" v
			)
			
			verts_to_process[v] = false

			v_pos = verts_pos[v]
			lower_found = false

			faces = polyop.getFacesUsingVert obj v

			for f in faces while  not lower_found do
			(
				face_verts = polyop.getFaceVerts obj f

				for adj in face_verts where adj != v do
				(
					--adj_pos = polyop.getVert obj adj
					adj_pos = verts_pos[adj]

					if adj_pos.z < v_pos.z then
					
						lower_found = true
					else
						verts_to_process[adj] = false
				)
			)
			
			if not lower_found then result[v] = true
		)
	)

	result -- return
	
	
	
)
/* 
Finds lowest vertices within search_verts on TriMesh object
*/
function getLowestVertsTrimesh obj search_verts =
(
	result = #{}

	if (isProperty obj #mesh) and (isKindOf obj.mesh TriMesh) then
	(
		mesh_obj = obj.mesh

		vertex_count = mesh_obj.numverts

		-- ensure search_verts fits vertex count
		if search_verts.count < vertex_count do
			search_verts.count = vertex_count

		verts_to_process = search_verts as BitArray

		for v = 1 to vertex_count where verts_to_process[v] do
		(
			verts_to_process[v] = false

			v_pos = getVert obj v

			is_lowest = true

			faces = meshop.getFacesUsingVert mesh_obj v

			for f in faces while is_lowest do
			(
				face_verts = getFace mesh_obj f

				for i = 1 to 3 do
				(
					adj = face_verts[i]

					if adj != v then
					(
						if verts_to_process[adj] then
							verts_to_process[adj] = false

						adj_pos = getVert obj adj

						if adj_pos.z < v_pos.z then
							is_lowest = false
					)
				)
			)

			if is_lowest then result[v] = true
		)
	)

	result -- return
)

			

function getLowestVertsGemini obj search_verts =
(
    -- Initialize result BitArray. It will grow as needed.
    local result = #{} 

    if classof obj == Editable_Poly or (isProperty obj #baseObject and classof obj.baseObject == Editable_Poly) then
    (
        -- Store current sub-object level and set to Vertex for operation.
        local originalSubObjectLevel = subObjectLevel 
        subObjectLevel = 1

        -- Get all vertex positions once. This is efficient.

		PolyToolsSelect.Normal 3 140 true
		
		verts_normal_down = obj.getSelection #Vertex 
		
		verts_to_process = verts_normal_down * search_verts

        -- Calculate initial set of verts to process (intersection).
        local vertex_count = getNumVerts obj.mesh
        local verts_all = #{1..vertex_count}
        local verts_pos = in coordsys world meshop.getVerts obj.mesh verts_all node:obj
        
        -- IMPORTANT FOR COMPATIBILITY & CORRECTNESS:
        -- When iterating over a BitArray and modifying it inside the loop, 
        -- it's safest to iterate over a COPY of the BitArray.
        -- Modifications are then applied to the original 'verts_to_process'.
        local verts_to_iterate = copy verts_to_process

        -- Loop through the vertices that need processing.
        for v in verts_to_iterate do -- Iterate over the copy
        (
            -- Debugging output - remove in production for performance.
            -- if mod v 100 == 0 then
            -- (
            --     format "\n"
            --     format "v: %\n" v
            --     format "verts_to_process.numberSet: %\n" verts_to_process.numberSet
            -- )

            -- If this vertex has already been marked false by an adjacent check, skip it.
            -- This ensures we don't re-process vertices that have already been determined not lowest.
            if not verts_to_process[v] then continue 

            -- Mark the current vertex as processed in the ORIGINAL BitArray.
            verts_to_process[v] = false 
            
            -- This is a temporary BitArray `adj_verts` created in each iteration.
            local adj_verts = #{} 

            local v_pos = verts_pos[v]

            -- Get adjacent vertices via faces.
            local faces = polyop.getFacesUsingVert obj v
            for f in faces do
                adj_verts += (polyop.getFaceVerts obj f) as BitArray -- `+=` performs a union.

            local is_lowest = true
            
            -- Iterate through adjacent vertices while 'is_lowest' is true.
            -- The 'while is_lowest do' condition will make the loop exit early if set to false.
            for adj in adj_verts while is_lowest do
            (
                local adj_pos = verts_pos[adj]
            
                if adj_pos.z < v_pos.z then (
                    is_lowest = false -- Found a lower adjacent vertex, so current_v is not the lowest.
                )
                
                -- Optimization: If an adjacent vertex is found, it cannot be a "lowest" vertex 
                -- relative to 'current_v'. If it's *also* in 'verts_to_process', we can mark it
                -- as processed in the ORIGINAL 'verts_to_process' to avoid re-evaluating it later.
                -- This helps reduce the number of iterations in the outer loop.
                verts_to_process[adj] = false 
            )
            
            -- If after checking all adjacent vertices, no lower one was found, mark current_v as a result.
            if is_lowest then result[v] = true
        )
        
        -- Restore original sub-object level.
        subObjectLevel = originalSubObjectLevel
    )
    
    return result -- Return the final BitArray of lowest vertices
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
		
		verts_normal_down = obj.getSelection #Vertex 
		
		verts_to_process = verts_normal_down * search_verts
		
		vertex_count = getNumVerts obj.mesh
		verts_all = #{1..vertex_count}
		
		verts_pos = in coordsys world meshop.getVerts obj.mesh verts_all node:obj
		
		format "verts_to_process.numberSet: %\n" verts_to_process.numberSet

		for v in verts_to_process do
		(
			--if mod v 100 == 0 then
			--(
			--	format "v: %\n" v
			--)

			verts_to_process[v] = false
			
			adj_verts = #{}

			v_pos = verts_pos[v]
			
			--edges = polyop.getEdgesUsingVert obj v
			--for e in edges do
			--	adj_verts += ( polyop.getEdgeVerts obj e) as BitArray
		
			faces = polyop.getFacesUsingVert obj v
			for f in faces do
				adj_verts += ( polyop.getFaceVerts obj f) as BitArray
			
			--is_lowest = true
			--
			--for adj in adj_verts while is_lowest do
			--(
			--	adj_pos = verts_pos[adj]
			--
			--	if adj_pos.z < v_pos.z then is_lowest = false
			--	
			--	verts_to_process[adj] = false
			--)
			--
			--if is_lowest then result[v] = true
			
			lower_found = false
			
			for adj in adj_verts while not lower_found do
			(
				adj_pos = verts_pos[adj]
			
				if adj_pos.z < v_pos.z then
				
					lower_found = true
				else
					verts_to_process[adj] = false
				
			)
			
			if not lower_found then result[v] = true
			
			
		)
	)
	
	result -- return
)




--delete objects
--createTestObject()



_obj = selection[1]




format "\n\n"
snapshot_obj = snapshot _obj
convertTo snapshot_obj PolyMeshObject

timer_getLowestVertsGPT = timeStamp()

verts_to_check = #{1..( polyop.getNumVerts snapshot_obj)}
lowest_verts = #{}
format "verts_to_check: %\n" verts_to_check
try(
	lowest_verts = getLowestVertsGPT snapshot_obj verts_to_check
	
	format "getLowestVertsGPT: % ms\n" (( timeStamp()) - timer_getLowestVertsGPT)
	format "lowest_verts: %\n" lowest_verts
)catch(
	
	delete snapshot_obj
)

delete snapshot_obj

select _obj

max modify mode

--format "lowest_verts.numberSet: %\n" lowest_verts.numberSet

if classOf ( modPanel.getCurrentObject()) != Edit_Poly then
modPanel.addModToSelection (Edit_Poly ()) ui:on

subObjectLevel = 1
--_obj.SetSelection #Vertex lowest_verts
_obj.modifiers[#Edit_Poly].ButtonOp #UnhideAllVertex

_obj.modifiers[#Edit_Poly].Select #Vertex #{}
_obj.modifiers[#Edit_Poly].Select #Vertex lowest_verts




--
--
--timer_getLowestVertsGPT = timeStamp()
--
--convertTo _obj PolyMeshObject
--
--verts_to_check = #{1..( polyop.getNumVerts _obj)}
--
--lowest_verts = getLowestVertsGPT _obj verts_to_check
--
--format "getLowestVertsGemini: % ms\n" (( timeStamp()) - timer_getLowestVertsGPT)
--format "lowest_verts: %\n" lowest_verts
--subObjectLevel = 1
--_obj.SetSelection #Vertex lowest_verts
--



--timer_getLowestVertsGemini = timeStamp()
--
--lowest_verts = getLowestVertsGemini _obj verts_to_check
--
--format "getLowestVertsGemini: % ms\n" (( timeStamp()) - timer_getLowestVertsGemini)



--
--format "lowest_verts: %\n" lowest_verts
--
--select _obj
--
--modPanel.addModToSelection (Edit_Poly ()) ui:on
--
--subObjectLevel = 1
----_obj.SetSelection #Vertex lowest_verts
--_obj.modifiers[#Edit_Poly].Select #Vertex lowest_verts


