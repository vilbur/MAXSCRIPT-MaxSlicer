-- Struct: only main working functions
struct SearchForNearObjectsByRadius (
    
    function createTestObjects object_count area_size = (
        created_objects = #()
        for i = 1 to object_count do (
            pos = [ 
                random (area_size * -1) area_size,
                random (area_size * -1) area_size,
                random (area_size * -1) area_size]
            sphere_obj = sphere radius:(random 5 15) pos:pos
            append created_objects sphere_obj
        )
        created_objects -- return
    ),

    function buildSpatialGrid objects cell_size = (
        grid = Dictionary()
        for obj in objects do (
            cell_x = floor (obj.position.x / cell_size)
            cell_y = floor (obj.position.y / cell_size)
            cell_z = floor (obj.position.z / cell_size)

            cell_key_str = "cell_" + (cell_x as string) + "_" + (cell_y as string) + "_" + (cell_z as string)
            cell_key = (cell_key_str as name)

            if not (HasDictValue grid cell_key) do (
                grid[cell_key] = #()
            )
            append grid[cell_key] obj
        )
        grid -- return
    ),

    function getObjectsInRadius _grid center_pos radius cell_size = (
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
    )
)


-- Global test function: builds grid and returns test data
function testBuildGrid = (
    delete objects -- clear scene
    s = SearchForNearObjectsByRadius()
    test_objects = s.createTestObjects 200 500.0
    cell_size = 100.0
    grid = s.buildSpatialGrid test_objects cell_size
    #(s, test_objects, grid, cell_size) -- return
)

-- Global test function: runs search
function testRunSearch = (
    local test_data = testBuildGrid()
    s = test_data[1]
    test_objects = test_data[2]
    grid = test_data[3]
    cell_size = test_data[4]

    some_object = test_objects[1]
    nearby_objects = s.getObjectsInRadius grid some_object.position 500.0 cell_size

    for obj in nearby_objects do (
        obj.wirecolor = orange
    )
    some_object.wirecolor = red

    print nearby_objects
    nearby_objects -- return
)

-- Run it like:
 testRunSearch()
