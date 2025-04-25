
--
--/*
--*/
--macroscript	_print_support_generator_rafts
--category:	"_3D-Print"
--buttontext:	"R A F T"
--icon:	"across:4|offset:[0, 6]|height:32|width:96|tooltip:GEENERATE RAFTS.\n\nWORKS ON SELECTION OF:\n\t1) SOURCE OBJECT\n\t2) POINTS\n\t3) SUPPORTS - Turn support into raft"
--(
--	on execute do
--		undo "Generate Rafts" on
--		(
--
--			--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-SUPPORTS\2-SUPPORTS.mcr"
--			generateSupportsOrRafts obj_type:#RAFT
--		)
--)




/** BAR WIDTH
 */
macroscript	_print_platform_generator_raft_width
category:	"_3D-Print"
buttontext:	"WIDTH"
tooltip:	"Raft width in mm of printed model.\n\nExported scale is used"
icon:	"control:spinner|id:SPIN_raft_width|across:4|range:[ 0.3, 99, 0.5 ]|width:64|offset:[ 4, 12]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)

/**
 */
macroscript	_print_platform_generator_raft_chamfer
category:	"_3D-Print"
buttontext:	"CHAMFER"
tooltip:	"Chamfer of support`s top.\n\n\nCHAMFER MIN: 0\nCHAMFER MAX: 10\n\nValue is portion of bar radius.\n\nE.EG: 5 == 50% use of radius"
icon:	"control:spinner|id:SPIN_chamfer_raft|across:4|type:#integer|range:[ 0, 10, 5 ]|width:64|offset:[ 24, 12 ]"
(
	--format "EventFired:	% \n" EventFired
	on execute do
		SUPPORT_MANAGER.updateModifiers ( EventFired )
)
--
--/** EXTRUDE TOP
-- */
--macroscript	_print_platform_generator_extrude_top
--category:	"_3D-Print"
--buttontext:	"EXTEND"
--tooltip:	"Extrude end part in mm of printed model.\n\nExported scale is used"
--icon:	"control:spinner|id:SPIN_extend_end|across:4|width:64|range:[ 0, 99, 0.5 ]|offset:[ 6, 12 ]"
--(
--	--format "EventFired:	% \n" EventFired
--	on execute do
--		SUPPORT_MANAGER.updateModifiers ( EventFired )
--)
