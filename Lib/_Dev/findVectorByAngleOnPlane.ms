clearListener(); print("Cleared in:\n"+getSourceFileName())



function createAlignedCylinder align_vector position:[0,0,0] height:100 radius:1 wirecolor:gray =
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

	cyl.wirecolor = wirecolor
	
    cyl -- return
)



/*
Finds a vector at a given angle in the plane defined by two vectors.

vector1 and vector2 define the plane.
angle is in degrees.
*/
function findVectorByAngleOnPlane vector1 vector2 _angle =
(
	-- Create orthonormal basis in the plane
	dir_x = normalize vector1
	-- Remove projection of vector2 on dir_x to get perpendicular direction
	proj = (dot vector2 dir_x) * dir_x
	dir_y = normalize (vector2 - proj)

	-- Compute vector using _angle in plane
	result = (cos _angle) * dir_x + (sin _angle) * dir_y
	format "result: %\n" result
	result -- return
)


vec_A = [1,0,0]
vec_B = [0,1,0]
_angle = 22.5
_angle = (90 - 22.5)
_angle = 45
_angle = 85
vec_c = findVectorByAngleOnPlane vec_A vec_B _angle



delete objects 
createAlignedCylinder vec_a wirecolor:red
createAlignedCylinder vec_b	wirecolor:green
createAlignedCylinder vec_c wirecolor:blue
--createAlignedCylinder [0.707107, 0.707107, 0.0] wirecolor:blue
