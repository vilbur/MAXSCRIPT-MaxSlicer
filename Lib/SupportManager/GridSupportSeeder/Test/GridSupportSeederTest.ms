filein( getFilenamePath(getSourceFileName()) + "/../GridSupportSeeder.ms" )	--"./../GridSupportSeeder.ms"

/* 
	Creates a flat box above ground and 20 randomly placed cylinders below it.

	--"./../Doc/select-verts-up-down.gif.gif.gif"

*/

function createBoxAndCylinders =
(
	-- create flat box
	/** Create box
	 */
	function createBox box_width box_length box_height pos =
	(
		--format "\n"; print ".createBox()"
		flat_box = box length:box_length width:box_width height:box_height pos:pos --wirecolor:yellow
		--flat_box.position = [0, 0, box_z + box_height/2]
		
		addModifier flat_box (tessellate faceType:1 iterations:3 tension:0 )
		--addModifier flat_box (tessellate iterations:3 tension:0 )
		convertTo flat_box PolyMeshObject
		
		flat_box --return
	)
	
	flat_box1 = createBox 100 100 20 [ 0, 0, 80 ]
	flat_box2 = createBox 80  80  10  [ 50, 0, 90 ]
	
	
	rotate flat_box1 (angleaxis 45 [0,0,1])

	bbox	= nodeGetBoundingBox flat_box1 ( Matrix3 1) -- return array of min\max positions E.G.: bbox[1].z | bbox[2].z
	
	format "bbox: %\n" bbox
	
	-- create 20 random cylinders below the box
	--num_cylinders = 20
	num_cylinders = 30
	cyl_height = flat_box1.pos.z - 40
	cyl_radius = 1
	min_z = flat_box1.pos.z - 80
	max_z = flat_box1.pos.z - cyl_height - 5
	
	for i = 1 to num_cylinders do
	(
		x = random bbox[1].x bbox[2].x
		y = random bbox[1].y bbox[2].y
		
		cyl = cylinder radius:cyl_radius height:cyl_height wirecolor:green
		cyl.position = [x, y, 0 ]
	)
)


/* PREPARE SCENE */ 
delete objects

createBoxAndCylinders() -- run

boxes     = $Box* as Array
cylinders = ( $'Cylinder*' as Array ) 


/*------------------------------------------------------------------------------
	TEST
--------------------------------------------------------------------------------*/
GridSupportSeeder = GridSupportSeeder_v()

GridSupportSeeder.cell_size = 15

GridSupportSeeder.target_objects = boxes

GridSupportSeeder.initGrid(boxes)

GridSupportSeeder.sortNodesToMatrix (cylinders)

closest_verts_pos = GridSupportSeeder.getClosestVertsOfEmptyCells()



for closest_vert_pos in closest_verts_pos do
	Sphere pos:closest_vert_pos radius:1 wirecolor:red
