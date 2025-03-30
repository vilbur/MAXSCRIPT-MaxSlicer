clearListener(); print("Cleared in:\n"+getSourceFileName())


/* MOCKUP DEPENDENCY */ 
global MODIFIERS_MANAGER
global SUPPORT_OPTIONS	
global SUPPORT_MANAGER	

filein( getFilenamePath(getSourceFileName()) + "/../../../content/rollouts-Main/rollout-06-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms" )	--"./../../../content/rollouts-Main/rollout-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms"

filein( getFilenamePath(getSourceFileName()) + "/../SupportManager.ms" )	--"./../SupportManager.ms"

filein( getFilenamePath(getSourceFileName()) + "/helpers/createTestObjectPackMan.ms" )	--"./helpers/createTestObjectPackMan.ms"

filein( getFilenamePath(getSourceFileName()) + "/../Lib/generateSupportsOrRafts.ms" )	--"./../Lib/generateSupportsOrRafts.ms"


/*------------------------------------------------------------------------------
	PREPARE SCENE
--------------------------------------------------------------------------------*/

/*  */ 
verts_colors = Dictionary #string

clr_blue =  ( color 30 144 255 ) as string
clr_cyan =  ( color 0 255 255 ) as string

verts_colors[ "red"	] = #{ 113 }
--verts_colors[ clr_blue	] = #{ 22 }
verts_colors[ "green"	] = #{ 42 }
--verts_colors[ "orange"	] = #{ 40 }
--verts_colors[ "gray"	] = #{ 32 }
verts_colors[ clr_cyan	] = #{ 59 }

/* CREATE TEST OBJECT */
obj = $PackMan

--pos_z = 1
pos_z = 10

--if selection.count == 0 then
(
	delete objects
	
	obj = createTestObjectPackman pos_z:pos_z verts_colors:verts_colors
)


/* SELECT VERTS */ 
select_verts	= #{}
 
 
select_verts += verts_colors["red"]
--select_verts += verts_colors["orange"]
 --select_verts += verts_colors["green"]
 --select_verts += verts_colors[clr_cyan]
--select_verts += verts_colors[clr_blue]
--select_verts += #{ 40 }

if select_verts.numberSet > 0 then
	obj.EditablePoly.SetSelection #Vertex select_verts



/*------------------------------------------------------------------------------
	SET GENERATOR OPTIONS
------------------------------------------------------------------------------*/
SUPPORT_OPTIONS	= SupportOptions_v()



/* SET BAR WIDTH */ 
--SUPPORT_OPTIONS.bar_width	= 1.5
SUPPORT_OPTIONS.bar_width	= 2


/* SET TOP WIDTH */ 
--SUPPORT_OPTIONS.top_width	= 0.1
--SUPPORT_OPTIONS.top_width	= 0.5
SUPPORT_OPTIONS.top_width	= 1
--SUPPORT_OPTIONS.top_width	= 1.5
--SUPPORT_OPTIONS.top_width	= 2


/* SET BASE WIDTH */ 
SUPPORT_OPTIONS.base_width	= 10


/* SET NORMAL LENGTH */ 
SUPPORT_OPTIONS.normal_length	= 0 -- AUTO NORMAL LENGTH 
--SUPPORT_OPTIONS.normal_length	= 0.75
--SUPPORT_OPTIONS.normal_length	= 1.25
--SUPPORT_OPTIONS.normal_length	= 5
SUPPORT_OPTIONS.normal_length	= 10
-- SUPPORT_OPTIONS.normal_length	= 30



/* NORMLA DIRECTION */ 
----SUPPORT_OPTIONS.second_point_direction	= 1 -- NORMAL
--SUPPORT_OPTIONS.second_point_direction	= 2 -- DOWN


/*------------------------------------------------------------------------------
	GENERATE SUPPORTS
--------------------------------------------------------------------------------*/

MODIFIERS_MANAGER	= ModifiersManager_v()
SUPPORT_MANAGER	= SupportManager_v()

generateSupportsOrRafts obj_type:#SUPPORT


--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS.base_width
--SupportObject = SupportObject_v()
--
--/* GENERATE SUPPORT */ 
--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS.base_width
--SupportObject = SupportObject.generateSupport 1 first_knot_pos:[ 0, 0, 10 ]
--
--
--/* ADD MOFIFIERS */ 
--MODIFIERS_MANAGER.addModifiers #( SupportObject.support_obj ) obj_type:#SUPPORT --supports_exists:supports_exists
--
----SUPPORT_MANAGER.updateShapes()
