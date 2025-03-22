global SUPPORTS_BINDED = #()

global SUPPORTS_TRANSFORM_CHANGED = #()

/** On timeout callback
 */
function onSupportTransformTimeoutCallback sender evt =
(
	--format "\n"; print "onSupportTransformCallback.ms.onSupportTransformTimeoutCallback()"
	--format "SOURCE_OBJECT_TRANSFORM.delay_timer: %\n" SOURCE_OBJECT_TRANSFORM.delay_timer

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

	if SOURCE_OBJECT_TRANSFORM.delay_timer == undefined then
	(
		if selection.count > 0 then
		(
			--format "\n"; print "onSupportTransformCallback.ms.onSupportTransformTimeoutCallback()"
			if not mouse.buttonStates[1] then
			(
				SUPPORT_MANAGER.updateSupports( SUPPORTS_TRANSFORM_CHANGED ) update_knot_2:true direction:#CUSTOM
				
				SUPPORT_MANAGER.updateShapes() -- update all shapes at once

				removeTimeout sender
			)
		)
		else if selection.count == 0 then
			removeTimeout sender
	)
)

/** Start timeout
 */
function startSupportTransformTimeout =
(
	--format "\n"; print "onSupportTransformCallback.ms.startSupportTransformTimeout()"
	--delay_ms = 3000
	--delay_ms = 1000
	delay_ms = 100

	delay_timer = dotNetObject "Windows.Forms.Timer"

	delay_timer.Interval = delay_ms

	dotNet.addEventHandler delay_timer "Tick" onSupportTransformTimeoutCallback

	delay_timer.enabled = true
)


/** Bind transform event
 */
function bindSupportToTransformEvent supports =
(
	--format "\n"; print "onSupportTransformCallback.ms.bindSupportToTransformEvent()"
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
		/*------------------------------------------------------------------------------
			SET HOW MANY SUPPORT MUST BE SELECETED FOR LIVE UPDATE
		--------------------------------------------------------------------------------*/
		live_update_max_objects_count = 1

		/*------------------------------------------------------------------------------
			ON MULTIPLE SUPPORTS TRANSFORM
		--------------------------------------------------------------------------------*/
		if selection.count > live_update_max_objects_count then
		(

			if  SUPPORTS_TRANSFORM_CHANGED.count == 0 then
				startSupportTransformTimeout()

			appendIfUnique SUPPORTS_TRANSFORM_CHANGED support

		)
		/*------------------------------------------------------------------------------
			ON SINGLE SUPPORT TRANSFORM
		--------------------------------------------------------------------------------*/
		else if support.isSelected then
		(
			--print "!!!!!!!!! FIRED UPDATE"

			--bar_width   = SUPPORT_OPTIONS.getOption #BAR_WIDTH
			--base_height = SUPPORT_OPTIONS.getOption #BASE_HEIGHT
			--chamfer_val = SUPPORT_OPTIONS.getOption #TOP_WIDTH
			--
			--z_pos_limit = base_height + chamfer_val
			z_pos_limit = 0
			
			if support.pos.z < z_pos_limit then
				support.pos.z = z_pos_limit
			
			SUPPORT_MANAGER.updateSupports #( support ) update_knot_2:true direction:#CUSTOM
			
			
			--if selection.count == SUPPORT_MANAGER.shapes_to_update.count then
			SUPPORT_MANAGER.updateShapes() -- update all shapes at once
		)
		
	)
)


/** Pause events
 */
function pauseSupportTransformEvent =
(
	--format "\n"; print "onSupportTransformCallback.ms.pauseSupportTransformEvent()"
	deleteAllChangeHandlers id:#updateSupportsEvent
)
/** Resume events
 */
function resumeSupportTransformEvent =
(
	--format "\n"; print "onSupportTransformCallback.ms.resumeSupportTransformEvent()"
	bindSupportToTransformEvent #()
)