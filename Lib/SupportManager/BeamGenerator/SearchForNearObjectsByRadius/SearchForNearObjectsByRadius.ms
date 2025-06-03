/** Search for near objects by radius
  *	
  */
struct SearchForNearObjectsByRadius_v
(
	radius, 
	--cell_size = 100.0,
	cell_size = 10.0,
	min_distance = 0.0,
	
	pair_matrix = #(),
	checked_pairs = #(),
	supports = #(),
	--radius = SUPPORT_OPTIONS.max_distance,
	--cell_size = radius * 2,

    /** 
    * Main function: Find closest pairs of supports
    */
    function findClosestPairs supports  =
    (
 		 format "\n"; print "SearchForNearObjectsByRadius_v.findClosestPairs()"
		-- format "radius: %\n" radius
		format "min_distance: %\n" min_distance
		/** 
		* Compare two distances for sorting
		*/
		function compareDistanceAsc a b = if a[1] < b[1] then -1 else if a[1] > b[1] then 1 else 0
		
		/** Is duplicate
		 */
		function isDuplicate pair =
		(
			--format "\n"; print "SearchForNearObjectsByRadius_v.isDuplicate()"
			is_duplicate = false
			
			for existing_pair in checked_pairs while not is_duplicate where this.pairExist pair existing_pair do
				is_duplicate = true
			
			is_duplicate --return
		)
		
		max_connections_per_object = SUPPORT_OPTIONS.max_connections

        distance_matrix = for i = 1 to supports.count collect #()

        supports = for support in supports where not this.supportHasMaxConnections support collect support

		 if radius != undefined then
		(
			--cell_size = radius * 3 -- value: 3 makes most less iterations of loops in this.getObjectsInRadius()
			cell_size = ( radius * 3 ) as float -- value: 3 makes most less iterations of loops in this.getObjectsInRadius()

			_grid = this.buildSpatialGrid supports
		 )

        for i = 1 to supports.count do
        (
            support = supports[i]
			
			/* GET SUPPORTS TO COMPARE DISTANCE */ 
            other_supports = if radius != undefined then  this.getObjectsInRadius _grid support.position radius else supports

			/* GET DISTANCES */ 
            distances = for j = 1 to other_supports.count where other_supports[j] != support collect #((distance support.position other_supports[j].position), other_supports[j])

			/* SORT DISTANCES */ 
            qsort distances compareDistanceAsc

			/* GET CLOSEST DISTANCES */ 
            --for k = 1 to ( amin max_connections_per_object distances.count ) where distances[k][1] > min_distance do
            for k = 1 to ( amin max_connections_per_object distances.count ) where distances[k][1] > min_distance do
            (
               
                closest_obj = distances[k][2]

				pair = #(support, closest_obj)

				if not isDuplicate(pair) do
				(
					append pair_matrix 	pair
					
					append checked_pairs pair
					
					--append distance_matrix (distance pair[1].position pair[2].position)
					append distance_matrix distances[k][1]
				)
            )
        )

        result = #(pair_matrix, distance_matrix)
        result[1] -- return
    ),

	
    /** 
    * Build spatial grid for fast lookup
    */
    function buildSpatialGrid _objects =
    (
        _grid = Dictionary() 
        for obj in _objects do (
            cell_x = floor (obj.position.x / cell_size)
            cell_y = floor (obj.position.y / cell_size)
            cell_z = floor (obj.position.z / cell_size)

            cell_key_str = "cell_" + (cell_x as string) + "_" + (cell_y as string) + "_" + (cell_z as string)
            cell_key = (cell_key_str as name)

            if not (HasDictValue _grid cell_key) do (
                _grid[cell_key] = #()
            )
            append _grid[cell_key] obj
        )
        _grid -- return
    ),

    /** 
    * Get nearby objects within a given radius
    */
    function getObjectsInRadius _grid center_pos radius =
    (
        result = #()
        cell_radius = ceil (radius / cell_size)
        center_cell_x = floor (center_pos.x / cell_size)
        center_cell_y = floor (center_pos.y / cell_size)
        center_cell_z = floor (center_pos.z / cell_size)

        for x = (center_cell_x - cell_radius) to (center_cell_x + cell_radius) do (
			-- format "x: %\n" x
            for y = (center_cell_y - cell_radius) to (center_cell_y + cell_radius) do (
				-- format "y: %\n" y
                for z = (center_cell_z - cell_radius) to (center_cell_z + cell_radius) do (
					-- format "z: %\n" z
                    cell_key_str = "cell_" + (x as string) + "_" + (y as string) + "_" + (z as string)
                    cell_key = (cell_key_str as name)

                    if HasDictValue _grid cell_key do (
                        for obj in _grid[cell_key] do (
							-- format "\n"
							-- format "radius: %\n" radius
							-- format "distance: %\n" (distance obj.position center_pos)
							-- format "TEST: %\n" (distance obj.position center_pos <= radius )
                            if distance obj.position center_pos <= radius do (
                                append result obj
                            )
                        )
                    )
                )
            )
        )
        result -- return
    ),



    /** 
    * Check if support has maximum allowed connections
    */
    function supportHasMaxConnections support =
    (
        -- format "\n------------------------------------------------------------\n"
        -- format "\n\n"; print "BeamGenerator_v.supportHasMaxConnections()"
        -- format "support: %\n" support.name
        max_connections = SUPPORT_OPTIONS.max_connections
        -- format "max_connections: %\n" max_connections

        if classOf max_connections == integer and max_connections > 0 then
        (
            beams_of_support = SUPPORT_MANAGER.getObjectsByType support type:#BEAM
            -- format "BEAMS_OF_SUPPORT: %\n" beams_of_support.count
            -- format "TEST: %\n" (beams_of_support.count >= max_connections)
            beams_of_support.count >= max_connections
        )
        else
            false
    ),

    /** 
    * Filter pairs by average distance
    */
    function filterPairsByAverageDistance result =
    (
        pair_matrix = result[1]
        distance_matrix = result[2]
        filtered_pairs = #()

        if distance_matrix.count == 0 then filtered_pairs -- return

        total = 0.0
        for d in distance_matrix do total += d
        avg_distance = total / distance_matrix.count
        max_allowed_distance = avg_distance

        for i = 1 to distance_matrix.count do
        (
            if distance_matrix[i] <= max_allowed_distance do
            (
                append filtered_pairs pair_matrix[i]
            )
        )
        filtered_pairs -- return
    ),

    /** 
    * Check if two objects are already paired
    */
    function pairExist pair existing_pair =
    (
        (existing_pair[1] == pair[1] and existing_pair[2] == pair[2]) or \
        (existing_pair[1] == pair[2] and existing_pair[2] == pair[1])
    ),
	
	/**
	*/
	on create do
	(
		
	)
)

-- Create instance
--SearchForNearObjectsByRadius = SearchForNearObjectsByRadius_v(100)
