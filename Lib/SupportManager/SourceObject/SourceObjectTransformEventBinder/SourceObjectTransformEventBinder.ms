/*
	USE:
		"./../../onEvents/onSourceObjectTransform/onSourceObjectTransform.ms"
		
*/ 



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
	
	moved_objects = #(),

	transform_data = Dictionary #STRING,
	
	delay_timer,
    min_limit = [0,0,0],
    max_limit = [100,100,100],
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
		
		/* DO THIS WHEN NODES CHANGES TRANSFORM */ 
		--when transform binded_objects changes id:#onSourceObjectTransform handleAt:#redrawViews obj do
		when transform binded_objects changes id:#onSourceObjectTransform obj do
		(
			if SUPPORT_OPTIONS.keep_source_minz_z_pos then
				this._keepMinZposition(obj)

			appendIfUnique moved_objects obj
			
			if this.delay_timer == undefined then
			(
				pauseSupportTransformEvent()
				
				this._startObjectTransformTimeout()
			)
		)
	),

	/** Start timeout
	  * 
	  * EXECUTE onSourceObjectTransform() on timeout
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
	  
	 * @return Dictionary KEYS: #POS_Z, #ROTATION
	 */
	function _setTransformData source_obj =
	(
		--format "\n"; print "SourceObjectTransform_v._setTransformData()"
		--format "source_obj: %\n" source_obj
		--binded_objects[getHandleByAnim source_obj] = Dictionary #( #OBJECT, source_obj ) #( #POS_Z, source_obj.position.z ) #( #ROTATION, quatToEuler2 source_obj.rotation.controller.value )
		transform_data[this._getPointer source_obj] = Dictionary #( #POS_Z, source_obj.position.z ) #( #ROTATION, quatToEuler2 source_obj.rotation.controller.value )
	),
	
	private
	
	/** Keep min zposition
	 */
	function _keepMinZposition source_obj =
	(
		--format "\n"; print "SourceObject_v._keepMinZposition()"
		bbox	= nodeGetBoundingBox source_obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z
		
		mini_z_pos = SUPPORT_OPTIONS.base_height + ( SUPPORT_OPTIONS.layer_height * SUPPORT_OPTIONS.base_to_support_gap ) 
		
		source_obj.position.z = mini_z_pos + ( source_obj.position.z - bbox[1].z )

		transform_data[this._getPointer source_obj][#POS_Z] = source_obj.position.z
 	),

	/** Get pointer
	 */
	function _getPointer source_obj =
	(
		(getHandleByAnim source_obj) as string --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SourceObjectTransform.onCreate()"
	)
)


SOURCE_OBJECT_TRANSFORM = SourceObjectTransformEventBinder_v()


