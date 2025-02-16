clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../SourceObjectNormals.ms" )	--"./../SourceObjectNormals.ms"


/** Prepare object
 */
	
function prepareObject verts =
(
	--format "\n"; print ".prepareObject()"
	/** Set verts colors
	 */
	function setVertsColors obj verts =
	(
		verts_colors = Dictionary #string
		
		verts_colors[ "red" as string ]	= verts

		
		--verts_colors[ "red" as string ]	= #{ 29, 40, 45 }
		--verts_colors[ "green" as string ]	= #{ 22 }
		--verts_colors[ ( color 0 255 255 ) as string  ]	= #{ 30 }
		--verts_colors[ "orange" as string ]	= #{ 40 }
	

		/* SET VERTEX COLOR */ 
		for color_data in verts_colors do
			polyop.setVertColor obj.baseobject 0 color_data.value ( execute color_data.key )
		
		obj.showVertexColors	= true
		obj.vertexColorsShaded	= true
		
		--channelInfo.Dialog ()
		--channelInfo.Update ()
	)
	
	delete objects
	
	segments = 10
	seg_angle = (360 / segments) as integer
	
	radius = 100
	
	obj = Cylinder radius:radius height:50 sides:(segments - 2 ) slice:on slicefrom:( 360 - seg_angle ) sliceto:seg_angle transform:( Matrix3 [0, 1, 0] [0, 0, 1] [1, 0, 0] [0, 0, radius + 50 ] ) isSelected:on
	
	addModifier obj ( meshsmooth sepBySmGroups:true )
	
	convertTo obj PolyMeshObject
	
	setVertsColors(obj)verts
	
	obj --return
)


verts = #{ 29, 40, 45 }

--obj = prepareObject(verts)

obj = objects[1]

SourceObjectNormals = SourceObjectNormals_v(obj)


SourceObjectNormals.setLocalVertexNormals(verts)
