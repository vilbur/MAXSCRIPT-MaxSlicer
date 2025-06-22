clearListener(); print("Cleared in:\n"+getSourceFileName())


/** Grid of nodes_v
 */
struct GridSupportSeeder_v
(
	/* construct */
	target_objects,
	cell_size = 50,

	/* required */
	

	/* properties */
	grid_origin = [0,0],
	matrix,
	empty_cells = #(),
	
	num_cols,
	num_rows,
	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	
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
	
	/** Set grid
	 */
	function initGrid grid_objects =
	(
		--format "\n"; print "GridSupportSeeder_v.initGrid()"
		if classOf grid_objects != Array then grid_objects = #(grid_objects)
		
		min_x = 1e9
		min_y = 1e9
		max_x = -1e9
		max_y = -1e9

		for node in target_objects where isProperty node #position do
		(
			pos = node.position
			
			if node.min.x < min_x then min_x = node.min.x
			if node.min.y < min_y then min_y = node.min.y
			if node.max.x > max_x then max_x = node.max.x
			if node.max.y > max_y then max_y = node.max.y
		)
		
		this.grid_origin = [ min_x, min_y ]
		-- format "grid_origin: %\n" grid_origin
		
		num_cols = ceil ((max_x - min_x + 0.1) / cell_size)
		num_rows = ceil ((max_y - min_y + 0.1) / cell_size)
		
		/* Initialize matrix */ 
		matrix = for r = 1 to num_rows collect (for c = 1 to num_cols collect #())
	),

	function formatMatrixWithXYIndexes =
	(
		 -- format "\n"; print "GridSupportSeeder_v.formatMatrixWithXYIndexes()"
		result = ""
		-- format "matrix: %\n" matrix
		for y = 1 to matrix.count do
		(
			row = matrix[y]
			
			for x = 1 to row.count do
			(
				val = row[x]
				
				x_pos = grid_origin.x + ((x - 1) * cell_size) -- + (cell_size/2)
				y_pos = grid_origin.y + ((y - 1) * cell_size) -- + (cell_size/2)
				
				cell_pos = [ x_pos, y_pos, 0 ]
				
				if val.count == 0 then
				(
					hit = this.intersectRayWithObjects ( Ray cell_pos [0,0,1])
					-- format "hit: %\n" hit
					
					if hit != undefined then
						append empty_cells cell_pos
				)
			)
		)
		
		empty_cells
	),
	
	/*
	  Intersect ray only with specific objects.
	  Finds the closest intersection point with any of them.
	*/
	
	function intersectRayWithObjects ray =
	(
		closest_dist = 1e9
		closest_hit = undefined
	
		for obj in target_objects where isProperty obj #mesh and obj.mesh != undefined do
		(
			hit = intersectRay obj ray
	
			if hit != undefined then
			(
				dist = distance ray.pos hit.pos
				if dist < closest_dist then
				(
					closest_dist = dist
					closest_hit = hit
				)
			)
		)
	
		closest_hit -- return
	),


	private
	
	/**
	 */
	on create do
	(
		--format "\n"; print "GridSupportSeeder_v.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)


