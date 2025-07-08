clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../InvalidFaceChecker.ms" )	--"./../InvalidFaceChecker.ms"


for obj in objects do obj.alledges = on


obj	= selection[1]

InvalidFaceChecker 	= InvalidFaceChecker_v(obj)


InvalidFaceChecker.search()