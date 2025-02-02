clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../../SourceObject/SupportObject/SupportObject.ms" )	--"./../../SourceObject/SupportObject/SupportObject.ms"

/** Prepare object
 */
	
function prepareObject =
(
	--format "\n"; print ".prepareObject()"
	/** Set verts colors
	 */
	function setVertsColors obj =
	(
		verts_colors = Dictionary #string
	
		verts_colors[ "red" as string ]	= #{ 29, 30, 40, 45 }
		verts_colors[ "orange" as string ]	= #{ 40 }
		verts_colors[ "green" as string ]	= #{ 22 }
	
		/* SET VERTEX COLOR */ 
		for color_verts in verts_colors do
			polyop.setVertColor obj.baseobject 0 color_verts.value ( execute color_verts.key )
		
		
		obj.showVertexColors	= true
		obj.vertexColorsShaded	= true
		
		--channelInfo.Dialog ()
		--channelInfo.Update ()
	)
	delete objects
	
	segments = 10
	seg_angle = (360 / segments) as integer
	
	radius = 100
	
	obj = Cylinder radius:radius height:50 sides:(segments - 2 ) slice:on slicefrom:( 360 - seg_angle ) sliceto:seg_angle transform:( Matrix3 [0, 1, 0] [0, 0, 1] [1, 0, 0] [0, 0, radius + 50 ] )  isSelected:on
	
	addModifier obj ( meshsmooth sepBySmGroups:true )
	
	convertTo obj PolyMeshObject
	
	setVertsColors(obj)
	
	obj --return
)




