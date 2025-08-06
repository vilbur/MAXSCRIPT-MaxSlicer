clearListener(); print("Cleared in:\n"+getSourceFileName())



/*
  Function to copy animation keys of selected objects to different time offset
*/
function copyKeysWithOffset offset_time =
(

	for obj in selection where isValidNode obj do
	(
		-- transform controllers: position, rotation, scale
		track_list = #(obj.position.controller, obj.rotation.controller, obj.scale.controller)

		for ctrl in track_list do
		(
			format "ctrl: %\n" ctrl
			if isController ctrl then
			(
				num_keys = numKeys ctrl
				format "num_keys: %\n" num_keys
				for k = 1 to num_keys do
				(
					key_time = getKeyTime ctrl k
					new_time = key_time + offset_time
					key_val = getKeyValue ctrl k
					at time new_time setKey ctrl new_time
					setKeyValue ctrl (getKeyIndex ctrl new_time) key_val
				)
			)
		)
	)
) -- return

copyKeysWithOffset 10 -- shifts keys 30 frames forward
