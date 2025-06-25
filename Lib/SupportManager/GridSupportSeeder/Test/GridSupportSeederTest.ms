filein( getFilenamePath(getSourceFileName()) + "/../GridSupportSeeder.ms" )	--"./../GridSupportSeeder.ms"

/* 
	Creates a flat box above ground and 20 randomly placed cylinders below it.

	--"./../Doc/select-verts-up-down.gif.gif.gif"

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
	
	addModifier flat_box (tessellate faceType:1 iterations:3 tension:0 )
	--addModifier flat_box (tessellate iterations:3 tension:0 )
	convertTo flat_box PolyMeshObject
	
	rotate flat_box (angleaxis 45 [0,0,1])

	bbox	= nodeGetBoundingBox flat_box ( Matrix3 1) -- return array of min\max positions E.G.: bbox[1].z | bbox[2].z
	
	format "bbox: %\n" bbox
	
	-- create 20 random cylinders below the box
	--num_cylinders = 20
	num_cylinders = 30
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
)

--/** Get index of closest vertex in Editable_Poly to given position */
--function getClosestVertex obj position =
--(
--	if classof obj != Editable_Poly and (isProperty obj #baseObject and classof obj.baseObject != Editable_Poly) then return undefined
--
--	poly = obj
--	
--	closest_index = 0
--	closest_dist = 1e9
--
--	num_verts = poly.getNumVerts()
--	
--	for i = 1 to num_verts do
--	(
--		vpos = poly.getVert i
--		dist = distance vpos position
--		
--		if dist < closest_dist then
--		(
--			closest_index = i
--			closest_dist = dist
--		)
--	)
--	
--	closest_index -- return
--)

/** Get index of closest face in Editable_Poly to given position */
function getClosestFace obj position =
(
	if classof obj != Editable_Poly and (isProperty obj #baseObject and classof obj.baseObject != Editable_Poly) then return undefined

	closest_index = 0
	closest_dist = 1e9

	num_faces = polyop.getNumFaces obj

	for i = 1 to num_faces do
	(
		face_verts = polyop.getFace obj i
		sum_pos = [0,0,0]

		for j = 1 to face_verts.count do
		(
			v = polyop.getVert obj face_verts[j]
			sum_pos += v
		)

		center = sum_pos / face_verts.count
		dist = distance center position

		if dist < closest_dist then
		(
			closest_index = i
			closest_dist = dist
		)
	)

	closest_index -- return
)


delete objects
createBoxAndCylinders() -- run

cylinders = ( $'Cylinder*' as Array ) 

GridSupportSeeder = GridSupportSeeder_v()

GridSupportSeeder.target_objects = #($Box001)
GridSupportSeeder.cell_size = 15
--GridSupportSeeder.cell_size = 10
GridSupportSeeder.cell_size = 20

GridSupportSeeder.initGrid(cylinders)

GridSupportSeeder.sortNodesToMatrix (cylinders)

closest_verts_pos = GridSupportSeeder.getClosestVertsOfEmptyCells()



--closest_verts = #{}

for closest_vert_pos in closest_verts_pos do
(
	format "closest_vert_pos: %\n" closest_vert_pos
	
	
	--closest_vert_pos.z = 0
	
	--vert = getClosestFace $Box001 hit.pos
	Sphere pos:closest_vert_pos radius:1 wirecolor:red
	--format "vert: %\n" vert
	
	--closest_verts[vert] = true
	
	
)

format "closest_verts: %\n" closest_verts

--format "empty_cell: %\n" empty_cell
--
--select $Box001
--max modify mode
--
--subObjectLevel = 4
--
--
--
--$.EditablePoly.SetSelection #Face closest_verts
