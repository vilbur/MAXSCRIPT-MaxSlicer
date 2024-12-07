
/*------------------------------------------------------------------------------
	SOURCE OBJECT
--------------------------------------------------------------------------------*/

/*
*/
macroscript	_print_support_visibility_source_show
category:	"_3D-Print"
buttontext:	"SOURCE"
tooltip:	"Show source objects\n\nCTRL: Select source objects\n\nSHIFT:Select more"
icon:	"across:3|height:32|width:128|border:false"
(
	on execute do
		undo "Show\Hide Source" on
			selectHideUnhideSupports type:#SOURCE state:true
)

/*
*/
macroscript	_print_support_visibility_source_hide
category:	"_3D-Print"
buttontext:	"SOURCE"
--icon:	""
(
	on execute do
		undo "Show\Hide Source" on
			selectHideUnhideSupports type:#SOURCE state:false
)

/*------------------------------------------------------------------------------
	SUPPORTS
--------------------------------------------------------------------------------*/

/*
*/
macroscript	_print_support_visibility_show
category:	"_3D-Print"
buttontext:	"SUPPORTS"
tooltip:	"Show SUPPORT objects\n\nCTRL: Select support objects\n\nSHIFT:Select more"
--icon:	"tooltip:CTRL: Select support objects\n\nSHIFT:Select more"
(
	on execute do
		undo "Show\Hide Supports" on
			selectHideUnhideSupports type:#SUPPORT state:true
)

/*
*/
macroscript	_print_support_visibility_hide
category:	"_3D-Print"
buttontext:	"SUPPORTS"
tooltip:	"Hide supports"
--icon:	"id:BTN_visibility_Supports"
(
	on execute do
		undo "Show\Hide Supports" on
			selectHideUnhideSupports type:#SUPPORT state:false
)


/*------------------------------------------------------------------------------
	RAFTS
--------------------------------------------------------------------------------*/
/*
*/
macroscript	_print_support_visibility_rafts
category:	"_3D-Print"
buttontext:	"RAFTS"
tooltip:	"Show RAFT objects\n\nCTRL: Select raft objects\n\nSHIFT:Select more"
--icon:	"tooltip:CTRL: Select raft objects\n\nSHIFT:Select more"
(
	on execute do
		undo "Show\Hide Supports" on
		(
			selectHideUnhideSupports type:#RAFT state:true

		)
)

/*
*/
macroscript	_print_support_visibility_rafts_hide
category:	"_3D-Print"
buttontext:	"RAFTS"
tooltip:	"Hide rafts"
--icon:	"id:BTN_visibility_Supports"
(
	on execute do
		undo "Show\Hide Rafts" on
			selectHideUnhideSupports type:#RAFT state:false
)




/*------------------------------------------------------------------------------
	BEAMS
--------------------------------------------------------------------------------*/
/*
*/
macroscript	_print_support_visibility_beams_show
category:	"_3D-Print"
buttontext:	"BEAMS"
tooltip:	"Show BEAMS objects\n\nCTRL: Select beams objects\n\nSHIFT:Select more"
icon:	"across:3"
(
	on execute do
		undo "Show\Hide Beams" on
			selectHideUnhideSupports type:#BEAM state:true
)

/*
*/
macroscript	_print_support_visibility_beams_hide
category:	"_3D-Print"
buttontext:	"BEAMS"
tooltip:	"Hide beams"
--icon:	"id:BTN_visibility_beams|across:5|height:32|width:96|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Show\Hide Beams" on
			selectHideUnhideSupports type:#BEAM state:false
)

/*------------------------------------------------------------------------------
	PINS
--------------------------------------------------------------------------------*/
/*
*/
macroscript	_print_support_visibility_pins_show
category:	"_3D-Print"
buttontext:	"PINS"
tooltip:	"Show PINS objects\n\nCTRL: Select pins objects\n\nSHIFT:Select more"
--icon:	"tooltip:CTRL: Select pins objects\n\nSHIFT:Select more"
(
	on execute do
		undo "Show\Hide Beams" on
			selectHideUnhideSupports type:#PIN state:true
)

/*
*/
macroscript	_print_support_visibility_pins_hide
category:	"_3D-Print"
buttontext:	"PINS"
tooltip:	"Hide pins"
--icon:	"id:BTN_visibility_pins|across:5|height:32|width:96|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Show\Hide Beams" on
			selectHideUnhideSupports type:#PIN state:false
)

/*------------------------------------------------------------------------------
	DRAINS
--------------------------------------------------------------------------------*/
/*
*/
macroscript	_print_support_visibility_drains_show
category:	"_3D-Print"
buttontext:	"DRAINS"
tooltip:	"Show DRAINS objects\n\nCTRL: Select drains objects\n\nSHIFT:Select more"
--icon:	"tooltip:CTRL: Select drains objects\n\nSHIFT:Select more"
(
	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\Lib\SupportManager\SupportManager.ms"
		undo "Show\Hide Beams" on
			selectHideUnhideSupports type:#DRAIN state:true
	)
)

/*
*/
macroscript	_print_support_visibility_drains_hide
category:	"_3D-Print"
buttontext:	"DRAINS"
tooltip:	"Hide drains"

--icon:	"id:BTN_visibility_drains|across:5|height:32|width:96|tooltip:GEENERATE BEAMS between supports.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS"
(
	on execute do
		undo "Show\Hide Beams" on
			selectHideUnhideSupports type:#DRAIN state:false
)


--
--/*------------------------------------------------------------------------------
--	ALL
----------------------------------------------------------------------------------*/
--
--/**
-- */
--macroscript	_print_support_visibility_all
--category:	"_3D-Print"
--buttontext:	"✅All"
--icon:	"id:BTN_visibility_all|across:5|height:32|width:96|tooltip:GENERATE POINTS From selected object.\n\nLAST OBEJCT IS USED IF NOTHING SELECTED"
--(
--	on execute do
--		undo "Show\Hide Points" on
--		--undo off
--		(
--			clearListener(); print("Cleared in:\n"+getSourceFileName())
--			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-viltools3\VilTools\rollouts-Tools\rollout-PRINT-3D\SUPPORT GENERATOR.mcr"
--
--			selectHideUnhideSupports type:#ALL state:false
--
--
--	--		if ( points_created = (getSupportManagerInstance()).generatePointHelpers( selection ) reset_helpers: keyboard.controlPressed ).count > 0 then
--	--			select points_created
--	--		--	--format "POINTS_CREATED	= % \n" POINTS_CREATED
--		)
--)
