
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
		sender.enabled = false

		dotNet.removeEventHandler sender "Elapsed" onSourceObjectTransform
		
		SOURCE_OBJECT_TRANSFORM.delay_timer = undefined
	)
	

	/* UPDATE IF LMB IS NOT PRESSED */ 
	if selection.count > 0 and not mouse.buttonStates[1] then
	(
		--format "\n"; print "onSourceObjectTransform.ms.onSourceObjectTransform()"
		source_objects = for obj in selection where findItem SOURCE_OBJECT_TRANSFORM.binded_objects obj > 0 collect obj 

		obj = source_objects[1]
		
		transform_data = SOURCE_OBJECT_TRANSFORM.transform_data[(getHandleByAnim obj) as string ]

		rotation_chaged = transform_data[#ROTATION] != quatToEuler2 obj.rotation.controller.value
		
		pos_z_changed	 = roundFloat transform_data[#POS_Z] != roundFloat obj.position.z
		
		
		what_to_update = case of
		(
			(not rotation_chaged and not pos_z_changed ):	#POSITION_XY
			(pos_z_changed):	#POSITION_Z
			default:	#ROTATION
		)
		
		/* Update SourceObject and its suports if necessary */
		if what_to_update != #POSITION_XY then
		try(
			SUPPORT_MANAGER.updateBySourceObject( source_objects ) (what_to_update)
			
		)
		catch
		(
			format "\n************ EXCEPTION FILE: ************\n%\n***********************************\n"  (getCurrentException())

			format "FILE: \n%\n" (getErrorSourceFileName())
			format "LINE: %\n" ( (getErrorSourceFileLine()) as integer )
			
			format "\n************ STACK ************\n%\n***********************************\n" (getCurrentExceptionCallStack())
			
		)
		
		
		for obj in source_objects do 
			SOURCE_OBJECT_TRANSFORM._setTransformData(obj)
				
		
		removeTimeout sender
		
		resumeSupportTransformEvent()
	)
)


fn roundFloat val = ( local mult = 10.0 ^ 3; (floor ((val * mult) + 0.5)) / mult )

roundFloat 0.123456789