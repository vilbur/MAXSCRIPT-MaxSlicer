filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/_Test/helpers/createTestObjectPackMan.ms" )	--"./../../../Lib/SupportManager/_Test/helpers/createTestObjectPackMan.ms"

/**  
 */
macroscript	_create_test_object_wave_box
category:	"_maxslicer"
buttontext:	"WaveBox"
toolTip:	"Create WaveBox Object"
--icon:	"#(path, index)"
(
	on execute do
	(
		--filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/_Test/helpers/createTestObjectPackman.ms" )	--"./../../../Lib/SupportManager/_Test/helpers/createTestObjectPackman.ms"

		Box length:100 width:100 height:10 pos:[ 0, 0, 50] isSelected:on backfacecull:off lengthsegs:50 widthsegs:50 heightsegs:1
		--Plane length:100 width:100 pos:[ 0, 0, 50] isSelected:on backfacecull:off lengthsegs:2 widthsegs:2
		
		rotate $ ( AngleAxis 180 [1,0,0] )
		
		modPanel.addModToSelection (Noisemodifier scale:30 strength:[0,0,20] ) ui:on
	)
)

/*------------------------------------------------------------------------------
	PACKMAN
--------------------------------------------------------------------------------*/

/**  
 */
macroscript	_create_test_object_pack_man
category:	"_maxslicer"
buttontext:	"PackMan"
toolTip:	"Create PackMan Object"
--icon:	"#(path, index)"
(
	on execute do
	(
		--filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/_Test/helpers/createTestObjectPackman.ms" )	--"./../../../Lib/SupportManager/_Test/helpers/createTestObjectPackman.ms"
		--filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/_Test/helpers/createTestObjectPackMan.ms" )	--"./../../../Lib/SupportManager/_Test/helpers/createTestObjectPackMan.ms"

		--delete objects
		
		--if $PackMan != undefined then 
			----delete $PackMan
		
		verts_colors = Dictionary #string
		
		clr_blue =  ( color 30 144 255 ) as string
		clr_cyan =  ( color 0 255 255 ) as string
		clr_pink =  ( color 255 190 200 ) as string
		
		verts_colors[ "yellow"	] = #{ 113 }
		verts_colors[ "orange"	] = #{ 57 }
		verts_colors[ clr_pink	] = #{ 115 }
		-- verts_colors[ clr_blue	] = #{ 22 }
		verts_colors[ clr_blue	] = #{ 85 }
		verts_colors[ "green"	] = #{ 42 }
		verts_colors[ "gray"	] = #{ 32 }
		verts_colors[ clr_cyan	] = #{ 59 }

		obj = createTestObjectPackman  verts_colors:verts_colors
		
		rotate obj (angleaxis -6 [ 1, 0, 0 ])

	)
)

/**  
 */
macroscript	_create_test_object_pack_man_delete_objects
category:	"_maxslicer"
buttontext:	"PackMan"
toolTip:	"Delete all objects except PackMan"
--icon:	"#(path, index)"
(
	on execute do
	(
		--all_packmans = $'PackMan*' as Array
		
		objs_to_delete = for obj in objects where obj.name != "PackMan" collect obj 
		
		delete objs_to_delete
		
		--macros.run "_maxslicer" "_create_test_object_pack_man"
	)
)
