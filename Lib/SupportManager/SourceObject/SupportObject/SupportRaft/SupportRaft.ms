/** Support raft
 */
struct SupportRaft_v
(
	/* construct */
	Support, -- parent class

	/* required */
	/* properties */
	hit_raft,
	--is_space_for_leg = true,
	--foot_space_exists = true,

	max_raft_auto_length = 10, -- max length of raft if space for leg not found on generate
	
	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	
	/* COMPARE FLOATS - is A >= B */ 
	function isMoreThen A B = (( A as string ) as float ) >= (( B as string ) as float ),
	
	function raftLenght = (distance this.Support.points[2] this.Support.points[3]),
	--function getRaftLenght = (distance ( getKnotPoint Support.support_obj 1 2) ( getKnotPoint Support.support_obj 1 3)),

	/** Generate raft
	 */
	function createRaft update_or_generate: =
	(
		--format "\n----------------------------------------------\n"
		 --format "\n"; print "SupportRaft_v.createRaft()"
		-- format "Support.obj_type: %\n" Support.obj_type
		-- format "Support.raft_vector:    %\n" Support.raft_vector
		--for i = 1 to Support.points.count do
		--format "Support.points[i].z: %\n" Support.points[i].z
		
		/*------------------------------------------------------------------------------
			HELPERS
		--------------------------------------------------------------------------------*/
		--function raftLenght = (distance this.Support.points[2] this.Support.points[3])

		function raftHasMinLenght     = isMoreThen ( this.raftLenght() )  ( Support.min_length_by_angle )
		function raftHasFullLenght    = isMoreThen ( this.raftLenght() )  ( Support.raft_length )

		function notSupportInMininmalMode = Support.raft_vector != [0,0,-1] --and ( Support.direction != #NORMAL or Support.direction != #CUSTOM )
		
		function getRaftEndPoint Support raft_length = Support.points[2] + ( raft_length * Support.raft_vector )
		--function isSpaceForRaftAndLeg = isMoreThen ( Support.points[2].z) ( Support.min_length_by_angle + Support.min_leg_pos + 0.2 )
		function isLegPointAboveMinLimit min_z_pos = isMoreThen ( Support.points[3].z ) ( min_z_pos )
		
		/*------------------------------------------------------------------------------
			CREATE RAFT
		--------------------------------------------------------------------------------*/
		
		/* USE CURRENT OR MINIMAL LENGTH OF RAFT */ 
		--raft_length = if Support.raft_mode == 1 then Support.min_length_by_angle else Support.raft_length
		
		
		--raft_length = Support.min_length_by_angle
		raft_length = if update_or_generate == #GENERATE then Support.raft_length else this.raftLenght()
		--raft_length = Support.raft_length
		

		/* IF RAFT LENGTH IS 0 THEN MIN RAFT LENGTH IS USED */
		if update_or_generate == #GENERATE then
		(
			/*------------------------------------------------------------------------------
				GET RAFT LENGTH
			--------------------------------------------------------------------------------*/
			raft_length = case SUPPORT_OPTIONS.raft_mode of
			(
				/* CUSTOM raft length */ 
				0: Support.raft_length
				
				/* MINIMAL raft length */ 
				1: Support.min_length_by_angle
				--1: 0.1
				
				/* AUTO raft length */ 
				2: (
					
					/* START SEARCH WITH MINIMAL RAFT LENGTH */ 
					raft_length = Support.min_length_by_angle
					
					raft_end = getRaftEndPoint (Support) (raft_length)
			
					/* SEARCH FOR RAFT LENGTH WHERE IS POSSIBLE TO CREATE LEG	*/ 
					while ( Support.intersectRaySourceObject ( raft_end ) [0,0,-1] ) != undefined and raft_length <= max_raft_auto_length do
					(
						/* EXTEND RAFT LENGTH ABOUT SUPPORT WIDTH EACH TIME */ 
						raft_length += Support.bar_width
						
						/* SET TEMP SECOND POINT FOR NEXT LOOP */ 
						raft_end = getRaftEndPoint (Support) (raft_length)
					)
					
					/* USE MINIMAL RAFT LENGTH IF SPACE FOR LEG OT FOUND */ 
					if raft_length >= max_raft_auto_length then
						raft_length = Support.min_length_by_angle
					
					--raft_length += 0.1
					
					raft_length --return
				 )
			)
			
			--Support.points[3] = getRaftEndPoint (Support) (raft_length)
			
		)
		else
		(
			--Support.points[3] = getKnotPoint Support.support_obj 1 3
			--raft_length = this.getRaftLenght()
			--format "pivot: %\n" Support.support_obj.pos
			--Support.points[3] = Support.support_obj.pos
			
		)

		Support.points[3] = getRaftEndPoint (Support) (raft_length)
		--format "RAFT_LENGTH: %\n" raft_length
			
		/*------------------------------------------------------------------------------
			SET POINT  OF RAFT END
		--------------------------------------------------------------------------------*/
		

		/*------------------------------------------------------------------------------
			TEST HIT SOURCE OBJECT
		--------------------------------------------------------------------------------*/
		
	    hit_raft = this._testHitOfSourceObject( raft_length )
		 
		/*------------------------------------------------------------------------------
			MANAGE CASE OF SUUPORT IS LOW ABOVE GROUND
		--------------------------------------------------------------------------------*/
		if hit_raft == undefined then
		(
			--if Support.obj_type == #SUPPORT then
			(
				/* EXTEND RAFT TO FULL LENGTH BEFORE UPDATE */ 
				if not raftHasFullLenght() then
					this._extendSecondPoint( raft_length )
				
				
				/* SHORTEN REAFT IF ITS TOO LONG and goes under min size of leg ( foot can not be created ) */ 
				if not isLegPointAboveMinLimit( Support.min_foot_pos ) then
					this._shortenRaftOnDirection( Support.min_foot_pos )
				
				
				/* IF RAFT IS TOO SHORT ( small support without foot ) */ 
				if not raftHasMinLenght() then
				(
					format "RAFT IS TOO SHORT\n"
					/* MAKE SURE THAT RAFT HAS MINIMAL LENGTH ( at least ) */ 
					this._extendSecondPoint( raft_length )
					
					/* SET RAFT POINT TO GROUND - if support is too low on the ground */ 
					if Support.points[3].z < Support.min_leg_pos then
						this._shortenRaftOnDirection( Support.min_leg_pos )
				)
				
				
				/* SUPPORT MINIMAL MODE - only 2 points straight to ground - if support has not minimla height */ 
				if Support.points[3].z > Support.points[2].z then
				(
					format "NOT SPACE FOR RAFT AND LEG\n"
					pos = copy Support.points[2]
					
					pos.z = 0
					
					Support.points[3] = pos
				)
			)
			--else
				--this._shortenRaftOnDirection( 0 )
		)
		
		/*------------------------------------------------------------------------------
			GET POSITION OF HIT
		--------------------------------------------------------------------------------*/
		else
		(
			Support.points[3] = hit_raft.pos
			-- format "not raftHasMinLenght(): %\n" (not raftHasMinLenght())
			
			--Point pos:hit_raft.pos size:0.5 wirecolor:red box:true name:("GRID-SEEDER-HELPER-HIT-"+ Support.sync_key as string )
		
			--if Support.obj_type == #RAFT and not raftHasMinLenght() then
			--(
			--	add_to_min_distance = (Support.min_length_by_angle * 1.5 ) - distance Support.points[2] Support.points[3]
			--
			--	line_vector = normalize (Support.points[3] - Support.points[2])
			--
			--	Support.points[3] = Support.points[3] + ( add_to_min_distance * line_vector )
			--)
		)
		
		
		/*------------------------------------------------------------------------------
			GET DATA ABOUT STATE OF SUPPORTs
		--------------------------------------------------------------------------------*/
		--is_space_for_leg = isSpaceForRaftAndLeg()
		--foot_space_exists = isLegPointAboveMinLimit( Support.min_foot_pos )
		--format "FOOT_SPACE_EXISTS: %\n" foot_space_exists
		
		/* SAVE DIR VECTOR IF SUPPORT IS NOT MINIMAL */ 
		if notSupportInMininmalMode() then 
			setUserPropVal Support.support_obj "RAFT_VECTOR" Support.raft_vector
		
		--if raftHasFullLenght() then
		/* SAVE RAFT LENGTH IF NOT LOCKED, AUTO OR NOT SHORTENED */ 
		if not SUPPORT_OPTIONS.lock_raft_length and Support.raft_length > 0 and raftHasFullLenght() then
			setUserPropVal Support.support_obj "RAFT_LENGTH" raft_length

	),
	
	/** Make raft shorter
	 */
	function _shortenRaftOnDirection pos_z =
	(
		format "\n"; print "SupportRaft_v._shortenRaftOnDirection()"
		--format "pos_z: %\n" pos_z

		triangle_height = Support.points[2].z - pos_z
		--format "triangle_height: %\n" triangle_height
		--line_vector = normalize ( Support.points[2] - Support.points[3] )
		line_vector = Support.raft_vector
		
		--format "line_vector: %\n" line_vector

		angle_of_leg = acos (dot [0,0,-1] line_vector) -- get angle between
		--format "angle_of_leg: %\n" angle_of_leg

		raft_length = triangle_height / cos angle_of_leg
		--format "raft_length:  %\n" raft_length
		
		--if line_vector.z < 0 then
			Support.points[3] = Support.points[2] + ( raft_length * line_vector )
	),
	
	/** Extend raft knot to normal lenght
	  * 
	  * @return point3 coordinates of point extended to normal length
	 */
	function _extendSecondPoint raft_length =
	(
		format "\n"; print "SupportRaft_v._extendSecondPoint()"
		--format "Support.raft_vector: %\n" Support.raft_vector
		--line_vector = normalize ( Support.points[3] - Support.points[2] )
		line_vector = Support.raft_vector
		--format "line_vector.z: %\n" line_vector.z
		
		--if line_vector.z < 0 then
		Support.points[3] = Support.points[2] + ( raft_length * line_vector )
	),
	
	/** Get secon point position
	 */
	function _testHitOfSourceObject max_distance =
	(
		 --format "\n"; print "SupportRaft_v._testHitOfSourceObject()"
		-- format "max_distance: %\n" max_distance
		
		ray_pos = Support.points[2]
		 
		hit = Support.intersectRaySourceObject (ray_pos)  ( Support.raft_vector )
		-- format "hit: %\n" hit
		/* TEST IF HIT IS BETWEEN POINTS, RESET HIT IF HIT IS FURTHER THEN SECOND POINT */
		if hit != undefined and Support.obj_type == #SUPPORT and distance ray_pos hit.pos > max_distance then
			hit = undefined
		
		hit --return
	),
	
	
	/**
	 */
	on create do
	(
		--format "\n"; print "SupportRaft.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
