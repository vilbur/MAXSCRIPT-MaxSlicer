clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../PrintLayerManager.ms" )	--"./../PrintLayerManager.ms"


PrintLayerManager = PrintLayerManager_v( selection[1] )

PrintLayerManager.getLayerContours()