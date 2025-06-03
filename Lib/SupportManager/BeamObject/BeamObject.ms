/** Beam object
 */
struct BeamObject_v
(
	/* construct */
	support_A, -- support node
	support_B, -- support node
	sync_key,

	/* required */
	beam_key,

	/* properties */
	beam,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Create beams
	 */
	function generateBeam =
	(
		--format "\n"; print "BeamObject_v.generateBeam()"
		/* CREATE NEW BEAM */
		--if beam == unsupplied then

		points_of_lines = this._getBeamsEndPoints()
		--format "points_of_lines: %\n" points_of_lines

		this._createBeam()

		this.rotatePivotZAlignX (points_of_lines[1][1] - points_of_lines[2][1] )
		
		this._drawLines(points_of_lines)

		this._centerPivot()

		this._lockTransforms()

		bindOnObjectDeletedCallback( beam )

		support_A.layer.addNode beam

		SUPPORT_MANAGER.updateShapeAdd (this.beam)

		this --return
	),

	/** Update beam
	 */
	function updateBeam =
	(
		-- format "\n..........................................................................\n"
		-- format "\n"; print "BeamObject_v.updateBeam()"
		--format "beam: %\n" beam

		
		function getWidthOfBeam points_of_lines = distance points_of_lines[1][1] points_of_lines[2][1]
		
		function getHeightOfBeam points_of_lines =
		(
			-- returns vertical distance (along Z axis)
			function getZDistance p1 p2 = abs(p2.z - p1.z)  -- return

			getZDistance points_of_lines[1][1] points_of_lines[1][points_of_lines[1].count]
		)
		
		/* IS SUPPORT TALL ENOOGH */ 
		--function isTallEnough = (amin support_A.pos.z support_B.pos.z ) - support_A.min.z > SUPPORT _OPTIONS.min_height
		function isTallEnough height_of_beam = height_of_beam > SUPPORT_OPTIONS.min_height

		/* REMOVE OLD LINE */ 
		for i = numSplines beam to 1 by -1 do
			deleteSpline beam i


		/* SET POINTS */ 
		points_of_lines = this._getBeamsEndPoints()
		--format "points_of_lines: %\n" points_of_lines
	
		height_of_beam = getHeightOfBeam (points_of_lines)
		width_of_beam  = getWidthOfBeam (points_of_lines)
		
		ratio = height_of_beam / width_of_beam
		--format "RATIO: %\n" ratio
		
		min_distance	= getUserPropVal support_A "BAR_WIDTH" * SUPPORT_OPTIONS.min_distance_beams
		
		/* DRAW LINE */
		if (not support_A.boxmode and not support_B.boxmode) \
			and width_of_beam >= min_distance \
			and isTallEnough(height_of_beam) \
			and ratio >= 1
				then 
					this._drawLines(points_of_lines)

		
		SUPPORT_MANAGER.updateShapeAdd (this.beam)
	),


	--private

	/** Lock transforms
	 */
	function _lockTransforms =
	(
		--format "\n"; print "BeamObject_v._lockTransforms()"
		--lock_keys   = #( #MOVE_X,	#MOVE_Y,	#MOVE_Z,	#ROTATE_X,	#ROTATE_Y,	#ROTATE_Z,	#SCALE_X,	#SCALE_Y,	#SCALE_Z )
		--lock_states = #( 1,	1,	0,	1,	1,	1,	1,	1,	0        ) as BitArray

		setTransformLockFlags beam #{1..2,4..8}
	),

	/** Create beam
	 */
	function _createBeam =
	(
		-- format "\n"; print "BeamObject_v._createBeam()"
		this.beam = SplineShape name:(support_A.name + "-beam") wirecolor:(this._shiftWirecolor(support_A.wirecolor) )

		this._addToGroup (beam) (support_A)

		beam.parent	= support_A
		beam.pivot  = beam.center

		max create mode

		addModifier beam support_A.modifiers[#BAR_WIDTH]

	),

	/** Get beams end points
	  * 
	  * 
	  * @return
	 */
	function _getBeamsEndPoints beams_split_count: =
	(
		 --format "\n"; print "BeamObject_v.getBeamEndPoints()"
		/** Get posiotion of point on line
		 */
		function getPosOnLine pos vector offset = pos	+ ( offset	* vector * -1 )
		
		beams_created = #()
		
		if beams_split_count == unsupplied then
			beams_split_count = SUPPORT_OPTIONS.beams_split


		point_data_A = this._getSegmentEndPoints(support_A)
		point_data_B = this._getSegmentEndPoints(support_B)

		vectors = #( point_data_A[#VECTOR], point_data_B[#VECTOR] )
		--format "vectors: %\n" vectors
		/* BEAM 1 */
		bottom_A  	= point_data_A[#BOTTOM]
		top_A	= point_data_A[#TOP]

		/* BEAM 2 */
		bottom_B  	= point_data_B[#BOTTOM]
		top_B	= point_data_B[#TOP]

		/* COMPARE BOTTOM POSTIONS - GET HIGHER ONE */
		bottom_A.z = bottom_B.z = if ( bottom_A.z > bottom_B.z ) then bottom_A.z else bottom_B.z

		/* COMPARE TOP POSTIONS - GET LOWER ONE */
		top_A.z = top_B.z = if ( top_A.z > top_B.z ) then top_B.z else top_A.z
		
		points_on_supports = #( #( bottom_A ), #( bottom_B ) )
		

		/* SPLIT BEAMS */ 
		support_height = distance bottom_A top_A
		support_dist   = distance bottom_A bottom_B

		/*------------------------------------------------------------------------------
			SPLIT SUPPORT TO BEAM SEGMENTS
		--------------------------------------------------------------------------------*/
		segments_count = ceil (support_height / (support_dist * beams_split_count ) )
		--format "segments_count: %\n" segments_count

		segment_height = support_height / segments_count
		--format "segment_height: %\n" segment_height
--
		
		/* GET POINTS ON SUPPORTS */ 
		for support = 1 to 2 do
		(
			point_on_support = points_on_supports[support][1]
			
			/* DIVIDE SUPPORT */
			for segment = 1 to segments_count do
			(
				/* GET POSITIONS OF BEAMS */ 
				point_on_support = getPosOnLine point_on_support vectors[support] segment_height

				append points_on_supports[support] point_on_support
			)
		)
		--format "points_on_supports[1].count: %\n" points_on_supports[1].count
		/* GET POINTS OF BEAMS */ 

		points_of_beams = deepCopy points_on_supports
		--format "points_on_supports[1].count: %\n" points_on_supports[1].count
		
		/*------------------------------------------------------------------------------
			GET EACH LINE OF BEAM
		--------------------------------------------------------------------------------*/
		for support = 1 to SUPPORT_OPTIONS.beams_count do
		(
			/*------------------------------------------------------------------------------
				LOOP EACH POINT ON SUPPORT
			--------------------------------------------------------------------------------*/
			for point_i = 1 to points_on_supports[1].count do
			(
				/*------------------------------------------------------------------------------
					GET ZIG ZAG PATTERN
				--------------------------------------------------------------------------------*/
				
				even_pos = ( mod point_i 2 ) == 0

				point_pos =	if (support == 1 and even_pos) or (support == 2 and even_pos)
					then
						points_on_supports[if support == 1 then 2 else 1][point_i]
					else
						points_on_supports[support][point_i]
						
				points_of_beams[support][point_i] = point_pos
			)
		)

		points_of_beams --return
	),

	/** Draw lines
	 */
	function _drawLines points_of_lines =
	(
		--format "\n"; print "BeamObject_v._drawLines()"
	--if end_points[1] != undefined and end_points[2] != undefined then

		--format "\n"
		--format "points_of_lines: %\n" points_of_lines
		--format "points_of_lines[1][1]: %\n" points_of_lines[1][1]
		--format "points_of_lines[2][1]: %\n" points_of_lines[1][2]
		--
		--this._drawLine points_of_lines[1][1] points_of_lines[1][2] 1
		new_spline_i = 0
		
		for _line = 1 to points_of_lines.count do
			for point_pos = 1 to points_of_lines[_line].count - 1 do
				--this._drawLine points_of_lines[_line][point_pos] points_of_lines[_line][point_pos + 1] (_line)
				this._drawLine points_of_lines[_line][point_pos] points_of_lines[_line][point_pos + 1] (new_spline_i += 1)

				
		--if SUPPORT_OPTIONS.cross_beams then
			--this._drawLine  (end_points[2][1]) (end_points[2][2]) 2

		--updateShape this.beam
	),

	/** Draw line
	 */
	function _drawLine start_point end_point spline_id =
	(
		--format "\n"; print "BeamObject_v.drawLine()"
		addNewSpline this.beam

		addKnot this.beam spline_id #corner #line start_point
		addKnot this.beam spline_id #corner #line end_point

		--setMaterialID this.beam spline_id 1 SUPPORT_OPTIONS.mat_ids[#BEAM] -- setMaterialID <splineShape> <spline_index> <seg_index> <matID>
	),

	/** Get segment point_data
	 */
	function _getSegmentEndPoints support =
	(
		--format "\n"; print "BeamObject_v._getSegmentEndPoints()"
		num_knots = numKnots support
		
		offset_from_ends = SUPPORT_OPTIONS.bar_width / 2
		
		/* GET INDEX OF USED POINTS */
		index_bottom	= if ( numSegments support 1) <= 2 then num_knots else num_knots - 1 -- get second point or second point from end ( above ground point )
		index_top	= index_bottom - 1

		/* GET POSITIONS OF POINTS */
		point_bottom	= getKnotPoint support	1 index_bottom	-- get 2. point from bottom
		point_top	= getKnotPoint support	1 index_top	-- get 1. or 2. point from top

		point_bottom.z	+= offset_from_ends
		point_top.z	-= offset_from_ends

		Dictionary #( #BOTTOM, point_bottom ) #( #TOP, point_top ) #( #VECTOR, normalize (point_bottom - point_top) ) --return
	),

	/** Center pivot
	 */
	function _centerPivot =
	(
		--format "\n"; print "BeamObject_v._centerPivot()"
		beam.pivot = beam.center
	),
	
	/** Filter edit spline objects
	  *
	  */
	function filterEditSplineObjects =
	(
		for support in supports where superClassOf support.baseobject == shape collect support
	),

	/** Sort supports by distance
	 */
	function sortSupportsByDistance =
	(
		-- format "\n"; print "BeamObject_v.sortSupportsByDistance()"

		supports_positions	= for support in supports collect support.pos
		proccessed_supports 	= #{1..supports.count} * #{}

		next_support_i	= 1
		supports_sorted = #(supports[next_support_i])

		while next_support_i != undefined do
		(
			min_distance = 9999999
			next_support	= supports[next_support_i]
			next_support_pos	= next_support.pos

			proccessed_supports[next_support_i]	= true

			next_support_i = undefined
			--supports_to_search = for i = 1 to supports.count where not proccessed_supports[i] collect i

			for i = 1 to supports.count where not proccessed_supports[i] do
			--if supports_to_search.count > 0 then
			(
				--for i in supports_to_search do
					if (dist = distance next_support_pos supports_positions[i] ) < min_distance then
					(
						min_distance = dist


						--proccessed_supports[i]	= true

						next_support_i = i
					)
			)
			--else
				--next_support_i = undefined

			if next_support_i != undefined then
				append supports_sorted supports[next_support_i]
		)

		--this.supports = makeUniqueArray supports_sorted
		this.supports = supports_sorted
	),

	function rotatePivotZAlignX targetVec =
	(
		-- Helper function for clamping a value
		fn manual_clamp val vMin vMax =
		(
			if val < vMin then vMin
			else if val > vMax then vMax
			else val
		)
	
		-- Ensure the provided node is valid
		if not isValidNode beam then
		(
			-- format "Error: Invalid node provided.\n"
			return false
		)
		
		--pivot_pos = beam.pivot
		
		--point_1 = getKnotPoint beam 1 1
		--point_2 = getKnotPoint beam 2 1
		--
		
		--targetVec = point_1 - point_2
	
		-- Ensure targetVec is a vector (Point3 in MAXScript)
		if not isKindOf targetVec Point3 then
		(
			-- format "Error: targetVec must be a Point3 value.\n"
			return false
		)
	
		-- Normalize the world target vector
		local targetVec_world_norm = normalize targetVec
		if length targetVec_world_norm == 0 then
		(
			-- format "Error: targetVec has zero length.\n"
			return false
		)
	
		-- Get inverse of the node's world rotation part
		local nodeRotation_inv = inverse beam.transform.rotationpart
		
		-- Transform the target vector into the node's local space
		local V_target_nodeLocal = normalize (targetVec_world_norm * nodeRotation_inv)
	
		-- Get the current objectOffsetRotation
		local Q_objOffset_current = beam.objectOffsetRot
		local M_objOffset_current = Q_objOffset_current as matrix3
	
		-- Get the current local axes of the pivot
		local X_c = normalize M_objOffset_current.row1 
		local Z_c = normalize M_objOffset_current.row3 
	
		-- Project target onto pivot's XY plane
		local V_target_proj_on_XYplane_vec = V_target_nodeLocal - (dot V_target_nodeLocal Z_c) * Z_c
		
		if length V_target_proj_on_XYplane_vec < 0.00001 then
		(
			-- format "Warning: Target vector is (nearly) collinear with the pivot's local Z-axis for node \"%\". Cannot uniquely align X-axis.\n" beam.name
			return false 
		)
		local V_target_proj_on_XYplane_norm = normalize V_target_proj_on_XYplane_vec
	
		-- Calculate angle and clamp
		local cos_angle = dot X_c V_target_proj_on_XYplane_norm
		cos_angle = manual_clamp cos_angle -1.0 1.0 
		local angle_rad = acos cos_angle
	
		-- Determine signed direction
		local cross_prod_vec = cross X_c V_target_proj_on_XYplane_norm
		if (dot cross_prod_vec Z_c) < 0.0 then
		(
			angle_rad = -angle_rad
		)
	
		-- Create delta rotation quaternion around pivot local Z-axis
		local Q_delta_Z_intrinsic = quat angle_rad Z_c
	
		-- Apply pivot rotation
		local Q_objOffset_new = Q_objOffset_current * Q_delta_Z_intrinsic
		beam.objectOffsetRot = Q_objOffset_new
	
		-- Rotate the object in world space with inverse to preserve visual orientation
		local Q_world_inv = inverse Q_delta_Z_intrinsic
		beam.rotation = Inverse ( Q_world_inv *  beam.rotation )
	
		--beam.pivot = pivot_pos
	
		--return true -- return
	),

	/** Add to group
	 */
	function _addToGroup support point_helper =
	(
		/** Find group
		 */
		function _findGroup obj =
		(
			--format "\n"; print "SupportGenerator_v.findGroup()"

			if isGroupMember obj then
			(
				while not isGroupHead obj.parent do
					obj = obj.parent

				obj.parent --return
			)
		)

		--format "\n"; print "SupportGenerator_v.addToGroup()"
		if ( _group = _findGroup point_helper ) != undefined then
			attachNodesToGroup support _group
	),

	/** Shift wirecolor sligtly to +1 - Helper points are shifter -1
	  *
	  *
	  *
	  * Each level of points has different wirecolor for better selection
	  */
	function _shiftWirecolor wirecolor =
	(
		--format "\n"; print "PlatformGenerator_v.shiftWirecolor()"
		--format "WIRECOLOR:	% \n" wirecolor
		i = 1

		wirecolor_shifted = copy wirecolor

		if wirecolor_shifted.r <= 254 then wirecolor_shifted.r += i
		if wirecolor_shifted.g <= 254 then wirecolor_shifted.g += i
		if wirecolor_shifted.b <= 254 then wirecolor_shifted.b += i
		--format "WIRECOLOR_SHIFTED:	% \n" wirecolor_shifted

		wirecolor_shifted --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "BeamObject.onCreate()"
		--beam_key = this.getBeamKey()

	)
)
