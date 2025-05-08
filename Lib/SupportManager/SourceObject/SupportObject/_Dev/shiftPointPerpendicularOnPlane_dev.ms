clearListener(); print("Cleared in:\n"+getSourceFileName())

function createCylinderByVector align_vector position:[0,0,0] height:100 radius:1 =
(

    -- Normalize input direction
    z = normalize align_vector

    -- Build orthonormal basis: find X axis first
    x = normalize (cross z [0,0,1])
    if (length x) < 0.001 do x = normalize (cross z [0,1,0]) -- fallback if z ≈ world Z

    -- Compute Y axis
    y = cross z x

    -- Build rotation matrix (X, Y, Z, position)
    rotMatrix = matrix3 x y z position

    -- Create cylinder at origin
    cyl = cylinder height:height radius:radius

    -- Move and rotate it
    cyl.transform = rotMatrix

    cyl -- return
)

/*
	Shift origin point perpendicular to a vector and project to plane
	
	This function shifts a point perpendicular to a given vector,
	and constrains the result to a specific plane: #XY, #XZ, or #YZ.
	
	Arguments:
	 - origin_point: Point3 - the original point
	 - direction_vector: Point3 - the vector to be perpendicular to
	 - shift_distance: Float - distance to shift
	 - plane: Symbol - one of #XY, #XZ, #YZ to constrain projection
	
	Returns:
	 - Point3 - shifted and projected point
*/

function shiftPointPerpendicularOnPlane origin_point direction_vector shift_distance plane =
(
	-- Project direction vector to selected plane
	case plane of
	(
		#XY: projected_vector = normalize [direction_vector.x, direction_vector.y, 0]
		#XZ: projected_vector = normalize [direction_vector.x, 0, direction_vector.z]
		#YZ: projected_vector = normalize [0, direction_vector.y, direction_vector.z]
		default: (format "Unsupported plane: %\n" plane; projected_vector = [1,0,0])
	)
	
	-- Calculate perpendicular vector within the plane
	case plane of
	(
		#XY: perp_vector = normalize [-projected_vector.y, projected_vector.x, 0]
		#XZ: perp_vector = normalize [-projected_vector.z, 0, projected_vector.x]
		#YZ: perp_vector = normalize [0, -projected_vector.z, projected_vector.y]
	)
	
	-- Apply shift
	shifted_point = origin_point + (perp_vector * shift_distance)
	
	shifted_point -- return
)



p = [0, 0, 0]
v = [0, 0, 1]

shifted_1 = shiftPointPerpendicularOnPlane p v 5 #XY
shifted_2 = shiftPointPerpendicularOnPlane p v -5 #XY
shifted_3 = shiftPointPerpendicularOnPlane p v 5 #XZ
shifted_4 = shiftPointPerpendicularOnPlane p v -5 #XZ


delete objects

createCylinderByVector v position:p
createCylinderByVector v position:shifted_1
createCylinderByVector v position:shifted_2
createCylinderByVector v position:shifted_3
createCylinderByVector v position:shifted_4



