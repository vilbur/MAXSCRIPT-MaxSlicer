clearListener(); print("Cleared in:\n"+getSourceFileName())

-- Create a new SplineShape with two knots
mySpline = SplineShape()
addNewSpline mySpline
addKnot mySpline 1 #corner #line [0,0,0]
addKnot mySpline 1 #corner #line [50,0,0]
updateShape mySpline

-- Add an Edit_Spline modifier
editSplineMod = Edit_Spline()
addModifier mySpline editSplineMod

max modify mode

modPanel.setCurrentObject mySpline.modifiers[#Edit_Spline]

-- Access the sub-object level to work with knots and segments
subobjectLevel = 1 -- 1 for vertex (knot) level

-- Go to the sub-object level of the modifier
max modify mode
modPanel.setCurrentObject mySpline.baseObject
subobjectLevel = 1

-- Change the position of the second knot
setKnotPoint mySpline 1 2 [75, 25, 0]

-- Add a new knot to the spline
addKnot mySpline 1 #corner #line [100, -10, 0]

-- Update the shape to reflect the changes
updateShape mySpline

-- Go to the segment sub-object level
subobjectLevel = 2

-- Set the material ID of the new segment (segment 2)
setMaterialID  mySpline 1 2 3
updateShape mySpline

-- Exit sub-object level
subobjectLevel = 0

-- For verification, you can print the knot count and segment material ID
format "Total knots: %\n" ( numKnots mySpline 1)
format "Material ID of segment 2: %\n" ( getMaterialID  mySpline 1 2)

-- Select the spline in the viewport
select mySpline