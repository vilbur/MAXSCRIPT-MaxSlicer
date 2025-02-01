clearListener(); print("Cleared in:\n"+getSourceFileName())


/* MOCKUP DEPENDENCY */ 
global MODIFIERS_MANAGER
global SUPPORT_OPTIONS	
global SUPPORT_MANAGER	

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



/*------------------------------------------------------------------------------
	RUN TESTS
--------------------------------------------------------------------------------*/


/* MOCKUP DEPENDENCY */ 
MODIFIERS_MANAGER	= ModifiersManager_v()
SUPPORT_OPTIONS		= SupportOptions_v()
SUPPORT_MANAGER		= SupportManager_v()

format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS.base_width
/* SET SUPPORT OPTIONS */ 
SUPPORT_OPTIONS.top_width	= 1
SUPPORT_OPTIONS.bar_width	= 1.5
SUPPORT_OPTIONS.base_width	= 5

SUPPORT_OPTIONS.top_width	= 0.5
SUPPORT_OPTIONS.bar_width	= 2
SUPPORT_OPTIONS.base_width	= 6


format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS.base_width
SupportObject = SupportObject_v()

/* GENERATE SUPPORT */ 
format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS.base_width
SupportObject = SupportObject.generateSupport 1 first_knot_pos:[ 0, 0, 10 ]


/* ADD MOFIFIERS */ 
MODIFIERS_MANAGER.addModifiers #( SupportObject.support_obj ) obj_type:#SUPPORT --supports_exists:supports_exists

--SUPPORT_MANAGER.updateShapes()
