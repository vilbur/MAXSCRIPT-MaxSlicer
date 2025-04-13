/*------------------------------------------------------------------------------

	
	USED IN:
		"./../../SourceObject/SourceObjectTransformEventBinder/SourceObjectTransformEventBinder.ms"


--------------------------------------------------------------------------------*/


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

	fn valuesAreSame f1 f2 eps:0.001 = abs(f1) == abs(f2) OR abs (f1 - f2) <= eps
	
	/** Remove timeout
	 */
	fn removeTimeout sender =
	(
		sender.enabled = false

		dotNet.removeEventHandler sender "Elapsed" onSourceObjectTransform
		
		SOURCE_OBJECT_TRANSFORM.delay_timer = undefined
	)
	

	/* UPDATE WHEN LBM IS RELEASED */ 
	--if selection.count > 0 and not mouse.buttonStates[1] then
	if not mouse.buttonStates[1] then
	(
		--format "\n"; print "onSourceObjectTransform.ms.onSourceObjectTransform()"
		source_objects = for obj in SOURCE_OBJECT_TRANSFORM.moved_objects where findItem SOURCE_OBJECT_TRANSFORM.binded_objects obj > 0 collect obj 
		
		obj = source_objects[1]
		
		transform_data = SOURCE_OBJECT_TRANSFORM.transform_data[(getHandleByAnim obj) as string ]

		rotation_current = quatToEuler2 obj.rotation.controller.value
		rotation_saved   = transform_data[#ROTATION]
		
		/* TEST IF OBJECT HAS BEEN ROTATED ONLY BY Z AXIS - rotation only on z axis does not need update */ 
		rotated_only_z = ( valuesAreSame rotation_current.x rotation_saved.x and valuesAreSame rotation_current.y rotation_saved.y ) and not ( valuesAreSame rotation_current.z rotation_saved.z )

		rotation_chaged = not rotated_only_z

		/* TEST POSITION */ 		
		pos_z_changed	 = roundFloat transform_data[#POS_Z] != roundFloat obj.position.z
		
		/* CHOOSE WAHT TO UPDATE */ 		
		what_to_update = case of
		(
			(not rotation_chaged and not pos_z_changed ):	#POSITION_XY
			(pos_z_changed):	#POSITION_Z
			default:	#ROTATION
		)
		
		/* Update SourceObject and its suports if necessary */
		if what_to_update != #POSITION_XY then
		try(

			/*------------------------------------------------------------------------------
			  
				EXECUTE UPDATE
				
			--------------------------------------------------------------------------------*/
			--format "WHAT_TO_UPDATE: %\n" what_to_update
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