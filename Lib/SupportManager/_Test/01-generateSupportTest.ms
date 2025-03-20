clearListener(); print("Cleared in:\n"+getSourceFileName())


/* MOCKUP DEPENDENCY */ 
global MODIFIERS_MANAGER
global SUPPORT_OPTIONS	
global SUPPORT_MANAGER	

filein( getFilenamePath(getSourceFileName()) + "/../../../content/rollouts-Main/rollout-06-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms" )	--"./../../../content/rollouts-Main/rollout-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms"

filein( getFilenamePath(getSourceFileName()) + "/../SupportManager.ms" )	--"./../SupportManager.ms"

filein( getFilenamePath(getSourceFileName()) + "/helpers/createTestObjectPackMan.ms" )	--"./helpers/createTestObjectPackMan.ms"

filein( getFilenamePath(getSourceFileName()) + "/../Lib/generateSupportsOrRafts.ms" )	--"./../Lib/generateSupportsOrRafts.ms"

delete objects
/* PREPARE SCENE */ 
--obj = createTestObjectPackman()
obj = createTestObjectPackman pos_z:50
--obj = createTestObjectPackman pos_z:15


select obj

/*------------------------------------------------------------------------------
	RUN TESTS
------------------------------------------------------------------------------*/


/* MOCKUP DEPENDENCY */ 
MODIFIERS_MANAGER	= ModifiersManager_v()
SUPPORT_OPTIONS	= SupportOptions_v()
SUPPORT_MANAGER	= SupportManager_v()
--
--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS.base_width
/* SET SUPPORT OPTIONS */ 
SUPPORT_OPTIONS.top_width	= 1
SUPPORT_OPTIONS.bar_width	= 1.5s
SUPPORT_OPTIONS.base_width	= 5

SUPPORT_OPTIONS.top_width	= 0.5
SUPPORT_OPTIONS.bar_width	= 1.5
SUPPORT_OPTIONS.base_width	= 10

SUPPORT_OPTIONS.normal_length	= 10

--
----SUPPORT_OPTIONS.second_point_direction	= 1 -- 1:NORMAL|2:DOWN
--SUPPORT_OPTIONS.second_point_direction	= 2 -- 1:NORMAL|2:DOWN
--
--

select_verts	= #{}
--select_verts = #{ 22 }
--select_verts = #{ 29 } -- bottom vertex
--select_verts = #{ 40 }

if select_verts.numberSet > 0 then
	obj.EditablePoly.SetSelection #Vertex select_verts



--
generateSupportsOrRafts obj_type:#SUPPORT

--
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
