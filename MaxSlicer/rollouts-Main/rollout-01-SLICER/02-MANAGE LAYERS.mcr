filein( getFilenamePath(getSourceFileName()) + "/Lib/PrintLayerManager/PrintLayerManager.ms" )	--"./Lib/PrintLayerManager/PrintLayerManager.ms"

/** Colorize verts per layer
  */
macroscript	_maxtoprint_slice_set_stripes_per_layers
category:	"_3D-Print"
buttontext:	"Show Layers"
tooltip:	"Select verts per each 1mm of height"
icon:	""
(
	--filein @"c:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-01-SLICER\[SLICER].mcr"
	on execute do
	(
        PrintLayerManager = PrintLayerManager_v( selection[1] )
	
        PrintLayerManager.getLayerContours()
	)
)


