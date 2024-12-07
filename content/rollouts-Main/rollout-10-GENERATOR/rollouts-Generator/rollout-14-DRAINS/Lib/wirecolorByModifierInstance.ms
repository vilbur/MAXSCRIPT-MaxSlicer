/** Wirecolor by modifier instance
 */
function wirecolorByModifierInstance mod_name =
(
	--format "\n"; print ".wirecolorByModifierInstance()"
--mod_name = #DRAIN_WIDTH

	_objects = for obj in selection where obj.modifiers[mod_name] != undefined collect obj

	objects_by_mods	=  Dictionary #STRING -- KEY:"modifier pointer" VALUE:#(objects with same instance of modifier )


	for obj in _objects do
	(
		mod_pointer = (getHandleByAnim obj.modifiers[mod_name]) as string
		--format "mod_pointer: %\n" mod_pointer

		if objects_by_mods[mod_pointer] == undefined then
			objects_by_mods[mod_pointer] = #()

		append objects_by_mods[mod_pointer] obj
	)



	for mod_pointer in objects_by_mods.keys do
	(
		objects_with_mod = objects_by_mods[mod_pointer]

		_wirecolor = orange

		_wirecolor.hue = ( random 0 255 )
		_wirecolor.saturation = ( random 128 255 )

		for obj in objects_with_mod do
			obj.wirecolor = _wirecolor
	)

)
