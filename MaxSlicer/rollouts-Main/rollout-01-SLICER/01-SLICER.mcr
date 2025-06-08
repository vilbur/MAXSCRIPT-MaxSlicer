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
		createSlicerDialog() --"./Lib/SlicerSystem/createSlicerDialog.ms"

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
