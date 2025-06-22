filein( getFilenamePath(getSourceFileName()) + "/../GridSupportSeeder.ms" )	--"./../GridSupportSeeder.ms"

/* 
Creates a flat box above ground and 20 randomly placed cylinders below it.
*/

function createBoxAndCylinders =
(
	-- create flat box
	box_width = 100
	box_length = 100
	box_height = 5
	box_z = 100
	
	flat_box = box length:box_length width:box_width height:box_height wirecolor:yellow
	flat_box.position = [0, 0, box_z + box_height/2]
	
	rotate flat_box (angleaxis 45 [0,0,1])

	bbox	= nodeGetBoundingBox flat_box ( Matrix3 1) -- return array of min\max positions E.G.: bbox[1].z | bbox[2].z
	
	format "bbox: %\n" bbox
	
	-- create 20 random cylinders below the box
	num_cylinders = 20
	cyl_height = 20
	cyl_radius = 1
	min_z = box_z - 80
	max_z = box_z - cyl_height - 5
	
	for i = 1 to num_cylinders do
	(
		x = random bbox[1].x bbox[2].x
		y = random bbox[1].y bbox[2].y
		
		cyl = cylinder radius:cyl_radius height:cyl_height wirecolor:green
		cyl.position = [x, y, 0 ]
	)
) -- return


delete objects
createBoxAndCylinders() -- run

cylinders = ( $'Cylinder*' as Array ) 

GridSupportSeeder = GridSupportSeeder_v()

GridSupportSeeder.target_objects = $Box001
GridSupportSeeder.cell_size = 15

GridSupportSeeder.initGrid(cylinders)

GridSupportSeeder.sortNodesToMatrix (cylinders)

empty_cells = GridSupportSeeder.formatMatrixWithXYIndexes()


for cell_pos in empty_cells do
--format "empty_cell: %\n" empty_cell
	Sphere pos:cell_pos radius:1 wirecolor:red
