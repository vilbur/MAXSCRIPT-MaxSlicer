
global SOURCE_OBJECT_TRANSFORM = undefined  -- Dictionary KEYS:#OBJECT|#POS_Z|#ROTATION


/** Execute callback on timeout
 */
function onSourceObjectTransformTimeoutCallback sender evt =
(
	--format "\n"; print "onSourceObjectTransform.ms.onSourceObjectTransformTimeoutCallback()"

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
		dotNet.removeEventHandler sender "Elapsed" onSourceObjectTransformTimeoutCallback
		
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


/** Source object transform
 */
struct SourceObjectTransform_v
(
	/* construct */
	/* required */
	/* properties */
	delay_ms = 1000,
	
	binded_objects = #(),

	transform_data = Dictionary #STRING,
	
	delay_timer,
	
	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	
	/** Bind source object transform event
	 */
	function bindSourceObjectTransformEvent source_obj =
	(
		--format "\n"; print "onSourceObjectTransform.ms.bindSourceObjectTransformEvent()"
		format "\n"; print "SourceObjectTransform_v.bindSourceObjectTransformEvent()"
		format "source_obj: %\n" source_obj
		
		this._setBindedObjects(source_obj)

		deleteAllChangeHandlers id:#onSourceObjectTransform
		
		/* BIND ALL NODES TO EVENT */ 
		when transform binded_objects changes id:#onSourceObjectTransform handleAt:#redrawViews obj do
		(
			for obj in binded_objects where transform_data[this._getPointer obj] == undefined do 
				this._setTransformData(obj)
			
			if this.delay_timer == undefined then 
				this._startObjectTransformTimeout()
		)
	),

	/** Start timeout
	 */
	function _startObjectTransformTimeout =
	(
		format "\n"; print "SourceObjectTransform_v._startObjectTransformTimeout()"
		--format "\n"; print "onSourceObjectTransform.ms.startObjectTransformTimeout()"
		delay_timer = dotNetObject "Windows.Forms.Timer"
	
		delay_timer.Interval = delay_ms
	
		dotNet.addEventHandler delay_timer "Tick" onSourceObjectTransformTimeoutCallback
	
		delay_timer.enabled = true
	),
	
	/** Set binded objects
	 */
	function _setBindedObjects source_obj =
	(
		--format "\n"; print "SourceObjectTransform_v.setBindedObjects()"
		binded_objects = for obj in binded_objects where isValidNode obj collect obj
	
		/* GET OBJECT BIND TO EVENT */ 
		if classOf source_obj == Array then
			join binded_objects source_obj
	
		else
			append binded_objects source_obj
	),
	
	/** Set binded object
	 */
	function _setTransformData obj =
	(
		format "\n"; print "SourceObjectTransform_v._setTransformData()"
		format "obj: %\n" obj
		--binded_objects[getHandleByAnim obj] = Dictionary #( #OBJECT, obj ) #( #POS_Z, obj.position.z ) #( #ROTATION, quatToEuler2 obj.rotation.controller.value )
		transform_data[this._getPointer obj] = Dictionary #( #POS_Z, obj.position.z ) #( #ROTATION, quatToEuler2 obj.rotation.controller.value )
	),
	
	private
	
	/** Get pointer
	 */
	function _getPointer obj =
	(
		(getHandleByAnim obj) as string --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObjectTransform.onCreate()"
	)
)


SOURCE_OBJECT_TRANSFORM = SourceObjectTransform_v()


