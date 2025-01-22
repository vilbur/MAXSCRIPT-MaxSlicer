clearListener(); print("Cleared in:"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../MAXSCRIPT-UI-framework/Lib/ContentLoader/ContentLoader.ms" )	--"./../MAXSCRIPT-UI-framework/Lib/ContentLoader/ContentLoader.ms"

filein( getFilenamePath(getSourceFileName()) + "/../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms" )	--"./../MAXSCRIPT-UI-framework/Lib/Menus/RcMenu/RcMenu.ms"

filein( getFilenamePath(getSourceFileName()) + "/../MAXSCRIPT-UI-framework/Lib/MacroscriptGenerator/generateMacroscripts.ms" )	--"./../MAXSCRIPT-UI-framework/Lib/MacroscriptGenerator/generateMacroscripts.ms"

/* UI GLOBALS */
global DIALOG_content
global DIALOG_slicer_slider
global ROLLOUT_generator
global ROLLOUT_slicer

/* STRUCT GLOBALS - before import SupportManager */
global SUPPORT_OPTIONS -- global SUPPORT_OPTIONS must be defined before SUPPORT_MANAGER
global SUPPORT_MANAGER
global MODIFIERS_MANAGER
global ISLANDS_SYSTEM
global SLICER_SYSTEM

global DIALOG_island_manager


filein( getFilenamePath(getSourceFileName()) + "/content/rollouts-Main/rollout-01-SLICER/Lib/SlicerSystem/SlicerSystem.ms" )	--"./content/rollouts-Main/rollout-SLICER/Lib/SlicerSystem/SlicerSystem.ms"

filein( getFilenamePath(getSourceFileName()) + "/content/rollouts-Main/rollout-02-ISLANDS/Lib/IslandsSystem/IslandsSystem.ms" )	--"./content/rollouts-Main/rollout-ISLANDS/Lib/IslandsSystem/IslandsSystem.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/SupportManager/SupportManager.ms" )	--"./Lib/SupportManager/SupportManager.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/SupportManager/Callbacks/selectHideUnhideSupports.ms" )	--"./Lib/SupportManager/Callbacks/selectHideUnhideSupports.ms"

current_dir = getFilenamePath(getSourceFileName())


/*------------------------------------------------------------------------------
	GENERATE MACROS
--------------------------------------------------------------------------------*/
--generateMacroscripts( current_dir + "/content" )


/*------------------------------------------------------------------------------
	START 
------------------------------------------------------------------------------*/
try(

	--generateMacroscripts( current_dir )


	/** LOAD CONTENT */
	--ContentLoader	= ContentLoader_v path:(current_dir+"\\content") -- WITHOUT INI FILE --DEV
	--ContentLoader	= ContentLoader_v path:(current_dir+"\\content") ini:( getSourceFileName())
	ContentLoader	= ContentLoader_v path:(current_dir+"\\content") ini:( getSourceFileName()) min_size:[ 400, -1 ] max_size:[400, -1] width:400



	/* CHANGE PROPERTIES oF ROLLOUTS */
	ContentLoader.Dialog.title = "Max Slicer"


	--/* CREATE DIALOG */
	--MaxToPrint = ContentLoader.create width:420 height:1024
	--MaxToPrint = ContentLoader.create width:420 height:#AUTO
	--MaxToPrint = ContentLoader.create width:420 height:undefined
	MaxToPrint = ContentLoader.create lockWidth:true
	--MaxToPrint = ContentLoader.create()
	--MaxToPrint = ContentLoader.create width:420 height:unsupplied

	MaxToPrint.register()

	/*------------------------------------------------------------------------------
		INIT GLOBAL CLASSES when ui exists
	--------------------------------------------------------------------------------*/
	SUPPORT_OPTIONS = SupportOptions_v #(ROLLOUT_generator, ROLLOUT_supports)

	SUPPORT_OPTIONS.getValuesFroUi()

	MODIFIERS_MANAGER = ModifiersManager_v()

	SLICER_SYSTEM = SlicerSystem_v()

	SUPPORT_MANAGER = SupportManager_v()

	/*------------------------------------------------------------------------------
		RELAUNCH SUB DIALOGS
	--------------------------------------------------------------------------------*/

	--/* RELAUNCH ISLAND MANAGER */
	--if DIALOG_island_manager != undefined then
	--	macros.run "_3D-Print" "maxtoprint_islands_dialog"
	--
	--/* RELAUNCH SLICER MANAGER */
	--if DIALOG_slicer_slider != undefined then
	--	macros.run "_3D-Print" "maxtoprint_create_slicerdialog"

)catch(
	format "\n——————————————— ERROR IN FILE ———————————————\n\n%\n" (getSourceFileName())
	format "\n————————————————— EXCEPTION —————————————————\n\n%\n" (getCurrentException())
	format "\n——————————————————— TRACE ———————————————————\n%\n"   (getCurrentExceptionStackTrace())
	format "\n——————————————————— STACK ———————————————————\n%\n"   (getCurrentExceptionCallStack())
)
