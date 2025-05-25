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
			/* KEEP Z POSITION */ 
			if SUPPORT_OPTIONS.keep_source_minz_z_pos then
				this.keepMinZposition(obj)
			
			/* MARK OBJECT AS TRANSFOMRED */ 
			appendIfUnique moved_objects obj
			
			/* START TIMEOUT */ 
			if this.delay_timer == undefined then
			(
				pauseSupportTransformEvent() -- pause callback for suports while source object is transormed
				
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
		transform_data[this._getPointer source_obj] = Dictionary #( #POS_Z, source_obj.position.z ) #( #ROTATION, quatToEuler2 source_obj.rotation.controller.value )
	),
	
	/** Lock min z position of source object on transform
	  * 
	  * @param boolean use_current_z_pos
	 */
	function keepMinZposition obj use_current_z_pos:false =
	(
		 --format "\n"; print "SourceObjectTransform_v.keepMinZposition()"
		
		/* In MaxScript, due to floating-point precision limitations
		*   setting an object's position with very small float values (e.g. less than 0.009) can result in truncation or rounding issues — especially when these values are smaller than the UI display precision or fall below the transformation matrix threshold.
		*/ 
		function setObjectPosition node pos =
		(
			t_matrix = node.transform
			
			t_matrix.row4.z = pos
			
			node.transform = t_matrix -- return
		)
		
		bbox_min_z = ( nodeGetBoundingBox obj ( Matrix3 1))[1].z

        /* GET Z POSITION */ 		
		z_pos_lock = if use_current_z_pos or (z_pos_lock_saved = getUserPropVal obj "Z_POS_LOCK") == undefined then
			ceil (bbox_min_z / SUPPORT_OPTIONS.layer_height) -- get miz z pos of bounging box

		else
			z_pos_lock_saved -- get value from user props

			
		/* KEEP ABOVE GROUND */ 
		if z_pos_lock < 0 then z_pos_lock = 0
		
		/* USE LAYER HEIGHT TO GET MIN Z POSITION */ 
		min_z_pos = ( SUPPORT_OPTIONS.layer_height * z_pos_lock )

		/* GET POSITION OF PIVOT */ 
		new_pos = obj.position.z - bbox_min_z + min_z_pos
		
		/* MOVE OBJECT */ 
		setObjectPosition obj new_pos
		
		/* SAVE Z POS */ 
		setUserPropVal obj "Z_POS_LOCK" z_pos_lock
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


