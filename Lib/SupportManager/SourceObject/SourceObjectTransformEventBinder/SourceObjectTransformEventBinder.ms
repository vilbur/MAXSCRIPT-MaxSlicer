/*
	USE:
		"./../../onEvents/onSourceObjectTransform/onSourceObjectTransform.ms"
		
*/ 


global SOURCE_OBJECT_TRANSFORM

/** Source object transform event binder
 */
struct SourceObjectTransformEventBinder_v
(
	/* construct */
	/* required */
	/* properties */
	--delay_ms = 1000,
	delay_ms = 200,
	--delay_ms = 20,
	
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
		--format "\n"; print "SourceObjectTransform_v.bindSourceObjectTransformEvent()"
		--format "source_obj: %\n" source_obj
		
		this._setBindedObjects(source_obj)
		
		for obj in binded_objects where transform_data[this._getPointer obj] == undefined do 
			this._setTransformData(obj)
			
		deleteAllChangeHandlers id:#onSourceObjectTransform
		
		/* DO THIS WHEN NODES CHANESTRANSFORM */ 
		when transform binded_objects changes id:#onSourceObjectTransform handleAt:#redrawViews obj do
		(
			
			--for obj in binded_objects where transform_data[this._getPointer obj] == undefined do 
			--	this._setTransformData(obj)
			--if selection.min.z < 0 then
			--(
			--	selection.center.z += abs selection.min.z
			--	
			--)		
			
			if this.delay_timer == undefined then
			(
				pauseSupportTransformEvent()
				
				this._startObjectTransformTimeout()
			)
		)
	),

	/** Start timeout
	 */
	function _startObjectTransformTimeout =
	(
		--format "\n"; print "SourceObjectTransform_v._startObjectTransformTimeout()"
		--format "\n"; print "onSourceObjectTransform.ms.startObjectTransformTimeout()"
		delay_timer = dotNetObject "Windows.Forms.Timer"
	
		delay_timer.Interval = delay_ms
	
		dotNet.addEventHandler delay_timer "Tick" onSourceObjectTransform
	
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
		--format "\n"; print "SourceObjectTransform_v._setTransformData()"
		--format "obj: %\n" obj
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


SOURCE_OBJECT_TRANSFORM = SourceObjectTransformEventBinder_v()


