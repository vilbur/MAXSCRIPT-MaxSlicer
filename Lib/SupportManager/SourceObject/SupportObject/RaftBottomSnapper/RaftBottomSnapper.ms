/* 
  Struct for circle ray projection and intersection
*/
struct RaftBottomSnapper_v
(
	/* construct */
	target_obj,

	/* properties */
	mesh_snapshot,
	
	test_hits_around = 4,
	limit_angle = 180.0, -- avoid snaping if raft is perpendicular to face
	
	/** Snap rafts to target object
	 */
	function snapRaftsToTargetObject supports =
	(
		--format "\n"; print "RaftBottomSnapper_v.snapRaftsToTargetObject()"
		this._snapshotTargetObjAsMesh()
		
		try
		 (
			for support in supports where numKnots support == 2 do 
				this.run support
			
			delete mesh_snapshot
		)
		catch
		(
			delete mesh_snapshot
		)
		
	),
	
	
	/* 
	  Run projection and intersection process
	*/
	function run support  =
	(
		--format "\n"; print "RaftBottomSnapper_v.run()"
		--format "support: %\n" support

		knot_pos_1 = getKnotPoint support 1 1
		knot_pos_2 = getKnotPoint support 1 2
		
		dir = normalize (knot_pos_2 - knot_pos_1)
		--format "dir: %\n" dir
		radius = support.modifiers[#BAR_WIDTH][#Cylinder_Section].radius
		
		--format "radius: %\n" radius
		hits = this._getHitsOnTarget (support) (knot_pos_1) (dir) (radius)

		--format "hits: %\n" hits
		
		hit = this._getHighestHit (hits)
		
		
		
		hit_pos = hit[1].pos
		--format "hit_pos: %\n" hit_pos
		face_normal = getFaceNormal mesh_snapshot hit[2]
		--format "face_normal: %\n" face_normal
		the_angle = this._getVectorsAngle dir face_normal
		--if (the_angle = this._getVectorsAngle ( Inverse dir ) face_normal ) < limit_angle then
		--if the_angle < limit_angle then
		(
			
			--this._createLineFromVectorDebug hit_pos face_normal
	
			intersection_point = this._lineIntersection knot_pos_1 dir hit_pos face_normal
			--format "intersection_point: %\n" intersection_point
			
			--Point pos:intersection_point size:1 wirecolor:red

			
			this._updateKnotsPositions(support)(hit_pos)(intersection_point)
		)
		-- return
	),
	
	/** Get hits on target
	 */
	function _getHitsOnTarget support knot_pos_1 dir radius =
	(
		--format "\n"; print "for._getHitsOnTarget()"

		ray_positions = this._getRayPositions knot_pos_1 dir radius
		
		hits = this._collectRayHits ((ray_positions)) (dir)

		hits --return
	),
	
	/** Get highest hit
	 */
	function _getHighestHit hits =
	(
		--format "\n"; print "for._getHighestHit()"
		index_of_max_pos = 1
		max_pos = -1e9

		for i = 1 to hits.count do
		(
			if hits[i][1].pos.z > max_pos then
			(
				max_pos = hits[i][1].pos.z
				index_of_max_pos = i
			)
		)

		hits[index_of_max_pos]
	),
	
	/** Update knots positions
	 */
	function _updateKnotsPositions support hit_pos intersection_point =
	(
		--format "\n"; print "for._updateKnotsPositions()"
		
		setKnotPoint support 1 2 intersection_point
		
		addKnot support 1 #corner #line hit_pos
		
		setMaterialID support 1 2 3
		
		updateShape support
	),
	
	/* 
	  Get point on a circle in 3D and rotate it around the normal axis
	*/
	function _getRotatedPointOnCircle center normal radius angle_deg =
	(
		n = normalize normal
		ref = if abs (dot n [1,0,0]) < 0.99 then [1,0,0] else [0,1,0]
		v1 = normalize (cross n ref)
		v2 = normalize (cross n v1)
		p = center + (cos angle_deg) * v1 * radius + (sin angle_deg) * v2 * radius
		p -- return
	),

	/* 
	  Find intersection point of two lines in 3D
	*/
	function _lineIntersection p1 v1 p2 v2 =
	(
		v1 = normalize v1
		v2 = normalize v2
		v3 = cross v1 v2

		if (length v3) < 0.00001 then return undefined

		t2 = (dot (cross (p2 - p1) v1) v3) / (length v3)^2
		intersectionPoint = p2 - t2 * -v2
		intersectionPoint -- return
	),

	/* 
	  Create a line shape from a point and vector
	*/
	function _createLineFromVectorDebug start_point direction_vector length:10 =
	(
		direction_vector = normalize direction_vector * length
		
		end_point = start_point + direction_vector
		
		shape = splineShape name:"vector_line"
		addNewSpline shape
		
		addKnot shape 1 #corner #line start_point
		
		addKnot shape 1 #corner #line end_point
		
		updateShape shape
		
		shape -- return
	),

	/* 
	  Generate positions around a circle
	*/
	function _getRayPositions base_point normal radius =
	(
		positions = #()
		for i = 1 to test_hits_around do
		(
			_angle = (360.0 / test_hits_around) * i
			
			pos = this._getRotatedPointOnCircle base_point normal radius _angle
			
			append positions pos
		)
		positions -- return
	),


	/** Snapshot target obj as mesh
	 */
	function _snapshotTargetObjAsMesh =
	(
		--format "\n"; print "for._snapshotTargetObjAsMesh()"
		mesh_snapshot = copy target_obj
		
		convertTo mesh_snapshot TriMeshGeometry
	),

	
	/* 
	  Intersect rays with mesh from given positions
	*/
	function _collectRayHits ray_positions dir =
	(
		hits = #()
		for ray_position in ray_positions do 
		(
			--format "\n"
			--Point pos:ray_position size:0.5 wirecolor:green

			_ray = Ray ray_position dir
			
			hit = IntersectRayEx mesh_snapshot _ray
			
			if hit != undefined and distance ray_position hit[1].pos > 0.01 then
			(
				face_index = hit[2]
				--Point pos:hit[1].pos size:0.5 wirecolor:red
				--format "ray_position: %\n" ray_position
				--format "hit[1].pos: %\n" hit[1].pos
				face_normal = getFaceNormal mesh_snapshot face_index
				--format "TEST: %\n" ( dot face_normal _ray.dir)
				
				/* Check if dot product is less than zero (ray hits front face) */ 
				if (dot face_normal _ray.dir) < 0.0 then
				(
					append hit face_normal
					
					append hits hit
				)
			)
		)
		
		hits -- return
	),

	function _getVectorsAngle v1 v2 =
	(
		--format "\n"; print "RaftBottomSnapper_v._getVectorsAngle()"
		--the_angle = acos(dot (normalize v1) (normalize v2)) - 90
		the_angle = acos(dot (normalize v1) (normalize v2)) 
		
		--format "THE_ANGLE: %\n" the_angle
		
		the_angle --return
	),
	
	on create do
	(
	)
)