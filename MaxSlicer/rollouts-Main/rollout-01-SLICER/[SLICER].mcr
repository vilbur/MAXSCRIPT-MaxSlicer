/**
  */
macroscript	maxtoprint_create_slicer_dialog
category:	"_3D-Print"
buttontext:	"S L I C E R  ☰"
tooltip:	"Slice selected object."
icon:	"across:3|height:32|tooltip:FIX IF NOT WORK PROPERLY: RESET OBJECT XFORM\n\nIF Z POZITION OF SLICE PLANE DOES NOT WORK PROPERLY"
(
	on execute do
	(
		clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-01-SLICER\Lib\SlicerSystem\createSlicerDialog.ms"

		SLICER_SYSTEM.setObjectsBySelection()

		SLICER_SYSTEM.addModifiers()

		SLICER_SYSTEM.whenSelectionChange()

		/* CREATE SLICE DIALOG */
		createslicerSliderDialog()

		SLICER_SYSTEM.setSliderByModifier()

		--select selection -- fire when selected event -- open modify panel and select Edit or Editable Poly

	)
)

/**
  */
macroscript	maxtoprint_remove_slice_modifiers
category:	"_3D-Print"
buttontext:	"S L I C E R  ☰"
tooltip:	"EXIT SLICE MODE"
icon:	""
(
	on execute do
	(
		_selection = if selection.count == 0 then selection else geometry

		--for mod_name in #( #SLICE_PLANE_TOP, #SLICE_PLANE_BOTTOM, #SELECT_BY_PRINT_LAYER ) do
		for mod_name in #( #SLICE_PLANE_TOP, #SLICE_PLANE_BOTTOM, #SLICE_EDIT_VERTS ) do
		(

			/*  */
			 if selection.count == 0 then
			 (
				modifiers_in_scene = for mod_in_scene in getClassInstances ( SliceModifier ) where mod_in_scene.name as name == mod_name collect mod_in_scene

				for mod_in_scene in modifiers_in_scene do
					for obj in refs.dependentNodes mod_in_scene do
						deleteModifier obj mod_in_scene
			 )
			 else
				for obj in selection where (_mod = obj.modifiers[mod_name]) != undefined do
				(
					format "deleteModifier obj _mod: %\n" (deleteModifier obj _mod)
					deleteModifier obj _mod
				)
		)
	)
)

/**
  */
macroscript	_maxtoprint_slice_set_slice_material
category:	"_3D-Print"
buttontext:	"Material"
tooltip:	"Toggle ID multimaterial on selected object"
icon:	""
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-SLICER\[SLICE PLANE].mcr"
		obj	= selection[1]

		mat_name = "SLICE MATERIAL"

		if obj.material == undefined or obj.material.name != mat_name then
		(
			_materials = for mat in sceneMaterials where mat.name == mat_name collect mat
			--print ( "_materials = " + _materials.count as string )
			mat = if( _materials.count == 0 ) then
			(
				mat = Multimaterial name:mat_name numsubs:3

				mat[2].base_color = color 0 75 255


				mat[3].base_color = color 255 0 0

				for i = 1 to 3 do
					mat[i].roughness = 0.75

				mat --return
			)
			else
				_materials[1]

			if obj.material != undefined  then
				setUserPropVal obj "SLICE_MATERIAL_ORIGINAL" obj.material.name

			obj.material = mat
		)
		else if ( mat_name = getUserPropVal obj "SLICE_MATERIAL_ORIGINAL" ) != undefined then
		(
			_materials = for mat in sceneMaterials where mat.name == mat_name collect mat

			mat = if _materials.count > 0 then
				obj.material = _materials[1]

			deleteUserProp obj "SLICE_MATERIAL_ORIGINAL"
		)
		else
			obj.material = undefined


	)
)



/** Colorize verts per layer
  */
macroscript	_maxtoprint_slice_set_stripes_per_layers
category:	"_3D-Print"
buttontext:	"Show Layers"
tooltip:	"Select verts per each 1mm of height"
icon:	""
(
	filein @"c:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\MaxSlicer\rollouts-Main\rollout-01-SLICER\[SLICER].mcr"
	on execute do
	if ( obj = selection[1] ) != undefined then 
	(
		--stripe_height = 20 -- number of layers in stripe
		stripe_height = ( 1 / DIALOG_maxslicer.SPIN_layer_height.value ) as integer -- get number of layers per 1mm
		
		first_layer = 0
		counter     = 0
		
		stripes = #{} -- verts in stripes
		
		add_verts = true
		
		verts_all = #{1..(getNumVerts obj.mesh)}
		
		VertIslandFinder = VertIslandFinder_v(obj)
		
		VertIslandFinder.verts_all = verts_all
		
		VertIslandFinder.verts_process = verts_all
		
		
		verts_layers = VertIslandFinder.sortVertsToLayers()
	
		for i = 1 to verts_layers.count while classOf verts_layers[i] != BitArray do  
			first_layer = i + 1

		format "FIRST_LAYER: %\n" first_layer
	
		for i = first_layer to verts_layers.count do
		(
			counter += 1

            /* ADD ONLY EVENT SET OF LAYERS */ 			
			if classOf verts_layers[i] == BitArray and add_verts then
				stripes += verts_layers[i]
			
			--format "%: %\n" i verts_layers[i]
			
			
			if counter == stripe_height then
			(
				add_verts = not add_verts
				
				counter = 0
			)
			
		)
		
		max modify mode

		subobjectLevel = 1

		obj.EditablePoly.SetSelection #Vertex #{}
		obj.EditablePoly.SetSelection #Vertex stripes
	)
	else
		messageBox "NOTHING SELECTED" title:"Colorize Layers"
	
)


