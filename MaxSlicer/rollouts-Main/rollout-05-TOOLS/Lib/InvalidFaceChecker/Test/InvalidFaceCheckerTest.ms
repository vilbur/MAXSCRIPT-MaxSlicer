clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../InvalidFaceChecker.ms" )	--"./../InvalidFaceChecker.ms"


obj	= selection[1]

InvalidFaceChecker 	= InvalidFaceChecker_v(obj)
