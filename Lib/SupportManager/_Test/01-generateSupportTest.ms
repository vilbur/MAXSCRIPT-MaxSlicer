clearListener(); print("Cleared in:\n"+getSourceFileName())


/* MOCKUP DEPENDENCY */ 
global MODIFIERS_MANAGER
global SUPPORT_OPTIONS	
global SUPPORT_MANAGER	

--filein( getFilenamePath(getSourceFileName()) + "/../../../content/rollouts-Main/rollout-06-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms" )	--"./../../../content/rollouts-Main/rollout-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms"
filein( getFilenamePath(getSourceFileName()) + "/../../../MaxSlicer/rollouts-Main/rollout-06-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms" )	--"./../../../MaxSlicer/rollouts-Main/rollout-06-VERTEX_COLORS/Lib/VertexColors/VertexColors.ms"

filein( getFilenamePath(getSourceFileName()) + "/../SupportManager.ms" )	--"./../SupportManager.ms"

filein( getFilenamePath(getSourceFileName()) + "/helpers/createTestObjectPackMan.ms" )	--"./helpers/createTestObjectPackMan.ms"

filein( getFilenamePath(getSourceFileName()) + "/../Lib/generateSupportsOrRafts.ms" )	--"./../Lib/generateSupportsOrRafts.ms"


/*------------------------------------------------------------------------------
	PREPARE SCENE
--------------------------------------------------------------------------------*/

/*  DEFINE VERTEX COLORS */ 
verts_colors = Dictionary #string

clr_blue =  ( color 30 144 255 ) as string
clr_cyan =  ( color 0 255 255 ) as string
clr_pink =  ( color 255 190 200 ) as string

verts_colors[ "yellow"	] = #{ 113 }
verts_colors[ "orange"	] = #{ 57 }
verts_colors[ clr_pink	] = #{ 115 }
verts_colors[ clr_blue	] = #{ 85 }
verts_colors[ "green"	] = #{ 42 }
verts_colors[ "gray"	] = #{ 32 }
verts_colors[ clr_cyan	] = #{ 59 }

/*==============================================================================
	CREATE TEST OBJECT
================================================================================*/
obj = $PackMan

pos_z = 0.2 -- TEST MINIMAL SIZE OF RED AND ORANGE SUPPORT
-- pos_z = 0.5 -- TEST MINIMAL SIZE OF RED AND ORANGE SUPPORT
pos_z = 1
-- pos_z = 1.2
pos_z = 1.5
pos_z = 2
-- pos_z = 3
-- pos_z = 10

-- if selection.count == 0 then
(
	delete objects
	
	obj = createTestObjectPackman pos_z:pos_z verts_colors:verts_colors collapse_object:true
)


/* SELECT VERTS  BY COLORS */ 
select_verts = #{}
 
--select_verts += verts_colors["yellow"]
--select_verts += verts_colors["orange"]
select_verts += verts_colors[clr_pink]
--select_verts += verts_colors[clr_cyan]
--select_verts += verts_colors["green"]
-- select_verts += verts_colors[clr_blue]
--select_verts += #{ 40 }

if select_verts.numberSet > 0 then
	obj.EditablePoly.SetSelection #Vertex select_verts

/*==============================================================================
	SET GENERATOR OPTIONS
================================================================================*/
SUPPORT_OPTIONS	= SupportOptions_v()



/* SET BAR WIDTH */ 
--SUPPORT_OPTIONS.bar_width	= 1.5
SUPPORT_OPTIONS.bar_width	= 2

/* SET BASE HEIGHT  */ 
-- SUPPORT_OPTIONS.base_height	= 2

/* SET BASE WIDTH  */ 
SUPPORT_OPTIONS.base_width	= 10
-- SUPPORT_OPTIONS.base_width	= 5


/* SET TOP WIDTH */ 
--SUPPORT_OPTIONS.top_width	= 0.1
--SUPPORT_OPTIONS.top_width	= 0.5
-- SUPPORT_OPTIONS.top_width	= 1
--SUPPORT_OPTIONS.top_width	= 1.5
--SUPPORT_OPTIONS.top_width	= 2


/* SET NORMAL LENGTH */ 
SUPPORT_OPTIONS.raft_length	= 0 -- AUTO NORMAL LENGTH 
-- SUPPORT_OPTIONS.raft_length	= 0.5
-- SUPPORT_OPTIONS.raft_length	= 0.75
-- SUPPORT_OPTIONS.raft_length	= 1
SUPPORT_OPTIONS.raft_length	= 2
SUPPORT_OPTIONS.raft_length	= 5
-- SUPPORT_OPTIONS.raft_length	= 10
-- SUPPORT_OPTIONS.raft_length	= 20
--SUPPORT_OPTIONS.raft_length	= 30



/* RAFT DIRECTION */ 
SUPPORT_OPTIONS.raft_direction	= 2 -- NORMAL
-- SUPPORT_OPTIONS.raft_direction	= 1 -- DOWN


/* SET RAFT MODE */ 
--SUPPORT_OPTIONS.raft_mode = 0 -- CUSTOM
SUPPORT_OPTIONS.raft_mode = 1 -- MIN
-- SUPPORT_OPTIONS.raft_mode = 2 -- AUTO


/* UNLOCK  RAFT LENGTH  */
SUPPORT_OPTIONS.lock_raft_length = false
SUPPORT_OPTIONS.lock_raft_length = true


/* FOOT ENABLED */
-- SUPPORT_OPTIONS.foot_enabled = false

/*==============================================================================
	GENERATE SUPPORTS
================================================================================*/

MODIFIERS_MANAGER	= ModifiersManager_v()
SUPPORT_MANAGER	= SupportManager_v()

/* WHAT TO GENERATE - SUPPORT  OR  RAFT  */
obj_type = #SUPPORT
-- obj_type = #RAFT

/* GENERATE */
generateSupportsOrRafts obj_type:obj_type


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










/*==============================================================================
	
	POST TEST
	
================================================================================*/
-- move $ ( [2.04037e-06,-14.1112,2.17744] - $.pos )

--all_supports = $'*-support-*'

--single_support = all_supports[all_supports.count]


--select single_support

-- format " TEST:  MOVE SUPPORT\n"
-- move single_support [ 0, -10, 0 ]

-- format " TEST:  MOVE SOURCE OBJECT\n"

-- select $PackMan
-- move  $PackMan [ 0, 0, 10 ]


--select $PackMan

/* UPDATE MODIFIER */


-- select $'*-support-*' -- SELECT ALL SUPPORT


-- SUPPORT_OPTIONS.setOptionValue #BAR_WIDTH 3.0

-- SUPPORT_OPTIONS.init()


--MODIFIERS_MANAGER.updateModifier( selection as array )( #BAR_WIDTH  )

--move $PackMan [ 0, 0, 5 ]

-- move $ [0,0,-29.8397]
-- rotate $ (angleaxis 41 [1,0,0])
-- rotate $ (angleaxis -28 [1,0,0])
-- rotate $ (angleaxis -18 [1,0,0])
-- move $ [0,0,42.175]
-- rotate $ (angleaxis -115 [1,0,0])
-- move $ [0,0,-36.9619]
-- rotate $ (angleaxis 67 [1,0,0])
-- move $ [0,0,33.2041]
-- move $ [0,0,-3.84295]
-- move $ [0,0,3.02209]
-- move $ [0,0,-44.8418]
-- rotate $ (angleaxis -3.5 [1,0,0])

-- rotate $ (angleaxis 64.5 [1,0,0])
-- rotate $ (angleaxis 31.5 [1,0,0])
-- rotate $ (angleaxis -22 [1,0,0])
