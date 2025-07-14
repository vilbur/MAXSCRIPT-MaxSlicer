/* 
  Struct for circle ray projection and intersection
*/
struct RaftBottomSnapper_v
(
	/* 
	  Run projection and intersection process
	*/
	function run target_obj support radius segments =
	(
		mesh_snapshot = copy target_obj
		convertTo mesh_snapshot TriMeshGeometry

		knot_pos_1 = getKnotPoint support 1 1
		knot_pos_2 = getKnotPoint support 1 2
		dir = normalize (knot_pos_2 - knot_pos_1)

		ray_positions = this._getRayPositions knot_pos_1 dir radius segments
		hits = this._collectRayHits mesh_snapshot ray_positions dir

		if hits.count == 0 then
		(
			delete mesh_snapshot
			return undefined
		)

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

		hit = hits[index_of_max_pos]
		hit_pos = hit[1].pos
		face_normal = getFaceNormal mesh_snapshot hit[2]

		this._createLineFromVector hit_pos face_normal

		intersection_point = this._lineIntersection knot_pos_1 dir hit_pos face_normal

		delete mesh_snapshot

		setKnotPoint support 1 2 intersection_point
		addKnot support 1 #corner #line hit_pos
		setMaterialID support 1 2 3
		updateShape support
		ok -- return
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
	function _getRayPositions base_point normal radius segments =
	(
		positions = #()
		for i = 1 to segments do
		(
			angle = (360.0 / segments) * i
			pos = this._getRotatedPointOnCircle base_point normal radius angle
			append positions pos
		)
		positions -- return
	),

	/* 
	  Intersect rays with mesh from given positions
	*/
	function _collectRayHits mesh ray_positions dir =
	(
		hits = #()
		for ray_position in ray_positions do 
		(
			_ray = Ray ray_position dir
			hit = IntersectRayEx mesh _ray
			if hit != undefined then append hits hit
		)
		hits -- return
	),
	

	on create do
	(
	)
)



delete helpers

circleIntersect = RaftBottomSnapper_v()
circleIntersect.run $PackMan selection[1] 0.5 4


