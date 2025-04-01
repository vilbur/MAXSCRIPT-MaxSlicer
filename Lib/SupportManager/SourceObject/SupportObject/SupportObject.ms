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

	support_key, -- pointer of support when node is created
	sync_key,

	
	/* properties */
	points = #(),

	--is_on_ground= true,
	foot_enabled = true,
	foot_exists  = false,

	hit_raft,
	hit_leg,
	
	/* dependency */
	SupportRaft	= SupportRaft_v(this),
	SupportLeg	= SupportLeg_v (this),
	SupportFoot	= SupportFoot_v(this),
	
	/* support properties */
	normal_length,
	bar_width,
	base_height,
	chamfer_val,
	
	dir_vector,
	--min_leg_pos,    -- minimal z position of leg knot where leg without foot can be created
	--min_foot_pos,   -- minimal z position of leg knot where foot can be created, value is varied by angle of support
	min_leg_length,     -- min length of raft part to avoid sweep artifact on leg knot
	min_raft_length,
	min_support_pos,
	
	private

	spline_1 = 1, -- each support line has ony 1 spline
	
	--height_offset = 0.1, -- MINIMAL SPACE BETWEEN LEG AND BASE KNOTS
	height_offset = 0.5, -- MINIMAL SPACE BETWEEN LEG AND BASE KNOTS

	public


	/** Generate support
	  * 
	  * @param point3	first_knot_pos	top position of support
	  * @param #DOWN|point3	direction	dir_vector of direction from 1st to 2nd point
	  * @param color	wirecolor	of support object
	 */
	function generateSupport vertex_index first_knot_pos: direction:#DOWN dir_vector:undefined wirecolor:( color ( random 100 255) ( random 100 255) ( random 100 255)) =
	(
		format "\n----------------------------------------------\n"
		format "\n"; print "SupportObject_v.generateSupport()"
		
		function isLegPointAboveMinimalLimit leg_point = ( leg_point as string ) as float >= ( min_leg_length as string ) as float
		
		this._setSupportObject(wirecolor)
		
		this._setDirVector(dir_vector)

		this._saveProps()
		
		--min_raft_length = bar_width / 2.0
		min_raft_length = bar_width 
		
		min_leg_length = base_height + height_offset
		
		min_support_pos = min_leg_length + 1
		--SupportRaft.createRaft (first_knot_pos) (dir_vector)
		
		this.points = #( first_knot_pos )


		
		/*------------------------------------------------------------------------------
			SET SUPPORT LINE POINTS
		--------------------------------------------------------------------------------*/
		
		this._setSupportLinePoints()
		
			--	
		--/* MAKE SURE THAT SUPPORT DIRECTION OF SUPPORT IS NOT HORIZONTAL */ 
		--if this.dir_vector.z > -0.25 then this.dir_vector.z = -0.25
		--
		--
		--/* ADD FIRST POINT */
		--points = #( first_knot_pos, undefined )
		--
		--
		--/* SET LIMITS WHEN SECOND POINT IS KNOWN */ 
		--this._setMinLimints (direction) new_support:new_support
		--
		--
		--/* SET RAFT PART of support */ 
		--this._setSecondKnotPosition(first_knot_pos) --(dir_vector)
		--
		--
		--/* SET LEG AND FOOT */ 
		--if obj_type == #SUPPORT and hit_raft == undefined then
		--	this._setLegAndFootKnotPositions()

			
		/*------------------------------------------------------------------------------
			CREATE SUPPORT
		--------------------------------------------------------------------------------*/
				
		this._drawLine()

		this._setMaterialsToLineSegments()
		
		this._setName(vertex_index)
		
		this._setPivotToSecondPoint()
		
		--this._alignPivotToRaft()
		--
		--SUPPORT_MANAGER.addSupportObjects (this)
		--
		SUPPORT_MANAGER.updateShapeAdd (support_obj)

		--setUserPropVal support_obj "NORMAL_LENGTH" ( distance points[1] points[2]  )

		/* RETURN */ 
		this
	),
	
	/** Update supports position
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
		format "\n"; print "SupportObject_v.updateSupport()"
		----format "first_knot_pos: %\n" first_knot_pos
		--format "update_raft: %\n" update_raft
		--format "update_leg: %\n" update_leg
		
		--points = this._getPointsPositionsFromLine()
		
		/* GET 1st knot POSITION FROM LINE */ 
		if first_knot_pos == undefined then
			first_knot_pos = getKnotPoint support_obj spline_1 1
		

		/*------------------------------------------------------------------------------
			PREPARE UPDATE
		--------------------------------------------------------------------------------*/
		
		points = #(first_knot_pos, support_obj.pos)

		this._setDirVector(dir_vector)

		this._keepVectorDown()
		
		
		/*------------------------------------------------------------------------------
			UPDATE SUPPORT LINE POINTS
		--------------------------------------------------------------------------------*/
		
		this._setSupportLinePoints()
			
		
		/*------------------------------------------------------------------------------
			POST UPDATE
		--------------------------------------------------------------------------------*/
		
		foot_exists = SupportRaft.hit_raft == undefined and SupportLeg.hit_leg == undefined and SupportRaft.is_space_for_leg

		this._updateCountOfKnots()
		
		this._updateKnotsPositionByPoints()
		
		this._setPivotToSecondPoint()
		
		----this._alignPivotToRaft()
		
		this._setMaterialsToLineSegments()
		
		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),
	
	/** Set support line points
	 */
	function _setSupportLinePoints =
	(
		format "\n"; print "SupportObject_v._setSupportLinePoints()"
		
		/* CREATE RAFT */ 
		SupportRaft.createRaft()
		

		/* CREATE LEG */ 
		--if SupportRaft.hit_raft == undefined and SupportRaft.is_space_for_leg then 
		if SupportRaft.hit_raft == undefined then 
			SupportLeg.createLeg( if SupportRaft.is_space_for_foot then min_leg_length else 0 )
		
		/* CREATE FOOT */ 
		if SupportLeg.hit_leg == undefined and SupportRaft.is_space_for_foot then 
			SupportFoot.createFoot()
	),
	
	
	/** Get support points
	 */
	function _getSupportPoints =
	(
		--format "\n"; print "SupportObject_v._getSupportPoints()"

		SupportRaft.createRaft()
		
		
		/* CREATE LEG */ 
		if SupportRaft.hit_raft == undefined then 
			SupportLeg.createLeg()
		
		
		/* CREATE FOOT */ 
		--if SupportLeg.hit_leg == undefined and SupportRaft.raft_is_full then 
		if SupportLeg.hit_leg == undefined then 
			SupportFoot.createFoot()

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



	--/** Update leg position
	-- */
	--function updateSupportHeight =
	--(
	--	format "\n"; print "SupportObject_v.updateSupportHeight()"
	--	
	--	points = this._getPointsPositionsFromLine()
	--
	--	format "TEST: %\n" (points[2].z < min_leg_length )
	--	
	--	if points[2].z < min_leg_length then
	--	(
	--		points[2] = SupportRaft.makeRaftShorter()
	--		--points[2].z = min_leg_length
	--		
	--	)
	--	
	--	
	--	if foot_exists then
	--	(
	--		SupportFoot.createFoot()
	--		
	--		--format "points: %\n" this.points
	--	)
	--
	--	this._updateKnotsPositionByPoints start_knot:2
	--
	--	SUPPORT_MANAGER.updateShapeAdd (support_obj)
	--),
	
	/** Update base height
	 */
	function updateBaseHeight =
	(
		format "\n"; print "SupportObject_v.updateBaseHeight()"
		--format "support_obj: %\n" support_obj.name
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
		--format "\n"; print "SupportObject_v.isRaft()"
		getUserPropVal support_obj "RAFT_KEY" != undefined
	),

	/** Is vector pointing down
	 */
	function isVectorPointingDown =
	(
		--format "\n"; print "SupportObject_v.isVectorPointingDown()"
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
		--format "\n"; print "SupportObject_v.intersectRaySourceObject()"
		--format "pos: %\n" pos
		--format "direction: %\n" direction
		
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
			half_of_bar_width = this.bar_width / 2
	
			pos += 0.1 * direction -- shift ray pos along vector outside of object
	
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


	--private
	
	/** Create new support object or get existing and delete spline subobject
	 */
	function _setSupportObject wirecolor =
	(
		--format "\n"; print "SupportObject_v._getSupportNode()"
		/* CREATE NEW OBJECT */ 
		if support_obj == undefined then
			support_obj = SplineShape wirecolor:wirecolor
		
		else /* USE OLD OBEJCT - RESET SPLINE */ 
			deleteSpline support_obj spline_1
	),
	
	/** Save props
	 */
	function _saveProps =
	(
		--format "\n"; print "SupportObject_v._saveProps()"
        bar_width     = SUPPORT_OPTIONS.getOption #BAR_WIDTH
        base_height   = SUPPORT_OPTIONS.getOption #BASE_HEIGHT
        normal_length = SUPPORT_OPTIONS.getOption #NORMAL_LENGTH
		
		chamfer_val = SUPPORT_OPTIONS.getChamferBarValue()

        setUserPropVal support_obj "NORMAL_LENGTH"  normal_length
        setUserPropVal support_obj "BAR_WIDTH"		bar_width
        setUserPropVal support_obj "BASE_HEIGHT"	base_height
        setUserPropVal support_obj "CHAMFER_VAL"	chamfer_val

		setUserPropVal support_obj "DIR_VECTOR" dir_vector
		
	),
	
	/** Get points positions from line
	 */
	function _getPointsPositionsFromLine =
	(
		--format "\n"; print "SupportObject_v._getPointsPositionsFromLine()"
		for knot = 1 to numKnots support_obj spline_1 collect getKnotPoint support_obj spline_1 knot
	),
		
	/** Get vector of raft from current line if not defined
	  * 
	 */
	function _setDirVector dir_vector =
	(
		this.dir_vector = if dir_vector != undefined then dir_vector else normalize ( support_obj.pos - points[1] )
	),
		
	/** KEEP RAFT PONT BELLOW FIRST
	  * 
	  * Make sure that dir_vector of support is not horizontal or up
	 */
	function _keepVectorDown =
	(
		--format "\n"; print "SupportObject_v._keepVectorDown()"
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
			--format "\n"; print "SupportObject_v.addKnots()"
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
			--format "\n"; print "SupportObject_v.removeKnots()"
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
		--format "\n"; print "SupportObject_v._updateKnotsPositionByPoints()"
		--format "points: %\n" points
		--format "points.count: %\n" points.count
		
		for knot_i = start_knot to points.count do
			setKnotPoint support_obj spline_1 knot_i points[knot_i]
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
		for pos in points do
			addKnot support_obj spline_1 #corner #line pos

		SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),
	
	/** Set nide name
	 */
	function _setName vertex_index =
	(
		--format "\n"; print "SupportObject_v._getName()"
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
	
	/** Align to vector
	 */
	function _alignPivotToRaft =
	(
		format "\n"; print "SupportObject_v._alignPivotToRaft()"
		--support_obj = $
		--dir = normalize (support_obj.pos - points[1])
		--dir = normalize ( points[1] - support_obj.pos )
		--dir = normalize ( (  getKnotPoint support_obj spline_1 1 ) - ( getKnotPoint support_obj spline_1 2 ) )
		--dir = this.dir_vector
		
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
		format "angle_vectors: %\n" angle_vectors
		
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
			--format "tempObjTM: %\n" tempObjTM
			WorldAlignPivot support_obj
	
			rot = Inverse tempObjTM.rotation
	
			in coordsys local support_obj.rotation *= rot
	
			support_obj.objectoffsetrot *= rot
			
			support_obj.objectoffsetpos *= rot
			
		)
		else
		(
			--format "\n"; format "SupportObject_v._alignPivotToRaft() %" support_obj.name
			--format " ANGLE_VECTORS: %\n" angle_vectors
		)

		--support_obj.pivot = p1
	),

	/** Set pivot to position
	 */
	function _setPivotToSecondPoint =
	(
		--format "\n"; print "SupportObject_v._alignPivotToRaft()"
		support_obj.pivot = getKnotPoint support_obj spline_1 2
	),
	
	/** Set materials to line segments
	 */
	function _setMaterialsToLineSegments =
	(
		--format "\n"; print "SupportObject_v._setMaterialsToLineSegments()"
		--format "foot_exists: %\n" foot_exists
		--format "SupportRaftUpdater.foot_exists: %\n" SupportRaftUpdater.foot_exists
		num_of_segments = numSegments support_obj ( numSplines support_obj)
	
		for segment_i = 1 to num_of_segments do
			setMaterialID support_obj spline_1 segment_i SUPPORT_OPTIONS.mat_ids[#MIDDLE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
	
		/*------ SET MATERIAL TO GROUND SEGMENT ------*/
		if foot_exists then
			setMaterialID support_obj spline_1 num_of_segments SUPPORT_OPTIONS.mat_ids[#BASE] -- setMaterialID <splineShape> <spline_1> <seg_index> <matID>
	),




	/**
	 */
	on create do
	(
		--format "\n"; print "SupportObject.onCreate()"
		--this._setSupportRaftUpdater()
	)

)
