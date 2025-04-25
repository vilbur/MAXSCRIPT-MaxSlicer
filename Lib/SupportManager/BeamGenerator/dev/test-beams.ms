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
	--grid_size = 10
	sphere_radius = 5
	sphere_segments = 8
	sphere_spacing = 15
	--sphere_spacing = 30
	start_position = [0, 0, 0]
	
	random_range = 2  -- Max random offset in each direction
	random_range = 3  -- Max random offset in each direction
	random_range = 4  -- Max random offset in each direction
	random_range = 10  -- Max random offset in each direction
	random_range = 0  -- Max random offset in each direction
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

-- === CONFIGURATION ===
--max_connections_per_object = 1
max_connections_per_object = 2
--max_connections_per_object = 3


-- === FUNCTIONS ===

fn compareDistanceAsc a b =
(
    if a[1] < b[1] then -1 else if a[1] > b[1] then 1 else 0
)

fn findClosestPairs obj_array =
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

        qsort distances compareDistanceAsc
        for k = 1 to (amin max_connections_per_object distances.count) do
        (
            local closest_obj = distances[k][2]
            local pair = #(obj, closest_obj)

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

-- Filters out pairs that are above average distance
fn filterPairsByAverageDistance result =
(
    local pair_matrix = result[1]
    local distance_matrix = result[2]
    local filtered_pairs = #()

    if distance_matrix.count == 0 then return filtered_pairs

    local total = 0.0
    for d in distance_matrix do total += d
    local avg_distance = total / distance_matrix.count
    max_allowed_distance = total / distance_matrix.count
    --max_allowed_distance = 1.0
    max_allowed_distance = 1e6

    --local max_allowed_distance = avg_distance * 2

    for i = 1 to distance_matrix.count do
    (
        if distance_matrix[i] <= max_allowed_distance do
        (
            append filtered_pairs pair_matrix[i]
        )
    )

    return filtered_pairs
)

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

        line_obj.wirecolor = color 255 128 0
    )
)

delete shapes

createTestObjects()

-- === USAGE ===
result = findClosestPairs objects
filtered_pairs = filterPairsByAverageDistance result
createConnectionLines filtered_pairs
--createConnectionLines result[1]

