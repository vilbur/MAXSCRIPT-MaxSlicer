/**  
 */
macroscript	_create_test_object_pack_man
category:	"_maxslicer"
buttontext:	"Create PackMan"
toolTip:	"Create PackMan Object"
--icon:	"#(path, index)"
(
	on execute do
	(
		filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/_Test/helpers/createTestObjectPackman.ms" )	--"./../../../Lib/SupportManager/_Test/helpers/createTestObjectPackman.ms"

		delete objects
		
		if $PackMan != undefined then 
			delete $PackMan
		
		createTestObjectPackman()
	)
)
