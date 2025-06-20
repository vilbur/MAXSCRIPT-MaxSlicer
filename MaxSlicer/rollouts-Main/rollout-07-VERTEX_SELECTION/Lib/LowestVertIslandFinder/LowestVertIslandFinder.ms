/** Lowest vert island finder
 */
struct LowestVertIslandFinder_v
(
	/* construct */
	obj,

	/* required */
	

	/* properties */
	verts_all,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/* 
	Finds lowest vertices within search_verts
	*/
	function getLowestVertsOfIslands search_verts =
	(
		format "getLowestVertsGPT()\n"
		result = #{}
		islands_data = #()
	
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
				
				if not lower_found then
				(
					island_data = Dictionary #( #LOWEST_VERT, v )
					
					island_data[#BOTTOM] = layers_count = ceil ( v_pos / SUPPORT_OPTIONS.layer_height)
					
					append islands_data island_data
				)
			)
		)
	
		--result -- return
		
		islands_data --return
	),

	private


	/**
	 */
	on create do
	(
		--format "\n"; print "LowestVertIslandFinder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
