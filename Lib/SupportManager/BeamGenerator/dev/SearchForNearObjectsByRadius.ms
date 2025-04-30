-- Struct: contains only spatial _grid and search logic
struct SearchForNearObjectsByRadius_v (

    cell_size = 0.0,

    /** Search for objects in radius
    */
    function searchForObjectsInRadius search_object _objects radius = 
    (
		--cell_size = radius * 2.5
		cell_size = radius * 3 -- value: 3 makes most less iterations of loops in this.getObjectsInRadius()
		
        _grid = this.buildSpatialGrid _objects
        this.getObjectsInRadius _grid search_object.position radius -- return
    ),

    /** Build spatial _grid based on objects and cell size
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

    /** Get nearby objects within radius
    */
    function getObjectsInRadius _grid center_pos radius = 
    (
        result = #()
        cell_radius = ceil (radius / cell_size)
        center_cell_x = floor (center_pos.x / cell_size)
        center_cell_y = floor (center_pos.y / cell_size)
        center_cell_z = floor (center_pos.z / cell_size)

        for x = (center_cell_x - cell_radius) to (center_cell_x + cell_radius) do (
            for y = (center_cell_y - cell_radius) to (center_cell_y + cell_radius) do (
                for z = (center_cell_z - cell_radius) to (center_cell_z + cell_radius) do (
                    cell_key_str = "cell_" + (x as string) + "_" + (y as string) + "_" + (z as string)
                    cell_key = (cell_key_str as name)

                    if HasDictValue _grid cell_key do (
                        for obj in _grid[cell_key] do (
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

    on create do
    (
    )
)

-- Global function: create random test objects
function createTestObjects object_count area_size = 
(
    created_objects = #()
    for i = 1 to object_count do (
        pos = [
            random (area_size * -1) area_size,
            random (area_size * -1) area_size,
            random (area_size * -1) area_size ]
		
        sphere_obj = sphere radius:(random 5 15) pos:pos wirecolor:gray
        append created_objects sphere_obj
    )
    created_objects -- return
)

-- Global function: run search and visualize
function runSearchForObjectsInRadius _objects radius  = 
(
	-- Helper function: get random element from array
	function getRandomElement arr = 
	(
		if arr.count > 0 then (
			arr[random 1 arr.count]
		)
		else undefined -- return
	)
	
    first_object = getRandomElement _objects

    SearchForNearObjectsByRadius = SearchForNearObjectsByRadius_v()

    nearby_objects = SearchForNearObjectsByRadius.searchForObjectsInRadius first_object _objects radius

    for obj in nearby_objects do (
        obj.wirecolor = orange
    )

    first_object.wirecolor = red

    select first_object

    print nearby_objects
    nearby_objects -- return
)



-- Usage:
delete objects


test_objects = createTestObjects 400 500.0

radius = 200

runSearchForObjectsInRadius test_objects radius 
--runSearchForObjectsInRadius test_objects radius
