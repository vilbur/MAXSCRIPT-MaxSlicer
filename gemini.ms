clearListener(); print("Cleared in:\n"+getSourceFileName())

delete objects

myObject = Sphere()

-- Get the currently selected object
--myObject = selection[1]

if (myObject != undefined and canConvertTo myObject Editable_Poly) then
(
    -- Convert to Editable Poly if it's not already
    if (classof myObject != Editable_Poly) then convertToPoly myObject
    
    -- Add a VertexPaint modifier if it doesn't have one
    if (myObject.modifiers[#VertexPaint] == undefined) do
    (
        addModifier myObject (VertexPaint())
    )
    
    -- Get the number of vertices
    local numVerts = polyOp.getNumVerts myObject
    
    -- Create an array to hold the color for each vertex
    local vertexColors = #()
    
    -- Initialize all vertices to white
    for i = 1 to numVerts do append vertexColors white
    
    -- Set specific vertices to red
    vertexColors[1] = red
    vertexColors[5] = red
    
    -- Set a range of vertices to blue
    for i = 10 to 20 do vertexColors[i] = blue
    
    -- Apply the vertex colors
    -- The '0' refers to the vertex color map channel
    polyOp.setVertColor myObject 0 vertexColors
    
    -- Refresh the viewports
    completeRedraw()
    
    print "Vertex colors have been assigned."
)
else
(
    messageBox "Please select a convertible poly object."
)