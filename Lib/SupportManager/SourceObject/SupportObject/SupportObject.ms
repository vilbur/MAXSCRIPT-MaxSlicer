filein( getFilenamePath(getSourceFileName()) + "/SupportRaft/SupportRaft.ms" )	--"./SupportRaft/SupportRaft.ms"
filein( getFilenamePath(getSourceFileName()) + "/SupportLeg/SupportLeg.ms" )	--"./SupportLeg/SupportLeg.ms"
filein( getFilenamePath(getSourceFileName()) + "/SupportFoot/SupportFoot.ms" )	--"./SupportFoot/SupportFoot.ms"

/** Support object
  
  USES: global SUPPORT_OPTIONS --"./../../../SupportOptions/SupportOptions.ms"
  
  
 */
struct SupportObject_v
(
	/* construct */
	source_obj,

	/* required on load from scene */
	obj_type = #SUPPORT, -- #SUPPORT|#RAFT
	
	support_obj,

	sync_key,
	support_key, -- pointer of support`s node -- used for both types: #SUPPORT and #RAFT
	
	is_updated_now = false, -- on\off update mode of raft part
	
	/* generate properties */
	points = #(),

	hit_raft,
	hit_leg,
	
	/* dependency */
	SupportRaft	= SupportRaft_v(this),
	SupportLeg	= SupportLeg_v (this),
	SupportFoot	= SupportFoot_v(this),
	
	/* SUPPORT PROPERTIES */
	changed_props = Dictionary(),

	direction,
	pin_vector,
	raft_vector,
	raft_mode,

	
	bar_width,
	raft_length,
	base_height,
	base_width,
	top_width,
	
	/* minimal dimensions */
	min_lenght_by_angle,
	min_raft_length,
	
	min_foot_pos,   -- minimal z position of leg knot where foot can be created, value is varied by angle of support
	min_leg_pos,     -- min length of raft part to avoid sweep artifact on leg knot
	min_support_pos,
	
	/* properties of existing supports */ 
	foot_enabled = false, -- false is defaut for raft type
	foot_exists  = false,
	is_on_ground = false,
	
	/* static */ 
	raft_vector_angle_range = 80,
	
	this_props  = #( #DIRECTION, #PIN_VECTOR, #RAFT_VECTOR, #FOOT_EXISTS, #IS_ON_GROUND ),	-- props of this saved to node userProps
	--this_props  = #( #DIRECTION, #RAFT_VECTOR, #NORMAL_WORLD, #FOOT_EXISTS, #IS_ON_GROUND ),	-- props of this saved to node userProps
	--this_props  = #( #DIRECTION, #NORMAL_WORLD, #FOOT_EXISTS, #IS_ON_GROUND ),	-- props of this saved to node userProps
	option_keys = #( #BAR_WIDTH, #BASE_HEIGHT, #BASE_WIDTH, #RAFT_LENGTH, #TOP_WIDTH, #FOOT_ENABLED, #RAFT_MODE ),	-- props of this saved to node userProps WHICH ARE LOADED FROM OTPION when generate
	
	
	private

	spline_1 = 1, -- each support line has ony 1 spline
	
	dilatation  = 0.05, 

	public

	/** Generate support
	  * 
	  * @param point3	first_knot_pos	top position of support
	  * @param #DOWN|point3	direction	raft_vector of direction from 1st to 2nd point
	  * @param color	wirecolor	of support object
	 */
	function generateSupport vertex_index first_knot_pos: direction:undefined pin_vector:undefined wirecolor: =
	(
		  --format "\n===========================================================\n"
		  --format "\n"; print "SupportObject_v.generateSupport()"
		  --format "wirecolor: %\n" wirecolor
		  --format "direction: %\n" direction
		-- format "vertex_index: %\n" vertex_index
		--format "EXPORT_SIZE: %\n" EXPORT_SIZE
		
		function isLegPointAboveMinimalLimit leg_point = ( leg_point as string ) as float >= ( min_leg_pos as string ) as float
		
		
		/*------------------------------------------------------------------------------
			SET PARAMS
		--------------------------------------------------------------------------------*/
		if direction != undefined then  this.direction = direction
		
		--if raft_vector != undefined then  this.raft_vector = raft_vector
		
		if pin_vector != undefined then  this.pin_vector = this.raft_vector = pin_vector
		
		--this.pin_vector = this.raft_vector
		  --format "this.DIRECTION: %\n" this.direction

		this.points = #( first_knot_pos )

		
		--format "this._isFirstPointAboveGround: %\n" (this._isFirstPointAboveGround())
		
		/* TEST SUPPORT Z POSITION */ 
		if not this._isFirstPointAboveGround() then
			return false
			
		/*------------------------------------------------------------------------------
			GENERATE
		--------------------------------------------------------------------------------*/

		this._setSupportObject(wirecolor)
		
		this._saveUserPropsToSupport(vertex_index)
		
		this._fillThisWithOptionValues()
		--format "BAR_WIDTH: %\n" bar_width
		
		this._setMinLimints (direction)
		
		/*------------------------------------------------------------------------------
			SET SUPPORT LINE POINTS
		--------------------------------------------------------------------------------*/
		
		--SupportPin.createPin()
		--this.points[2] = this._getPinPointPosition(points[1])

		this._setSupportLinePoints update_or_generate:#GENERATE
		--format "POINTS.count: %\n" points.count
		
		/*------------------------------------------------------------------------------
			CREATE SUPPORT
		--------------------------------------------------------------------------------*/

		this._drawLine()

		this._setMaterialsToLineSegments()
		
		this._setName(vertex_index)
		
		this.setPivotToPoint(3)
		
		--this._alignPivotToRaft()

		this._isOnGround()
		
		this._saveOptionsToUserProps()

		this._lockRotationAndScaleTransforms()
		
		SUPPORT_MANAGER.updateShapeAdd (support_obj)

		true --return
	),
	
	/** 	UPDATE SUPPORTS
	  * 
	  * 	first_knot_pos: undefined	-- GET POS FROM LINE,	WHEN SOURCE OBJECT HAS BEEN ROTATED
	  * 	first_knot_pos: Point3	-- GET POS FROM SOURCE OBJECT,	WHEN SUPPORT ITSELF HAS BEEN MOVED, to keep support sticked on source object
	  * 
	  * 
	  *	UPDATE RAFT IF:
	  *    • If source object ROTATED and support direction is #DOWN
	  *    • If Support was transformed
	  * 
	 */
	function updateSupport first_knot_pos:undefined update_raft:true update_leg:false direction:undefined pin_vector:undefined =
	(
		 --format "\n----------------------------------------------\n"
		 --format "first_knot_pos: %\n" first_knot_pos
		--format "\n"; print ("SupportObject_v.updateSupport(\""+support_obj.name+"\")")
		
		/*------------------------------------------------------------------------------
			SANITIZE PARAMETERS
		--------------------------------------------------------------------------------*/
		if pin_vector != undefined then
			this.pin_vector = pin_vector

		/* GET 1st knot POSITION FROM LINE */ 
		if first_knot_pos == undefined then
			first_knot_pos = getKnotPoint support_obj spline_1 1
			
		--second_knot_pos = getKnotPoint support_obj spline_1 2

		if direction != undefined then this.direction = direction

		/*------------------------------------------------------------------------------
			PREPARE UPDATE
		----------------------------------------------------------------------------------*/

		points = this._getPointsPositions(first_knot_pos)
		
		this.raft_vector =  normalize (points[3] - points[2])
		
		this._setNormalLenght update_raft:update_raft

		
		this._keepVectorDown()

		if not this._isFirstPointAboveGround() then
			return false

		if not this.vectorIsInRangeCone() then
			this.raft_vector = this._findVectorByAngle this.raft_vector ( raft_vector_angle_range  )
			
			
		this._disbaleBoxMode()

		--this._checkChangedProps raft_vector_current:this.raft_vector -- MUST BE EXECUTED BEFORE this._setRaftVector() for recognizing of chaged value

		this._setMinLimints(direction) force_set:(update_raft == true or min_raft_length == undefined)
		
		/*------------------------------------------------------------------------------
			UPDATE SUPPORT LINE POINTS
		--------------------------------------------------------------------------------*/
		
		this._setSupportLinePoints()

		/*------------------------------------------------------------------------------
			POST UPDATE
		--------------------------------------------------------------------------------*/
		this._postUpdate()
		
		--this._alignPivotToRaft() -- THIS MAKES SUPPORT "JIGGLE AND JUMPING"
		this.setPivotToPoint(3)

		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),
	
	/** Convert SUPPORT to RAFT and vice versa
	  *
	  * @param #SUPPORT|#RAFT to_type type of obejct to covert
	  *
	 */
	function convertType to_type =
	(
		-- format "\n"; print "SupportObject_v.convert()"
		-- format "TO_TYPE: %\n" to_type
	
		function _getKey type = ( toUpper (type as string ) + "_KEY")
		
		/* SET PROPERTIES */ 
		this.obj_type = to_type
		
		this.hit_raft 	= undefined
		this.hit_leg	= undefined
		--this.is_on_ground	= false
		
		
		/* GET TYPE OF ORIGIN OBJECT */ 
		from_type =  if to_type == #RAFT then #SUPPORT else #RAFT
		
		
		/* UPDATE OBJECT PROPERTY DATA */ 
		deleteUserProp support_obj ( _getKey from_type  )
		
		setUserPropVal support_obj ( _getKey to_type  ) support_key
		
		
		/* IF TYPE IS CONVERTED */ 
		------this._getPositionsFromLineOnConvert()
		
		
		/* UPDATE SUPPORT */ 
		--this.updateSupport()
		--this.updateSupport first_knot_pos:(undefined)
		this.updateSupport update_raft:( to_type == #RAFT )
		
		/* POST UPDATE */ 
		this.setPivotToPoint(3)
		
		this._alignPivotToRaft()
	),

	/** Rebulid support
	 */
	function rebulidSupport pin_vector:undefined =
	(
		-- format "\n"; print "SupportObject_v.rebulidSupport()"
		-- format "pin_vector: %\n" pin_vector
		index = getUserPropVal support_obj "INDEX"
		
		if pin_vector == undefined  then 
			pin_vector = getUserPropVal support_obj "PIN_VECTOR"
		  -- format "pin_vector: %\n" pin_vector

		--wirecolor = getUserPropVal support_obj "WIRECOLOR"
		support_obj.boxmode = false

		--if numSplines support_obj == 0 then
			--addNewSpline support_obj

		--first_knot_pos = if classOf support_obj != Point then getKnotPoint support_obj spline_1 1 else support_obj.position
		--first_knot_pos = getKnotPoint support_obj spline_1 1
		--first_knot_pos = support_obj.pivot
		
		--this.generateSupport index first_knot_pos:(getKnotPoint support_obj spline_1 1) direction:direction pin_vector:pin_vector  --wirecolor:support_obj.wirecolor
		this.generateSupport index first_knot_pos:(getKnotPoint support_obj spline_1 1) direction:direction pin_vector:pin_vector raft_vector:raft_vector  --wirecolor:support_obj.wirecolor
		
		--this.setPivotToPoint(3)
	),
	
	/** Update support height
	 */
	function updateSupportHeight  =
	(
		--format "\n"; print "SupportObject_v.updateSupportHeight()"
		 -- format "support_obj:  %\n" support_obj.name
		function isTallEnough = support_obj.pos.z > min_foot_pos
		
		/** Set knot zposition
		 */
		function setKnotZposition knot z_pos =
		(
			-- format "\n"; print "SupportObject_v.setKnotZposition z_pos()"
			knot_pos = getKnotPoint support_obj spline_1 knot

			knot_pos.z = z_pos

			setKnotPoint support_obj spline_1 knot knot_pos
		)
		
		
		--set_min_limits = update_raft == true or min_raft_length == undefined
		
		if  min_raft_length == undefined then
			this._setMinLimints(direction) force_set:true
		
		if is_on_ground then
		(
			first_knot_pos = getKnotPoint support_obj spline_1 1
			
			points = this._getPointsPositions(first_knot_pos)
			
			if not this._isFirstPointAboveGround() then
				return false
			
			points_distance = distance points[2] points[3]
			
			/*------------------------------------------------------------------------------------------
				SET KNOTS TO GROUND IF SUPPORT IS TALL EANOUGH, NOT SHORTEN AND FOOT EXISTS
			--------------------------------------------------------------------------------------------*/

			if isTallEnough() and not points_distance < raft_length and (( foot_enabled and foot_exists ) or not foot_enabled ) then
			(
				num_knots = numKnots support_obj spline_1
				
				setKnotZposition (num_knots) 0
				
				if foot_exists then
					setKnotZposition (num_knots - 1) base_height
			)
			
			/*------------------------------------------------------------------------------------------
				UPDATE RAFT, LEG AND FOOT
			--------------------------------------------------------------------------------------------*/
			
			else
			(
				this._setSupportLinePoints()
			
				this._disbaleBoxMode()
				
				this._postUpdate()
			)
			
			SUPPORT_MANAGER.updateShapeAdd (support_obj)
		)
	),


	/** TEST COLLISION WITH SOURCE OBJECT
	 */
	function intersectRaySourceObject pos dir =
	(
		  --format "\n"; print "SupportObject_v.intersectRaySourceObject()"
		/* Shift origin point perpendicular to a vector and project to plane
			
			DEV EXAMPLE: --"./_Dev/shiftPointPerpendicularOnPlane_dev.ms"
		*/
		function shiftPointPerpendicularOnPlane origin_point direction_vector shift_distance plane =
		(
			-- Project raft vector to selected plane
			case plane of
			(
				#XY: projected_vector = normalize [direction_vector.x, direction_vector.y, 0]
				#XZ: projected_vector = normalize [direction_vector.x, 0, direction_vector.z]
				#YZ: projected_vector = normalize [0, direction_vector.y, direction_vector.z]
				default: (format "Unsupported plane: %\n" plane; projected_vector = [1,0,0])
			)
			
			-- Calculate perpendicular vector within the plane
			case plane of
			(
				#XY: perp_vector = normalize [-projected_vector.y, projected_vector.x, 0]
				#XZ: perp_vector = normalize [-projected_vector.z, 0, projected_vector.x]
				#YZ: perp_vector = normalize [0, -projected_vector.z, projected_vector.y]
			)
			
			-- Apply shift
			origin_point + (perp_vector * shift_distance) -- return
		)
	    
	
		local _ray
		
		local hit

		local hit_distance

		local pos_shifted
		
		local closest_hit 
		
		hits = #()
		
		closest_dist = 1e9
		
		planes = #( #XY, #XY, #XZ, #XZ )
		
		half_of_bar_width = this.bar_width / 2
		
		ray_pos = pos + (0.1 * dir)
		
		_ray = ( Ray ray_pos dir )

		/*------------------------------------------------------------------------------
			
			GET VISIBLE NOT FROZEN OBJECTS WHICH ARE NOT SUPPORTS FOR TEST HIST
			
		--------------------------------------------------------------------------------*/
		
		objs_check_hits = for obj in geometry where superClassOf obj == GeometryClass and not ( obj.isHidden or obj.isFrozen ) and getUserProp obj "SYNC_KEY" == undefined collect obj
		
		--format "objs_check_hits: %\n" objs_check_hits
		for source_obj in objs_check_hits do
		(
			hit = intersectRay source_obj _ray
			
			 --format "HIT A: %\n" hit
			/*------------------------------------------------------------------------------
				TRY HIT ON CENTER OF SUPPORT
			------------------------------------------------------------------------------*/
			if (hit = intersectRay source_obj _ray) == undefined then
			(
				
				/*------------------------------------------------------------------------------
					TRY HITS ON BORDER OF SUPPORT
				--------------------------------------------------------------------------------*/
				for i = 1 to 4 while hit == undefined do 
				(
					shift_distance = if mod i 2 == 0 then half_of_bar_width * -1 else half_of_bar_width
					
					pos_shifted = shiftPointPerpendicularOnPlane ray_pos dir shift_distance planes[i]
					
					_ray = ( Ray pos_shifted dir )
					
					/* GET DISTANCE TO HIT */ 
					if ( hit = intersectRay source_obj _ray ) != undefined then 
						hit_distance = distance ray_pos hit.pos
					--format "HIT B: %\n" hit
				)
			)
			else /* GET DISTANCE TO HIT IN CENTER */ 
				hit_distance = distance ray_pos hit.pos
			
			--format "HIT C: %\n" hit
			
			/* GET HIT POSITION DIR VECTOR */ 
			--if hit != undefined then
				--hit.pos = pos + ( hit_distance * dir )
				
			if hit != undefined then 
				append hits #( _ray, hit )
 		)
		
		/* GET CLOSLOSEST HIT */
		if hits.count > 1 then
			for ray_hit in hits do
			(
				dist = distance ray_hit[1].pos ray_hit[2].pos
				
				if dist < closest_dist then
				(
					closest_dist = dist
					closest_hit = ray_hit[2]
				)			
			)
			
		else if hits.count == 1 then
			closest_hit = hits[1][2]


		closest_hit --return
	),

	/** Is raft
	 */
	function isRaft =
	(
		 -- format "\n"; print "SupportObject_v.isRaft()"
		 
		if isValidNode support_obj then
			getUserPropVal support_obj "RAFT_KEY" != undefined
			
		else
		(
			-- format "\n!!!!!!!!!!!!!!!!!!!!!!!!! isValidNode \n"
			
			false --return
		)
	),

	/** Is vector pointing down
	 */
	function isVectorPointingDown =
	(
		-- format "\n"; print "SupportObject_v.isVectorPointingDown()"
		fn round p3 =
		(
			local tempArr = #(p3.x,p3.y,p3.z)
			local mult = 10.00^(3 as float)
			local rp3Arr = for c in tempArr collect ((floor ((c * mult)+0.5)) / mult)
			point3 rp3Arr[1] rp3Arr[2] rp3Arr[3]
		)
	
		knot_1 = round (getKnotPoint support_obj spline_1 1)
		knot_2 = round (getKnotPoint support_obj spline_1 2)
		
		knot_1.x == knot_2.x and knot_1.y == knot_2.y and knot_1.z != knot_2.z
	),

	
	/** Disable support by showing it as box
	 */
	function enableBoxMode =
	(
		  -- format "\n"; print "SourceObject_v.enableBoxMode()"
		support_obj.boxmode = true
	),
	
	/** Is box mode
	 */
	function isBoxMode =
	(
		--format "\n"; print "SupportObject_v.isBoxMode()"
		support_obj.boxmode == true
	),
		
	/** Set pivot to position
	  *
	  *	IMPORTANT PREVENT CRASH:
	  *		NEVER RUN ON UPDATE: this.setPivotToPoint(3) -- must be after updateShape
	  *
	 */
	function setPivotToPoint index =
	(
		 --format "\n"; print "SupportObject_v.setPivotToPoint()"
		--support_obj.pivot = getKnotPoint support_obj spline_1 2
		support_obj.pivot = points[index]
	),
	
	private

	/*==============================================================================
	
			SET SUPPORT LINE POINTS
	
	================================================================================*/
	/**
        point vert	= 1
        point pin	= 2
        point raft	= 3
        point leg	= 4
        point foot	= 5
	  
	  */
	function _setSupportLinePoints update_or_generate:#UPDATE =
 	(
		--format "\n"; print "SupportObject_v._setSupportLinePoints()"
		--format "update_or_generate: %\n" update_or_generate
		-- format "obj_type: %\n" obj_type
		this.points[2] = this._getPinPointPosition(points[1])
		--format "points[2].z: %\n" points[2].z
		--format "points.count: %\n" points.count

		--if points[2].z > 0 then
		if points[this.points.count].z > 0 then
		(
			/* CREATE RAFT */ 
			SupportRaft.createRaft update_or_generate:update_or_generate --"./SupportRaft/SupportRaft.ms"
				--format "SupportRaft.hit_raft: %\n" SupportRaft.hit_raft
			
			/* CREATE LEG */ 
			if SupportRaft.hit_raft == undefined then
			(
				foot_exists = foot_enabled and SupportRaft.foot_space_exists
				
				/* CREATE LEG */ 
				SupportLeg.createLeg( if foot_exists then base_height else 0 ) --"./SupportLeg/SupportLeg.ms"
				--format "SupportLeg.hit_leg: %\n" SupportLeg.hit_leg
				/* CREATE FOOT */ 
				if SupportLeg.hit_leg == undefined and foot_exists then 
					SupportFoot.createFoot() --"./SupportFoot/SupportFoot.ms"
			)
		)
		else
		(
			this._alignKnotToPreviousKnot index:2 pos_z:0
			
			for i = points.count to 3 by -1 do
				deleteItem points i
		)
		
		
		
		
		this._setFootExists()
	),
	
	/** Align next knot bellow
	 */
	function _alignKnotToPreviousKnot index: pos_z: =
	(
		--format "\n"; print "SupportRaftUpdater_v._alignKnotToPreviousKnot()"
		pos = copy this.points[index - 1]
		
		pos.z = pos_z
		
		this.points[index] = pos
	),
	
	/** Get points positions
	 */
	function _getPointsPositions first_knot_pos =
	(
		--format "\n"; print "SupportObject_v._getPointsPositions()"
		second_knot_pos = this._getPinPointPosition(first_knot_pos)

		#(first_knot_pos, second_knot_pos, support_obj.pos)
	),
	
	/** Get pin point position
	 */
	function _getPinPointPosition first_knot_pos =
	(
		--format "\n"; print "SupportObject_v._getPinPointPosition()"
		
		first_knot_pos + ( min_raft_length * pin_vector )
	),
	
	/** Methods needs to be done after this._setSupportLinePoints()

		IMPORTANT PREVENT CRASH:
			NEVER RUN ON UPDATE: this.setPivotToPoint(3) -- must be after updateShape
			
		THIS ALSO ALOW TO PIVOT BE FREE WHEN: SupportRaft.hit_raft == true or SupportLeg.hit_leg == true
	 */
	function _postUpdate =
	(
		--format "\n"; print "SupportObject_v._postUpdate()"
		this._updateCountOfKnots()
		
		this._updateKnotsPositionByPoints()
		
		this._saveFirstKnotPos()

		this._isOnGround()
		
		this._setMaterialsToLineSegments()
	),
	
	--/** Get knots postions from existing line
	--  * 
	--  * 1) SUPPORT > RAFT 
	--  * 
	--  *		A) Get 2nd point if support is on ground
	--  * 		B) Get LAST knot if support is NOT on ground
	--  * 
	--  * 
	--  *  2) RAFT > SUPPORT
	--  * 
	--  * 	 	Get LAST knot of raft
	-- */
	--function _getPositionsFromLineOnConvert =
	--(
	--	--format "\n"; print "SupportObject_v._getPositionsFromLineOnConvert()"
	--	
	--	second_point = if obj_type == #RAFT and is_on_ground then 2 else numKnots support_obj spline_1
	--	
	--	
	--	points_positions = #(
	--		getKnotPoint support_obj spline_1 1,
	--		getKnotPoint support_obj spline_1 second_point
	--	)
	--),
	
	/** AVOID SUPORT UNDER GROUND
	 */
	--function _isFirstPointAboveGround first_knot_pos raft_vector =
	function _isFirstPointAboveGround =
	(
		--format "\n"; print "SupportObject_v._isFirstPointAboveGround()" 
		points[1].z > 0.0 
	),
	
	/**  ALLOW TO MOVE SUPPORT IN ONLY GIVEN ANGLE
	  *  AVOID TO FLIP DIR VECTOR TO BACKSIDE
	  *		
	  * 1)Create future dir vetor from OLD FISRT POSITION and new SUPPORT POSITION
	  *		  
	  * 2) Test if new vector firs to range of world normal
	 */
	function vectorIsInRangeCone =
	(
		-- format "\n"; print "SupportObject_v.vectorIsInRangeCone()"
		 
		if distance pin_vector this.raft_vector > 0.001 then
		(
			dot_product = dot (normalize pin_vector) (normalize this.raft_vector)
			
			theAngle = acos(dot_product)
			
			theAngle < raft_vector_angle_range --return
		)
		else
			true --return true if vectors are equal
	),
	
	/* Finds a vector at a given angle in the plane defined by two vectors.
		
		vector1 and vector2 define the plane.
		angle is in degrees.
	*/
	function _findVectorByAngle vector2 _angle =
	(
		  --format "\n"; print "SupportObject_v._findVectorByAngle()"
		dir_x = pin_vector -- Create orthonormal basis in the plane

		/*  Remove projection of vector2 on dir_x to get perpendicular direction */ 
		proj = (dot vector2 dir_x) * dir_x
		dir_y = normalize (vector2 - proj)

		/* Compute vector using _angle in plane */ 
		(cos _angle) * dir_x + (sin _angle) * dir_y
	),

	/** Create new support object or get existing and delete spline subobject
	 */
	function _setSupportObject wirecolor =
	(
		-- format "\n"; print "SupportObject_v._getSupportNode()"
		
		/* CREATE NEW OBJECT */ 
		if support_obj == undefined then
		(
			if wirecolor == undefined then 
				wirecolor = ( color ( random 100 255) ( random 100 255) ( random 100 255))
			
			
			support_obj = SplineShape wirecolor:wirecolor
		
			source_obj.layer.addNode support_obj
		
			support_key = (getHandleByAnim support_obj) as string
		)
		else /* USE OLD OBEJCT - RESET SPLINE */ 
			deleteSpline support_obj spline_1
				
		--support_obj.wirecolor = wirecolor
	),
	

	/** Set normal lenght
	  * 
	  * 1) Get normal length from options if new support is created
	  * 2) Use current length if support is updated
	  * 3) Use saved length if support is updated BUT NORMAL LENGTH IS LOCKED
	  * 
	 */
	function _setNormalLenght update_raft:false =
	(
		-- format "\n"; print "SupportObject_v._setNormalLenght()"
		
		this.raft_length = if update_raft and not SUPPORT_OPTIONS.lock_raft_length then
			 distance points[2] points[3]
		else
			getUserPropVal support_obj "RAFT_LENGTH"
	),
	
	/** SET USER DATA TO SUPPORT OBJECT
	 */
	function _saveUserPropsToSupport vert =
	(
		-- format "\n"; print "SupportObject_v._saveUserPropsToSupport()"
		--support_obj = SupportObject.support_obj
		
		--support_key_prop = toUpper (SupportObject.obj_type as string ) + "_KEY"
		support_or_raft = if obj_type == #SUPPORT then "SUPPORT_KEY" else "RAFT_KEY"
		--support_key_val  = (getHandleByAnim support_obj) as string
		--setUserPropVal support_obj "WIRECOLOR" SupportObject.wirecolor
	
		setUserPropVal support_obj "SYNC_KEY" sync_key
		
		setUserPropVal support_obj support_or_raft support_key
		
		setUserPropVal support_obj "INDEX" vert
		
		setUserPropVal support_obj "EXPORT_SIZE" export_size
	 ),

	/** Fill props of this with data from options
	  * 
	  * Save props to objects user props
	 */
	function _fillThisWithOptionValues =
	(
		 -- format "\n"; print "SupportObject_v._fillThisWithOptionValues()"

		for prop_key in option_keys do
			--setProperty this prop_key ( SUPPORT_OPTIONS.getModVal prop_key )
			setProperty this prop_key ( SUPPORT_OPTIONS.getProp prop_key )
	),
	
	/** Save user props to node
	 */
	function _saveOptionsToUserProps =
	(
		 --format "\n"; print "SupportObject_v._saveOptionsToUserProps()"
		for prop_key in this_props + option_keys do
		(
			key = toUpper ( prop_key as string )
			val = getProperty this prop_key

			if val != undefined and val != unsupplied then 
				setUserPropVal support_obj key val
		)

        --setUserPropVal support_obj "RAFT_VECTOR" raft_vector
	),
	
	/** Load user props from node
	 */
	function _loadUserPropsFromNode =
	(
		-- format "\n"; print "SupportObject_v._loadUserPropsFromNode()"
		for prop_key in this_props +option_keys do
			setProperty this prop_key ( getUserPropVal support_obj ( toUpper ( prop_key as string )) )
	),

	/** Minimal values depedns on isze and direction of support
	  * 
	  * 
	  * 
	 */
	function _checkChangedProps raft_vector_current:undefined =
	(
		-- format "\n"; print "SupportObject_v._checkChangedProps()"

		/** Get current values
		 */
		function getCurrentValues raft_vector_current =
		(
			-- format "\n"; print "SupportObject_v.getCurrentValues()"
			--bar_width_current = support_obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius * 2
			this.changed_props = Dictionary()
			
			changed_props[#RAFT_VECTOR]   = raft_vector_current
			
			changed_props[#BAR_WIDTH]   = getUserPropVal support_obj "BAR_WIDTH"
			
			changed_props[#TOP_WIDTH]   = getUserPropVal support_obj "TOP_WIDTH"
		
			changed_props[#BASE_HEIGHT] = getUserPropVal support_obj "BASE_HEIGHT"
		)
		
		/** Test if values changed
		 */
		--function compareValuesWithPropertisOfThis changed_props =
		function compareValuesWithPropertisOfThis =
		(
			-- format "\n"; print "SupportObject_v.compareValuesWithPropertisOfThis()"
			/** Value changed
			 */
			function valueChanged this_val current_val =
			(
				--format "\n"; print "SupportObject_v.valueChanged()"
				if classOf this_val == point3 then
					distance this_val current_val > 0.001  --return
					
				else
					this_val as string != current_val as string
			)
			
			/* REMOVE UNCHANGED VALUES FROM DICTIONARY */ 
			for prop in changed_props.keys do
				if not valueChanged ( getProperty this prop ) changed_props[prop] then
					RemoveDictValue changed_props prop 
			
			 --format "CHANGED_PROPS: %\n" this.changed_props.keys
		)
		
		/** UPDATE PROPERTIES OF:
		  *
		  *  	1) this
		  *  	2) node userProps
		 */
		function syncProperties =
		(
			--format "\n"; print "SupportObject_v.syncProperties()"
			--format "CHANGED_PROPS: %\n" changed_props
			for prop in changed_props.keys do
			(
				/* UPDATE THIS */ 
				setProperty this prop changed_props[prop]
				
				/* UPDATE USER PROPERTIES */ 
				setUserPropVal support_obj ( toUpper ( prop as string ) ) changed_props[prop]
			)
		)
		
		getCurrentValues( raft_vector_current )
		
		compareValuesWithPropertisOfThis()
		
		syncProperties()
	),
	
	/** Set minimal foot pos
	  
		TUNE MINIMAL FOOT HEIGHT BASED ON ANGLE OF SUPPORT -- to avoid corner artefact on sweep modifier
		
		support - 90°  > remove 90% of bar with
		support - 135° > remove 45% of bar with
		support - 180° > remove 0%  of bar with
	 */
	function _setMinLimints direction force_set:true =
	(
		 --format "\n"; print "SupportObject_v._setMinLimints()"
		-- format "bar_width: %\n" bar_width
		-- format "top_width: %\n" top_width

		/*  roundFloat 123.456 -2 >>> 100.0
			roundFloat 123.456  0 >>> 123.0
			roundFloat 123.456  2 >>> 123.46
		*/
		fn roundFloat val decimal_palces = ( local mult = 10.0 ^ decimal_palces; (floor ((val * mult) + 0.5)) / mult )
		
		/* ADJUST min raft length for adding more\less space for chamfer
		   
            space_for_chamfer = 0.25 -- PRODUCE VERTICAL SUPPORT  -- chamfer is deformed
            space_for_chamfer = 0.5  -- PRODUCE BEST RESULT		  -- chamfer is correct and raft is short as possible
            space_for_chamfer = 1    -- PRODUCE LONG RAFT		  -- raft has additional length 
			
		*/ 
		space_for_chamfer = 0.25

		
		update_minimal_lenght  = force_set or changed_props[#PIN_VECTOR]  != undefined or changed_props[#BAR_WIDTH] != undefined 
        update_min_raft_length = force_set or changed_props[#TOP_WIDTH]   != undefined or update_minimal_lenght
        update_min_foot_pos    = force_set or changed_props[#BASE_HEIGHT] != undefined or update_minimal_lenght

        min_length_for_chamfer = ( bar_width - top_width ) * space_for_chamfer
		
		/* MINIMAL SIZE OF RAFT depends on with of sweep modifier and angle of line corners */
		--if update_minimal_lenght then
			min_lenght_by_angle = if this.pin_vector.z == -1 then dilatation else this._getMinLenghtByAngle ( this.pin_vector )

		
		/* MINIMAL LENGTH OF SUPPORT to avoid artifacts of sweep modifier */
		--if update_min_raft_length then
			--min_raft_length = min_lenght_by_angle + min_length_for_chamfer -- + dilatation -- chamfer is removing length of raft also
			min_raft_length = min_lenght_by_angle + min_length_for_chamfer -- + dilatation -- chamfer is removing length of raft also
			
		min_raft_length = roundFloat min_raft_length 2

		-- format "min_raft_length: %\n" min_raft_length
	
		/* MINIMAL Z POZIOTION WHERE LEG WIHTOUT FOOT IS CREATED */ 
		--if update_minimal_lenght then
			min_leg_pos = min_lenght_by_angle --+ dilatation 
	
		/* MINIMAL Z POZIOTION WHERE FOOT IS CREATED */ 
		--if update_min_foot_pos then
			min_foot_pos = min_lenght_by_angle + base_height + dilatation
		
		--format "min_leg_pos: %\n" min_leg_pos
		--format "min_foot_pos: %\n" min_foot_pos
		
		if EXPORT_SIZE != 1.0 then
		(
			min_foot_pos /= EXPORT_SIZE
			--min_foot_pos -= base_height

			min_leg_pos /= EXPORT_SIZE
			min_raft_length = roundFloat (min_raft_length / EXPORT_SIZE) 2
			min_lenght_by_angle /= EXPORT_SIZE
		)
	),
	
	/** Get points positions from line
	 */
	function _getPointsPositionsFromLine =
	(
		-- format "\n"; print "SupportObject_v._getPointsPositionsFromLine()"
		for knot = 1 to numKnots support_obj spline_1 collect getKnotPoint support_obj spline_1 knot
	),
	
	/** KEEP RAFT PONT BELLOW FIRST
	  * 
	  * Make sure that raft_vector of support is not horizontal or up
	 */
	function _keepVectorDown =
	(
		-- format "\n"; print "SupportObject_v._keepVectorDown()"
		if this.raft_vector.z > 0 then
			this.raft_vector.z = -0.1
	),
	
	/** SET CORECT NUMBER OF KNOTS ON OBJECT
	 */
	function _updateCountOfKnots =
	(
		/** Add knots
		 */
		function addKnots num_knots =
		(
			-- format "\n"; print "SupportObject_v.addKnots()"
			num_knots = numKnots support_obj spline_1
	
			for knot_i = num_knots + 1 to points.count do
				addKnot support_obj spline_1 #corner #line points[knot_i]
		)
	
		/** Remove redundant knots from line object
		  * 
		  * Used if updated shape has less knots then old shape
		 */
		function removeKnots num_knots =
		(
			-- format "\n"; print "SupportObject_v.removeKnots()"
			num_knots = numKnots support_obj spline_1
	
			for knot_i = num_knots to points.count + 1 by -1 do
				deleteKnot support_obj spline_1 knot_i
		)
		
		if (num_knots = numKnots support_obj spline_1) != points.count then
			case of
			(
				(num_knots < points.count): addKnots(num_knots)
				(num_knots > points.count): removeKnots(num_knots)
			)
	),

	/** Update line
	 */
	function _updateKnotsPositionByPoints start_knot:1 =
	(
		-- format "\n"; print "SupportObject_v._updateKnotsPositionByPoints()"
		-- format "points: %\n" points
		-- format "points.count: %\n" points.count
		
		for knot_i = start_knot to points.count do
			setKnotPoint support_obj spline_1 knot_i points[knot_i]
	),
	
	/** Create line
	  */
	function _drawLine =
	(
		-- format "\n"; print "SupportObject_v._drawRaftLine()"
		addNewSpline support_obj

		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for pos in points do
			addKnot support_obj spline_1 #corner #line pos

		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),
	
	/** Set nide name
	 */
	function _setName vertex_index =
	(
		-- format "\n"; print "SupportObject_v._getName()"
		if source_obj != undefined then
		(
			support_name = substituteString source_obj.name "-source" ""
	
			if not matchPattern support_name pattern:("*-support*") then
				support_name += "-support"
			--support_name + "-support-" + vertex_index as string -- + "-" + index as string
			support_name += "-"+ vertex_index as string
	
			support_obj.name = support_name --return
		)
	),
	
	/** Is on ground
	 */
	function _isOnGround =
	(
		 --format "\n"; print "SupportObject_v._isOnGround()"
		is_on_ground = obj_type == #SUPPORT and SupportRaft.hit_raft == undefined and SupportLeg.hit_leg == undefined

		setUserPropVal support_obj "IS_ON_GROUND" is_on_ground
	),
	
	/** Set foot exists
	 */
	function _setFootExists =
	(
		 --format "\n"; print "SupportObject_v._setFootExists()"
		foot_exists = obj_type != #RAFT and SupportRaft.hit_raft == undefined and SupportLeg.hit_leg == undefined and SupportRaft.foot_space_exists
	),

	/** Save first knot pos
	 */
	function _saveFirstKnotPos =
	(
		--format "\n"; print "SupportObject_v._saveFirstKnotPos()"
		setUserPropVal support_obj "FIRST_KNOT_POS" points[2]
	),

	/** Support is displayed as box if raft_vector or support position is not valid
	 */
	function _disbaleBoxMode =
	(
		-- format "\n"; print "SupportObject_v._disbaleBoxMode()"
		support_obj.boxmode = false
	),
	/** Align to vector
	 */
	function _alignPivotToRaft =
	(
		-- format "\n"; print "SupportObject_v._alignPivotToRaft()"
		--support_obj = $
		--dir = normalize (support_obj.pos - points[2])
		--dir = normalize ( points[2] - support_obj.pos )
		--dir = normalize ( (  getKnotPoint support_obj spline_1 1 ) - ( getKnotPoint support_obj spline_1 2 ) )
		dir = this.raft_vector * -1
		
		axis = #z

		vec = case axis of
		(
			#x: support_obj.transform[1]
			#y: support_obj.transform[2]
			#z: support_obj.transform[3]
		)

		--tm  = Inverse support_obj.transform
		tm  = support_obj.transform
		vec = normalize vec
		dir = normalize dir
		
		angle_vectors = acos (dot vec dir) -- get angle between
		-- format "angle_vectors: %\n" angle_vectors
		
		/**
			PROBLEM:
				sometimes acos() returns -nan(ind) 
		  
			IT CAUSES ERROR AND MAKES SUPPORT DISSAPEAR
		  
			WORKAROUND:
				Check if acos() returns number
		  
		*/
		if ( (angle_vectors as string ) as float ) != undefined then
		(
			axis_of_plane_defined_by_vectors = normalize (cross dir vec)
	
			rtm = AngleAxis (angle_vectors) ( axis_of_plane_defined_by_vectors )
	
			tempObjTM = Translate ( Rotate ( ScaleMatrix  tm.scale) (tm.rotation*rtm)) tm.pos
			-- format "tempObjTM: %\n" tempObjTM
			WorldAlignPivot support_obj
	
			rot = Inverse tempObjTM.rotation
	
			in coordsys local support_obj.rotation *= rot
	
			support_obj.objectoffsetrot *= rot
			
			support_obj.objectoffsetpos *= rot
			
		)
		else
		(
			-- format "\n"; format "SupportObject_v._alignPivotToRaft() %" support_obj.name
			-- format " ANGLE_VECTORS: %\n" angle_vectors
		)

		--support_obj.pivot = p1
	),

	/** Set materials to line segments
	 */
	function _setMaterialsToLineSegments =
	(
		-- format "\n"; print "SupportObject_v._setMaterialsToLineSegments()"
		-- format "foot_exists: %\n" foot_exists
		-- format "SupportRaftUpdater.foot_exists: %\n" SupportRaftUpdater.foot_exists
		num_of_segments = numSegments support_obj ( numSplines support_obj)
	
		for segment_i = 1 to num_of_segments do
			setMaterialID support_obj spline_1 segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
	
		/*------ SET MATERIAL TO GROUND SEGMENT ------*/
		if foot_enabled and foot_exists then
			setMaterialID support_obj spline_1 num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
	),
	
	/** Get minimal lenght of segment by angle to KEEP CLEAND CORNERS OF SWEEP MODIFIER 
	 */
	function _getMinLenghtByAngle raft_vector /*first_knot_pos:undefined second_knot_pos:undefined*/ /*add_bar:false add_chamfalse */=
	(
		 -- format "\n"; print "SupportObject_v._getMinimalLenghtByAngle()"
		-- format "first_knot_pos:  %\n" first_knot_pos
		-- format "second_knot_pos: %\n" second_knot_pos
		/** Get percentage of bar with by angle of corner
		  *
		  *    • IF ANGLE is 180° then 0%   of bar with is added
		  *    • IF ANGLE is  90° then 100% of bar with is added
		  *
		  * @return integer % of bar with needed for clean corners of sweep modifier
		 */
		function getPercentageByAngle angle_of_leg =
		(
			-- format "\n"; print "SupportObject_v.getPercentageByAngle()"
			angle_of_leg -= 90
			 -- format "angle_of_leg: %\n" angle_of_leg
			( angle_of_leg / 90 * 100.0 )
		)
	
		vector_leg = [ 0, 0, -1 ]
	
		raft_vector = normalize ( raft_vector * -1 )
		
		angle_of_leg = acos (dot raft_vector vector_leg) -- get angle between
		 -- format "angle_of_leg:    %\n" angle_of_leg
		percentage_by_angle = getPercentageByAngle(angle_of_leg)

		-- format "percentage_by_angle: %\n" percentage_by_angle
		
		--width_by_angle = ( bar_width / 2.0) * (percentage_by_angle / 100.0)
		width_by_angle = ( bar_width ) * (percentage_by_angle / 100.0)
		-- format "width_by_angle: %\n" width_by_angle
		--length_by_angle = ( bar_width / 2.0) - width_by_angle
		length_by_angle = ( bar_width ) - width_by_angle
		length_by_angle /= 2.0
		length_by_angle *= EXPORT_SIZE  --return
		
		 -- format "length_by_angle: %\n" length_by_angle
		 length_by_angle --return
	),
	
	/** Lock objects transforms
	  * 
	  * @param type #MOVE|#ROTATE|#SCALE
	 */
	function _lockRotationAndScaleTransforms =
	(
		-- format "\n"; print ".lockObjectsTransforms()"
		/** Lock 
		  *
		  */
		function toggleTransformLock type state =
		(
			-- format "\n"; print "TransformLocker_v._lock()"
			lock_keys = #( #MOVE_X, #MOVE_Y, #MOVE_Z, #ROTATE_X, #ROTATE_Y, #ROTATE_Z, #SCALE_X, #SCALE_Y, #SCALE_Z )

			lock_states = getTransformLockFlags support_obj
	
			if type != #ALL then
				for lock_key in lock_keys where matchPattern (lock_key as string ) pattern:( type as string +"*" ) do
					lock_states[findItem lock_keys lock_key] = state
			else
				lock_states = if state then #{1..9} else #{}
	
			setTransformLockFlags support_obj lock_states
		)

		toggleTransformLock #ROTATE true
		
		toggleTransformLock #SCALE true
	),
	

	/**
	 */
	on create do
	(
		 -- format "\n"; print "SupportObject.onCreate()"
		--this._setSupportRaftUpdater()
		if support_obj != undefined then
			this._loadUserPropsFromNode()
	)

)
