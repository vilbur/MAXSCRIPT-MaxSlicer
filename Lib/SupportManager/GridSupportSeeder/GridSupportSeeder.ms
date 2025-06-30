clearListener(); print("Cleared in:\n"+getSourceFileName())


/** Grid of nodes_v
  
  
  Create grid of supports under target_objects where support is missing
  
  SCREEN: --"./Doc/select-verts-up-down.gif"
  
 */
struct GridSupportSeeder_v
(
	/* construct */
	target_objects,
	--target_objects,
	cell_objects,
	intersect_objs = #(),
	
	seeder_mode,
	cell_size = 50,
	/* required */
	mode = #VERTS, -- #VERTS|#HITS|#POS -- vertex indexes | hits positions | verts positions of closest hit

	/* radial setup */ 
	segments_count = 32,
	--segments_count_keep = false,
	segments_count_keep = true,
	
	
	/* properties */
	grid_origin = [0,0],
	grid_positions,
	
	closest_verts_pos,
	search_treshold = 1.5, -- how far from cell center is searched for grid object 
	--search_treshold = 2.0, -- how far from cell center is searched for grid object 
	
	num_cols,
	num_rows,


	
	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	/** Get closest verts of empty cells
	  
		@param #VERTS|#HITS|#POS  mode vertex indexes | hits positions | verts positions of closest hit
	  
		@param #GRID|undefined grid_type if not #GRID the cicrcle is used
	 */
	function getClosestVertsOfEmptyCells cell_objects mode grid_type =
	(
		  -- format "\n"; print "GridSupportSeeder_v.getClosestVertsOfEmptyCells()"
		  --format "cell_objects: %\n" cell_objects
		  -- format "grid_type: %\n" grid_type
		this.cell_objects = if classOf cell_objects != Array then #(cell_objects) else cell_objects

		this.mode = mode
		
		closest_verts_pos = Dictionary #STRING
		
		this._convertTargetsToMeshSnapshots()
		
		if grid_type == #GRID then
		(
			--ratios = #( 3.0, 1.2 ) -- size of inner radials around center
			
			this.initGrid()
			
			this.sortNodesToMatrix()
			
			empty_cells = this.getEmptyCells()
		)
		else
		(
			this.initGridRadial()
			
			empty_cells = this.getEmptyCellsRadial()
			
		)
		  -- format "EMPTY_CELLS: %\n" empty_cells
		
		/* LOOP EMPTY CELLS */ 
		for cell_center in empty_cells do
		(
			 --format "\n"
			--format "cell_center: %\n" cell_center
			 --Point pos:cell_center size:10 Box:true  wirecolor:red
		
			/* TEST CENTER OF CELL */ 
			hit_data = this._testHit cell_center
			 -- format "hit_data: %\n" hit_data
			 
			if hit_data == undefined then
				hits_data = this._getRadialPositions(cell_center)(cell_size / 2 )(cell_size) clr:white --test_hit:true
				
			--if hit_data != undefined then
			--	Point pos:cell_center size:10 Box:true  wirecolor:red
				
			if hit_data != undefined then
				this._addToHits( hit_data )
		)
		
		this._removeSnapshots()
		
		closest_verts_pos --return
	),

	/** Set grid
	 */
	function initGrid =
	(
		--format "\n"; print "GridSupportSeeder_v.initGrid()"
		
		bbox = this._getBbox()
		
		min_x = bbox[1]
		min_y = bbox[2]
		max_x = bbox[3]
		max_y = bbox[4]
		
		this.grid_origin = [ min_x, min_y ]
		
		/* SUBDIVIDE GRID IF OBJECT IS TO SMALL OR CELL SIZE TO BIG */ 
		if distance [ min_x, min_y, 0 ] [ max_x, max_y, 0 ] < cell_size * 4 then
			cell_size /= 2
		
		--point pos:[ min_x, min_y, 0 ] size:1
		--point pos:[ max_x, max_y, 0 ] size:1
		
		num_cols = ceil ((max_x - min_x + 0.1) / cell_size)
		num_rows = ceil ((max_y - min_y + 0.1) / cell_size)
		
		/* Initialize grid_positions */ 
		grid_positions = for r = 1 to num_rows collect (for c = 1 to num_cols collect #())
	),
	
	/** Init grid radial
	 */
	function initGridRadial =
	(
		 -- format "\n"; print "GridSupportSeeder_v.initGridRadial()"
		bbox = this._getBbox()
		
		min_x = bbox[1]
		min_y = bbox[2]
		max_x = bbox[3]
		max_y = bbox[4]
		
		p1 = [ min_x, min_y, 0 ] -- bottom left 
		p2 = [ max_x, max_y, 0 ] -- top right
		p3 = [ max_x, min_y, 0 ] -- bottom right
		p4 = [ min_x, max_y, 0 ] -- top left

		this.grid_origin = ( p1 + p2 + p3 + p4 ) / 4
		

		/* GET LONGER SIDE OF BOUNGING BOX */ 
		radius = (amax (distance p1 p3) (distance p1 p4)) / 2.0
		-- format "radius: %\n" radius
		/* SUBDIVIDE GRID IF OBJECT IS TO SMALL OR CELL SIZE TO BIG */ 
		--if radius < cell_size * 4 then
			--cell_size /= 2
		
		--cell_size = 60
		
		/* GET HITS */ 		
		grid_positions = this._getRadialPositions(this.grid_origin)(radius)(cell_size)  clr:green  --test_hit:true
		-- format "grid_positions: %\n" grid_positions
		-- format "grid_positions.count: %\n" grid_positions.count
		
		--for grid_position in grid_positions do 
			--this._getRadialPositions(grid_position)(cell_size)(cell_size/4)  clr:yellow  --test_hit:true
		-- format "grid_positions: %\n" grid_positions
	),
	
	/* 
	Sorts array of nodes into 2D grid_positions based on node position.x and position.y 
	*/
	function sortNodesToMatrix =
	(
		 -- format "\n"; print "GridSupportSeeder_v.sortNodesToMatrix()"
		 -- format "nodes: %\n" nodes
		--this.cell_objects = if classOf cell_objects != Array then #(cell_objects) else cell_objects
		
		
		for node in cell_objects do
		(
			col = 1 + floor (( node.position.x - grid_origin.x) / cell_size )
			row = 1 + floor (( node.position.y - grid_origin.y) / cell_size )
			
			if row >= 1 and row <= num_rows and col >= 1 and col <= num_cols then
				append grid_positions[row][col] node
		)
		
		grid_positions -- return
	),
	


	/** Test positions in cicrles around center of cell
	 */
	function _getRadialPositions cell_center radius split_size test_hit:false clr:undefined =
	(
		  -- format "\n"; print "GridSupportSeeder_v._getRadialPositions()"
		-- format "cell_center: %\n" cell_center
		-- format "radius: %\n" radius
		-- format "split_size: %\n" split_size
		/* 	RATIOS WHICH PRODUCE BEST RESULTS
		
			THIS NUMBER IS CONTROLING PATTERN OF HITS FOOTPRINT
		*/ 
		--ratios = #( 1.0, 2.0, 4.0, 6.0, 12.0, 24.0 , 36.0  )
		--ratios = #( 1.0, 2.0, 4.0, 6.0  )

		result = #(cell_center)
		
		ratio = (radius / split_size  as float )
		-- format "ratio: %\n" ratio
		/* ADJSUT CELL SIZE */ 
		split_size = radius / ratio

		/* GET RADIUSES */ 
		radius_count = radius / split_size
		-- format "radius_count: %\n" radius_count
		segment_size = radius / radius_count
		
		radiuses = for i = 1 to radius_count collect segment_size * i
		
		  -- format "RADIUSES: %\n" radiuses
		 
		/*------------------------------------------------------------------------------
			TEST CIRCLES OF POSITIONS AROUND CENTER OF CELL
		--------------------------------------------------------------------------------*/
		for radius_portion in radiuses while hit_data == undefined do 
		(
			--format "------------------\n"
			point_pos = cell_center + [ radius_portion, 0, 0 ]
			
			segments = if segments_count_keep then segments_count else ceil( segments_count * radius_portion / radius )
			--segments = ceil( segments_count * radius_portion / radius )
		
			/*------------------------------------------------------------------------------
				TEST EACH ANGLE
			--------------------------------------------------------------------------------*/
			for i = 1 to segments while hit_data == undefined do
			(
				rotate_about = ( 360.0 / segments ) * i
				
				moved_pos = this.movePointOnRadialDeg (cell_center) (radius_portion) (point_pos) (rotate_about)
				
				--if clr != undefined then 
					--Point pos:moved_pos size:5 wirecolor:clr Box:true 
				
				if test_hit then
				(
					hit_data = this._testHit moved_pos 
					
					if hit_data != undefined then
						result = hit_data
				)
				else
					append result moved_pos
			)
		)
		
		result --return
	),
		/** Test hit
	 */
	function _testHit pos =
	(
		 -- format "\n"; print "GridSupportSeeder_v._testHit()"
		--this._intersectRayWithObjects ( Ray pos [0,0,1] )
		hit_data = this._intersectRayWithObjects ( Ray pos [0,0,1] )
		-- format "HIT_DATA: %\n" hit_data
		hit_data --return
	),
	
	/** Append closest vert
	 */
	function _addToHits hit_data =
	(
		 -- format "\n"; print "GridSupportSeeder_v._addToHits()"
		grid_object = target_objects[findItem intersect_objs hit_data[1]]

		pointer = (getHandleByAnim grid_object) as string

		if this.closest_verts_pos[pointer] == undefined then
			this.closest_verts_pos[pointer] = if mode != #VERTS then #() else #{}
		
		 if mode != #HITS then
			index_or_pos = this._getClosestVertToHit hit_data[1] hit_data[2] hit_data[3]
		 
		 
		 case mode of
		 (
			#HITS:  appendIfUnique this.closest_verts_pos[pointer] hit_data[2]
			
			#POS:   appendIfUnique this.closest_verts_pos[pointer] index_or_pos
			
			#VERTS: this.closest_verts_pos[pointer][index_or_pos] = true	
		)	
	),
	
	/** 
	Move point along a radial by rotation angle using only degrees
	*/
	function movePointOnRadialDeg center_pos radius point_pos angle_deg =
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
	
		-- Final position on radial
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

		if mode == #VERTS then closest_vert else closest_pos -- return
	),
	
	/** 
	  *	
	  */
	function getEmptyCells =
	(
		 -- format "\n"; print "GridSupportSeeder_v.getEmptyCells()"
		empty_cells	= #()
		
		for y = 1 to grid_positions.count do
 		(
			row = grid_positions[y]
			
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

	/** Sort nodes to radial grid
	 */
	function getEmptyCellsRadial =
	(
		-- format "\n"; print "GridSupportSeeder_v._sortNodesToRadialGrid()"
		--this.cell_objects = if classOf cell_objects != Array then #(cell_objects) else cell_objects

		empty_cells = #()
		
		dev_show_radius = #()
		
		for pos in grid_positions do
		(
			nodes_of_pos = #()
			
			for node in cell_objects while nodes_of_pos.count == 0 do
			(
				node_pos = node.position
				--format "\n"
				pos.z = node_pos.z = 0
				
				--serach_radius = 20.0
				serach_radius = cell_size / 2
				
				/* DEVELOPENT
					if findItem dev_show_radius node == 0 then
						VolumeHelper pos:pos radius:serach_radius segments:16 wirecolor:brown volumeType:1 name:node.name
					
					appendIfUnique dev_show_radius node
				*/ 
				
				if distance pos node_pos < serach_radius  then
					append nodes_of_pos node
			)
			--format "nodes_of_pos: %\n" nodes_of_pos
			if nodes_of_pos.count == 0 then
				append empty_cells pos
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
		 -- format "\n"; print "GridSupportSeeder_v._intersectRayWithObjects()"
		closest_dist  = 1e9
		closest_hit   = undefined
		hit_obj   = undefined
		result = undefined
		-- format "intersect_objs: %\n" intersect_objs
		for obj in intersect_objs do
		(
			hit = IntersectRayEx obj ray
			-- format "hit: %\n" hit
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

				--mesh_node = snapshot this.target_objects[i]
				mesh_node = copy this.target_objects[i]
				
				convertTo mesh_node TriMeshGeometry
				
				setUserPropVal mesh_node "GRID_SUPPORT_SEEDER_SNAPSHOT" true
				
				this.intersect_objs[i] = mesh_node
			)
			else
				this.intersect_objs[i] = target_objects[i]
	),
	
	/** Get bbox
	 */
	function _getBbox =
	(
		-- format "\n"; print "GridSupportSeeder_v._getBbox()"
		min_x = 1e9
		max_x = -1e9
		min_y = 1e9
		max_y = -1e9

		for node in this.target_objects where isProperty node #position do
		(
			-- format "node: %\n" node
			pos = node.position
			
			if node.min.x < min_x then min_x = node.min.x
			if node.min.y < min_y then min_y = node.min.y
			if node.max.x > max_x then max_x = node.max.x
			if node.max.y > max_y then max_y = node.max.y
		)
		
		#( min_x, min_y, max_x, max_y ) --return	
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
		-- format "\n"; print "GridSupportSeeder_v.onCreate()"
		if classOf this.target_objects != Array then 
			this.target_objects = #( this.target_objects )
		
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)


