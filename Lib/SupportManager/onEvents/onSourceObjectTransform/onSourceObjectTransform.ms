/*------------------------------------------------------------------------------

	
	USED IN:
		"./../../SourceObject/SourceObjectTransformEventBinder/SourceObjectTransformEventBinder.ms"


--------------------------------------------------------------------------------*/


/** Execute callback on timeout
 */
function onSourceObjectTransform sender evt =
(
	--format "\n===========================================================\n"
	--format "\n"; print "onSourceObjectTransform()"
	/* Round position or rotation of object to 3 deciamls
	 *
	 * Coordinates are changing little bit on unchaged axises beacause of "high precision" of Max values
	*/
	fn roundFloat val = ( local mult = 10.0 ^ 3; (floor ((val * mult) + 0.5)) / mult )

	--fn valuesAreSame f1 f2 eps:0.001 = abs(f1) == abs(f2) OR abs (f1 - f2) <= eps
	
	/** Remove timeout
	 */
	fn removeTimeout sender =
	(
		sender.enabled = false

		dotNet.removeEventHandler sender "Elapsed" onSourceObjectTransform
		
		SOURCE_OBJECT_TRANSFORM.delay_timer = undefined
	)
		/** Test rotation
	 */
	function XorYrotationChanged angle_A angle_B =
	(
		-- format "\n"; print "XorYrotationChanged()"
		
		fn valuesAreClose f1 f2 eps:0.001 = abs(f1) == abs(f2) OR abs (f1 - f2) <= eps
	
		flip_x = angle_A.x != angle_B.x and abs angle_A.x == abs angle_B.x
		flip_y = angle_A.y != angle_B.y and abs angle_A.y == abs angle_B.y
		
		if flip_x or flip_y then
		(
			--if abs angle_A.x + abs angle_B.x == 180 or abs angle_A.y + abs angle_B.y == 180 then
			
			if (flip_x and valuesAreClose ( abs angle_A.y + abs angle_B.y ) 180) \
			or(flip_y and valuesAreClose ( abs angle_A.x + abs angle_B.x ) 180) 
			then
			--if abs angle_A.x + abs angle_B.x == 180 or abs angle_A.y + abs angle_B.y == 180 then
			(
				angle_B.x = angle_A.x
				angle_B.y = angle_A.y		
			)
		)
		-- format "angle_A: %\n" angle_A
		-- format "angle_B: %\n" angle_B
		--( valuesAreClose angle_A.x angle_B.x and valuesAreClose angle_A.y angle_B.y) and not valuesAreClose angle_A.z angle_B.z
		not valuesAreClose angle_A.x angle_B.x or not valuesAreClose angle_A.y angle_B.y
		
	)
	
	
	source_objects = for source_object in SOURCE_OBJECT_TRANSFORM.moved_objects where findItem SOURCE_OBJECT_TRANSFORM.binded_objects source_object > 0 collect source_object 
		
		for source_object in source_objects do 
		(
			/* UPDATE WHEN LBM IS RELEASED */ 
			if not mouse.buttonStates[1] then
			(
				--clearListener(); print("Cleared in:\n"+getSourceFileName())
				  format "\n===========================================================\n"
				 -- format "\n"; print "onSourceObjectTransform()"
				--format "SOURCE_OBJECTS: %\n" source_objects
				
				pauseSupportTransformEvent()
				
				transform_data = SOURCE_OBJECT_TRANSFORM.transform_data[(getHandleByAnim source_object) as string ]
		
				rotation_current = quatToEuler2 source_object.rotation.controller.value
				 -- format "rotation_current: %\n" rotation_current
				rotation_saved   = transform_data[#ROTATION]
				 -- format "rotation_saved:   %\n" rotation_saved	
	
				/* TEST IF OBJECT HAS BEEN ROTATED ONLY BY X or Y AXIS - rotation only on z axis does not need update */
				rotation_chaged = XorYrotationChanged rotation_current rotation_saved
				 format "ROTATION_CHAGED: %\n" rotation_chaged
				format "transform_data[#POS_Z]:   %\n" transform_data[#POS_Z]
				format "source_object.position.z: %\n" (source_object.position.z)
				format "TEST: %\n" (abs(source_object.position.z - transform_data[#POS_Z]))
				
				/* TEST POSITION */ 		
				pos_z_changed = roundFloat transform_data[#POS_Z] != roundFloat source_object.position.z
	
				/* CHOOSE WAHT TO UPDATE */ 		
				what_to_update = case of
				(
					--(not rotation_chaged and not pos_z_changed ):	#POSITION_XY
					(rotation_chaged):	#ROTATION
					(pos_z_changed):	#POSITION_Z
					--default:	#ROTATION
				)
				 format "what_to_update: %\n" what_to_update 
				/* Update SourceObject and its suports if necessary */
				/*------------------------------------------------------------------------------
					EXECUTE UPDATE
				--------------------------------------------------------------------------------*/
				if what_to_update != #POSITION_XY then -- if source object
		
						SUPPORT_MANAGER.updateBySourceObject( source_objects ) (what_to_update)				
					--)
					--catch
					--(
						-- format "\n************ EXCEPTION FILE: ************\n%\n***********************************\n"  (getCurrentException())
			
						-- format "FILE: \n%\n" (getErrorSourceFileName())
						-- format "LINE: %\n" ( (getErrorSourceFileLine()) as integer )
						
						-- format "\n************ STACK ************\n%\n***********************************\n" (getCurrentExceptionCallStack())
						
					--)
					
					
				for source_object in source_objects do 
					SOURCE_OBJECT_TRANSFORM.setTransformData(source_object)
						
				--SOURCE_OBJECT_TRANSFORM.moved_objects = #()
				
				resumeSupportTransformEvent()
				
				
				removeTimeout sender
				
			)
		)
	)

