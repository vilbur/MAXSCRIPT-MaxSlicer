clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../smoothAndKeepVertexColors.ms" )	--"./../smoothAndKeepVertexColors.ms"


/** Create test object
 */
function createTestObject =
(
	--format "\n"; print ".createTestObject()"
	delete objects
	
	obj	= Sphere radius:10 isSelected:on showVertexColors:true vertexColorsShaded:true segs:7
	
	macros.run "_Object-ConvertTo" "selection_convert_to_editable_poly"
	
	subobjectLevel = 1
	
	--$.EditablePoly.SetSelection #Vertex #{144}
	
	num_verts = polyop.getNumVerts obj
	format "num_verts: %\n" num_verts
	polyop.setMapSupport obj 0 true
	polyop.setNumMapVerts obj 0 num_verts
	
	--polyop.setVertColor obj 0 #{1,3,5} (red)
	polyop.setVertColor obj 0 #{1} black
	--polyop.setVertColor obj 0 #{2..5} red
	polyop.setVertColor obj 0 #{11..12, 14} red
	
	obj --return
)


--obj if selection.count > 0 then selection[1] else createTestObject()

--obj = createTestObject()

obj	= selection[1]

smoothAndKeepVertexColors( obj )