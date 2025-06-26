filein( getFilenamePath(getSourceFileName()) + "/../GridSupportSeeder.ms" )	--"./../GridSupportSeeder.ms"

/* 
	Creates a flat box above ground and 20 randomly placed support_mockup below it.

	--"./../Doc/select-verts-up-down.gif.gif.gif"

*/

function createBoxAndCylinders box_width box_length wirecolor =
(
	num_cylinders = 60

	obj = box length:box_length width:box_width height:20 pos:[ 0, 0, 80 ] lengthsegs:( ceil (box_length/5) ) widthsegs:( ceil (box_width/5) ) heightsegs:1	wirecolor:wirecolor

	min_x = 1e9
	min_y = 1e9
	max_x = -1e9
	max_y = -1e9


	bbox	= at time 1 nodeGetBoundingBox obj ( Matrix3 1) -- return array of min\max positions E.G.: bbox[1].z | bbox[2].z

	if bbox[1].x < min_x then min_x = bbox[1].x
	if bbox[1].y < min_y then min_y = bbox[1].y
	if bbox[2].x > max_x then max_x = bbox[2].x
	if bbox[2].y > max_y then max_y = bbox[2].y


	/* CREATE 20 RANDOM SUPPORT_MOCKUP BELOW THE BOX */ 
	for i = 1 to num_cylinders do
	(
		x = random min_x max_x
		y = random min_y max_y
		
		pos = [x, y, 0 ]
		

		/* CREATE MOCK SUPPORTS IF ARE BELLOW TEST BOXES */ 		
		if intersectRay obj ( Ray pos [0,0,1] ) != undefined  then
			cyl = cylinder radius:1 pos:pos height:obj.pos.z wirecolor:gray
	)
	
	obj --return
)

/*------------------------------------------------------------------------------
	RESET TEST
--------------------------------------------------------------------------------*/
delete objects

--currentTime = 1

closest_verts = undefined 
hit_positions = undefined 

/*------------------------------------------------------------------------------
	PREPARE SCENE
--------------------------------------------------------------------------------*/

--createBoxAndCylinders 100 100
--box_green = createBoxAndCylinders 100 20 green
box_blue  = createBoxAndCylinders 100 5  blue


parent_point = Point()

box_blue.parent = parent_point


at time 1
	rotate box_blue (angleaxis 90 [0,0,1])

sliderTime = 1



source_objs    = $Box* as Array
support_mockup = ( $'Cylinder*' as Array ) 


/*==============================================================================
  
	TEST
	
================================================================================*/
--GridSupportSeeder = GridSupportSeeder_v()
--
--GridSupportSeeder.cell_size = 10
----GridSupportSeeder.cell_size = 5
--
--GridSupportSeeder.initGrid(source_objs)
--
--GridSupportSeeder.sortNodesToMatrix (support_mockup)
--
--
--
--format "\n------------------------ PALCE OBJECTS TO POSITION OF CLOSEST VERT OF HIT -------------------------------\n"
--
--closest_verts = GridSupportSeeder.getClosestVertsOfEmptyCells(source_objs) #VERTS
--
--/* SHOW RESULT */ 
--if closest_verts != undefined then
--	for obj_pointer in closest_verts.keys do
--		for closest_vert_pos in closest_verts[obj_pointer] do 
--			Sphere pos:closest_vert_pos radius:1 wirecolor:(getAnimByHandle ( obj_pointer as IntegerPtr )).wirecolor
--
--
--
--format "\n------------------------ PALCE TO POSITION OF HITS -------------------------------\n"
--
----hit_positions = GridSupportSeeder.getClosestVertsOfEmptyCells(source_objs) #HITS
--
--/* SHOW RESULT */ 
--if hit_positions != undefined then 
--	for obj_pointer in hit_positions.keys do
--		for closest_vert_pos in hit_positions[obj_pointer] do 
--			Sphere pos:closest_vert_pos radius:1 wirecolor:red
