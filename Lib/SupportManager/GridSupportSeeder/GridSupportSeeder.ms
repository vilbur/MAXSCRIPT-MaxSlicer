clearListener(); print("Cleared in:\n"+getSourceFileName())


/** Grid of nodes_v
  
  
  Create grid of supports under target_objects where support is missing
  
  SCREEN: --"./Doc/select-verts-up-down.gif"
  
 */
struct GridSupportSeeder_v
(
	/* construct */
	target_objects,
	snapshot_sources = #(),
	grid_objects,
	cell_size = 50,

	/* required */
	

	/* properties */
	grid_origin = [0,0],
	matrix,
	hits = #(),
	
	num_cols,
	num_rows,
	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	
	/** Set grid
	 */
	function initGrid grid_objects =
	(
		--format "\n"; print "GridSupportSeeder_v.initGrid()"
		this.grid_objects = if classOf grid_objects != Array then #(grid_objects) else grid_objects
		
		min_x = 1e9
		min_y = 1e9
		max_x = -1e9
		max_y = -1e9

		for node in this.grid_objects where isProperty node #position do
		(
			pos = node.position
			
			if node.min.x < min_x then min_x = node.min.x
			if node.min.y < min_y then min_y = node.min.y
			if node.max.x > max_x then max_x = node.max.x
			if node.max.y > max_y then max_y = node.max.y
		)
		
		this.grid_origin = [ min_x, min_y ]
		 --format "GRID_ORIGIN: %\n" grid_origin
		
		num_cols = ceil ((max_x - min_x + 0.1) / cell_size)
		num_rows = ceil ((max_y - min_y + 0.1) / cell_size)
		
		/* Initialize matrix */ 
		matrix = for r = 1 to num_rows collect (for c = 1 to num_cols collect #())
	),
	
	/* 
	Sorts array of nodes into 2D matrix based on node position.x and position.y 
	*/
	function sortNodesToMatrix nodes =
	(
		 -- format "\n"; print "GridSupportSeeder_v.sortNodesToMatrix()"
		 -- format "nodes: %\n" nodes
		-- Create dictionary to hold cells
		
		cell_dict = #()
		
		-- format "grid_origin: %\n" grid_origin

		for node in nodes do
		(
			col = 1 + floor (( node.position.x - grid_origin.x) / cell_size )
			row = 1 + floor (( node.position.y - grid_origin.y) / cell_size )
			
			if row >= 1 and row <= num_rows and col >= 1 and col <= num_cols then
				append matrix[row][col] node
		)
		
		-- return
		matrix
	),
	
	/** Get closest verts of empty cells
	 */
	function getClosestVertsOfEmptyCells target_objects =
	(
		--format "\n"; print "GridSupportSeeder_v.getClosestVertsOfEmptyCells()"
		this.target_objects = if classOf target_objects != Array then #(target_objects) else target_objects

		
		closest_verts = #{}
		closest_verts_pos = #()
		
		empty_cells = this.getEmptyCells()
		
		this._convertTargetsToMeshSnapshots()
		
		for cell_pos in empty_cells do
		(
			closest_vert_pos = undefined
			hit_data = this.intersectRayWithObjects ( Ray cell_pos [0,0,1])
				 
			if hit_data != undefined then
			(
				closest_vert_pos = this._getClosestVert hit_data[1] hit_data[2] hit_data[3]
				
				if closest_vert_pos != undefined then 
					append closest_verts_pos closest_vert_pos
			)
		)
		
		this._removeSnapshots()
		
		closest_verts_pos --return
	),
	
	/** Get closest vert
	 */
	function _getClosestVert hitted_object hit_pos hitted_face =
	(
		-- format "\n"; print "GridSupportSeeder_v._getClosestVert()"
		verts_of_face = meshop.getVertsUsingFace hitted_object hitted_face
	
		closest_vert = -1
		closest_dist = 1e9
		closest_pos  = undefined
	
		for v in verts_of_face do
		(
			vpos = getVert hitted_object v
			
			dist = distance vpos hit_pos
			
			if dist < closest_dist then
			(
				closest_dist = dist
				closest_vert = v
				closest_pos  = vpos
			)
		)
		-- format "closest_pos: %\n" closest_pos
		closest_pos -- return
	),
	
	/** 
	  *	
	  */
	function getEmptyCells =
	(
		 -- format "\n"; print "GridSupportSeeder_v.getEmptyCells()"
		--for i = 1 to target_objects.count do
		--target_objects[i] = snapshotAsMesh target_objects[i]
		
		empty_cells	= #()
		
		for y = 1 to matrix.count do
		(
			row = matrix[y]
			
			for x = 1 to row.count do
			(
				objects_in_row = row[x]
				
				x_pos = grid_origin.x + ((x - 1) * cell_size) -- + (cell_size/2)
				y_pos = grid_origin.y + ((y - 1) * cell_size) -- + (cell_size/2)
				
				cell_center = [ x_pos, y_pos, 0 ]
				
				
				close_to_center_found = false
				
				--format "\n"
				for obj in grid_objects while not close_to_center_found do
				(
					_distance = distance cell_center obj.pos

					if _distance < cell_size / 2.5 then
						close_to_center_found = true
				)

				if not close_to_center_found then
					append empty_cells cell_center					
			)
		)

		empty_cells --return
	),
	
	/* Intersect ray only with specific objects.
	   Finds the closest intersection point with any of them.
	  
	  return #( Hitted object, postion of hit, hitted face )
	  
	*/
	function intersectRayWithObjects ray =
	(
		closest_dist  = 1e9
		closest_hit   = undefined
		hit_obj   = undefined
		result = undefined
	
		for obj in target_objects do
		(
			hit = IntersectRayEx obj ray
			
			if hit != undefined then
			(
				dist = distance ray.pos hit[1].pos
				
				if dist < closest_dist then
				(
					hit_obj = obj
					
					closest_dist = dist
					
					closest_hit = hit
				)
			)
		)
		
		
		if closest_hit != undefined then 
			result = #( hit_obj, closest_hit[1].pos, closest_hit[2] )
			
		result -- return
	),


	private
	
	/** Convert targets to mesh
	 */
	function _convertTargetsToMeshSnapshots =
	(
		-- format "\n"; print "GridSupportSeeder_v._convertTargetsToMeshSnapshots()"
		for i = 1 to target_objects.count where classOf target_objects[i] != Editable_mesh do
		(
			append snapshot_sources target_objects[i]
			
			target_objects[i].isHidden = true
			
			--format "target_objects[i]: %\n" target_objects[i]
			mesh_node = copy target_objects[i]
			
			collapseStack mesh_node
			
			convertToMesh mesh_node
			
			setUserPropVal mesh_node "GRID_SUPPORT_SEEDER_SNAPSHOT" true
			
			target_objects[i] = mesh_node
		)
	),
	
	/** Remove snapshots
	 */
	function _removeSnapshots =
	(
		/* DELETE SNAPSHOT OBJECTS */ 
		for i = target_objects.count to 1 by -1 where getUserPropVal target_objects[i] "GRID_SUPPORT_SEEDER_SNAPSHOT" != undefined do
			delete target_objects[i]
		
		/* SHOW SOURCE OBJECTS OF SNAPSHOTS */ 
		for snapshot_source in snapshot_sources do 
			snapshot_source.isHidden = false
	),
	
	/**
	 */
	on create do
	(
		--format "\n"; print "GridSupportSeeder_v.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)


