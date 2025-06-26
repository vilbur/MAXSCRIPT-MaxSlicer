clearListener(); print("Cleared in:\n"+getSourceFileName())


/** Grid of nodes_v
  
  
  Create grid of supports under target_objects where support is missing
  
  SCREEN: --"./Doc/select-verts-up-down.gif"
  
 */
struct GridSupportSeeder_v
(
	/* construct */
	grid_objects,
	cell_objects,
	target_objects,
	intersect_objs,
	
	cell_size = 50,
	/* required */
	

	/* properties */
	grid_origin = [0,0],
	matrix,
	
	closest_verts_pos,
	search_treshold = 1.5, -- how far from cell center is searched for grid object 
	--search_treshold = 2.0, -- how far from cell center is searched for grid object 
	
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
		max_x = -1e9
		min_y = 1e9
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
		
		point pos:[ min_x, min_y, 0 ]
		point pos:[ max_x, max_y, 0 ]
		--plane pos:grid_origin width:( max_x - min_x ) length:( max_y - max_y )
		
		num_cols = ceil ((max_x - min_x + 0.1) / cell_size)
		num_rows = ceil ((max_y - min_y + 0.1) / cell_size)
		
		/* Initialize matrix */ 
		matrix = for r = 1 to num_rows collect (for c = 1 to num_cols collect #())
	),
	
	/* 
	Sorts array of nodes into 2D matrix based on node position.x and position.y 
	*/
	function sortNodesToMatrix cell_objects =
	(
		 -- format "\n"; print "GridSupportSeeder_v.sortNodesToMatrix()"
		 -- format "nodes: %\n" nodes
		this.cell_objects = if classOf cell_objects != Array then #(cell_objects) else cell_objects
		
		cell_dict = #()
		
		for node in cell_objects do
		(
			col = 1 + floor (( node.position.x - grid_origin.x) / cell_size )
			row = 1 + floor (( node.position.y - grid_origin.y) / cell_size )
			
			if row >= 1 and row <= num_rows and col >= 1 and col <= num_cols then
				append matrix[row][col] node
		)
		
		matrix -- return
	),
	
	/** Get closest verts of empty cells
	  
		@param #VERTS|#HITS mode
	  
	 */
	function getClosestVertsOfEmptyCells target_objects mode =
	(
		--format "\n"; print "GridSupportSeeder_v.getClosestVertsOfEmptyCells()"

		
		this.target_objects = if classOf target_objects != Array then #(target_objects) else target_objects

		closest_verts_pos = Dictionary #STRING
		
		empty_cells = this.getEmptyCells()
		
		this._convertTargetsToMeshSnapshots()
		
		/* LOOP EMPTY CELLS */ 
		for cell_center in empty_cells do
		(
			--format "\n"
			/* TEST CENTER OF CELL */ 
			hit_data = this._testHit cell_center mode

			if hit_data == undefined then
				this._testPositionsAroundCenterOfCell(cell_center)(mode)
		)
		
		this._removeSnapshots()

		closest_verts_pos --return
	),
	
	/** Test positions in cicrles around center of cell
	 */
	function _testPositionsAroundCenterOfCell cell_center mode =
	(
		--format "\n"; print "GridSupportSeeder_v._testPositionsAroundCenterOfCell()"
		--increment = 60
		
		--radiuses = #( cell_size / 2 / 3, cell_size / 2 / 1.5 )
		ratios = #( 3.0, 1.2 )
		
		
		/*------------------------------------------------------------------------------
			TEST CIRCLES OF POSITIONS AROUND CENTER OF CELL
		--------------------------------------------------------------------------------*/
		--for radius in radiuses while hit_data == undefined do 
		for ratio in ratios while hit_data == undefined do 
		(
			radius = cell_size / 2 / ratio	
			
			point_pos = cell_center + [ radius, 0, 0 ]
			
			--increment_count = increment / ratio
			increment = if ratio == 3 then 60 else 30 -- add more test if radius is bigger

			/*------------------------------------------------------------------------------
				TEST EACH ANGLE
			--------------------------------------------------------------------------------*/
			for i = 1 to 360 / increment while hit_data == undefined do
			(
				rotate_about = increment * i
				
				moved_pos = this.movePointOnCircleDeg cell_center radius point_pos rotate_about
				--format "moved_pos: %\n" moved_pos
				--Sphere pos:moved_pos radius:0.1 wirecolor:orange
				
				hit_data = this._testHit moved_pos mode
			)
		)
		
	),
	
	
	/** Test hit
	 */
	function _testHit pos mode =
	(
		--format "\n"; print "GridSupportSeeder_v._testHit()"
		
		hit_data = this._intersectRayWithObjects ( Ray pos [0,0,1] )
		
		if hit_data != undefined then
		(
			grid_object = grid_objects[findItem intersect_objs hit_data[1]]
			
			this.appendClosestVert( grid_object )( if mode == #HITS then hit_data[2] else this._getClosestVertToHit hit_data[1] hit_data[2] hit_data[3] )
			--this.appendClosestVert( grid_object )( pos )
		)
		
		 hit_data--return
	),
	
	/** Append closest vert
	 */
	function appendClosestVert grid_object vert_or_pos =
	(
		--format "\n"; print "GridSupportSeeder_v.appendClosestVert()"
		if vert_or_pos != undefined then 
		(
			pointer = (getHandleByAnim grid_object) as string

			if this.closest_verts_pos[pointer] == undefined then
				this.closest_verts_pos[pointer] = #()
				
			appendIfUnique this.closest_verts_pos[pointer] vert_or_pos
		)
	),
	
	/** 
	Move point along a circle by rotation angle using only degrees
	*/
	function movePointOnCircleDeg center_pos radius point_pos angle_deg =
	(
		-- Vector from center to point
		vec = point_pos - center_pos
	
		-- Get current angle in degrees
		current_angle = atan2 vec.y vec.x * 180 / pi
	
		-- Add rotation in degrees
		new_angle = current_angle + angle_deg
	
		-- Convert to position using degrees
		new_x = cos(new_angle) * radius
		new_y = sin(new_angle) * radius
	
		-- Final position on circle
		new_pos = center_pos + [new_x, new_y, 0]
	
		new_pos -- return
	),
	
	/** Get closest vert
	 */
	function _getClosestVertToHit hitted_object hit_pos hitted_face =
	(
		-- format "\n"; print "GridSupportSeeder_v._getClosestVertToHit()"
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

		closest_pos -- return
	),
	
	/** 
	  *	
	  */
	function getEmptyCells =
	(
		 -- format "\n"; print "GridSupportSeeder_v.getEmptyCells()"
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
				
				for obj in cell_objects while not close_to_center_found do
				(
					_distance = distance cell_center obj.pos

					--if _distance < cell_size / 2.5 then
					if _distance < cell_size / search_treshold then
					--if _distance < cell_size then
						close_to_center_found = true
				)

				if not close_to_center_found then
					append empty_cells cell_center					
			)
		)

		empty_cells --return
	),


	private
	
	/* INTERSECT RAY only with specific objects.
	   
	   Finds the closest intersection point with any of them.
	  
		return #( pointer of hitted object, postion of hit, hitted face )
	  
	*/
	function _intersectRayWithObjects ray =
	(
		closest_dist  = 1e9
		closest_hit   = undefined
		hit_obj   = undefined
		result = undefined
	
		for obj in intersect_objs do
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
		(
			result = #( hit_obj, closest_hit[1].pos, closest_hit[2] )
			--hit_pos = closest_hit[1].pos * hit_obj.transform
			
			--result = #( hit_obj, hit_pos, closest_hit[2] )
		)
			
		result -- return
	),

	/** Convert targets to mesh
	 */
	function _convertTargetsToMeshSnapshots =
	(
		-- format "\n"; print "GridSupportSeeder_v._convertTargetsToMeshSnapshots()"
		this.intersect_objs = #()

		for i = 1 to this.target_objects.count do
			if classOf this.target_objects[i] != Editable_mesh then
			(
				this.target_objects[i].isHidden = true

				mesh_node = snapshot this.target_objects[i]
				
				mesh_node.transform = target_objects[i].transform -- snapshot is created at time 0
				
				setUserPropVal mesh_node "GRID_SUPPORT_SEEDER_SNAPSHOT" true
				
				this.intersect_objs[i] = mesh_node
			)
			else
				this.intersect_objs[i] = target_objects[i]
	),
	
	/** Remove snapshots
	 */
	function _removeSnapshots =
	(
		/* DELETE SNAPSHOT OBJECTS */ 
		for i = intersect_objs.count to 1 by -1 where getUserPropVal intersect_objs[i] "GRID_SUPPORT_SEEDER_SNAPSHOT" != undefined do
			delete intersect_objs[i]
				
		/* SHOW SOURCE OBJECTS OF SNAPSHOTS */ 
		for target_object in target_objects do
			target_object.isHidden = false
				
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


