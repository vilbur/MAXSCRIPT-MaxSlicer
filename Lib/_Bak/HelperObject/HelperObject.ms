/** Helper object
 */
struct HelperObject_v
(
	/* construct */

	--source_obj,
	--vertex_index,
	--pos,
	--normal,
	--wirecolor,
	--
	/* properties */
	point_helper,
	--
	--old_points 	= #(),
	--points_positions	= #(), -- vertex positions to generate platforms
	--
	--/* dependency */
	--/* reference */
	--/* inhered */
	--Options,

	/** Generate points
	 */
	function generatePoints knots_positions =
	(
		format "\n"; print "HelperObject_v.generatePoints()"
		function showBox i   = if ( old_point = old_points[i] ) != undefined then old_point.box   else i==1
		function showCross i = if ( old_point = old_points[i] ) != undefined then old_point.cross else true

		points_created	= #()

		format "knots_positions: %\n" knots_positions
		format "count: %\n" knots_positions.count

		--for old_point in old_points do
		--	format "isValidNode old_point: %\n" (isValidNode old_point)
		----delete old_points

		--this._setSecondPointPosition (pos)


		for i = 1 to knots_positions.count do
		(
			--_point = Point name:(this._getName()) pos:knots_positions[i] size:(SUPPORT_OPTIONS.bar_width * 2) wirecolor:(this._shiftWirecolor(i)) Box:(showBox(i)) Cross:(showCross(i)) showLinks:true
			_point = Point pos:knots_positions[i] size:(SUPPORT_OPTIONS.bar_width * 2)  showLinks:true

			--format "\n---------------\n"

			/* SET FIRST TOP POINT OF SUPPORT AS MAIN POINT HELPER */
			if i == 1 then
			(
				this.point_helper = _point

				if knots_positions.count > 1 then
					this._alignToVector (_point) (_point.pos) (knots_positions[i + 1]) -- HOT FIX THEN ALIGN BY NORMAL ( SINGLE VALUE ) WILL WORK
			)
			else
				this._alignToVector (_point) (knots_positions[i - 1]) (_point.pos)

			/* LINK FIRST POINT TO SOURCE OBJECT, OTHER POINTS ARE LINKED IN CHAIN  */
			_point.parent = if i == 1 then source_obj else points_created[points_created.count]

			/* ADD TO LAYER OF SOURCE OBJECT */
			--source_obj.layer.addNode _point

			/* SAVE USER PROPS DATA TO OBEJCT */
			--this._saveUserDataToPointHelper()

			append points_created _point
		)

		--/* RELINK CHILDREN OF LAST POINTS */
		--if old_points.count > 0 and (old_point_last = old_points[old_points.count]).children.count > 0 then
		--	old_points[old_points.count].children[1].parent = points_created[points_created.count]

		--for old_point in old_points do
		--delete old_points

		/* ADD TO PARENT GROUP BY source object */
		--this._addToGroup (points_created) (source_obj)

		--point_helper --return first point
		points_created --return

	),

	/** Create helper
	 */
	function createHelper =
	(
		--format "\n"; print "HelperObject_v.createOrUpdateHelper()"
		--format "old_points	= % \n" this.old_points

		function showBox i   = if ( old_point = old_points[i] ) != undefined then old_point.box   else i==1
		function showCross i = if ( old_point = old_points[i] ) != undefined then old_point.cross else true

		points_created	= #()

		--for old_point in old_points do
		--	format "isValidNode old_point: %\n" (isValidNode old_point)
		----delete old_points

		this._setSecondPointPosition (pos)


		for i = 1 to this.points_positions.count do
		(
			_point = Point name:(this._getName()) pos:this.points_positions[i] size:(this.Options.bar_width * 2) wirecolor:(this._shiftWirecolor(i)) Box:(showBox(i)) Cross:(showCross(i)) showLinks:true

			--format "\n---------------\n"

			/* SET FIRST TOP POINT OF SUPPORT AS MAIN POINT HELPER */
			if i == 1 then
			(
				this.point_helper = _point

				if points_positions.count > 1 then
					this._alignToVector (_point) (_point.pos) (points_positions[i + 1]) -- HOT FIX THEN ALIGN BY NORMAL ( SINGLE VALUE ) WILL WORK
			)
			else
				this._alignToVector (_point) (points_positions[i - 1]) (_point.pos)

			/* LINK FIRST POINT TO SOURCE OBJECT, OTHER POINTS ARE LINKED IN CHAIN  */
			_point.parent = if i == 1 then source_obj else points_created[points_created.count]

			/* ADD TO LAYER OF SOURCE OBJECT */
			source_obj.layer.addNode _point

			/* SAVE USER PROPS DATA TO OBEJCT */
			this._saveUserDataToPointHelper()

			append points_created _point
		)

		/* RELINK CHILDREN OF LAST POINTS */
		if old_points.count > 0 and (old_point_last = old_points[old_points.count]).children.count > 0 then
			old_points[old_points.count].children[1].parent = points_created[points_created.count]

		--for old_point in old_points do
		delete old_points

		/* ADD TO PARENT GROUP BY source object */
		this._addToGroup (points_created) (source_obj)

		point_helper --return first point

	),

	private

	/** Find position of second point of line
	  *
	  * Direction of that point is along normal or straig down
	  *
	  */
	function _setSecondPointPosition vert_pos =
	(
		--format "\n"; print "HelperObject_v._setSecondPointPosition()"
		--format "this.Options.keep_down: %\n" this.Options.keep_down
		/** Set second point by normal of vertex
		 */
		function setSecondByNormal vert_pos _normal =
		(
			--format "\n"; print "HelperObject_v.setSecondByNormal()"
			--format "_normal: %\n" _normal
			/** Get ray to ground
			 */
			function getRayToGround second_vert_pos = Ray second_vert_pos [0,0,-1]

			local second_vert_pos = copy vert_pos

			/* MOVE SECOND POINT ALONG NORMAL OF FIRST POINT */
			second_vert_pos += this.Options.normal_length * _normal

			/* EXTEND SECOND POINT ALONG NORMAL IF INTERSECT WITH OBJECT ON ITS WAY TO TTHE GROUND */
			while (intersection = intersectRay source_obj (getRayToGround(second_vert_pos))) != undefined do
				second_vert_pos += this.Options.bar_width * _normal

			/* MOVE SECOND POINT LITTLE MORE TO MAKE SURE THAT IT NOT COLLIDE WITH OBJECT */
			second_vert_pos += this.Options.bar_width * _normal


			/* KEEP SECOND POINT BELLOW FIRST OF GIVEN AMOUNT */
			--if this.Options.keep_down and ( second_vert_pos.z - second_vert_pos.z ) < 0 then
				--second_vert_pos.z = vert_pos.z - this.Options.keep_down_limit

			second_vert_pos --return
		)

		/** Set second down
		 */
		function setSecondDown vert_pos =
		(
			--format "\n"; print "HelperObject_v.setSecondDown()"
			vert_pos.z -= this.Options.normal_length

			--append this.points_positions vert_pos
			vert_pos --return
		)

		local _normal = if this.normal != undefined then this.normal * source_obj.transform - source_obj.pos


		/* ADD FIRST POINT */
		append this.points_positions (vert_pos )

		/* ADD SECOND POINT */
		second_point_pos = case this.Options.second_point_direction of
		(
			1: setSecondByNormal	(copy vert_pos)( normalize _normal)
			2: setSecondDown	(copy vert_pos)
		)

		/* CHECK POSITION ABOVE GROUND, POINT IS NOT CRETED IF BOTTOM SPACE IS NOT 2x BASE HEIGH */
		if second_point_pos != undefined and second_point_pos.z >= this.Options.base_height * 2 then
			append this.points_positions second_point_pos

	),

	/** Get name
	 */
	function _getName =
	(
		--format "\n"; print "HelperObject_v._getName()"

		name_stripped = substituteString source_obj.name "-source" ""

		name_stripped + "-point-" + vertex_index as string -- + "-" + index as string
	),


	/** Align to ctor
	 */
	function _alignToVector obj point_to_rotate obj_pos =
	(
		--format "\n"; print "HelperObject_v._alignToVector()"
		--format "obj	= % \n" obj
		--format "% %\n" point_to_rotate obj_pos

		dir = normalize (obj_pos - point_to_rotate)
		--format "dir: %\n" dir

		axis = #z

		vec = case axis of
		(
			#x: obj.transform[1]
			#y: obj.transform[2]
			#z: obj.transform[3]
		)

		tm  = obj.transform
		vec = normalize vec
		dir = normalize dir

		angle_vectors = acos (dot vec dir) -- get angle between

		axis_of_plane_defined_by_vectors = normalize (cross dir vec)

		rtm = AngleAxis (angle_vectors) ( axis_of_plane_defined_by_vectors )

		obj.transform = Translate ( Rotate ( ScaleMatrix tm.scale) (tm.rotation*rtm)) tm.pos

		if pos == true then
			obj.pos = point_to_rotate
	),

	--/** Align to ctor
	-- */
	--function _alignToNormal obj =
	--(
	--	format "\n"; print "HelperObject_v._alignToNormal()"
	--	--format "obj	= % \n" obj
	--	--format "% %\n" point_to_rotate obj_pos
	--
	--
	--
	--	obj_pos = obj.pos
	--	--point_to_rotate = obj.pos	+ ( 10.0	* normal )
	--	point_to_rotate = obj.pos + ( 10.0	* normal )
	--
	--
	--
	--	--format "normal: %\n" ((normal))
	--	--normal = normalize (obj_pos - point_to_rotate)
	--	dir = normalize (obj_pos - point_to_rotate)
	--	--dir = normal * -1
	--
	--	--format "dir: %\n" dir
	--	axis = #z
	--
	--	vec = case axis of
	--	(
	--		#x: obj.transform[1]
	--		#y: obj.transform[2]
	--		#z: obj.transform[3]
	--	)
	--
	--	tm	= obj.transform
	--	vec	= normalize vec
	--	normal	= normalize dir
	--
	--	angle_vectors = acos (dot vec dir) -- get angle between
	--
	--	axis_of_plane_defined_by_vectors = normalize (cross dir vec)
	--
	--	rtm = AngleAxis (angle_vectors) ( axis_of_plane_defined_by_vectors )
	--
	--	obj.transform = Translate ( Rotate ( ScaleMatrix tm.scale) (tm.rotation * rtm)) tm.pos
	--
	--	--if pos == true then
	--		--obj.pos = pos
	--),

	/** Set data about source object to first  point
	  *
	  * IMPORTANT: Other point in chain are without user data for easy editation, copy, linking etc.
	  *
	 */
	function _saveUserDataToPointHelper =
	(
		--format "\n"; print "HelperObject_v._saveUserDataToPointHelper()"
		--Options.syncProp source_obj point_helper #SUPPORTS_SOURCE destination_key:#pointer_sync

		Options.setProp point_helper #POINTER_SYNC  (( Options.getProp source_obj #SUPPORTS_SOURCE ) as IntegerPtr )
		Options.setProp point_helper #THIS	  ( getHandleByAnim point_helper )
		Options.setProp point_helper #SOURCE_VERT	  ( vertex_index )
	),

	/** Shift wirecolor sligtly
	  * Each level of points has different wirecolor for better selection
	  */
	function _shiftWirecolor i =
	(
		--format "\n"; print "PlatformGenerator_v.shiftWirecolor()"
		--format "wirecolor:	% \n" wirecolor
		wirecolor_shifted = copy this.wirecolor


		if wirecolor_shifted.r >= abs i then wirecolor_shifted.r -= i
		if wirecolor_shifted.g >= abs i then wirecolor_shifted.g -= i
		if wirecolor_shifted.b >= abs i then wirecolor_shifted.b -= i
		--format "wirecolor_shifted:	% \n" wirecolor_shifted

		wirecolor_shifted --return
	),

	/** Add to group
	 */
	function _addToGroup new_members search_group_obj =
	(
		/** Find group
		 */
		function _findGroup obj =
		(
			--format "\n"; print "SupportGenerator_v.findGroup()"
			if isGroupMember obj then
			(
				while not isGroupHead obj.parent do
					obj = obj.parent

				obj.parent --return
			)
		)

		if new_members.count > 0 and ( _group = _findGroup search_group_obj ) != undefined then
			attachNodesToGroup new_members _group
	),


	/**
	 */
	on create do
	(
	)
)