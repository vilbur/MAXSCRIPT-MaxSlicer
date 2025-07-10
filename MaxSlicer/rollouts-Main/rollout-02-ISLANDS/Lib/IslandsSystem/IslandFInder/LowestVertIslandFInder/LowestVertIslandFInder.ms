/** Lowest island per layer finder
 */
struct LowestVertIslandFinder_v
(
	/* construct */
	obj,

	/* required */
	

	/* properties */
	verts_all,
	verts_process,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/* 
	Finds lowest vertices within search_verts
	*/
	function getLowestVertsOfIslands =
	(
		 format "\n"; print "LowestVertIslandFinder_v.getLowestVertsOfIslands()"
		-- format "classof obj: %\n" (classof obj)
		--result = #{}
		islands_data = #()
		
		lowest_verts = verts_all * #{}
	
		format "verts_process[287878]: %\n" verts_process[287878]
	
		format "verts_process.numberSet: %\n" verts_process.numberSet
	
		if classof obj == Editable_Poly then
		(
			timer_verts_pos = timeStamp()
			verts_pos = in coordsys world meshop.getVerts obj.mesh verts_all node:obj
			format "verts_pos: % ms\n" (( timeStamp()) - timer_verts_pos)

			mesh_obj = obj.mesh
			
			
			numverts = mesh_obj.numverts
			
			for v = 1 to numverts where verts_process[v] do
			(
				if mod v 1000 == 0 then
					  FORMAT "%\% of verts checked\n" (v  / (numverts / 100 ))
					  --FORMAT "% of %\n" v numverts
				
					
				
				verts_process[v] = false
	
				v_pos = verts_pos[v]
				--if v == 287878 then
					--format "V_POS: %\n" v_pos
				
				lower_found = false
	
				faces = polyop.getFacesUsingVert obj v
	
				for f in faces while lower_found == false do
				(
					face_verts = polyop.getFaceVerts obj f
	
					--for adj in face_verts where adj != v do
					for adj in face_verts while lower_found == false where adj != v do
					(
						adj_pos = verts_pos[adj]
				
						/* LOWER FOUND */ 
						if v_pos.z > adj_pos.z then
						(
							lower_found = adj
							
							--lowest_verts[adj] = true
							
							--if not verts_process[lower_found] then
								--lowest_verts[lower_found] = true
								
							verts_process[adj] = true
							
						)
						/* LOWER NOT FOUND */ 
						else
						(
							verts_process[adj] = false
							
							--lowest_verts[adj] = false
						)
					)
				)
				
				--if v == 287878 then
					--format "lower_found: %\n" lower_found

				
				
				if lower_found == false then
					lowest_verts[v] = true
				

				--if v == 287878 then
					--format "lowest_verts[v]: %\n" lowest_verts[v]
				
				--if not lower_found then 
				--(
				--	island_data = Dictionary #( #LOWEST_VERT, v )
				--	
				--	island_data[#BOTTOM] = layers_count = ceil ( v_pos.z / SUPPORT_OPTIONS.layer_height ) as integer 
				--	
				--	island_data[#LOWEST_VERT] = island_data[#BOTTOM]
				--	
				--	append islands_data island_data
				--)
			)
			
			--format "lowest_verts: %\n" lowest_verts
			--format "lowest_verts: %\n" lowest_verts.count
			
			for v in lowest_verts do 
			(
				island_data = Dictionary()
				
				island_data[#LOWEST_VERT] = v 
			
				island_data[#BOTTOM] = ceil ( verts_pos[v].z / SUPPORT_OPTIONS.layer_height ) as integer 
				
				append islands_data island_data
			)
			
			
		)
		
		--format "\n\n\n"
		
		--for island_data in islands_data do
		--format "island_data: %\n" island_data[#LOWEST_VERT]
		
		--sorted = this.sortDictArrayByBottomKey(islands_data) --return
			--format "sorted: %\n" sorted
		--islands_data --return
		this.sortDictArrayByBottomKey(islands_data) --return --return
	),

	private
	
	
	/*
	  Sorts array of dictionaries in ascending order by #BOTTOM key
	*/
	function sortDictArrayByBottomKey dict_array =
	(
		-- format "\n"; print "LowestVertIslandFinder_v.sortDictArrayByBottomKey()"
		-- format "dict_array: %\n" dict_array
		/*
		  Comparison function for sorting dictionaries by key #BOTTOM
		*/
		function compareDictByBottom a b =
		(
			case of
			(
				(a[#BOTTOM] < b[#BOTTOM]): -1
				(a[#BOTTOM] > b[#BOTTOM]): 1
				default: 0
			)
		)
		
		qsort dict_array compareDictByBottom
		
		dict_array --return
	),


	/**
	 */
	on create do
	(
		--format "\n"; print "LowestVertIslandFInder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )

		
	)

)
