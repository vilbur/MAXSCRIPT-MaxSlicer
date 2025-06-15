--clearListener(); print("Cleared in:\n"+getSourceFileName())
--
--filein( getFilenamePath(getSourceFileName()) + "/../../SourceObject/SupportObject/SupportObject.ms" )	--"./../../SourceObject/SupportObject/SupportObject.ms"

/** Prepare object
 */
	
function createTestObjectPackman radius:50 pos_z:undefined verts_colors:undefined collapse_object:true  =
(
	--format "\n"; print ".createTestObjectPackman()"
	/** Set verts colors
	 */
	function setVertsColors obj verts_colors =
	(
		if verts_colors == undefined then
		(
			verts_colors = Dictionary #string
			
			verts_colors[ "red" as string ]	= #{ 29, 40, 45, 59 }
			verts_colors[ "green" as string ]	= #{ 22 }
			verts_colors[ ( color 0 255 255 ) as string  ]	= #{ 30 }
			verts_colors[ "orange" as string ]	= #{ 40 }
		)
	

		/* SET VERTEX COLOR */ 
		for color_data in verts_colors do
			polyop.setVertColor obj.baseobject 0 color_data.value ( execute color_data.key )
		
		obj.showVertexColors	= true
		obj.vertexColorsShaded	= true
		
		--channelInfo.Dialog ()
		--channelInfo.Update ()
	)
	
	--delete $PackMan
	
	segments = 20
	seg_angle = (360 / segments ) as integer
	
	--radius = 100
	
	--obj = Cylinder name:"PackMan" radius:radius height:(radius/2) sides:(segments - 2 ) slice:on slicefrom:( 360 - seg_angle ) sliceto:seg_angle transform:( Matrix3 [0, 1, 0] [0, 0, 1] [1, 0, 0] [0, 0, radius + 50 ] ) isSelected:on
	obj = Cylinder name:"PackMan" radius:radius height:(radius/2) sides:(segments - 2 ) slice:on slicefrom:( 360 - seg_angle ) sliceto:seg_angle isSelected:on
	
	obj.pivot = obj.center

	obj.pos = [ 0, 0, 0 ]
	 
	obj.pos.z = radius + ( if pos_z == undefined then radius + 2 else pos_z )
	 
	Rotate obj (angleaxis 90 [1,0,0])
	
	Rotate obj (angleaxis -90 [0,0,1])
	
	addModifier obj ( meshsmooth sepBySmGroups:true )
	
	
	if collapse_object then
		convertTo obj PolyMeshObject
	
	setVertsColors(obj)(verts_colors)
	
	obj --return
)




