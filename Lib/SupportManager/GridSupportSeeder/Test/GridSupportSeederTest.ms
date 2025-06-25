filein( getFilenamePath(getSourceFileName()) + "/../GridSupportSeeder.ms" )	--"./../GridSupportSeeder.ms"

/* 
	Creates a flat box above ground and 20 randomly placed cylinders below it.

	--"./../Doc/select-verts-up-down.gif.gif.gif"

*/

function createBoxAndCylinders box_width box_length =
(
	-- create flat box
	/** Create box
	 */
	function createBox box_width box_length box_height pos =
	(
		--format "\n"; print ".createBox()"
		flat_box = box length:box_length width:box_width height:box_height pos:pos lengthsegs:( ceil (box_length/5) ) widthsegs:( ceil (box_width/5) ) heightsegs:1		
		
		
		--addModifier flat_box (tessellate faceType:1 iterations:3 tension:0 )
		--addModifier flat_box (tessellate iterations:3 tension:0 )
		--convertTo flat_box PolyMeshObject
		
		flat_box --return
	)
	
	num_cylinders = 60

	flat_box1 = createBox box_width box_length 20 [ 0, 0, 80 ]
	flat_box2 = createBox box_width box_length  10  [ 45, 5, 90 ]
	
	test_objects = #( flat_box1, flat_box2 )
	
	rotate flat_box1 (angleaxis 45 [0,0,1])

	--bbox	= nodeGetBoundingBox flat_box1 ( Matrix3 1) -- return array of min\max positions E.G.: bbox[1].z | bbox[2].z
	min_x = 1e9
	min_y = 1e9
	max_x = -1e9
	max_y = -1e9

	for node in test_objects do
	(
		pos = node.position
		
		if node.min.x < min_x then min_x = node.min.x
		if node.min.y < min_y then min_y = node.min.y
		if node.max.x > max_x then max_x = node.max.x
		if node.max.y > max_y then max_y = node.max.y
	)
	
	/* create 20 random cylinders below the box */ 
	cyl_height = flat_box1.pos.z 
	cyl_radius = 1		--num_cylinders = 20

	--min_z = flat_box1.pos.z - 80
	--max_z = flat_box1.pos.z - cyl_height - 5
	
	for i = 1 to num_cylinders do
	(
		x = random min_x max_x
		y = random min_y max_y
		
		pos = [x, y, 0 ]
		

		/* CREATE MOCK SUPPORTS IF ARE BELLOW TEST BOXES */ 		
		for obj in test_objects do 
			if intersectRay obj ( Ray pos [0,0,1] ) != undefined  then
				cyl = cylinder radius:cyl_radius pos:pos height:cyl_height wirecolor:gray
	)
)

/*------------------------------------------------------------------------------
	PREPARE SCENE
--------------------------------------------------------------------------------*/
delete objects

closest_verts = undefined 
hit_positions = undefined 


--createBoxAndCylinders 100 100
--createBoxAndCylinders 100 20
createBoxAndCylinders 100 5

boxes     = $Box* as Array
cylinders = ( $'Cylinder*' as Array ) 


/*------------------------------------------------------------------------------
	TEST
--------------------------------------------------------------------------------*/
GridSupportSeeder = GridSupportSeeder_v()

GridSupportSeeder.cell_size = 10
--GridSupportSeeder.cell_size = 5

GridSupportSeeder.initGrid(boxes)

GridSupportSeeder.sortNodesToMatrix (cylinders)



format "\n------------------------ PALCE OBJECTS TO POSITION OF CLOSEST VERT OF HIT -------------------------------\n"

closest_verts    = GridSupportSeeder.getClosestVertsOfEmptyCells(boxes) #VERTS

/* SHOW RESULT */ 
if closest_verts != undefined then
	for key in closest_verts.keys do
		for closest_vert_pos in closest_verts[key] do 
			Sphere pos:closest_vert_pos radius:1 wirecolor:(getAnimByHandle ( key as IntegerPtr )).wirecolor



format "\n------------------------ PALCE TO POSITION OF HITS -------------------------------\n"

hit_positions = GridSupportSeeder.getClosestVertsOfEmptyCells(boxes) #HITS

/* SHOW RESULT */ 
if hit_positions != undefined then 
	for key in hit_positions.keys do
		for closest_vert_pos in hit_positions[key] do 
			Sphere pos:closest_vert_pos radius:1 wirecolor:red
