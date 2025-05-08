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
