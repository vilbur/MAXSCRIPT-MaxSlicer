
global SOURCE_OBJECTS_BINDED = #()
global SOURCE_OBJECT_POSITION


/** On timeout callback
 */
function onObjectTransformTimeoutCallback sender evt =
(
	--format "\n"; print "onSourceObjectTransform.ms.onObjectTransformTimeoutCallback()"

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
		SOURCE_OBJECT_POSITION = undefined

		sender.enabled = false
		-- for sanity and cleanup
		dotNet.removeEventHandler sender "Elapsed" onObjectTransformTimeoutCallback
	)

	saved_rotation = SOURCE_OBJECT_POSITION[#ROTATION]

	current_rotation = quatToEuler2 SOURCE_OBJECT_POSITION[#OBJECT].rotation.controller.value

	if selection.count > 0 then
	(
		--format "saved_rotation.x:   %\n" (roundFloat saved_rotation.x)
		--format "current_rotation.x: %\n" (roundFloat current_rotation.x)
		--format "saved_rotation.y:   %\n" (roundFloat saved_rotation.y)
		--format "current_rotation.y: %\n" (roundFloat current_rotation.y)

		if roundFloat saved_rotation.x != roundFloat current_rotation.x or roundFloat saved_rotation.y != roundFloat current_rotation.y then
		(
			print "ROTATION CHANGED"
			SUPPORT_MANAGER.updateSupportsBySourceObject( selection as Array )

			removeTimeout sender
		)
		else if roundFloat SOURCE_OBJECT_POSITION[#POS_Z] != roundFloat SOURCE_OBJECT_POSITION[#OBJECT].position.z then
		(
			print "Z POZITION CHANGED"
			SUPPORT_MANAGER.updateSupportsBySourceObject( selection as Array ) only_height:true

			removeTimeout sender
		)
	)
	else if selection.count == 0 then
		removeTimeout sender

)

/** Start timeout
 */
function startObjectTransformTimeout =
(
	--format "\n"; print "onSourceObjectTransform.ms.startObjectTransformTimeout()"
	--delay_ms = 3000
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

	if classOf source_obj == Array then
		join SOURCE_OBJECTS_BINDED source_obj

	else
		append SOURCE_OBJECTS_BINDED source_obj


	deleteAllChangeHandlers id:#onSourceObjectTransform

	when transform SOURCE_OBJECTS_BINDED changes id:#onSourceObjectTransform handleAt:#redrawViews obj do
	(
		if SOURCE_OBJECT_POSITION == undefined then
		(
			SOURCE_OBJECT_POSITION = Dictionary #( #OBJECT, obj ) #( #POS_Z, obj.position.z ) #( #ROTATION, quatToEuler2 obj.rotation.controller.value )

			startObjectTransformTimeout()
		)
	)
)