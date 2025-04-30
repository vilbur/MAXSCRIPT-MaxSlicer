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
	--SupportRaft	= SupportRaft_v(this),
	SupportRaft	= SupportRaft_v(this),
	SupportLeg	= SupportLeg_v (this),
	SupportFoot	= SupportFoot_v(this),
	
	/* SUPPORT PROPERTIES */
	prop_keys   = #( #DIRECTION, #DIR_VECTOR, #NORMAL_WORLD, #FOOT_EXISTS, #IS_ON_GROUND ),
	option_keys = #( #BAR_WIDTH, #BASE_HEIGHT, #NORMAL_LENGTH, #TOP_WIDTH, #FOOT_ENABLED ),
	
	changed_props = Dictionary(),

	direction,
	dir_vector,
	normal_world,

	
	bar_width,
	normal_length,
	base_height,
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
	dir_vector_angle_range = 80,
	--dir_vector_angle_range = 45,
	
	private

	spline_1 = 1, -- each support line has ony 1 spline
	
	dilatation  = 0.05, 

	public

	/** Generate support
	  * 
	  * @param point3	first_knot_pos	top position of support
	  * @param #DOWN|point3	direction	dir_vector of direction from 1st to 2nd point
	  * @param color	wirecolor	of support object
	 */
	function generateSupport vertex_index first_knot_pos: direction:#DOWN dir_vector:undefined normal_world: wirecolor: =
	(
		 --format "\n===========================================================\n"
		 -- format "\n"; print "SupportObject_v.generateSupport()"
		 --format "dir_vector: %\n" dir_vector
		-- format "wirecolor: %\n" wirecolor
		 -- format "vertex_index: %\n" vertex_index
		
		function isLegPointAboveMinimalLimit leg_point = ( leg_point as string ) as float >= ( min_leg_pos as string ) as float
		
		/* SET PARAMS */ 		
		this.direction = direction
		
		this.dir_vector = dir_vector
		
		this.normal_world = normal_world
		
		this.points = #( first_knot_pos )
		
		this._setSupportObject(wirecolor)
		
		this._saveUserPropsToSupport(vertex_index)
		
		if not this._isPositionAndVectorValid first_knot_pos dir_vector then
			return false
		
		--support_obj.boxmode = false
			
		this._fillThisWithOptionValues()
		
		this._setMinLimints (direction)

		
		/*------------------------------------------------------------------------------
			SET SUPPORT LINE POINTS
		--------------------------------------------------------------------------------*/
		
		this._setSupportLinePoints()
		

		/*------------------------------------------------------------------------------
			CREATE SUPPORT
		--------------------------------------------------------------------------------*/
				
		this._drawLine()

		this._setMaterialsToLineSegments()
		
		this._setName(vertex_index)
		
		this._setPivotToPoint(2)
		
		this._alignPivotToRaft()

		this._isOnGround()
		
		this._saveOptionsToUserProps()

		this._lockRotationAndScaleTransforms()
		
		SUPPORT_MANAGER.updateShapeAdd (support_obj)

		this -- return
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
	function updateSupport first_knot_pos:undefined update_raft:true update_leg:false direction:undefined dir_vector:undefined =
	(
		 --format "\n----------------------------------------------\n"
		 -- format "\n"; print "SupportObject_v.updateSupport()"
		 -- format "first_knot_pos: %\n" first_knot_pos
		-- format "update_raft: %\n" update_raft
		 -- format "dir_vector:  %\n" dir_vector
		
		/*------------------------------------------------------------------------------
			SANITIZE PARAMETERS
		--------------------------------------------------------------------------------*/
		
		/* GET 1st knot POSITION FROM LINE */ 
		if first_knot_pos == undefined then
			first_knot_pos = getKnotPoint support_obj spline_1 1
		
		/*------------------------------------------------------------------------------
			PREPARE UPDATE
		----------------------------------------------------------------------------------*/

		points = #(first_knot_pos, support_obj.pos)
		
		this._setRaftLenght update_raft:update_raft
		--format "dir_vector == undefined: %\n" (dir_vector == undefined)
		-- format "NORMAL: %\n" (normalize (points[2] - points[1]))
		this.dir_vector = if dir_vector == undefined then normalize (points[2] - points[1]) else dir_vector
		 -- format "this.dir_vector: %\n" this.dir_vector
		 
		 
		if not this.vectorIsInRange() or not this._isPositionAndVectorValid points[1] this.dir_vector then
			return false
			
		this._disbaleBoxMode()

		this._checkChangedProps() -- MUST BE EXECUTED BEFORE this._setDirVector() for recognizing of chaged value
		-- format "CHANGED_PROPS: %\n" this.changed_props.keys
			
		--this._setDirVector (dir_vector) update_raft:update_raft
		set_min_limits = update_raft == true or min_raft_length == undefined
		
		--this._setMinLimints(direction) update_raft:update_raft
		this._setMinLimints(direction) update_raft:set_min_limits

		this._keepVectorDown()
		
		/*------------------------------------------------------------------------------
			UPDATE SUPPORT LINE POINTS
		--------------------------------------------------------------------------------*/
		
		this._setSupportLinePoints()
		
		/*------------------------------------------------------------------------------
			POST UPDATE
		--------------------------------------------------------------------------------*/
		-- format "POINTS: %\n" POINTS.count
		this._updateCountOfKnots()
		
		this._updateKnotsPositionByPoints()

		this._setPivotToPoint(2)

		this._isOnGround()
		
		----this._alignPivotToRaft()
		
		this._setMaterialsToLineSegments()
		-- format "PROPS:      %\n" (getUserPropVal support_obj "DIR_VECTOR")
		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),
	
	/** Rebulid support
	 */
	function rebulidSupport dir_vector: =
	(
		 -- format "\n"; print "SupportObject_v.rebulidSupport()"
		-- format "dir_vector: %\n" dir_vector
		index = getUserPropVal support_obj "INDEX"
		
		if dir_vector == undefined  then 
			dir_vector = getUserPropVal support_obj "DIR_VECTOR"
		 -- format "dir_vector: %\n" dir_vector

		wirecolor = getUserPropVal support_obj "WIRECOLOR"
		
		if numSplines support_obj == 0 then
			addNewSpline support_obj

		--first_knot_pos = if classOf support_obj != Point then getKnotPoint support_obj spline_1 1 else support_obj.position
		--first_knot_pos = getKnotPoint support_obj spline_1 1
		first_knot_pos = support_obj.pivot
		
		this.generateSupport index first_knot_pos:first_knot_pos direction:direction dir_vector:dir_vector wirecolor:wirecolor 
	),
	
	/** Update support height
	 */
	function updateSupportHeight  =
	(
		-- format "\n"; print "SupportObject_v.updateSupportHeight()"
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
			this._setMinLimints(direction) update_raft:true
		
		if is_on_ground then
		(
			first_knot_pos = getKnotPoint support_obj spline_1 1
			
			if not this._isPositionAndVectorValid first_knot_pos dir_vector then
				return false
			
			points = #( first_knot_pos, support_obj.pos )
			
			points_distance = distance points[1] points[2]

			/*------------------------------------------------------------------------------------------
				SIMPLE SET KNOTS TO GROUND IF SUPPORT IS TALL EANOUGH, NOT SHORTEN AND FOOT EXISTS
			--------------------------------------------------------------------------------------------*/
			
			if isTallEnough() and not points_distance < normal_length and (( foot_enabled and foot_exists ) or not foot_enabled ) then
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
		
				this._updateCountOfKnots()
				
				this._updateKnotsPositionByPoints()
				
				this._setPivotToPoint(2)

				
				this._isOnGround()
				
				--this._saveFirstKnotPos()
				
				this._setMaterialsToLineSegments()
			
				this._disbaleBoxMode()
			)
		
			SUPPORT_MANAGER.updateShapeAdd (support_obj)
		)
	),
	
	
	/** Set support line points
	 */
	function _setSupportLinePoints =
	(
		-- format "\n"; print "SupportObject_v._setSupportLinePoints()"
		
		/* CREATE RAFT */ 
		SupportRaft.createRaft()

		/* CREATE LEG */ 
		if points[2].z > 0 and SupportRaft.hit_raft == undefined then
		(
			-- format "foot_enabled: %\n" foot_enabled
			foot_exists = foot_enabled and SupportRaft.foot_space_exists
		
			SupportLeg.createLeg( if foot_exists then min_leg_pos else 0 )
			
			/* CREATE FOOT */ 
			if SupportLeg.hit_leg == undefined and foot_exists then 
				SupportFoot.createFoot()
		)
		
		this._setFootExists()
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

		--function _getKey type = ( toUpper (type as string ) + "_KEY")
		--
		--/* SET PROPERTIES */ 
		--this.obj_type = to_type
		--
		--this.hit_raft 	= undefined
		--this.hit_leg	= undefined
		----this.is_on_ground	= false
		--
		--
		--/* GET TYPE OF ORIGIN OBJECT */ 
		--from_type =  if to_type == #RAFT then #SUPPORT else #RAFT
		--
		--
		--/* REPLACE OBJECT PROPERTY DATA */ 
		--deleteUserProp support_obj ( _getKey from_type  )
		--
		--setUserPropVal support_obj ( _getKey to_type  ) support_key
		--
		--
		--/* IF TYPE IS CONVERTED */ 
		--this._getPositionsFromLineOnConvert()
		--
		--
		--/* UPDATE SUPPORT */ 
		--this.updateSupport()
	),



	/** Update base height
	 */
	function updateBaseHeight =
	(
		-- format "\n"; print "SupportObject_v.updateBaseHeight()"
		-- format "support_obj: %\n" support_obj.name
		--if this.is_on_ground != undefined and this.is_on_ground then
		--(
		--	ground_knot = numKnots support_obj spline_1
		--	base_knot   = ground_knot - 1
		--	
		--	base_knot_pos   = getKnotPoint support_obj spline_1 base_knot
		--	base_knot_pos.z = SUPPORT_OPTIONS.base_height
		--	
		--	setKnotPoint support_obj spline_1 base_knot base_knot_pos
		--	
		--	setUserPropVal support_obj "BASE_HEIGHT" SUPPORT_OPTIONS.base_height
		--
		--	SUPPORT_MANAGER.updateShapeAdd (support_obj)
		--)
	),
 
	/** Is raft
	 */
	function isRaft =
	(
		-- format "\n"; print "SupportObject_v.isRaft()"
		getUserPropVal support_obj "RAFT_KEY" != undefined
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

	/** Test collision with source object
	 */
	function intersectRaySourceObject pos direction =
	(
		-- format "\n"; print "SupportObject_v.intersectRaySourceObject()"
		-- format "pos: %\n" pos
		-- format "direction: %\n" direction
		
		/** Modify pos
		 */
		function modifyPos _pos axis val =
		(
			-- format "\n"; print ".modifyPos()"
			_pos = copy _pos

			_pos[axis] += val

			_pos --return
		)

		local hit_result

		if source_obj != undefined then
		(
			--half_of_bar_width = this.bar_width / 2
			half_of_bar_width = this.bar_width 
	
			pos += 0.1 * direction -- shift ray pos along vector outside of object
	
			bar_bbox = #(
				modifyPos pos 1 half_of_bar_width,
				modifyPos pos 1 (half_of_bar_width * -1),
				modifyPos pos 2 half_of_bar_width,
				modifyPos pos 2 (half_of_bar_width * -1),
				pos
			)
	
			for pos in bar_bbox do
			(
				if ( hit = intersectRay source_obj ( Ray pos direction) ) != undefined then
					hit_result = copy hit
				
			)
		)

		hit_result --return
	),




	/** Has splines
	 */
	function hasSplines =
	(
		-- format "\n"; print "SupportObject_v.hasSplines()"
		numSplines support_obj > 0
	),
	
	private
	
	
	/** • AVOID SUPORT UNDER GROUND
	  *	• ALLOW ONLY VECTORS DIRECTING DOWN
	 */
	--function _isPositionAndVectorValid first_knot_pos dir_vector =
	function _isPositionAndVectorValid knot_pos _dir_vector =
	(
		 -- format "\n"; print "SupportObject_v._isPositionAndVectorValid()"
		knot_pos.z > 0 and _dir_vector.z < 0 --return
	),
	
	/** • ALLOW TO MOVE SUPPORT IN ONLY GIVEN ANGLE
	  * • AVOID TO FLIP DIR VECTOR TO BACKSIDE
	  *		  
	  * 1)Create future dir vetor from OLD FISRT POSITION and new SUPPORT POSITION
	  *		  
	  * 2) Test if new vector firs to range of world normal
	 */
	function vectorIsInRange =
	(
		
		function testVectorInCone v1 v2 angle_treshold =
		(
			if distance v1 v2 > 0.001 then
			(
				dot_product = dot (normalize v1) (normalize v2)
				
				theAngle = acos(dot_product)

				theAngle < angle_treshold
			)
			else
				true --return true if vectors are same
		)
		
		dir_vector_new = if points[2] != undefined then  normalize ( points[2] - points[1]) else this.dir_vector
		
		testVectorInCone normal_world dir_vector_new dir_vector_angle_range
	),

	/** Create new support object or get existing and delete spline subobject
	 */
	function _setSupportObject wirecolor =
	(
		-- format "\n"; print "SupportObject_v._getSupportNode()"
		if wirecolor == undefined then 
			wirecolor = ( color ( random 100 255) ( random 100 255) ( random 100 255))
		
		/* CREATE NEW OBJECT */ 
		if support_obj == undefined then
		(
			support_obj = SplineShape wirecolor:wirecolor
		
			support_key = (getHandleByAnim support_obj) as string
		)
		else /* USE OLD OBEJCT - RESET SPLINE */ 
			deleteSpline support_obj spline_1
				
		support_obj.wirecolor = wirecolor
		
	),
	

	/** Get vector of raft from current line or from user props
	  * 
	 */
	function _setDirVector dir_vector update_raft:false =
	(
		-- format "\n"; print "SupportObject_v._setDirVector()"
        vector_exist = dir_vector != undefined

		this.dir_vector = case of
		(
            (vector_exist):	dir_vector
            (update_raft):	normalize (points[2] - points[1])
            default: 		getUserPropVal support_obj "DIR_VECTOR"
		)
		
	),
		
	/** Set normal lenght
	  * 
	  * 1) Get normal length from options if new support is created
	  * 2) Use current length if support is updated
	  * 3) Use saved length if support is updated BUT NORMAL LENGTH IS LOCKED
	  * 
	 */
	function _setRaftLenght update_raft:false =
	(
		-- format "\n"; print "SupportObject_v._setRaftLenght()"
		
		this.normal_length = if update_raft and not SUPPORT_OPTIONS.lock_normal_length then
			 distance points[1] points[2]
		else
			getUserPropVal support_obj "NORMAL_LENGTH"
	),
	
	/** SET USER DATA TO SUPPORT OBJECT
	 */
	function _saveUserPropsToSupport vert =
	(
		--support_obj = SupportObject.support_obj
		
		--support_key_prop = toUpper (SupportObject.obj_type as string ) + "_KEY"
		key_prop = if obj_type == #SUPPORT then "SUPPORT_KEY" else "RAFT_KEY"
		--support_key_val  = (getHandleByAnim support_obj) as string
		--setUserPropVal support_obj "WIRECOLOR" SupportObject.wirecolor
	
		setUserPropVal support_obj "SYNC_KEY" sync_key
		
		setUserPropVal support_obj key_prop support_key
		
		setUserPropVal support_obj "INDEX" vert
	 ),

	/** Fill props of this with data from options
	  * 
	  * Save props to objects user props
	 */
	function _fillThisWithOptionValues =
	(
		-- format "\n"; print "SupportObject_v._fillThisWithOptionValues()"

		for prop_key in option_keys do
			setProperty this prop_key ( SUPPORT_OPTIONS.getOption prop_key )
		
        --bar_width     = SUPPORT_OPTIONS.getOption #BAR_WIDTH
        --base_height   = SUPPORT_OPTIONS.getOption #BASE_HEIGHT
        --normal_length = SUPPORT_OPTIONS.getOption #NORMAL_LENGTH
        --foot_enabled  = SUPPORT_OPTIONS.getOption #FOOT_ENABLED
        --top_width	  = SUPPORT_OPTIONS.getOption #TOP_WIDTH
		
		--top_width   = SUPPORT_OPTIONS.getChamferBarValue()
	),
	
	/** Save user props to node
	 */
	function _saveOptionsToUserProps =
	(
		-- format "\n"; print "SupportObject_v._saveOptionsToUserProps()"
		for prop_key in prop_keys + option_keys do
		(
			key = toUpper ( prop_key as string )
			val = getProperty this prop_key
			
			if val != undefined and val != unsupplied then 
			setUserPropVal support_obj key val
		)

        --setUserPropVal support_obj "DIR_VECTOR" dir_vector
	),
	
	/** Load user props from node
	 */
	function _loadUserPropsFromNode =
	(
		-- format "\n"; print "SupportObject_v._loadUserPropsFromNode()"
		for prop_key in prop_keys + option_keys do
			setProperty this prop_key ( getUserPropVal support_obj ( toUpper ( prop_key as string )) )
	),

	/** Minimal values depedns on isze and direction of support
	  * 
	  * 
	  * 
	 */
	function _checkChangedProps =
	(
		-- format "\n"; print "SupportObject_v._checkChangedProps()"

		/** Get current values
		 */
		function getCurrentValues =
		(
			-- format "\n"; print "SupportObject_v.getCurrentValues()"
			--bar_width_current = support_obj.modifiers[#BAR_WIDTH][#Cylinder_Section].radius * 2
			this.changed_props = Dictionary()
			
			changed_props[#DIR_VECTOR]  = normalize ( points[2] - points[1] )
			
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
				--format "current_val: %\n" current_val
				--format "this_val: %\n" this_val

				
				if classOf this_val == point3 then
					distance this_val current_val > 0.001  --return
					
				else
					this_val as string != current_val as string
			)
			
			/* REMOVE UNCHANGED VALUES FROM DICTIONARY */ 
			for prop in changed_props.keys do
				if not valueChanged ( getProperty this prop ) changed_props[prop] then
					RemoveDictValue changed_props prop 
			
			-- format "CHANGED_PROPS: %\n" this.changed_props.keys
		)
		
		/** UPDATE PROPERTIES OF:
		  *
		  *  	1) this
		  *  	2) node userProps
		 */
		function syncProperties =
		(
			--format "\n"; print "SupportObject_v.syncProperties()"
			for prop in changed_props.keys do
			(
				/* UPDATE THIS */ 
				setProperty this prop changed_props[prop]
				
				/* UPDATE USER PROPERTIES */ 
				setUserPropVal support_obj ( toUpper ( prop as string ) ) changed_props[prop]
			)
		)
		
		getCurrentValues()
		
		compareValuesWithPropertisOfThis()
		
		syncProperties()
	),
	
	/** Set minimal foot pos
	  
		TUNE MINIMAL FOOT HEIGHT BASED ON ANGLE OF SUPPORT -- to avoid corner artefact on sweep modifier
		
		support - 90°  > remove 90% of bar with
		support - 135° > remove 45% of bar with
		support - 180° > remove 0%  of bar with
	 */
	function _setMinLimints direction update_raft:true =
	(
		-- format "\n"; print "SupportObject_v._setMinLimints()"
		update_minimal_lenght  = update_raft or changed_props[#DIR_VECTOR]  != undefined or changed_props[#BAR_WIDTH] != undefined 
        update_min_raft_length = update_raft or changed_props[#TOP_WIDTH]   != undefined or update_minimal_lenght
        update_min_foot_pos    = update_raft or changed_props[#BASE_HEIGHT] != undefined or update_minimal_lenght
	
		
			/* MINIMAL SIZE OF RAFT depends on with of sweep modifier and angle of line corners */
		if update_minimal_lenght then
			min_lenght_by_angle = if this.dir_vector.z == -1 then dilatation else this._getMinLenghtByAngle ( this.dir_vector )
	
	
			/* MINIMAL LENGTH OF SUPPORT to avoid artifacts of sweep modifier */
		if update_min_raft_length then
			min_raft_length = min_lenght_by_angle + top_width + dilatation -- chmfer is removing length of raft also
	
			
			/* MINIMAL Z POZIOTION WHERE LEG WIHTOUT FOOT IS CREATED */ 
		if update_minimal_lenght then
			min_leg_pos = min_lenght_by_angle --+ dilatation 
	
			
			/* MINIMAL Z POZIOTION WHERE FOOT IS CREATED */ 
		if update_min_foot_pos then
			min_foot_pos = min_lenght_by_angle + base_height + dilatation
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
	  * Make sure that dir_vector of support is not horizontal or up
	 */
	function _keepVectorDown =
	(
		-- format "\n"; print "SupportObject_v._keepVectorDown()"
		if this.dir_vector.z > -0.25 then
			this.dir_vector.z = -0.25
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
		-- format "\n"; print "SupportObject_v._isOnGround()"
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

	/** Support is displayed as box if dir_vector or support position is not valid
	 */
	function _disbaleBoxMode =
	(
		--format "\n"; print "SupportObject_v._disbaleBoxMode()"
		support_obj.boxmode = false
	),
	/** Align to vector
	 */
	function _alignPivotToRaft =
	(
		-- format "\n"; print "SupportObject_v._alignPivotToRaft()"
		--support_obj = $
		--dir = normalize (support_obj.pos - points[1])
		--dir = normalize ( points[1] - support_obj.pos )
		--dir = normalize ( (  getKnotPoint support_obj spline_1 1 ) - ( getKnotPoint support_obj spline_1 2 ) )
		dir = this.dir_vector * -1
		
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

	/** Set pivot to position
	 */
	function _setPivotToPoint index =
	(
		-- format "\n"; print "SupportObject_v._alignPivotToRaft()"
		--support_obj.pivot = getKnotPoint support_obj spline_1 2
		support_obj.pivot = points[index]
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
	function _getMinLenghtByAngle dir_vector /*first_knot_pos:undefined second_knot_pos:undefined*/ /*add_bar:false add_chamfalse */=
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
	
		dir_vector = normalize ( dir_vector * -1 )
		
		angle_of_leg = acos (dot dir_vector vector_leg) -- get angle between
		-- format "angle_of_leg:    %\n" angle_of_leg
		percentage_by_angle = getPercentageByAngle(angle_of_leg)

		
		
		width_by_angle = ( bar_width/2.0) * (percentage_by_angle / 100.0)

		length_by_angle = ( bar_width/2.0) - width_by_angle
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
