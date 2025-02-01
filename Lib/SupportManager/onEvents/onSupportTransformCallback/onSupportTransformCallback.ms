global SUPPORTS_BINDED = #()

global SUPPORTS_TRANSFORM_CHANGED = #()

/** On timeout callback
 */
function onSupportTransformTimeoutCallback sender evt =
(
	--format "\n"; print "onSupportTransformCallback.ms.onSupportTransformTimeoutCallback()"

	/** Remove timeout
	 */
	fn removeTimeout sender =
	(
		--format "\n"; print "onSupportTransformCallback.ms.removeTimeout()"
		SUPPORTS_TRANSFORM_CHANGED = #()

		sender.enabled = false
		-- for sanity and cleanup
		dotNet.removeEventHandler sender "Elapsed" onSupportTransformTimeoutCallback
	)

	--if selection.count > 0 then
	--(
	--	print "\nTIMER"
	--
	--	removeTimeout sender
	--)


	if selection.count > 0 then
	(
		SUPPORT_MANAGER.updateSupports( SUPPORTS_TRANSFORM_CHANGED )

		removeTimeout sender
	)
	else if selection.count == 0 then
		removeTimeout sender
)

/** Start timeout
 */
function startSupportTransformTimeout =
(
	--format "\n"; print "onSupportTransformCallback.ms.startSupportTransformTimeout()"
	--delay_ms = 3000
	delay_ms = 1000
	--delay_ms = 100

	delay_timer = dotNetObject "Windows.Forms.Timer"

	delay_timer.Interval = delay_ms

	dotNet.addEventHandler delay_timer "Tick" onSupportTransformTimeoutCallback

	delay_timer.enabled = true
)


/** Bind transform event
 */
function bindSupportToTransformEvent supports =
(
	format "\n"; print "onSupportTransformCallback.ms.bindSupportToTransformEvent()"
	--format "SUPPORTS: %\n" SUPPORTS
	--format "COUNT: %\n" SUPPORTS.count
	SUPPORTS_BINDED = for obj in SUPPORTS_BINDED where isValidNode obj collect obj

	if classOf supports == Array then
		join SUPPORTS_BINDED supports

	else
		append SUPPORTS_BINDED supports

	deleteAllChangeHandlers id:#updateSupportsEvent

	when transform SUPPORTS_BINDED changes id:#updateSupportsEvent support do
	(

		--if selection.count > 2 then
		if selection.count > 1 then
		(

			if  SUPPORTS_TRANSFORM_CHANGED.count == 0 then
				startSupportTransformTimeout()

			appendIfUnique SUPPORTS_TRANSFORM_CHANGED support

		)
		/* ON SINGLE SUPPORT TRANSFORM */
		else if support.isSelected then
		(
			--print "!!!!!!!!! FIRED UPDATE"
			--format "Update Supports: %\n" support.name

			SUPPORT_MANAGER.updateSupports #( support )
		)

	)
)


/** Pause events
 */
function pauseSupportToTransformEvent =
(
	--format "\n"; print "onSupportTransformCallback.ms.pauseSupportToTransformEvent()"
	deleteAllChangeHandlers id:#updateSupportsEvent
)
/** Resume events
 */
function resumeSupportToTransformEvent =
(
	--format "\n"; print "onSupportTransformCallback.ms.resumeSupportToTransformEvent()"
	bindSupportToTransformEvent #()
)