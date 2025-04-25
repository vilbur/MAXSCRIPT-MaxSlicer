/* ISLANDS VIA VERTS */
clearListener(); print("Cleared in:\n"+getSourceFileName())
--

/** Create test objects
 */
function createTestObjects =
(
	delete objects 
	-- Parameters
	grid_size = 5
	sphere_radius = 5
	sphere_segments = 8
	sphere_spacing = 15
	start_position = [0, 0, 0]
	
	random_range = 2.0  -- Max random offset in each direction
	random_range = 3.0  -- Max random offset in each direction
--	
	for row = 0 to grid_size - 1 do (
		for col = 0 to grid_size - 1 do (
			local pos_x = start_position.x + col * sphere_spacing + random -random_range random_range
			local pos_y = start_position.y - row * sphere_spacing + random -random_range random_range
			local pos_z = start_position.z + random -random_range random_range
	
			sphere radius:sphere_radius segments:sphere_segments pos:[pos_x, pos_y, pos_z]
		)
	)
	--format "\n"; print ".createTestObjects()"
	select objects 
)

-- === FUNCTIONS ===

-- Comparison function for qsort (ascending by distance)
fn compareDistanceAsc a b =
(
    if a[1] < b[1] then -1 else if a[1] > b[1] then 1 else 0
)

-- Find closest neighbors for each object, avoiding duplicate pairs
fn findClosestPairs obj_array max_connections_per_object =
(
    local pair_matrix = #()
    local distance_matrix = #()
    local checked_pairs = #()

    for i = 1 to obj_array.count do
    (
        local obj = obj_array[i]
        local distances = #()

        for j = 1 to obj_array.count do
        (
            if i != j do
            (
                local other_obj = obj_array[j]
                local dist = distance obj.position other_obj.position
                append distances #(dist, other_obj)
            )
        )

        -- sort by distance and get N closest
        qsort distances compareDistanceAsc
        for k = 1 to (amin max_connections_per_object distances.count) do
        (
            local closest_obj = distances[k][2]
            local pair = #(obj, closest_obj)

            -- Check for duplicate regardless of order
            local is_duplicate = false
            for existing_pair in checked_pairs do
            (
                if (existing_pair[1] == pair[1] and existing_pair[2] == pair[2]) or \
                   (existing_pair[1] == pair[2] and existing_pair[2] == pair[1]) then
                (
                    is_duplicate = true
                    exit
                )
            )

            if not is_duplicate do
            (
                append pair_matrix pair
                append distance_matrix (distance pair[1].position pair[2].position)
                append checked_pairs pair
            )
        )
    )

    return #(pair_matrix, distance_matrix)
)

-- Create orange lines between all pairs
fn createConnectionLines pair_matrix =
(
    for pair in pair_matrix do
    (
        local obj1 = pair[1]
        local obj2 = pair[2]

        local line_obj = splineShape name:"connection_line"
        addNewSpline line_obj
        addKnot line_obj 1 #corner #line obj1.position
        addKnot line_obj 1 #corner #line obj2.position
        updateShape line_obj

        line_obj.wirecolor = color 255 128 0 -- orange
    )
)


-- === CONFIGURATION ===
-- Set how many closest connections each object should have:
max_connections_per_object = 1
max_connections_per_object = 2
max_connections_per_object = 3
--max_connections_per_object = 4



delete shapes

createTestObjects()

-- === USAGE ===
result = findClosestPairs objects max_connections_per_object
createConnectionLines result[1]
