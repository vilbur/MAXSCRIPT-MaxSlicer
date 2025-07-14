clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../GridSupportSeeder.ms" )	--"./../GridSupportSeeder.ms"
/* 
	Creates a
	
	flat box above ground and 20 randomly placed support_mockup below it.

	--"./../Doc/select-verts-up-down.gif.gif.gif"

*/

function createBox box_width box_length wirecolor cylinder_count:10 =
(
	--cylinder_count = 60

	obj = box length:box_length width:box_width height:20 pos:[ 0, 0, 80 ] lengthsegs:( ceil (box_length/5) ) widthsegs:( ceil (box_width/5) ) heightsegs:1	wirecolor:wirecolor
	
	obj --return
)

/** Create spheres
 */
function createSpheres =
(
	--format "\n"; print ".createSpheres()"
	local obj
	
	for i = 1 to 4 do
		obj = Sphere pos:[ 350 * i, 0, 300 ] radius:(50 * i) segments:4
		
	select obj
	
	convertTo obj PolyMeshObject
	
	obj --return
)

function createCylinders obj cylinder_count:10 =
(
	format "obj: %\n" format "cylinder_count: %\n" cylinder_count
	if obj == undefined then 
		return false
	
	min_x = 1e9
	min_y = 1e9
	max_x = -1e9
	max_y = -1e9

	bbox	= nodeGetBoundingBox obj ( Matrix3 1) -- return array of min\max positions E.G.: bbox[1].z | bbox[2].z

	if bbox[1].x < min_x then min_x = bbox[1].x
	if bbox[1].y < min_y then min_y = bbox[1].y
	if bbox[2].x > max_x then max_x = bbox[2].x
	if bbox[2].y > max_y then max_y = bbox[2].y


	/* CREATE 20 RANDOM SUPPORT_MOCKUP BELOW THE BOX */ 
	for i = 1 to cylinder_count do
	(
		x = random min_x max_x
		y = random min_y max_y
		
		pos = [x, y, 0 ]
		format "pos: %\n" pos

		/* CREATE MOCK SUPPORTS IF ARE BELLOW TEST BOXES */ 		
		--for obj in test_objects do 
			if intersectRay obj ( Ray pos [0,0,1] ) != undefined  then
			(
				cyl = cylinder radius:1 pos:pos height:obj.pos.z wirecolor:gray
				
				cyl.parent = obj
			)
	)
	
	obj --return
)


/** Rotate box
 */
function rotateBox obj =
(
	--format "\n"; print ".rotateBox()"
	parent_point = Point()
	
	obj.parent = parent_point
	
	
	at time 1
		--rotate obj (angleaxis 90 [0,0,1])
		rotate parent_point (angleaxis 90 [0,0,1])
	
	--at time 1
		--rotate parent_point (angleaxis 45 [0,1,0])
	
	sliderTime = 1
)


/*------------------------------------------------------------------------------
	RESET TEST
--------------------------------------------------------------------------------*/
closest_verts = undefined 
hit_positions = undefined 
closest_verts_pos = undefined 

--delete objects
delete helpers
delete $'Cylinder*'

obj	= selection[1]
support_mockup = #()

/*------------------------------------------------------------------------------
	PREPARE SCENE
--------------------------------------------------------------------------------*/

/*------ OBJ ------*/
if objects.count == 0 then
	obj = createSpheres()

--obj  = createBox 100 10  yellow
--rotateBox(obj)


/*------ SOURCE OBJECTS  ------*/
source_objs	= selection as Array
--source_objs    = $Box* as Array
--source_objs    = $Sphere* as Array


/*------ CELL OBJECTS ------*/
createCylinders obj --cylinder_count:5

support_mockup = ( $'Cylinder*' as Array ) 



format "source_objs: %\n" source_objs

/*==============================================================================
  
	CONFIGURE TEST
	
================================================================================*/
debug = false
debug = true

GridSupportSeeder = GridSupportSeeder_v(source_objs) debug:debug -- debug creates helpers to mark grid and hits

/* CELL SIZE */ 
--GridSupportSeeder.cell_size = 50
--GridSupportSeeder.cell_size = 25
GridSupportSeeder.cell_size = 10
--GridSupportSeeder.cell_size = 5
--GridSupportSeeder.cell_size = 5.5
--GridSupportSeeder.cell_size = 6
--GridSupportSeeder.cell_size = 2


/* COFIG CIRCLE PATERN */ 
grid_type = #GRID
--grid_type = #CIRCLE


--GridSupportSeeder.segments_count = 32
--GridSupportSeeder.segments_count = 4
--GridSupportSeeder.segments_count = 16
--GridSupportSeeder.segments_count_keep = true

/*==============================================================================

		RUN TESTS

================================================================================*/

format "\n------------------------ POSITION OF CLOSEST VERT OF HIT -------------------------------\n"

closest_verts_pos = GridSupportSeeder.getClosestVertsOfEmptyCells(support_mockup) #POS grid_type:grid_type
 format "closest_verts_pos: %\n" closest_verts_pos
/* SHOW RESULT */ 
if closest_verts_pos != undefined then
	for obj_pointer in closest_verts_pos.keys do
		for closest_vert_pos in closest_verts_pos[obj_pointer] do 
			Point pos:closest_vert_pos size:5 Box:true wirecolor:orange


format "\n------------------------ POSITION OF HITS -------------------------------\n"

 --hit_positions = GridSupportSeeder.getClosestVertsOfEmptyCells(support_mockup) #HITS grid_type:grid_type

/* SHOW RESULT */ 
 if hit_positions != undefined then 
	 for obj_pointer in hit_positions.keys do
		 for closest_vert_pos in hit_positions[obj_pointer] do 
			 Point pos:closest_vert_pos size:10 Box:true wirecolor:blue
--			
--			
format "\n------------------------ INDEXES OF VERTS CLOSEST TO HITS -------------------------------\n"
--
--closest_verts = GridSupportSeeder.getClosestVertsOfEmptyCells(support_mockup) #VERTS grid_type:grid_type
--format "closest_verts: %\n" closest_verts
-- /* SHOW RESULT */ 
if closest_verts != undefined then
	for obj_pointer in closest_verts.keys do
		for closest_vert in closest_verts[obj_pointer] do 
			format "CLOSEST_VERT: %\n" closest_vert

