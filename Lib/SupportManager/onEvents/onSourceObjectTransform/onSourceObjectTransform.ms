
global SOURCE_OBJECTS_BINDED = #()
global SOURCE_OBJECT_TRANSFORM -- Dictionary KEYS:#OBJECT|#POS_Z|#ROTATION


/** Execute callback on timeout
 */
function onObjectTransformTimeoutCallback sender evt =
(
	format "\n"; print "onSourceObjectTransform.ms.onObjectTransformTimeoutCallback()"

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
		SOURCE_OBJECT_TRANSFORM = undefined

		sender.enabled = false
		-- for sanity and cleanup
		dotNet.removeEventHandler sender "Elapsed" onObjectTransformTimeoutCallback
	)
	
	obj = SOURCE_OBJECT_TRANSFORM[#OBJECT]

	saved_rotation = SOURCE_OBJECT_TRANSFORM[#ROTATION]

	current_rotation = quatToEuler2 obj.rotation.controller.value

	--format "saved_rotation: %\n" saved_rotation
	--format "current_rotation: %\n" current_rotation
	--format "TEST: %\n" (current_rotation==saved_rotation)
	
	if selection.count > 0 then
	(
		/* UPDATE ROTATION */ 
		what_to_update = #ROTATION
		
		/* OR POSITION - IF CHANGED */ 
		if current_rotation == saved_rotation then
		(
			if roundFloat SOURCE_OBJECT_TRANSFORM[#POS_Z] == roundFloat obj.position.z then
				what_to_update = #POSITION_XY  -- XY POSITION  CHANGED
			
			else
				what_to_update = #POSITION_Z  -- Z POSITION  CHANGED
		)

		/* Update SourceObject and its suports if necessary */
		if what_to_update != #POSITION_XY then
			SUPPORT_MANAGER.updateBySourceObject( selection as Array ) (what_to_update)

		removeTimeout sender
		
	)
	else if selection.count == 0 then
		removeTimeout sender
)

/** Start timeout
 */
function startObjectTransformTimeout =
(
	--format "\n"; print "onSourceObjectTransform.ms.startObjectTransformTimeout()"
	--delay_ms = 3000X
	delay_ms = 1000
	--delay_ms = 100

	delay_timer = dotNetObject "Windows.Forms.Timer"

	delay_timer.Interval = delay_ms

	dotNet.addEventHandler delay_timer "Tick" onObjectTransformTimeoutCallback

	delay_timer.enabled = true

)


/** Bind source object transform event
 */
function bindSourceObjectTransformEvent source_obj =
(
	--format "\n"; print "onSourceObjectTransform.ms.bindSourceObjectTransformEvent()"
	SOURCE_OBJECTS_BINDED = for obj in SOURCE_OBJECTS_BINDED where isValidNode obj collect obj

	/* GET OBJECT BIND TO EVENT */ 
	if classOf source_obj == Array then
		join SOURCE_OBJECTS_BINDED source_obj

	else
		append SOURCE_OBJECTS_BINDED source_obj


	deleteAllChangeHandlers id:#onSourceObjectTransform

	
	
	when transform SOURCE_OBJECTS_BINDED changes id:#onSourceObjectTransform handleAt:#redrawViews obj do
	(
		if SOURCE_OBJECT_TRANSFORM == undefined then
		(
			SOURCE_OBJECT_TRANSFORM = Dictionary #( #OBJECT, obj ) #( #POS_Z, obj.position.z ) #( #ROTATION, quatToEuler2 obj.rotation.controller.value )

			startObjectTransformTimeout()
		)
	)
)