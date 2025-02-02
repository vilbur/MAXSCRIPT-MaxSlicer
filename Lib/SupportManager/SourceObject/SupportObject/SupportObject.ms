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

	support_key, -- pointer of support when node is created
	sync_key,

	/* properties */

	knots_positions = Array (2),

	is_on_ground, -- boolean


	private

	spline_1 = 1, -- each support line has ony 1 spline

	hit_raft,
	hit_support,

	direction_down = [0,0,-1],


	public


	/** Generate support
	  * 
	  * 
	  * 
	  * @param point3 first_knot_pos	top position of support
	  * @param point3 direction	vector of direction from 1st to 2nd point
	  * @param color  wirecolor	of support object
	 */
	function generateSupport vertex_index first_knot_pos: direction:[0,0,-1] wirecolor:( color ( random 100 255) ( random 100 255) ( random 100 255)) =
	(
		--format "\n"; print "SupportObject_v.generateSupport()"
		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS
	
		/** Set nide name
		 */
		function _setName vertex_index =
		(
			--format "\n"; print "SupportRaftBaseObject._getName()"
			if source_obj != undefined then
			(
				support_name = substituteString source_obj.name "-source" ""
		
				if not matchPattern support_name pattern:("*-support*") then
					support_name += "-support"
				--support_name + "-support-" + vertex_index as string -- + "-" + index as string
				support_name += "-"+ vertex_index as string
		
				support_obj.name = support_name --return
			)
		)
			
		
		
		/* CREATE NEW OBJECT */ 
		if support_obj == undefined then
			support_obj = SplineShape wirecolor:wirecolor

		else /* RESET SPLINE */ 
			deleteSpline support_obj spline_1
			
			
		/* MAKE SURE THAT SUPPORT DIRECTION OF SUPPORT IS NOT HORIZONTAL */ 
		if direction.z > -0.25 then direction.z = -0.25


		/* SET RAFT PART of support */ 
		this._setRaftKnots(first_knot_pos)(direction)
		
		/* SET LEG PART of support - if raft do not hit source object */ 
		if obj_type == #SUPPORT and hit_raft == undefined then
			this._setSupportLegPositions()

		
		/*------------------------------------------------------------------------------
			CREATE SUPPORT
		--------------------------------------------------------------------------------*/
		
		_setName(vertex_index)
		
		this._isOnGround()

		this._drawLine()

		this._setMaterialsToLineSegments()

		this._setPivotToSecondPoint()

		this._alignPivotToSeconPoint()

	
		SUPPORT_MANAGER.addSupportObjects (this)

	
		/* SET USER DATA TO SUPPORT OBJECT */ 	
		support_key = (getHandleByAnim support_obj) as string

		setUserPropVal support_obj ( toUpper (obj_type as string ) + "_KEY") support_key

		setUserPropVal support_obj "DIRECTION" direction --asString:true
		
		
		/* RETURN */ 
		this
	),

	/** Convert SUPPORT to RAFT and vice versa
	  *
	  * @param #SUPPORT|#RAFT to_type type of obejct to covert
	  *
	 */
	function convertType to_type =
	(
		--format "\n"; print "SupportObject_v.convert()"
		--format "TO_TYPE: %\n" to_type

		function _getKey type = ( toUpper (type as string ) + "_KEY")
		
		/* SET PROPERTIES */ 
		this.obj_type = to_type
		
		this.hit_raft 	= undefined
		this.hit_support	= undefined
		--this.is_on_ground	= false


		/* GET TYPE OF ORIGIN OBJECT */ 
		from_type =  if to_type == #RAFT then #SUPPORT else #RAFT

		
		/* REPLACE OBJECT PROPERTY DATA */ 
		deleteUserProp support_obj ( _getKey from_type  )
		
		setUserPropVal support_obj ( _getKey to_type  ) support_key

		
		/* IF TYPE IS CONVERTED */ 
		this._getPositionsFromLineOnConvert()
		
		
		/* UPDATE SUPPORT */ 
		this.updateSupport()
	),

	/** Update supports position
	 */
	function updateSupport first_knot_pos: update_direction:false =
	(
		--format "\n"; print "SupportObject_v.updateSupport()"
		--format "SUPPORT: %\n" support_obj.name
		--format "first_knot_pos: %\n" first_knot_pos
		--format "update_direction: %\n" update_direction

		direction = getUserPropVal support_obj "DIRECTION"
		
		--format "direction: %\n" direction
		--format "direction==direction_down: %\n" (direction==direction_down)
		
		
		/* GENERATE SECOND POINT */ 
		if first_knot_pos != unsupplied then
			this._setSecondKnotPosition( first_knot_pos )
		
		--else

		
		/* GENERATE LEG FOR SUPPORT */ 
		if obj_type == #SUPPORT and hit_raft == undefined then
			this._setSupportLegPositions()
			
			
		/* SET CORECT NUMBER OF KNOTS ON OBJECT */ 
		if (num_knots = numKnots support_obj spline_1) != knots_positions.count then
			case of
			(
				(num_knots < knots_positions.count): this._addKnots()
				(num_knots > knots_positions.count): this._removeKnots()
			)


		this._updateLine()

		this._isOnGround()
		
		this._setMaterialsToLineSegments()

		this._setPivotToSecondPoint()
		

		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),


	--/** Update support
	-- */
	--function updateRotation first_knot_pos: =
	--(
	--	--format "\n"; print "SupportObject_v.updateRotation()"
	--
	--	this._resetThisObject()
	--
	--	this._setSecondKnotPosition(first_knot_pos)
	--
	--	this._updateSupportLeg()
	--),

	/** Update support height
	 */
	function updateHeight =
	(
		--format "\n"; print "SupportObject_v.updateHeight()"
		--format "is_on_ground: %\n" this.is_on_ground
		
		--if this.is_on_ground then
		if this.is_on_ground != undefined and this.is_on_ground then
		(
			ground_knot	= numKnots support_obj spline_1
			base_knot	= ground_knot - 1
	
			ground_knot_pos	= getKnotPoint support_obj spline_1 ground_knot
			base_knot_pos	= getKnotPoint support_obj spline_1 base_knot
	
	
			ground_knot_pos.z	= 0
			base_knot_pos.z	= SUPPORT_OPTIONS.base_height
	
	
			setKnotPoint support_obj spline_1 ground_knot	ground_knot_pos
			setKnotPoint support_obj spline_1 base_knot	base_knot_pos
	
			--updateShape support_obj
			SUPPORT_MANAGER.updateShapeAdd (support_obj)
		)
	),
 
	/** Is raft
	 */
	function isRaft =
	(
		--format "\n"; print "SupportObject_v.isRaft()"
		getUserPropVal support_obj "RAFT_KEY" != undefined
	),

	private

	/** Check segments lenghts
	 */
	function _checkSegmentsLenghts vertex_index =
	(
		--format "\n"; print "SupportObject_v._checkSegmentsLenghts()"

		result = true

		if ( dist = distance knots_positions[1] knots_positions[knots_positions.count] ) < SUPPORT_OPTIONS.getOption #TOP_WIDTH  then
		(
			format "SUPPORT OF VERT:% HAS NO LENGTH\n" vertex_index

			result = false
		)
		else if knots_positions.count > 2 then
			for i = knots_positions.count to 2 by -1 do
			(
				if ( dist = distance knots_positions[i] knots_positions[i - 1] ) < SUPPORT_OPTIONS.getOption #BAR_WIDTH then
				(
					format "SUPPORT OF VERT:% IS TOO SHORT\n" vertex_index

					deleteItem knots_positions (i - 1)

					--result = false
				)
			)

		result --return
	),

	/** Add knots
	 */
	function _addKnots =
	(
		--format "\n"; print "SupportObject_v._addKnots()"
		num_knots = numKnots support_obj spline_1

		for knot_i = num_knots + 1 to knots_positions.count do
			addKnot support_obj spline_1 #corner #line knots_positions[knot_i]
	),

	/** Remove redundant knots from line object
	  * 
	  * Used if updated shape has less knots then old shape
	  * 
	 */
	function _removeKnots =
	(
		--format "\n"; print "SupportObject_v._removeKnots()"
		num_knots = numKnots support_obj spline_1

		for knot_i = num_knots to knots_positions.count + 1 by -1 do
			deleteKnot support_obj spline_1 knot_i
	),

	/** Set knots positions
	 */
	function _setRaftKnots vertex_pos direction =
	(
		--format "\n"; print "SupportObject_v._setRaftKnots()"
		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS
		limit_height_to_base = SUPPORT_OPTIONS.base_height * 1.3 -- z pozition preserved for base points

		/* ADD FIRST POINT */
		knots_positions[1] = vertex_pos


		/* TEST COLLISTION WITH SOURCE OBJECT FOR 2nd POINT */
		hit_raft = this._intersectRaySourceObject (vertex_pos) (direction)

		/* RESET COLLISION IF DISTANCE TO HIT IS GRTEATER THEN NORMAL - only for support */
		if obj_type == #SUPPORT and hit_raft != undefined and distance knots_positions[1] hit_raft.pos > SUPPORT_OPTIONS.normal_length then
			hit_raft = undefined


		length_multiplier = if obj_type == #SUPPORT then 1 else 10
		--format "length_multiplier: %\n" length_multiplier
		/* ADD SECOND POINT */
		if hit_raft != undefined
			then /* SECOND POINT IS POINT OF COLLISION */
				second_point_pos = hit_raft.pos

			else /* EXTEND SECOND POINT ALONG NORMAL */
				second_point_pos = vertex_pos +( SUPPORT_OPTIONS.normal_length * direction * length_multiplier ) -- make raft longer by multiplying normal length 10x


		/* CHECK POSITION ABOVE GROUND, SET LAST KNOT ABOVE BASE */
		if obj_type == #SUPPORT and second_point_pos.z < limit_height_to_base then
		(
			normal_length = abs ((vertex_pos.z - limit_height_to_base ) / direction.z)

			second_point_pos = vertex_pos + ( normal_length * direction)
		)


		/* ADD 2nd POINT */
		knots_positions[2] = second_point_pos
	),

	/** Set support knots
	 */
	function _setSupportLegPositions =
	(
		--format "\n"; print "SupportObject_v._setSupportLegPositions()"
		hit_support = this._intersectRaySourceObject (knots_positions[2]) (direction_down)

		--is_on_ground = hit_support == undefined
		hit_support == undefined

		pos = copy knots_positions[2] -- copy to avoid modifing of value in array

		if hit_support == undefined then
		(
			/* BASE POINT */
			pos.z = SUPPORT_OPTIONS.base_height -- set knot above ground to set base height and keep last segment straight for extrude

			knots_positions[3] = copy pos

			/* ADD GROUND POINT */
			pos.z = 0 -- set support_obj to ground

			knots_positions[4] = copy pos
		)
		else /* IF SUPPORT IS INTERSECTING SOURCE OBJECT, THEN ADD POINT TO INETSECTION */
			knots_positions[3] = hit_support.pos
	),

	/** Set update support knots
	 */
	function _setSecondKnotPosition vertex_pos =
	(
		--format "\n"; print "SupportObject_v._setSecondKnotPosition()"

		--function getNumKnots = numKnots support_obj spline_1
		--knots_positions = Array (2)
		--knots_positions[1] = vertex_pos
		
		knots_positions = #( vertex_pos, undefined )

		second_point_pos = getKnotPoint support_obj spline_1 2

		distance_of_points = distance knots_positions[1] second_point_pos

		direction = normalize (second_point_pos - vertex_pos)

		hit_support = this._intersectRaySourceObject (vertex_pos) ( direction )

		
		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit_support != undefined and distance knots_positions[1] hit_support.pos > distance_of_points then
			hit_support = undefined

			
		/* ADD SECOND POINT */
		knots_positions[2] =  if hit_support != undefined then hit_support.pos else second_point_pos

		
		/* KEEP SECOND POINT BELOW FIRST */
		if knots_positions[2].z >= knots_positions[1].z then
			knots_positions[2]-= SUPPORT_OPTIONS.bar_width

	),

	/** Get knots postions from existing line
	  * 
	  * 1) SUPPORT > RAFT 
	  * 
	  *		A) Get 2nd point if support is on ground
	  * 		B) Get LAST knot if support is NOT on ground
	  * 
	  * 
	  *  2) RAFT > SUPPORT
	  * 
	  * 	 	Get LAST knot of raft
	 */
	function _getPositionsFromLineOnConvert =
	(
		--format "\n"; print "SupportObject_v._getPositionsFromLineOnConvert()"
		
		second_point = if obj_type == #RAFT and is_on_ground then 2 else numKnots support_obj spline_1
		
		
		knots_positions = #(
			getKnotPoint support_obj spline_1 1,
			getKnotPoint support_obj spline_1 second_point
		)
	),

	/** Draw segments support
	 */
	function _createSupportLeg =
	(
		--format "\n"; print "SupportObject_v._createSupportLeg()"
		if knots_positions.count > 1 then
		(
			this._setPivotToSecondPoint()

			this._drawRaftLine()

			if obj_type = #SUPPORT and hit_support == undefined then
				this._drawSupportLine()

			this._setMaterialsToLineSegments()

			updateShape support_obj
		)
	),

	/** Update support leg
	 */
	function _updateSupportLeg =
	(
		--format "\n"; print "SupportObject_v._updateSupportLeg()"
			if update then
				deleteSpline support_obj 1

		ground_knot	= numKnots support_obj spline_1
		base_knot	= ground_knot - 1



		--ground_knot_pos	= getKnotPoint support_obj spline_1 ground_knot
		--base_knot_pos	= getKnotPoint support_obj spline_1 base_knot
		--
		--
		--ground_knot_pos.z	= 0
		--base_knot_pos.z	= SUPPORT_OPTIONS.base_height
		--
		--
		--setKnotPoint support_obj spline_1 ground_knot	ground_knot_pos
		--setKnotPoint support_obj spline_1 base_knot	base_knot_pos
		--
		--updateShape support_obj

	),

	/** Create line
	  */
	function _drawLine =
	(
		--format "\n"; print "SupportObject_v._drawRaftLine()"
		addNewSpline support_obj

		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for pos in knots_positions do
			addKnot support_obj spline_1 #corner #line pos

		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),

	/** Update line
	 */
	function _updateLine =
	(
		--format "\n"; print "SupportObject_v._updateLine()"
		for knot_i = 1 to knots_positions.count do
			setKnotPoint support_obj spline_1 knot_i	knots_positions[knot_i]
	),

	/** Draw leg line
	 */
	function _drawSupportLine =
	(
		--format "\n"; print "SupportObject_v._drawSupportLine()"
		/*------------------------------------------------------------------------------
			GET POSITION OF SECOND POINT
		--------------------------------------------------------------------------------*/
		pos = copy knots_positions[2] -- copy to avoid modifing of value in array

		/*------------------------------------------------------------------------------
			TEST COLLISION WITH OBJECT on straight down direction
		--------------------------------------------------------------------------------*/
		this.hit_support = this._intersectRaySourceObject pos direction_down

		this.is_on_ground = hit_support == undefined

		/* IF SUPPORT IS GOING TO GROUND */
		if is_on_ground then
		(
			/*------------------------------------------------------------------------------
				POINT ABOVE GROUND - NOT IF RAFT MODE
			--------------------------------------------------------------------------------*/
			pos.z = SUPPORT_OPTIONS.base_height -- set knot above ground to set base height and keep last segment straight for extrude

			addKnot support_obj spline_1 #corner #line pos

			pos.z = 0 -- set support_obj to ground

			/*------------------------------------------------------------------------------
				ADD GROUND POINT
			--------------------------------------------------------------------------------*/
			addKnot support_obj spline_1 #corner #line pos
		)
		else /* IF SUPPORT IS INTERSECTING SOURCE OBJECT, THEN ADD POINT TO INETSECTION */
		(
			--format "hit_support: %\n" hit_support
			--pos.z = hit_support.pos.z -- set knot above ground to set base height and keep last segment straight for extrude

			--addKnot support_obj spline_1 #corner #line pos
			addKnot support_obj spline_1 #corner #line hit_support.pos
		)
	),

	/** Set materials to line segments
	 */
	function _setMaterialsToLineSegments =
	(
		--format "\n"; print "SupportObject_v._setMaterialsToLineSegments()"

		num_of_segments = numSegments support_obj ( numSplines support_obj)

		for segment_i = 1 to num_of_segments do
			setMaterialID support_obj spline_1 segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>

		/*------ SET MATERIAL TO GROUND SEGMENT ------*/
		--if is_on_ground != undefined and is_on_ground then
		if is_on_ground then
			setMaterialID support_obj spline_1 num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
	),

	/** Align to ctor
	 */
	function _alignPivotToSeconPoint =
	(
		--format "\n"; print "SupportObject_v._alignPivotToSeconPoint()"

		--dir = normalize (support_obj.pos - knots_positions[1])
		dir = normalize (knots_positions[1] - support_obj.pos)

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

		axis_of_plane_defined_by_vectors = normalize (cross dir vec)

		rtm = AngleAxis (angle_vectors) ( axis_of_plane_defined_by_vectors )

		tempObjTM = Translate ( Rotate ( ScaleMatrix  tm.scale) (tm.rotation*rtm))  tm.pos

		WorldAlignPivot support_obj

		rot = Inverse tempObjTM.rotation

		in coordsys local support_obj.rotation *= rot

		support_obj.objectoffsetrot *= rot
		support_obj.objectoffsetpos *= rot

		--support_obj.pivot = p1
	),

	/** Set pivot to position
	 */
	function _setPivotToSecondPoint =
	(
		--format "\n"; print "SupportRaftBaseObject._alignPivotToSeconPoint()"
		support_obj.pivot = knots_positions[2]
	),

	/** Test collision with source object
	 */
	function _intersectRaySourceObject pos direction =
	(
		--format "\n"; print "SupportRaftBaseObject.testCollision()"
		--format "pos: %\n" pos
		/** Modify pos
		 */
		function modifyPos _pos axis val =
		(
			--format "\n"; print ".modifyPos()"
			_pos = copy _pos

			_pos[axis] += val

			_pos --return
		)

		local hit_result

		if source_obj != undefined then
		(
			half_of_bar_width = SUPPORT_OPTIONS.bar_width / 2
	
			pos += 0.1 * direction
	
			bar_bbox = #(
				modifyPos pos 1 half_of_bar_width,
				modifyPos pos 1 (half_of_bar_width * -1),
				modifyPos pos 2 half_of_bar_width,
				modifyPos pos 2 (half_of_bar_width * -1),
				pos
			)
	
			for pos in bar_bbox do
				if ( hit = intersectRay source_obj ( Ray pos direction) ) != undefined then
					hit_result = copy hit
		)

		hit_result --return
	),

	/** Reset knots
	 */
	function _resetThisObject =
	(
		this.knots_positions = Array (2)

		this.is_on_ground = false

		this.hit_support = undefined
	),

	/*------------------------------------------------------------------------------

		HELPERS

	--------------------------------------------------------------------------------*/
	
	/** Is on ground
	 */
	function _isOnGround =
	(
		--format "\n"; print "SupportObject_v.isOnGround()"
		--is_on_ground = hit_raft == undefined and hit_support == undefined
		new_value = obj_type == #SUPPORT and hit_raft == undefined and hit_support == undefined
		
		if is_on_ground == undefined or is_on_ground != new_value then
		(
			is_on_ground = new_value
			
			setUserPropVal support_obj "IS_ON_GROUND" is_on_ground
		)
	),
		
	/** Shift wirecolor sligtly
	  * Each level of points has different wirecolor for better selection
	  */
	function _shiftWirecolor wirecolor i =
	(
		--format "\n"; print "SupportRaftBaseObject.shiftWirecolor()"
		--format "wirecolor:	% \n" wirecolor
		wirecolor_shifted = copy wirecolor


		if wirecolor_shifted.r >= abs i then wirecolor_shifted.r -= i
		if wirecolor_shifted.g >= abs i then wirecolor_shifted.g -= i
		if wirecolor_shifted.b >= abs i then wirecolor_shifted.b -= i
		--format "wirecolor_shifted:	% \n" wirecolor_shifted

		wirecolor_shifted --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportObject.onCreate()"
		--format "SUPPORT_OPTIONS: %\n" SUPPORT_OPTIONS		
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
