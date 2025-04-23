clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../BeamGenerator.ms" )	--"./../BeamGenerator.ms"



/** Create test objects
 */
function createTestObjects =
(
	--format "\n"; print ".createTestObjects()"
	delete objects 
	-- Parameters
	grid_size = 5
	sphere_radius = 5
	sphere_segments = 8
	sphere_spacing = 15
	start_position = [0, 0, 0]
	
	random_range = 2.0  -- Max random offset in each direction
	random_range = 3.0  -- Max random offset in each direction
	
	-- Create grid of spheres with random position offsets
	for row = 0 to grid_size - 1 do (
		for col = 0 to grid_size - 1 do (
			local pos_x = start_position.x + col * sphere_spacing + random -random_range random_range
			local pos_y = start_position.y - row * sphere_spacing + random -random_range random_range
			local pos_z = start_position.z + random -random_range random_range
	
			sphere radius:sphere_radius segments:sphere_segments pos:[pos_x, pos_y, pos_z]
		)
	)
	
	select objects 
		
)


--createTestObjects()

BeamGenerator = BeamGenerator_v()


sorted = BeamGenerator._sortSupportsByDistance( objects ) 9999999999999

for item in sorted do
format "item: %\n" item
