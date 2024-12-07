/** Get lowest verts in grid
 */
struct GetLowestVertsInGrid_v
(
	/* construct */
	obj,

	/* properties */
	--resolution_grid = 5,
	resolution_grid = 10,

	points_grid 	= #(),
	verts_to_get 	= #{},
	verts_positions 	= #{},

	/* dependency */
	/* reference */
	/* inhered */

	/** Select lowest
	 */
	function selectLowestVerts =
	(
		--format "\n"; print "GetLowestVertsInGrid_v.selectLowestInts()"

		this.getVertsInGrid()

		lowest_verts = #{}

		for x = 1 to points_grid.count do
			for y = 1 to points_grid[x].count do
			(
				points_in_cell = points_grid[x][y]
				format "points_in_cell: %\n" points_in_cell

				verts_pos_in_cell = meshop.getVerts obj.mesh points_in_cell node:obj


				z_positions = for pos in verts_pos_in_cell collect pos.z
				--format "z_positions: %\n" z_positions
				z_pos_min = amin z_positions
			--format "z_pos_min: %\n" z_pos_min

				index	= findItem z_positions (amin z_positions)

				--lowest_vert = #{( vertex_sel as Array )[index]}
				lowest_vert = ( points_in_cell as Array )[index]

				lowest_verts[lowest_vert] = true
				--format "verts_to_get: %\n" points_in_cell

			)



		this._selectFinalSelection (lowest_verts)
	),

	/** Get point in grid
	 */
	function getVertsInGrid =
	(
		--format "\n"; print "GetLowestVertsInGrid_v.getPointInGrid()"
		fn round p3 dp =
		(
			local tempArr = #(p3.x,p3.y,p3.z)
			local mult = 10.00^(dp as float)
			local rp3Arr = for c in tempArr collect ((floor ((c * mult)+0.5)) / mult)
			point3 rp3Arr[1] rp3Arr[2] rp3Arr[3]
		)



		vertex_sel	= getVertSelection obj.mesh --else #{} -- ignore vertex selection if not suobject level active
		verts_count	= getNumVerts obj.mesh
		verts_all	= #{1..(verts_count)}

		verts_to_get = if vertex_sel.isEmpty then verts_all else vertex_sel

		verts_to_get_arr = verts_to_get as Array

		verts_positions = meshop.getVerts obj.mesh verts_to_get node:obj
		format "verts_positions: %\n" verts_positions
	--for verts_position in verts_positions do
		--format "verts_position: %\n" verts_position

		/* ROUND POSTIONS TO TENS - [111.1589,12.856,85.5896] >>> [110,10,90] */
		pos_round = for pos in verts_positions collect round pos 0

		x_positions = for pos in pos_round collect pos.x
		y_positions = for pos in pos_round collect pos.y
		z_positions = for pos in pos_round collect pos.z

		x_min = amin x_positions
		x_max = amax x_positions
		y_min = amin y_positions
		y_max = amax y_positions

		format "x_min: %\n" x_min
		format "x_max: %\n" x_max
		format "y_min: %\n" y_min
		format "y_max: %\n" y_max


		x_size = x_max - y_min
		y_size = y_max - y_min

		counter_x = 0

		--points_grid = for x = amin x_positions to (amax x_positions) - 0.00001 by resolution_grid collect
		--(
		--	counter_x +=1
		--	counter_y = 0
		--
		--	for y = amin y_positions to (amax y_positions) - 0.00001 by resolution_grid collect
		--		"X" + ( counter_x) as string + "Y" + ( counter_y +=1 ) as string
		--)

		this.points_grid = for x = x_min to x_max by resolution_grid collect
			for y = y_min to y_max by resolution_grid collect #{} -- bitAarray to store verts which occupy cell of grid


		--for verts_position in verts_positions do
		/*
			return 2 matrix of cells on XY grid
			#(
				#( #{x1y1}, #{x1y2} )
				#( #{x2y1}, #{x2y2} )
				#( #{x3y1}, #{x3y2} )
			)

		  */
		for i = 1 to verts_positions.count do
		(
			--format "\n--------------------\n"
			--format "verts_positions[i]: %\n" verts_positions[i]
			--format "X: %\n" verts_positions[i].x
			--format "Y: %\n" verts_positions[i].y

			index_x = ((( verts_positions[i].x - x_min ) / resolution_grid) as integer) + 1
			index_y = ((( verts_positions[i].y - y_min ) / resolution_grid) as integer) + 1

			index_vert = verts_to_get_arr[i]

			--format "index_x: %\n" index_x
			--format "index_y: %\n" index_y

			points_grid[index_x][index_y][index_vert] = true
		)

		/* MARGE LAST TOP SQUARES - verts from last cell are on border of verts, they belongs to last cell */
		for x = 1 to points_grid.count where points_grid[x].count > 1 do
		(
			last_cell_y = points_grid[x].count

			 points_grid[x][last_cell_y - 1 ] += points_grid[x][last_cell_y]

			deleteItem  points_grid[x] last_cell_y
		)

		/* MARGE LAST RIGHT SQUARE - verts from last cell are on border of verts, they belongs to last cell */
		if (x_max = points_grid.count) > 1 and (y_max = points_grid[1].count ) > 1 then
			for row = 1 to y_max  do
				points_grid[x_max - 1][row] += points_grid[x_max][row]

		deleteItem  points_grid points_grid.count


		--for x = amin x_positions to amax x_positions by resolution_grid do
		--	for y = amin y_positions to amax y_positions by resolution_grid do
		--	(
		--		format "\n--------------------\n"
		--		format "x: %\n" x
		--		format "y: %\n" y
		--		points_in_cell = #{}
		--		--points_in_cell = for p = 1 to pos_round.count \
		--		--	where pos_round[p].x >= x \
		--		--	and pos_round[p].x < x + resolution_grid \
		--		--	and pos_round[p].y >= y \
		--		--	and pos_round[p].y < y + resolution_grid \
		--		--collect p
		--
		--	format "points_in_cell: %\n" points_in_cell
		--	--if points_in_cell.count > 0 then
		--		append points_grid points_in_cell
		-- )


		--points_grid --return
	),

	private

	/** Select final selection
	 */
	function _selectFinalSelection lowest_verts =
	(
		--format "\n"; print "GetLowestVertsInGrid_v._selectFinalSelection()"
		subObjectLevel = 1

		if classOf ( _mod = modPanel.getCurrentObject() ) == Edit_Poly then
		(
			_mod.SetSelection #Vertex #{}
			_mod.Select #Vertex lowest_verts

		)
		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection #Vertex lowest_verts

	),

	/**
	 */
	on create do
	(
		--format "\n"; print "GetLowestVertsInGrid.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)

