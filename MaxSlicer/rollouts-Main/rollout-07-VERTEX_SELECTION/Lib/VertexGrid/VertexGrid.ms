--filein( getFilenamePath(getSourceFileName()) + "/../MeshDataGetter/MeshDataGetter.ms" )	--"./../MeshDataGetter/MeshDataGetter.ms"



/** Grid vert selector
 */
struct VertexGrid_v
(
	/* construct */
	obj,

	/* required */


	/* properties */
	--resolution = 5,
	resolution = 10,

	verts_pos,


	/* private */
	/* dependency */
	/* reference */
	/* inhered */



	/* reference */
	verts_data,	-- MeshDataGetter.verts_data
	data_faces,	-- MeshDataGetter.data_faces


	/* private */
	/* dependency */
	--VerIslandFinder = VerIslandFinder_v(),


	--resolution = 10,

	points_grid 	= #(), -- 2DMatrix of verts which share same cell in grid points_grid[X_CELL][Y_CELL]
	--sel_modified 	= #{}, -- modified selection for selecting
	round_grid	= #( #(), #(), #() ), -- 3D matrix of points positions rounded into 3 grid - round_grid[AXIS][CELL][VERT]

	--MeshDataGetter,


	/** Get point in grid

		return 2 matrix of cells on XY grid
			#(
				#( #{x1y1}, #{x1y2} )
				#( #{x2y1}, #{x2y2} )
				#( #{x3y1}, #{x3y2} )
			)
	 */
	function _getVertsInGrid verts =
	(
		format "\n"; print "VertexGrid_v._getVertsInGrid()"
		format "RESOLUTION: %\n" resolution
		format "verts: %\n" verts
		format "verts.numberSet: %\n" verts.numberSet

		/** Get cell by position
		 */
		function cellByPos vert_pos_on_axis axis_origin =
		(
			((( vert_pos_on_axis - axis_origin ) / this.resolution) as integer ) + 1
		)

		fn roundPoint3 p3 dp =
		(
			--format "p3: %\n" p3
			local tempArr = #(p3.x,p3.y,p3.z)
			local mult = 10.00^(dp as float)
			local rp3Arr = for c in tempArr collect ((floor ((c * mult)+0.5)) / mult)
			point3 rp3Arr[1] rp3Arr[2] rp3Arr[3]
		)
		--vertex_count = getNumVerts obj.mesh

		verts_all = #{1..(getNumVerts obj.mesh)}

		verts_pos = this._getVertsPositions(verts)

		verts_arr = verts as Array

		timer_pos_by_axis = timeStamp()
		pos_by_axis = this.getPositionsSplitByAxis(verts_arr)
		format "pos_by_axis: % seconds\n" ((( timeStamp()) - timer_pos_by_axis) / 1000.0)

		min_pos = #( amin pos_by_axis[1], amin pos_by_axis[2], amin pos_by_axis[3])

		/* FILL MATRIX
			round_grid[AXIS][CELL][VERT]
		*/
		for i = 1 to verts_arr.count do
		(
			vert	= verts_arr[i]
			vert_pos	= verts_pos[vert]

			for axis = 1 to 3 do
			--for axis = 1 to 2 do
			(
				level = cellByPos(vert_pos[axis])(min_pos[axis])

				--if level == 0 then
				--(
				--	format "\n"
				--	format "vert: %\n" vert
				--	format "VERT_POS: %\n" vert_pos
				--	format "VERT_POS[axis]: %\n" vert_pos[axis]
				--	format "min_pos[axis]:   %\n" min_pos[axis]
				--	format "level: %\n" level
				--
				--)

				--if level > 0 then
				(

				/* CRTEATE NEW CELL */
				if (round_grid[axis][level]) == undefined then
					round_grid[axis][level] = #{}

				/* SET VERT TO BITARRAY OF CELL */
				round_grid[axis][level][vert] = true
				)
			)
		)

		--gc()
		gc light:true


		--format "POINTS_GRID: %\n" points_grid

		points_grid --return
	),

	/** Set verts positions
	 */
	function _getVertsPositions verts =
	(
		--format "\n"; print "VertexGrid_v._getVertsPositions()"
		--format "verts_process: %\n" verts_process
		--format "verts: %\n" verts
		--format "verts.numberSet: %\n" verts.numberSet

		--if verts_pos == undefined then
		--	this.verts_pos = #{1..(getNumVerts obj.mesh)} as Array
		--
		--verts_process_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj
		----format "verts_process_pos: %\n" verts_process_pos
		--
		--for i = 1 to verts_process_pos.count do
		--(
		--	vert = (verts  as Array )[i]
		--	--format "vert: %\n" vert
		--
		--	verts_pos[vert] = verts_process_pos[i]
		--)
		--
		--
		--verts_pos --return





		all_verts = #{1..(getNumVerts obj.mesh)}

		--verts_pos = in coordsys world meshop.getVerts obj.mesh all_verts node:obj
		verts_pos = meshop.getVerts obj.mesh all_verts node:obj

		verts_pos --return
	),


	/** Check selection ingerity
	 */
	function _checkSelectionIngerity mesh_sel polyop_sel =
	(
		--format "\n"; print "VertexGrid_v._checkSelectionIngerity()"

		if mesh_sel[mesh_sel.count] 1= polyop_sel[polyop_sel.count] then
			messageBox ("Object '"+obj.name+"' needs to be rexported.\n\nVertex needs to be reindexed" )title:"VertexGrid_v"
	),


	/** Get positions of each vert splitted to XYZ
	  * Usefull for gettin min and max values oe verts by each axis separatly
	  *
	  * @return #( #(X pos), #(Y pos), #(Z pos) )
	 */
	function getPositionsSplitByAxis verts_arr =
	(
		format "\n"; print "VertexGrid_v.getPositionsSplitted()"
		x_positions = #()
		y_positions = #()
		z_positions = #()


		if (verts_count = verts_arr.count) > 0 then
		(
			x_positions[verts_count] = undefined
			y_positions[verts_count] = undefined
			z_positions[verts_count] = undefined

			--for vert in verts_arr do
			for i = 1 to verts_count do
			(
				vert = verts_arr[i]

				vert_pos = verts_pos[vert]

				x_positions[vert] = vert_pos.x
				y_positions[vert] = vert_pos.y
				z_positions[vert] = vert_pos.z
			)

			--format "x_positions: %\n" x_positions
			--format "y_positions: %\n" y_positions
			--format "z_positions: %\n" z_positions

			x_positions = for x_position in x_positions where x_position != undefined collect x_position
			y_positions = for y_position in y_positions where y_position != undefined collect y_position
			z_positions = for z_position in z_positions where z_position != undefined collect z_position


		)

		#( x_positions, y_positions, z_positions  ) --return
	),


	private


	/** Set units muliplier
	  *
	  */
	function _setResolutionUnits =
	(
		--format "\n"; print "VertexGrid_v.setUnitsMuliplier()"
		display_units = case units.SystemType of -- convert to milimeters
		(
			#millimeters:	1
			#centimeters:	10
			#meters:	1000
			#kilometers:	1000000
			default:	1 -- non metric units
		)

		this.resolution /= display_units
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "VertexGrid.onCreate()"
		this._setResolutionUnits()
	)



)
