/* 
  Struct for circle ray projection and intersection
*/
struct RaftBottomSnapper_v
(
	/* construct */

	/* properties */
	target_obj,
	mesh_snapshot,
	
	test_hits_around = 4,
	
	/** Snap rafts to target object
	 */
	function snapRaftsToTargetObject supports =
	(
		--format "\n"; print "for.snapRaftsToTargetObject()"
		
		for support in supports do 
			this.run support
		
		delete mesh_snapshot
	),
	
	
	/* 
	  Run projection and intersection process
	*/
	function run support  =
	(
		this._snapshotTargetObjAsMesh()

		radius = support.modifiers[#BAR_WIDTH][#Cylinder_Section].radius
		
		hits = this._getHitsOnTarget(support)(radius)

		hit = this._getHighestHit (hits)
		
		hit_pos = hit[1].pos
		
		face_normal = getFaceNormal mesh_snapshot hit[2]

		--this._createLineFromVector hit_pos face_normal
		knot_pos_1 = getKnotPoint support 1 1

		intersection_point = this._lineIntersection knot_pos_1 dir hit_pos face_normal

		this._updateKnotsPositions(support)(intersection_point)

		
		-- return
	),
	
	/** Get hits on target
	 */
	function _getHitsOnTarget support radius =
	(
		--format "\n"; print "for._getHitsOnTarget()"
		
		knot_pos_1 = getKnotPoint support 1 1
		knot_pos_2 = getKnotPoint support 1 2
		
		dir = normalize (knot_pos_2 - knot_pos_1)

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
	function _updateKnotsPositions support intersection_point =
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
	function _createLineFromVector start_point direction_vector length:10 =
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
			_ray = Ray ray_position dir
			
			hit = IntersectRayEx mesh_snapshot _ray
			
			if hit != undefined then
			(
				face_index = hit[2]
			
				face_normal = getFaceNormal mesh_snapshot face_index
				format "TEST: %\n" (TEST)
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

	on create do
	(
	)
)



delete helpers

circleIntersect = RaftBottomSnapper_v( $PackMan )
circleIntersect.snapRaftsToTargetObject (selection as Array )


