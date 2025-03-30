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
	points_positions = Array (2),

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
	bar_width,
	base_height,
	chamfer_val,
	
	dir_vector,
	min_leg_pos,    -- minimal z position of leg knot where leg without foot can be created
	min_foot_pos,   -- minimal z position of leg knot where foot can be created, value is varied by angle of support
	min_length,     -- min length of raft part to avoid sweep artifact on leg knot
	
	private

	spline_1 = 1, -- each support line has ony 1 spline
	
	height_offset = 0.1, -- MINIMAL SPACE BETWEEN LEG AND BASE KNOTS

	public


	/** Generate support
	  * 
	  * @param point3	first_knot_pos	top position of support
	  * @param #DOWN|point3	direction	dir_vector of direction from 1st to 2nd point
	  * @param color	wirecolor	of support object
	 */
	function generateSupport vertex_index first_knot_pos: direction:#DOWN dir_vector:undefined wirecolor:( color ( random 100 255) ( random 100 255) ( random 100 255)) =
	(
		--format "\n"
		format "\n"; print "SupportObject_v.generateSupport()"
		this.dir_vector = dir_vector
		
		bar_width   = SUPPORT_OPTIONS.getOption #BAR_WIDTH
		base_height = SUPPORT_OPTIONS.getOption #BASE_HEIGHT
		chamfer_val = SUPPORT_OPTIONS.getChamferBarValue()

		
		this._setSupportObject(wirecolor)
		
		
		SupportRaft.createRaft (first_knot_pos) (dir_vector)
		
		/* CREATE LERG */ 
		if SupportRaft.hit_raft == undefined then 
			SupportLeg.createLeg()
		
		
		/* CREATE FOOT */ 
		if SupportLeg.hit_leg == undefined then 
			SupportFoot.createFoot()

		
		--this._setSupportRaftUpdater()
		--	
		--/* MAKE SURE THAT SUPPORT DIRECTION OF SUPPORT IS NOT HORIZONTAL */ 
		--if this.dir_vector.z > -0.25 then this.dir_vector.z = -0.25
		--
		--
		--/* ADD FIRST POINT */
		--points_positions = #( first_knot_pos, undefined )
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
				
		this._setName(vertex_index)
		--
		----this._isOnGround()
		--
		this._drawLine()
		
		this._setMaterialsToLineSegments()
		
		this._setPivotToSecondPoint()
		
		this._alignPivotToRaft()
		--
		--SUPPORT_MANAGER.addSupportObjects (this)
		--
		SUPPORT_MANAGER.updateShapeAdd (support_obj)

		--setUserPropVal support_obj "NORMAL_LENGTH" ( distance points_positions[1] points_positions[2]  )

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

	/** Update supports position
	  * 
	  * 	first_knot_pos: undefined	-- GET POS FROM LINE,	WHEN SOURCE OBJECT HAS BEEN ROTATED
	  * 	first_knot_pos: Point3	-- GET POS FROM SOURCE OBJECT,	WHEN SUPPORT ITSELF HAS BEEN MOVED, to keep support sticked on source object
	  * 
	  * 
	  *	UPDATE KNOT 2 IF:
	  *    • If source object ROTATED and support direction is #DOWN
	  *    • If Support was transformed
	  * 
	 */
	function updateSupport first_knot_pos: update_knot_2:true direction: dir_vector:undefined =
	(
		--format "\n"; print "SupportObject_v.updateSupport()"
	
	
	),

	/** Update leg position
	 */
	function updateLeg points_positions: =
	(
		--format "\n"; print "SupportObject_v.updateLeg()"


		--SUPPORT_MANAGER.updateShapeAdd (support_obj)
	),
	
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



	private
	
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
	
	/** Create line
	  */
	function _drawLine =
	(
		--format "\n"; print "SupportObject_v._drawRaftLine()"
		addNewSpline support_obj

		/*------------------------------------------------------------------------------
			ADD KNOTS BY POINTS FROM TOP TO BOTTOM
		--------------------------------------------------------------------------------*/
		for pos in points_positions do
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
		--format "\n"; print "SupportObject_v._alignPivotToRaft()"

		--dir = normalize (support_obj.pos - points_positions[1])
		dir = normalize (points_positions[1] - support_obj.pos)

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
