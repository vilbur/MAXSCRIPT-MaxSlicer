filein( getFilenamePath(getSourceFileName()) + "/Lib/InvalidFaceChecker/InvalidFaceChecker.ms" )	--"./Lib/InvalidFaceChecker/InvalidFaceChecker.ms"

/**
 *
 */
macroscript	maxtoprint_test_mesh
category:	"_Tools"
buttontext:	"Check Invalid Faces"
toolTip:	"Search for invalid face.\n\nPolygons with invalid triangulation will be retriangulated.\n\nWORKS ON SELECTED OR ALL FACES"
icon:	"AXRTOSS:2|width:108"
(
	on execute do
	(
		for obj in objects do obj.alledges = on
		
		
		obj	= selection[1]
		
		InvalidFaceChecker 	= InvalidFaceChecker_v(obj)
		
		InvalidFaceChecker.search()
		
		
		if (invalid_faces = InvalidFaceChecker.invalid_faces).numberSet > 0 then
		(
			to_select = invalid_faces
			
			message = ( invalid_faces.numberSet as string + " Degenrated faces selected")
		)
		else if (retriangluted_faces = InvalidFaceChecker.retriangluted_faces).numberSet > 0 then
		(
			to_select = retriangluted_faces
			
			message = ( retriangluted_faces.numberSet as string + " Retriangulated faces selected")
		)
		else
			message = "All faces are valid"
		
		
		if to_select != undefined then
			(VertSelector_v( obj )).setSelection to_select subobject:#FACE

		
		
		if message != undefined then
			messageBox message title:"InvalidFaceChecker"  beep:false	
			
		
	)
)