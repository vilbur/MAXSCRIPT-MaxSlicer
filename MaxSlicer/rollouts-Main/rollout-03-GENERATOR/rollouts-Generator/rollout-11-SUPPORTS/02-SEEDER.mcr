filein( getFilenamePath(getSourceFileName()) + "/../../../../../Lib/SupportManager/GridSupportSeeder/GridSupportSeeder.ms" )	--"./../../../../../Lib/SupportManager/GridSupportSeeder/GridSupportSeeder.ms"


/** SUPPORT FOOT
 */
macroscript	_print_support_seeder
category:	"_3D-Print"
buttontext:	"Seeder"
tooltip:	"Seed Supports"
icon:	"ACROSS:4"
(
	on execute do
	(
		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-03-GENERATOR\rollouts-Generator\rollout-11-SUPPORTS\02-SEEDER.mcr"
		
		cylinders = ( $'Cylinder*' as Array ) 
		
		GridSupportSeeder = GridSupportSeeder_v()
		
		GridSupportSeeder.target_objects = $Box001
		GridSupportSeeder.cell_size = 15
		--GridSupportSeeder.cell_size = 10
		--GridSupportSeeder.cell_size = 20
		
		--GridSupportSeeder.initGrid(cylinders)
		GridSupportSeeder.initGrid($Box001)
		
		GridSupportSeeder.sortNodesToMatrix (cylinders)
		
		empty_cells = GridSupportSeeder.getEmptyCells()
		
		
		for cell_pos in empty_cells do
		--format "empty_cell: %\n" empty_cell
			Sphere pos:cell_pos radius:1 wirecolor:red
				
		
	)
)