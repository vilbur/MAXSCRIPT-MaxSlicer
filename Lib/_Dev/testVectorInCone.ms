clearListener(); print("Cleared in:\n"+getSourceFileName())

function testVectorInCone v1 v2 angle_treshold =
(
	createCylinderByVector v2
	
	dot_product = dot (normalize v1) (normalize v2)
	
	 theAngle = acos(dot_product)
	 
	 
	 format "\n"
	 format "dot: %\n" (dot (normalize v1) (normalize v2))
	 format "theAngle: %\n" theAngle
	 format "treshold: %\n" ( angle_treshold / 2.0 )

	 --theAngle <= angle_treshold
	 theAngle < angle_treshold
	 
)


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


origin = [0,0,0]
height = 100


--_angle = 10
_angle = 30
--_angle = 45.0
--_angle = 80
--_angle = 85

function getConeRadiusFromAngleHeight height angle_deg = radius = height * tan(angle_deg)
	

delete objects 

cone_obj = cone radius1:0 radius2:(getConeRadiusFromAngleHeight height _angle  ) height:height pos:origin


format "\n--------------\n"

print (testVectorInCone [0,0,10] [0,0,10] _angle )
print (testVectorInCone [0,0,10] [0,10,20] _angle )
print (testVectorInCone [0,0,10] [0,10,10] _angle )
print (testVectorInCone [0,0,10] [0,30,20] _angle )
print (testVectorInCone [0,0,10] [0,10,0] _angle )


--print (testVectorInCone [0,0,10] [0,9,10] _angle )
--print (testVectorInCone [0,0,10] [0,10,10] _angle )
--print (testVectorInCone [0,0,10] [0,11,10] _angle )

