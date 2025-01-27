clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../SupportManager.ms" )	--"./../SupportManager.ms"
--filein( getFilenamePath(getSourceFileName()) + "/../SupportObject.ms" )	--"./../SupportObject.ms"


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
	
		verts_colors[ "red" as string ]	= #{22,29}
		--verts_colors[ "green" as string ]	= #{3..4}
	
		for color_verts in verts_colors do
			polyop.setVertColor obj.baseobject 0 color_verts.value ( execute color_verts.key )
		
		
		obj.showVertexColors	= true
		obj.vertexColorsShaded	= true
		
		--channelInfo.Dialog ()
		--channelInfo.Update ()
	)
	
	segments = 10
	seg_angle = (360 / segments) as integer
	
	obj = Cylinder radius:100 height:50 sides:(segments - 2 ) slice:on slicefrom:( 360 - seg_angle ) sliceto:seg_angle transform:( Matrix3 [0, 1, 0] [0, 0, 1] [1, 0, 0] [0, 0, 200] )  isSelected:on
	
	addModifier obj ( meshsmooth sepBySmGroups:true )
	
	convertTo obj PolyMeshObject
	
	setVertsColors(obj)
	
	obj --return
)

/* PREPARE SCENE */ 
delete objects

--obj = prepareObject()

/* MOCKUP DEPENDENCY */ 
global MODIFIERS_MANAGER	= ModifiersManager_v()
global SUPPORT_OPTIONS		= SupportOptions_v()
global SUPPORT_MANAGER		= SupportManager_v()


SupportObject = SupportObject_v()

/*------------------------------------------------------------------------------
	RUN TESTS
--------------------------------------------------------------------------------*/

/* SET SUPPORT OPTIONS */ 
SUPPORT_OPTIONS.base_width	= 5
SUPPORT_OPTIONS.bar_width	= 1.5
SUPPORT_OPTIONS.chamfer_bar	= 1
SUPPORT_OPTIONS.base_width = 5

/* GENERATE SUPPORT */ 
support_obj = SupportObject.generateSupport 1 first_knot_pos:[ 0, 0, 10 ]

/* ADD MOFIFIERS */ 
MODIFIERS_MANAGER.addModifiers #( support_obj ) obj_type:#SUPPORT --supports_exists:supports_exists
