clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../smoothAndKeepVertexColors.ms" )	--"./../smoothAndKeepVertexColors.ms"

delete objects

obj	= Sphere radius:10 isSelected:on showVertexColors:true vertexColorsShaded:true segs:4

macros.run "_Object-ConvertTo" "selection_convert_to_editable_poly"

subobjectLevel = 1

--$.EditablePoly.SetSelection #Vertex #{144}

num_verts = polyop.getNumVerts obj
format "num_verts: %\n" num_verts
polyop.setMapSupport obj 0 true
polyop.setNumMapVerts obj 0 num_verts

--polyop.setVertColor obj 0 #{1,3,5} (red)
polyop.setVertColor obj 0 #{1} blue
polyop.setVertColor obj 0 #{2..5} red
	
	
smoothAndKeepVertexColors( obj )