clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../SourceObject.ms" )	--"./../SourceObject.ms"


/** Createa source object
 */
function createSourceObject =
(
	--format "\n"; print ".createSourceObject()"
	
	_sphere = Sphere pos:[ 0, 0, 100 ]
	
	addModifier _sphere ( Edit_Poly() )
	
	--addModifier _sphere ( meshsmooth sepBySmGroups:true )
	
	_sphere --return
)

delete objects

createSourceObject()