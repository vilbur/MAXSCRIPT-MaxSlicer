/** Grid of nodes_v
  
  
  Create grid of supports under target_objects where support is missing
  
  SCREEN: --"./Doc/select-verts-up-down.gif"
  
 */
struct GridSupportSeeder_v
(
	/* construct */
	target_objects,
	cell_objects,
	intersect_objs = #(),
	
	seeder_mode,
	
	cell_size = 50,
	
	/* required */
	mode = #VERTS, -- #VERTS|#HITS|#POS -- vertex indexes | hits positions | verts positions of closest hit

	/* radial setup */ 
	segments_count = 32,
	segments_count_keep = true,
	
	
	/* properties */
	sel_verts = #{},
	sel_faces = #{},
	
	grid_origin = [0,0],
	grid_cells,
	
	closest_verts_pos,
	
	num_cols,
	num_rows,
	
	debug = false,  -- debug creates helpers to mark grid and hits
	
	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	/** Get closest verts of empty cells
	  
		@param #VERTS|#HITS|#POS  mode vertex indexes | hits positions | verts positions of closest hit
	  
		@param #GRID|undefined grid_type if not #GRID the cicrcle is used
	 */
	function getClosestVertsOfEmptyCells cell_objects mode grid_type:#GRID =
	(
		--format "\n"; print "GridSupportSeeder_v.getClosestVertsOfEmptyCells()"
	   --format "cell_objects: %\n" cell_objects
		--format "grid_type: %\n" grid_type
		this.cell_objects = if classOf cell_objects != Array then #(cell_objects) else cell_objects

		this.mode = mode
		
		closest_verts_pos = Dictionary #STRING
		
		this._convertTargetsToMeshSnapshots()
		
		this._setIntersectFaces()
		--format "SEL_FACES: %\n" sel_faces
		
		/* SQUARE GRID */
		/*------------------------------------------------------------------------------
			SQUARE GRID
		--------------------------------------------------------------------------------*/
		if grid_type == #GRID then
		(
			this.segments_count_keep = false
		 
			this._initGrid()
			
			this._sortNodesToMatrix()
			
			empty_cells = this._getEmptyCells()
		)
		
		/*------------------------------------------------------------------------------
			RADIAL GRID
		--------------------------------------------------------------------------------*/
		else
		(
			this._initGridRadial()
			
			empty_cells = this._getEmptyCellsRadial()
		)
		
		
		/*------------------------------------------------------------------------------
			SEARCH FOR ALREADY OCCUPIED CELLS BY OTHER SUPPORTS
		--------------------------------------------------------------------------------*/
		for cell_center in empty_cells do
		(
			/* SEARCH FOR MESH IN CELL CENTER */ 	 
			hit_data = this._testHit cell_center
		
			/* SEARCH FOR MESH AROUND CELL CENTER */ 	 
			if hit_data == undefined then
				hit_data = this._getHitsOnAroundPos(cell_center)((cell_size / 2.0) - 0.5 )(  1.0 ) test_hit:true --clr:red
				--hit_data = this._getHitsOnAroundPos(cell_center)(cell_size / 2.3 )(  1.0 ) test_hit:true --clr:red
				--hit_data = this._getHitsOnAroundPos(cell_center)(cell_size / 2.5 )(  1.0 ) test_hit:true --clr:red
				
			if hit_data != undefined then
				this._addToHits( hit_data )
		)
		
		this._removeSnapshots()
		
		closest_verts_pos --return
	),
	
	private

	/*==============================================================================
	
			SQUARE GRID
	
	================================================================================*/
	
	/** Set grid
	 */
	function _initGrid =
	(
		--format "\n"; print "GridSupportSeeder_v._initGrid()"

		bbox = if sel_verts.isEmpty and sel_faces.isEmpty then this._getBbox() else this.getSelectedVertsXYBounds target_objects[1]
		
		p1 = bbox[1]
		p2 = bbox[2]
		p3 = bbox[3]
		p4 = bbox[4]
		
		grid_center = ( p1 + p2 + p3 + p4 ) / 4

		size_x = p4.x - p1.x
		size_y = p2.y - p1.y
		
		/* SUBDIVIDE GRID IF OBJECT IS TO SMALL OR CELL SIZE TO BIG */ 
		--if amax size_x size_y < cell_size * 4 then
			--cell_size /= 2
		
		/* GET NUMBER OF ROWS AND COLUMNS */ 		
		num_cols = ceil (size_x / cell_size)
		num_rows = ceil (size_y / cell_size)
	
		grid_size_x = cell_size * num_cols
		grid_size_y = cell_size * num_rows
		
		offset_x = (grid_size_x - size_x) / 2.0
		offset_y = (grid_size_y - size_y) / 2.0
		
		/* ALIGN GRID TO BOUNGING BOX LEFT BOTTOM CORNER */ 
		this.grid_origin = p1
		
		/* CENTER GRID TO SELECTION */ 
		this.grid_origin = p1 - [ offset_x, offset_y, 0 ]
		
		/* INITIALIZE GRID */ 
		grid_cells = for r = 1 to num_rows collect (for c = 1 to num_cols collect #())
	),
	
	/* 
	Sorts array of nodes into 2D grid_cells based on node position.x and position.y 
	*/
	function _sortNodesToMatrix =
	(
		 -- format "\n"; print "GridSupportSeeder_v._sortNodesToMatrix()"
		 -- format "nodes: %\n" nodes
		--this.cell_objects = if classOf cell_objects != Array then #(cell_objects) else cell_objects
		
		
		for node in cell_objects do
		(
			col = 1 + floor (( node.position.x - grid_origin.x) / cell_size )
			row = 1 + floor (( node.position.y - grid_origin.y) / cell_size )
			
			if row >= 1 and row <= num_rows and col >= 1 and col <= num_cols then
				append grid_cells[row][col] node
		)
		
		grid_cells -- return
	),

	/** 
	  *	
	  */
	function _getEmptyCells =
	(
		--format "\n"; print "GridSupportSeeder_v._getEmptyCells()"
		--format "grid_cells: %\n" grid_cells
		empty_cells	= #()
		
		for y = 1 to grid_cells.count do
 		(
			row = grid_cells[y]
			
			for x = 1 to row.count do
			(
				close_to_center_found = false
				
				x_pos = grid_origin.x + ((x - 1) * cell_size) + (cell_size/2)
				y_pos = grid_origin.y + ((y - 1) * cell_size) + (cell_size/2)
	
				cell_center = [ x_pos, y_pos, 0 ]
				
				if debug then
					Dummy pos:cell_center boxsize:[cell_size,cell_size,0] wirecolor:green name:("GRID-SEEDER-HELPER-CELL-"+ x as string +"-"+ y as string )

				/* SERACH FOR OBJECT NEAR TO CENTER OF CELL */ 
				for obj in cell_objects while not close_to_center_found do
					if distance cell_center obj.pos < cell_size / 2 then
						close_to_center_found = true

				/* IF ANY OBJECT FOUND */ 
				if not close_to_center_found then
					append empty_cells cell_center					
			)
		)

		empty_cells --return
	),
	
	/*==============================================================================
	  
		RADIAL GRID
		
	================================================================================*/
	
	
	/** Init grid radial
	 */
	function _initGridRadial =
	(
		  -- format "\n"; print "GridSupportSeeder_v._initGridRadial()"
		bbox = this._getBbox()
		
		p1 = bbox[1]
		p2 = bbox[2]
		p3 = bbox[3]
		p4 = bbox[4]

		this.grid_origin = ( p1 + p2 + p3 + p4 ) / 4
		
		/* GET LONGER SIDE OF BOUNGING BOX */ 
		radius = (amax (distance p1 p2) (distance p1 p4)) / 2.0
		 --format "RADIUS: %\n" radius
		/* SUBDIVIDE GRID IF OBJECT IS TO SMALL OR CELL SIZE TO BIG */ 
		if radius < cell_size * 4 then
			cell_size /= 2
		
		/* GET RADIAL POSITIONS AROUND CENTER */ 		
		grid_cells = this._getHitsOnAroundPos(this.grid_origin)(radius)(cell_size) --clr:green  --test_hit:true
		--format "grid_cells: %\n" grid_cells
	),

	/** Test positions in cicrles around center of cell
	 */
	function _getHitsOnAroundPos cell_center radius split_size test_hit:false clr:undefined =
	(
		  --format "\n"; print "GridSupportSeeder_v._getHitsOnAroundPos()"
		  --format "segments_count: %\n" segments_count
		 -- format "test_hit: %\n" test_hit
		/**  Move point along a radial by rotation angle using only degrees
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
		)
		
		/* Finds the closest float in an array to a given value
		   
			RATIOS WHICH PRODUCE BEST RESULTS
		
			THIS NUMBER IS CONTROLING PATTERN OF HITS FOOTPRINT
		*/
		--function getClosestFloatValue target_float = 
		--(
		--	ratios = #( 0.5, 1.0, 2.0, 4.0, 6.0, 12.0, 24.0 , 36.0  )
		--	--ratios = #( 1.0, 2.0, 4.0, 6.0  )
		--	
		--	closest_value = undefined
		--	min_diff = 1e9
		--
		--	for f in ratios do
		--	(
		--		diff = abs(f - target_float)
		--		if diff < min_diff then
		--		(
		--			min_diff = diff
		--			closest_value = f
		--		)
		--	)
		--	
		--	closest_value -- return
		--)
		
		/* Get round float to integer
			
			Never return 0 -- all value bellow 0.5 return 1
		*/ 
		fn roundToInteger val = if (rounded_val = floor (val  + 0.5)  as integer ) == 0 then 1 else rounded_val
		--fn roundToInteger val = if (rounded_val = ceil (val  + 0.5)  as integer ) == 0 then 1 else rounded_val

		
		hit_data = undefined
		
		/* SET CENTER AS CELL */ 
		radial_postions = #(cell_center)
		
		/* GET NUMBER OF ECCENTRIC CIRLES */ 
		radius_count = roundToInteger( radius / split_size )

		/* GET SIZE OF SEMENT */ 
		radius_split = radius / radius_count
		
		/* GET RADIUSES */ 
		radiuses = for i = 1 to radius_count collect radius_split * i

		/*------------------------------------------------------------------------------
			TEST CIRCLES OF POSITIONS AROUND CENTER OF CELL
		--------------------------------------------------------------------------------*/
		for radius_portion in radiuses while hit_data == undefined do 
		(
			--format "------------------\n"
			point_pos = cell_center + [ radius_portion, 0, 0 ]
			
			segments = if segments_count_keep then segments_count else ceil( segments_count * radius_portion / radius )

			/*------------------------------------------------------------------------------
				TEST EACH ANGLE
			--------------------------------------------------------------------------------*/
			for i = 1 to segments while hit_data == undefined do
			(
				-- format "hit_data: %\n" hit_data
				rotate_about = ( 360.0 / segments ) * i
				
				moved_pos = movePointOnRadialDeg (cell_center) (radius_portion) (point_pos) (rotate_about)
				
				if test_hit then
					hit_data = this._testHit moved_pos

				else
					append radial_postions moved_pos
			
				if debug then
					Point pos:moved_pos size:0.1 wirecolor:yellow box:false name:("GRID-SEEDER-HELPER-HIT-SEARCH")
			)
		)

		if test_hit then hit_data else radial_postions --return
	),
	
	/** Sort nodes to radial grid
	 */
	function _getEmptyCellsRadial =
	(
		 --format "\n"; print "GridSupportSeeder_v._sortNodesToRadialGrid()"
		--this.cell_objects = if classOf cell_objects != Array then #(cell_objects) else cell_objects

		empty_cells = #() 
		
		dev_show_radius = #()
		
		for pos in grid_cells do
		(
			nodes_of_pos = #()
			
			--Point pos:pos size:10 wirecolor:red box:true name:"RADIAL CELL"

			/* SERACH FOR OBJECT NEAR TO CENTER OF CELL */ 
			for node in cell_objects while nodes_of_pos.count == 0 do
			(
				search_radius = cell_size / 4 -- divide by 2x2 for radius and both sides

				node_pos = node.position
				
				pos.z = node_pos.z = 0
				
				/* DEVELOPENT
					if findItem dev_show_radius node == 0 then
						VolumeHelper pos:pos radius:search_radius segments:16 wirecolor:brown volumeType:1 name:node.name
					
					appendIfUnique dev_show_radius node
				*/ 
				
				
				if distance pos node_pos < search_radius  then
					append nodes_of_pos node
			)
			
			/* IF ANY OBJECT FOUND */ 
			if nodes_of_pos.count == 0 then
				append empty_cells pos
				
		)

		empty_cells --return
	),
	
	/*==============================================================================
	  
		HELPERS
		
	================================================================================*/
	
		/** Test hit
	 */
	function _testHit pos =
	(
		 --format "\n"; print "GridSupportSeeder_v._testHit()"
		hit_data = this._intersectRayWithObjects ( Ray pos [0,0,1] )
		
		/* TEST IF HIT HITS SELECTED FACE */ 
		if not sel_faces.isEmpty and hit_data != undefined and sel_faces[hit_data[3]] == false then 
			hit_data = undefined
		
		
		hit_data --return
	),
	
	/** Append closest vert
	 */
	function _addToHits hit_data =
	(
		--format "\n"; print "GridSupportSeeder_v._addToHits()"
		--format "mode: %\n" mode
		grid_object = target_objects[findItem intersect_objs hit_data[1]]

		pointer = (getHandleByAnim grid_object) as string

		if this.closest_verts_pos[pointer] == undefined then
			this.closest_verts_pos[pointer] = if mode != #VERTS then #() else #{}
		
		 if mode != #HITS then
			index_or_pos = this._getClosestVertToHit hit_data[1] hit_data[2] hit_data[3]

		 --if mode != #HITS and ( closest_vert = this._getClosestVertToHit hit_data[1] hit_data[2] hit_data[3] ) != undefined then 
			--index_or_pos =
		 
		 case mode of
		 (
			/* POSITION OF HIT */ 
			#HITS: appendIfUnique this.closest_verts_pos[pointer] hit_data[2]
			
			/* POSITION OF CLOSEST VERT OF HIT */ 
			#POS:   if index_or_pos != undefined then appendIfUnique this.closest_verts_pos[pointer] index_or_pos
			
			/* INDEXE OF VERTS CLOSEST TO HIT */ 
			#VERTS:  if index_or_pos != undefined then this.closest_verts_pos[pointer][index_or_pos] = true	
		)
		 
			
		if debug then
			Point pos:hit_data[2] size:0.5 wirecolor:red box:true name:("GRID-SEEDER-HELPER-HIT-"+ hit_data[3] as string )
		 
		 
	),
	
	/** Get closest vert
	 */
	function _getClosestVertToHit hitted_object hit_pos hitted_face =
	(
		--format "\n"; print "GridSupportSeeder_v._getClosestVertToHit()"
		verts_of_face = meshop.getVertsUsingFace hitted_object hitted_face
	
		if sel_verts.count > 0 then
			for vert in verts_of_face where not sel_verts[vert] do 
				verts_of_face[vert] = false
	
		closest_vert = undefined
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
	
	/** Set intersect faces
	 */
	function _setIntersectFaces =
	(
		--format "\n"; print "GridSupportSeeder_v._setIntersectFaces()"
		
		intescect_obj = intersect_objs[1]
		
		sel_verts = polyop.getVertSelection target_objects[1]
		
		
		/* GET FACES WITH ALL VERTS IN SELCTION */ 
		faces_of_verts = meshop.getFacesUsingVert intescect_obj sel_verts

		verts_of_faces = meshop.getVertsUsingFace intescect_obj faces_of_verts
		
		border_vets = verts_of_faces - sel_verts
		
		border_faces = meshop.getFacesUsingVert intescect_obj border_vets

		sel_faces = faces_of_verts - border_faces
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
		
		this._getCornerPointsOnGround min_x max_x min_y max_y
	),
	
	/* 
	Get min and max XY values of selected verts in Editable Poly or Edit Poly modifier
	*/
	function getSelectedVertsXYBounds src_obj =
	(
		-- format "\n"; print "GridSupportSeeder_v._getBbox()"
		--if isKindOf src_obj Editable_Poly or isKindOf src_obj Edit_Poly then
		--(
			-- get selected verts
		--if verts.isEmpty then (return undefined) -- no selected verts
		

		first_found = true

		min_x = 0.0
		max_x = 0.0
		min_y = 0.0
		max_y = 0.0

		for i in sel_verts do
		(
			p = polyop.getVert src_obj i
			
			if first_found then
			(
				min_x = p.x ; max_x = p.x
				min_y = p.y ; max_y = p.y
				first_found = false
			)
			else
			(
				if p.x < min_x then min_x = p.x
				if p.x > max_x then max_x = p.x
				if p.y < min_y then min_y = p.y
				if p.y > max_y then max_y = p.y
			)
		)
		
		this._getCornerPointsOnGround min_x max_x min_y max_y
	),
	
	/** Get corner points on ground
	 */
	function _getCornerPointsOnGround min_x max_x min_y max_y =
	(
		--format "\n"; print "GridSupportSeeder_v._getCornerPointsOnGround()"

		p1 = [ min_x, min_y, 0 ] -- bottom left 
		p2 = [ min_x, max_y, 0 ] -- top left
		p3 = [ max_x, max_y, 0 ] -- top right
		p4 = [ max_x, min_y, 0 ] -- bottom right
		
		#( p1, p2, p3, p4 ) --return	
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
	)
)