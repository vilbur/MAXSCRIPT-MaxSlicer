
global SOURCE_OBJECT_TRANSFORM = undefined  -- Dictionary KEYS:#OBJECT|#POS_Z|#ROTATION


/** Execute callback on timeout
 */
function onSourceObjectTransform sender evt =
(
	--format "\n"; print "onSourceObjectTransform.ms.onSourceObjectTransform()"

	/* Round position or rotation of object to 3 deciamls
	 *
	 * Coordinates are changing little bit on unchaged axises beacause of "high precision" of Max values
	*/
	fn roundFloat val = ( local mult = 10.0 ^ 3; (floor ((val * mult) + 0.5)) / mult )

	/** Remove timeout
	 */
	fn removeTimeout sender =
	(
		--format "\n"; print "onSourceObjectTransform.ms.removeTimeout()"
		
		sender.enabled = false
		-- for sanity and cleanup
		dotNet.removeEventHandler sender "Elapsed" onSourceObjectTransform
		
		SOURCE_OBJECT_TRANSFORM.delay_timer = undefined
	)
	
	--format "LMB STATE: %\n" mouse.buttonStates[1]

	/* UPDATE IF LMB IS NOT PRESSED */ 
	if selection.count > 0 and not mouse.buttonStates[1] then
	(
		source_objects = for obj in selection where findItem SOURCE_OBJECT_TRANSFORM.binded_objects obj > 0 collect obj 

		obj = source_objects[1]
		
		transform_data = SOURCE_OBJECT_TRANSFORM.transform_data[(getHandleByAnim obj) as string ]

		saved_rotation = transform_data[#ROTATION]
		
		current_rotation = quatToEuler2 obj.rotation.controller.value
		
		
		/* UPDATE ROTATION */ 
		what_to_update = #ROTATION
		
		/* OR UPDATE POSITION - IF CHANGED */ 
		if current_rotation == saved_rotation then
			what_to_update = ( if roundFloat transform_data[#POS_Z] == roundFloat obj.position.z then #POSITION_XY else #POSITION_Z )
		
		
		/* Update SourceObject and its suports if necessary */
		if what_to_update != #POSITION_XY then
			SUPPORT_MANAGER.updateBySourceObject( source_objects ) (what_to_update)
		
		for obj in source_objects do 
			SOURCE_OBJECT_TRANSFORM._setTransformData(obj)
				
		--SOURCE_OBJECT_TRANSFORM.resetSavedTransforms(source_objects)
		
		removeTimeout sender
	)
)
