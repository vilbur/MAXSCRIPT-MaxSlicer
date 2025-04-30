/** When transfrom ends callback
 */
function transfromEndsCallback _objects =
(
	format "\n"; print "WhenTransfromChangesEnds_v.transfromEndsCallback()"
	format "_OBJECTS: %\n" _objects
	
)

/** When transfrom changes
  * 
  * Bind when transform changes call back to nodes.
  * Track their changes and fire callback when transform ends
  * 
  * 
  * 
  * 
 */

--if WHEN_TRANSFROM_CHANGES_ENDS == undefined then 
global WHEN_TRANSFROM_CHANGES_ENDS =
(
	struct WhenTransfromChangesEnds_v
	(
		/* construct */

		/* required */
		test_callback = transfromEndsCallback,
	
		/* properties */
		delay_ms = 200,

	
		/* private */
		binded_objects = #(),
		
		moved_objects = #(),
		
		transform_data = Dictionary #STRING,
		
		delay_timer,
		
		/* dependency */
		/* reference */
		/* inhered */
		
		/** Bind
		 */
		function bind obj =
		(
			--format "\n"; print "WhenTransfromChangesEnds_v.bind()"
			this._addBindedObjects(obj)

			deleteAllChangeHandlers id:#onSourceObjectTransformEnds
			
			/* DO THIS WHEN NODES CHANGES TRANSFORM */ 
			when transform binded_objects changes id:#onSourceObjectTransformEnds handleAt:#redrawViews obj do
			(
				appendIfUnique moved_objects obj

				if this.delay_timer == undefined then
					this._startTimeout()
			)
		),
		
		/** Kill timer
		 */
		function killTimer =
		(
			--format "\n"; print "WhenTransfromChangesEnds_v.killTimer()"
			delay_timer.enabled = false
	
			dotNet.removeEventHandler delay_timer "Elapsed" onSourceObjectTransformEnds
			
			delay_timer = undefined
		),
		
		/** When transfrom changes callback
		 */
		function fireCallback sender evt =
		(
			format "\n"; print "WhenTransfromChangesEnds_v.fireCallback()"
			/** Remove timeout
			 */
			fn removeTimeout sender =
			(
				sender.enabled = false
		
				dotNet.removeEventHandler sender "Elapsed" onSourceObjectTransformEnds
				
				this.delay_timer = undefined
			)
			
		
			/* UPDATE WHEN LBM IS RELEASED */ 
			--if selection.count > 0 and not mouse.buttonStates[1] then
			if not mouse.buttonStates[1] then
			(
				format "\nTRANSFROM ENDS\n"
		
				--format "moved_objects: %\n" moved_objects
				
				test_callback(moved_objects)
				
				moved_objects = #()
		
				removeTimeout sender
			)
		),

	
		private
	
		/** Start timeout
		  * 
		  * EXECUTE onSourceObjectTransformEnds() on timeout
		 */
		function _startTimeout =
		(
			--format "\n"; print "SourceObjectTransform_v._startTimeout()"
			--format "\n"; print "onSourceObjectTransformEnds.ms.startObjectTransformTimeout()"
			delay_timer = dotNetObject "Windows.Forms.Timer"
		
			delay_timer.Interval = delay_ms
		
			--dotNet.addEventHandler delay_timer "Tick" fireCallback
			dotNet.addEventHandler delay_timer "Tick" WHEN_TRANSFROM_CHANGES_ENDS.fireCallback
		
			delay_timer.enabled = true
		),
		
		/** Set binded objects
		 */
		function _addBindedObjects source_obj =
		(
			--format "\n"; print "SourceObjectTransform_v.setBindedObjects()"
			binded_objects = for obj in binded_objects where isValidNode obj collect obj
		
			/* GET OBJECT BIND TO EVENT */ 
			if classOf source_obj == Array then
				join binded_objects source_obj
		
			else
				append binded_objects source_obj
		),
	
		/**
		 */
		on create do
		(
			--format "\n"; print "WhenTransfromChanges.onCreate()"
			--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
			--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
		)
	
	)
	
	WhenTransfromChangesEnds_v() --return
)




