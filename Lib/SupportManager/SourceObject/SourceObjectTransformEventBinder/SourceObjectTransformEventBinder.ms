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

	transform_data = Dictionary #STRING, -- KEY: "obj pointer" VALUE: Dictionary.keys #(#POS_Z, #ROTATION)
	
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
		--format "\n"; print "SourceObjectTransform_v.bindSourceObjectTransformEvent()"
		--format "source_obj: %\n" source_obj
		
		this._setBindedObjects(source_obj)
		
	
		for obj in binded_objects where transform_data[this._getPointer obj] == undefined do 
			this.setTransformData(obj)	
			
		deleteAllChangeHandlers id:#onSourceObjectTransform
		
		/* DO THIS WHEN NODES CHANGES TRANSFORM */ 
		--when transform binded_objects changes id:#onSourceObjectTransform handleAt:#redrawViews obj do
		when transform binded_objects changes id:#onSourceObjectTransform obj do
		(
			--format "WHEN TRANSFORM BINDED_OBJECTS CHANGES\n"
			--format "OBJ: %\n" obj
			--format "keep_source_minz_z_pos: %\n" SUPPORT_OPTIONS.keep_source_minz_z_pos
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

	/** Set binded object
	  
	 * @return Dictionary KEYS: #POS_Z, #ROTATION
	 */
	function setTransformData source_obj =
	(
		-- format "\n"; print "SourceObjectTransform_v.setTransformData()"
		--format "source_obj: %\n" source_obj
		--binded_objects[getHandleByAnim source_obj] = Dictionary #( #OBJECT, source_obj ) #( #POS_Z, source_obj.position.z ) #( #ROTATION, quatToEuler2 source_obj.rotation.controller.value )
		transform_data[this._getPointer source_obj] = Dictionary #( #POS_Z, source_obj.position.z ) #( #ROTATION, quatToEuler2 source_obj.rotation.controller.value )
	),
	
	/** Keep min zposition
	 */
	function _keepMinZposition obj use_current_pos:false =
	(
		-- format "\n"; print "SourceObjectTransform_v._keepMinZposition()"
		-- format "use_current_pos: %\n" use_current_pos
		/* In MaxScript, due to floating-point precision limitations, setting an object's position with very small float values (e.g. less than 0.009) can result in truncation or rounding issues — especially when these values are smaller than the UI display precision or fall below the transformation matrix threshold.
		*/ 
		function setObjectPosition node pos =
		(
			t_matrix = node.transform
			
			t_matrix.row4.z = pos
			
			node.transform = t_matrix -- return
		)

		z_pos_lock_saved = getUserPropVal obj "Z_POS_LOCK" 
		
		bbox = nodeGetBoundingBox obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z
		
		bbox_min = bbox[1].z

		z_pos_lock = if use_current_pos or z_pos_lock_saved == undefined then ceil (bbox_min / SUPPORT_OPTIONS.layer_height) else z_pos_lock_saved
		-- format "z_pos_lock: %\n" z_pos_lock
		
		if z_pos_lock < 0 then
			z_pos_lock = 0
		
		min_z_pos = ( SUPPORT_OPTIONS.layer_height * z_pos_lock )

		new_pos = obj.position.z - bbox_min + min_z_pos
		
		setUserPropVal obj "Z_POS_LOCK" z_pos_lock
		
		setObjectPosition obj new_pos
 	),
	
	private

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


