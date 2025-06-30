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
	
	seeder_mode,
	cell_size = 50,
	/* required */
	mode = #VERTS, -- #VERTS|#HITS|#POS -- vertex indexes | hits positions | verts positions of closest hit

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

	/** Get bbox
	 */
	function _getBbox =
	(
		--format "\n"; print "GridSupportSeeder_v._getBbox()"
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
		
		#( min_x, min_y, max_x, max_y ) --return	
	),
	
	/** Set grid
	 */
	function initGrid grid_objects =
	(
		--format "\n"; print "GridSupportSeeder_v.initGrid()"
		this.grid_objects = if classOf grid_objects != Array then #(grid_objects) else grid_objects
		
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
		
		--plane pos:grid_origin width:( max_x - min_x ) length:( max_y - max_y )
		
		num_cols = ceil ((max_x - min_x + 0.1) / cell_size)
		num_rows = ceil ((max_y - min_y + 0.1) / cell_size)
		
		-- format "num_cols: %\n" num_cols
		-- format "num_rows: %\n" num_rows
		
		/* Initialize matrix */ 
		matrix = for r = 1 to num_rows collect (for c = 1 to num_cols collect #())
	),
	
	/** Init grid circle
	 */
	function initGridCircle grid_objects =
	(
		format "\n"; print "GridSupportSeeder_v.initGridCircle()"
		this.grid_objects = if classOf grid_objects != Array then #(grid_objects) else grid_objects
		
		bbox = this._getBbox()
		
		min_x = bbox[1]
		min_y = bbox[2]
		max_x = bbox[3]
		max_y = bbox[4]
		
		p1 = [ min_x, min_y, 0 ] -- bottom left 
		p2 = [ max_x, max_y, 0 ] -- top right
		p3 = [ max_x, min_y, 0 ] -- bottom right
		p4 = [ min_x, max_y, 0 ] -- top left
--		
		--ratios = #( 4 , 3, 2, 1 ) -- size of inner circles around center

		this.grid_origin = ( p1 + p2 + p3 + p4 ) / 4
		
		Sphere pos:this.grid_origin radius:1  wirecolor:red
		

			
		--this.grid_origin = [ min_x, min_y, 0 ]
		--Sphere pos:p1 radius:1  wirecolor:red
		--Sphere pos:p2 radius:1  wirecolor:green
		--Sphere pos:p3 radius:1  wirecolor:blue
		--Sphere pos:p4 radius:1  wirecolor:yellow
		
		radius = (amax (distance p1 p3) (distance p1 p4)) / 2
		
		/* SUBDIVIDE GRID IF OBJECT IS TO SMALL OR CELL SIZE TO BIG */ 
		if radius < cell_size * 4 then
			cell_size /= 2
			
		radius_count = radius / cell_size

		segment_size = radius / radius_count

		radiuses = for i = 1 to radius_count collect segment_size * i
		
		this._testPositionsAroundCenterOfCell(this.grid_origin)(radius)(radiuses) all_hits:true 

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
	  
		@param #VERTS|#HITS|#POS  mode vertex indexes | hits positions | verts positions of closest hit
	  
	 */
	function getClosestVertsOfEmptyCells target_objects mode =
	(
		 -- format "\n"; print "GridSupportSeeder_v.getClosestVertsOfEmptyCells()"
		this.target_objects = if classOf target_objects != Array then #(target_objects) else target_objects

		ratios = #( 3.0, 1.2 ) -- size of inner circles around center

		this.mode = mode
		
		closest_verts_pos = Dictionary #STRING
		
		empty_cells = this.getEmptyCells()
		-- format "empty_cells: %\n" empty_cells
		this._convertTargetsToMeshSnapshots()
		
		/* LOOP EMPTY CELLS */ 
		for cell_center in empty_cells do
		(
			--format "\n"
			--format "cell_center: %\n" cell_center
			 --Sphere pos:cell_center radius:0.1 wirecolor:red

			/* TEST CENTER OF CELL */ 
			hit_data = this._testHit cell_center
			 --format "hit_data: %\n" hit_data
			if hit_data != undefined then
				this._addToHits( hit_data )
			
			--else
				--this._testPositionsAroundCenterOfCell(cell_center)(cell_size / 2 )(ratios)
		)
		
		this._removeSnapshots()

		closest_verts_pos --return
	),
	
	/** Test positions in cicrles around center of cell
	 */
	function _testPositionsAroundCenterOfCell cell_center radius radiuses all_hits:false =
	(
		 format "\n"; print "GridSupportSeeder_v._testPositionsAroundCenterOfCell()"
		 format "radiuses: %\n" radiuses
		 
		/*------------------------------------------------------------------------------
			TEST CIRCLES OF POSITIONS AROUND CENTER OF CELL
		--------------------------------------------------------------------------------*/
		--for radius in radiuses while hit_data == undefined do
		
		segments_count = 24 -- number of segments in full radius
		
		for radius_portion in radiuses while hit_data == undefined do 
		(
			format "------------------\n"
			--format "ratio: %\n" ratio
			
			--radius = radius / ratio	
			
			point_pos = cell_center + [ radius_portion, 0, 0 ]
			
			--increment_count = increment / ratio
			--increment = if ratio == 3 then 60 else 30 -- add more test if radius is bigger


			segments = ceil( segments_count * radius_portion / radius )
			format "segments: %\n" segments

			/*------------------------------------------------------------------------------
				TEST EACH ANGLE
			--------------------------------------------------------------------------------*/
			for i = 1 to segments while hit_data == undefined do
			(
				rotate_about = ( 360.0 / segments ) * i
				format "\n"
				format "rotate_about: %\n" rotate_about
				
				moved_pos = this.movePointOnCircleDeg (cell_center) (radius_portion) (point_pos) (rotate_about)
				--format "moved_pos: %\n" moved_pos
				Sphere pos:moved_pos radius:1 wirecolor:orange
				
				--hit_data = this._testHit moved_pos 
				--
				--if hit_data != undefined then
				--	this._addToHits( hit_data )
				--
				--if all_hits then
					hit_data = undefined 
			)
		)
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
		grid_object = grid_objects[findItem intersect_objs hit_data[1]]

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

		if mode == #VERTS then closest_vert else closest_pos -- return
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
		--format "intersect_objs: %\n" intersect_objs
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


