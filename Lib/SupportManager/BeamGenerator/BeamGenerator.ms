/** Beam generator
 */
struct BeamGenerator_v
(
	/* construct */
	/* required */
	/* properties */
	--use_max_distance	= true,
	--max_distance	= 999999,
	--only_ground	= true,
	--max_connections	= 2,
	
	use_only_selected_supports	= true,
	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate beam
	 */
	function generateBeam support_A support_B =
	(
		--format "\n"; print "BeamGenerator_v.generateBeam()"
		--format "support_A: %\n" support_A
		--format "support_B: %\n" support_B
		BeamObject = (BeamObject_v support_A support_B )

		/* IF BEAM DOES NOT EXISTS YET */
		--if SUPPORT_MANAGER.BeamObjects[BeamObject.beam_key] == undefined then
		--(
			BeamObject.generateBeam()

			BeamObject.beam_key = this._getBeamKey (support_A) (support_B)

			/* SAVE SYNC KEY */
			setUserPropVal BeamObject.beam "SYNC_KEY" ( getUserPropVal support_A "SYNC_KEY" )
			setUserPropVal BeamObject.beam "BEAM_KEY"  BeamObject.beam_key

			setUserPropVal BeamObject.beam "SUPPORT_A" ( this._getSupportKey(support_A) )
			setUserPropVal BeamObject.beam "SUPPORT_B" ( this._getSupportKey(support_B) )

			/* ADD TO BEAMS */
			SUPPORT_MANAGER.BeamObjects[BeamObject.beam_key] = BeamObject

			--append new_beams BeamObject.beam

			--format "BeamObject.beam: %\n" BeamObject.beam
			BeamObject.beam --return
		--)
	),

	/** Generate beams chain
	 */
	function generateBeamsChain supports =
	(
		format "\n"; print "BeamGenerator_v.generateBeamsChain()"
		--format "supports: %\n" supports
		new_beams = #()

		sorted_supports = this._sortSupportsByDistance(supports) (SUPPORT_OPTIONS.max_distance)

		--for supports_in_cluster in sorted_supports do
			--format "SUPPORTS_IN_CLUSTER %: %\n" supports_in_cluster.count supports_in_cluster

		for supports_in_cluster in sorted_supports do
			for i = 1 to supports_in_cluster.count - 1 do
				append new_beams (this.generateBeam supports_in_cluster[i] supports_in_cluster[i + 1])

		new_beams --return
	),

	/** Generate beams to closest supports
	 */
	function generateBeamsToClosestSupports _objects only_ground:true =
	(
		--format "\n"; print "BeamGenerator_v.generateBeamsToClosestSupports()"
		--format "_objects: %\n" _objects.count
		--format "max_distance:    %\n" max_distance
		--format "max_connections: %\n" max_connections

		/** Support has not max connections
		 */
		function supportHasMaxConnections support =
		(
			--format "\n\n"; print "BeamGenerator_v.supportHasMaxConnections()"
			--format "support: %\n" support
			max_connections = SUPPORT_OPTIONS.max_connections 

			if classOf max_connections == integer and max_connections > 0 then
			(
				beams_of_support = SUPPORT_MANAGER.getObjectsByType support type:#BEAM
				--format "beams_of_support: %\n" beams_of_support
				
				--connections = (SUPPORT_MANAGER.getObjectsByType support type:#BEAM).count
				--format "connections: %\n" beams_of_support.count
				beams_of_support.count >= max_connections
			)
			else
				false
		)
		
		new_beams = #()
		procesed_supports = #()

		
		max_distance = if SUPPORT_OPTIONS.use_max_distance then SUPPORT_OPTIONS.max_distance else 999999999999999
		
		
		source_objects = SUPPORT_MANAGER.getObjectsByType ( _objects ) type:#SOURCE -- hierarchy:shift
		--format "SOURCE_OBJECTS: %\n" source_objects

		--objects_support = for obj in _objects where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj
		--format "objects_support: %\n" objects_support
		--objects_rafts    = for obj in _objects where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj
		--
		--supports = objects_support + objects_rafts
		supports = SUPPORT_MANAGER.getSupportObjects(_objects) get_nodes:true
		
		
		--format "SUPPORTS: %\n" supports
		/* USE ALL SUPPORTS OF SOURCE OBJECT OR ONLY SELECTED */
		supports_to_connect = if not use_only_selected_supports then SUPPORT_MANAGER.getObjectsByType source_objects type:#SUPPORT else supports
		--format "SUPPORTS_TO_CONNECT: %\n" supports_to_connect

		/* DO NOT USE SUPPORTS WHICH HAS MAX BEAMS COUNT ALREADY */
		this._filterSupportsByCountOfBeams (&supports_to_connect)

		/* USE ONLY SUPPORTS TOUCHING GROUND - dont use rafts and supports without foot */
		this._filterOnlyGroundedSupports(&supports_to_connect)

		--format "supports_to_connect.count: %\n" supports_to_connect.count
		--format "MAX_DISTANCE:        %\n" max_distance
		--format "SUPPORTS_TO_CONNECT: %\n" supports_to_connect
		
		
		--supports = (this._sortSupportsByDistance(supports) (max_distance))[1]
		closest_pairs = this._findClosestPairs(supports_to_connect)
		
		-- Print results
		for pair in closest_pairs do
		(
			format "Pair: % <--> %\n" pair[1].name pair[2].name
				if (new_beam = this.generateBeam pair[1] pair[2] ) != undefined then
					append new_beams new_beam
		)

		--supports = deepCopy supports_to_connect
		--supports = (this._sortSupportsByDistance(supports) (9999999999999))[1]

		--for support in supports where findItem procesed_supports support == 0 do
		--(
		--	--format "\n\n------------------ %" support.name
		--	
		--	if not supportHasMaxConnections support then
		--	(
		--		local closest_support = undefined 
		--
		--		min_distance = 9999999
		--
		--		/* GET CLOSESTS SUPPORT - BY COMPARE DISTANCES OF SUPPORTS  */
		--		for support_other in supports_to_connect \
		--			where support_other != support \                                  -- avoid compare same support
		--			and not this.beamExists support support_other  \                   -- TEST IF BEAM EXISTS ALLERADY
		--			and not supportHasMaxConnections support_other \                                  -- 
		--			and ( dist = distance support support_other ) < min_distance \	 -- TEST MIN DISTANCE BETWEEN SUPPORTS
		--			and dist <= max_distance \                                       -- TEST MAX DISTANCE BETWEEN SUPPORTS
		--		do
		--		(
		--			min_distance = dist
		--
		--			closest_support = support_other
		--			--format "CLOSEST_SUPPORT: %\n" closest_support
		--
		--			if findItem supports support_other > 0 then
		--				appendIfUnique procesed_supports support
		--		)
		--		--format "CLOSEST_SUPPORT: %\n" CLOSEST_SUPPORT
		--		/* IF CLOSESTS SUPPORT FOUND */ 
		--		if closest_support != undefined and (new_beam = this.generateBeam support closest_support) != undefined then
		--			append new_beams new_beam
		--		
		--	)
		--	else
		--		appendIfUnique procesed_supports support
		--)

		new_beams --return
	),
	
	/** 
	*	
	*/
	function _findClosestPairs supports =
	(
	
		fn compareDistanceAsc a b =
		(
			if a[1] < b[1] then -1 else if a[1] > b[1] then 1 else 0
		)
		
		/** Support has not max connections
		 */
		function supportHasMaxConnections support =
		(
			--format "\n\n"; print "BeamGenerator_v.supportHasMaxConnections()"
			--format "support: %\n" support
			max_connections = SUPPORT_OPTIONS.max_connections 

			if classOf max_connections == integer and max_connections > 0 then
			(
				beams_of_support = SUPPORT_MANAGER.getObjectsByType support type:#BEAM
				--format "beams_of_support: %\n" beams_of_support
				
				--connections = (SUPPORT_MANAGER.getObjectsByType support type:#BEAM).count
				--format "connections: %\n" beams_of_support.count
				beams_of_support.count >= max_connections
			)
			else
				false
		)
		
		/** Filters out pairs that are above average distance
		*	
		*/
		fn filterPairsByAverageDistance result =
		(
			local pair_matrix = result[1]
			local distance_matrix = result[2]
			local filtered_pairs = #()
		
			if distance_matrix.count == 0 then return filtered_pairs
		
			local total = 0.0
			for d in distance_matrix do total += d
			local avg_distance = total / distance_matrix.count
			max_allowed_distance = total / distance_matrix.count
			--max_allowed_distance = 1.0
			--max_allowed_distance = 1e6
		
			--local max_allowed_distance = avg_distance * 2
			--max_allowed_distance /= 2.0
			max_allowed_distance *= 1.5
		
			for i = 1 to distance_matrix.count do
			(
				if distance_matrix[i] <= max_allowed_distance do
				(
					append filtered_pairs pair_matrix[i]
				)
			)
		
			return filtered_pairs
		)
		
		/** Pair exist
		 */
		function pairExist pair existing_pair  =
		(
			--format "\n"; print "BeamGenerator_v.pairExist()"
			(existing_pair[1] == pair[1] and existing_pair[2] == pair[2]) or \
		    (existing_pair[1] == pair[2] and existing_pair[2] == pair[1])
		)
		
		max_connections_per_object = SUPPORT_OPTIONS.max_connections 
		
		local pair_matrix		= #()
		local distance_matrix	= #()
		local checked_pairs	= #()
	
		supports = for support in supports where not supportHasMaxConnections support collect support
	
	
		for i = 1 to supports.count do
		(
			local support = supports[i]
			local distances = #()
	
			--for j = 1 to supports.count do
			for j = 1 to supports.count where i != j do
			(
				local support_other = supports[j]
				local dist = distance support.position support_other.position
	
				append distances #(dist, support_other)
			)
	
			qsort distances compareDistanceAsc
			
			for k = 1 to (amin max_connections_per_object distances.count) do
			(
				local closest_obj = distances[k][2]
				local pair = #(support, closest_obj)
	
				local is_duplicate = false
				
				for existing_pair in checked_pairs while not is_duplicate where pairExist pair existing_pair do
					is_duplicate = true
					
				
				if not is_duplicate do
				if not this.beamExists support closest_obj then
				
				(
					append pair_matrix pair
					append distance_matrix (distance pair[1].position pair[2].position)
					append checked_pairs pair
				)
			)
		)
	
		result = #(pair_matrix, distance_matrix)		
	
		filtered_pairs = filterPairsByAverageDistance result
	
		filtered_pairs --return
	),
	
	/** connected with beams
	 */
	function beamExists support_A support_B =
	(
		--format "\n"; print "SupportManager_v.beamExists()"
		SUPPORT_MANAGER.BeamObjects[this._getBeamKey support_A support_B] != undefined
	),


	--private


	/** Get beam key
	 */
	function _getBeamKey support_A support_B =
	(
		--format "\n"; print "SupportManager_v.getBeamKey()"
		pointers = sort #( this._getSupportKey(support_A) , this._getSupportKey(support_B) )
		--format "pointers: %\n" pointers
		( pointers[1] + "x" + pointers[2] ) --return
	),

	/** Get support key
	 */
	function _getSupportKey support =
	(
		--format "\n"; print "BeamObject_v._getSupportKey()"
		if ( support_key = getUserPropVal support "SUPPORT_KEY" ) != undefined then
			support_key --return
		else
			 getUserPropVal support "RAFT_KEY"

	),

	/** Sort supports by distance
	  * Return arrays of supports sorted by closest distance.
	  * Each array contains supports which are close enought to thmeselfs.
	  *
	  * Max distance of supports is set in SUPPORT_OPTIONS.max_distance
	  *
	  * @return 2D array
	 */
	function _sortSupportsByDistance supports max_distance =
	(
		format "\n"; print "SupportManager_v.sortSupportsByDistance()"
		format "supports.count: %\n" supports.count
		for support in supports do 
			format "support.name: %\n" support.name
		
		--format "max_distance: %\n" max_distance
        sorted_all = #()
		
		
		cluster    = #()

        proccessed_supports	= #{}

        /* SET FIRST SUPPORT INDEX */
        support_i	= 1

		while support_i != undefined do
		(
			min_distance_found = 9999999

			/* GET SUPPORT NODE AND POSITION */
            support     = supports[support_i]
            support_pos = support.pos
			format "\n"
			format "support: %\n" support.name
			/* AVOID TESTING SUPPORT AGAIN */
            proccessed_supports[support_i] = true

			support_i      = undefined
			next_support_i = undefined

			--format "SUPPORT_OPTIONS.max_distance: %\n" SUPPORT_OPTIONS.max_distance
			
			/*------------------------------------------------------------------------------
				LOOP SUPPORTS AND FIND NEXT CLOSEST SUPPORT
			--------------------------------------------------------------------------------*/
			for i = 1 to supports.count where not proccessed_supports[i] do
			(
				--format "distance: %\n" (distance support_pos supports[i].pos)
				if (current_distance = distance support_pos supports[i].pos ) < min_distance_found then
					--if not use_max_distance or current_distance <= SUPPORT_OPTIONS.max_distance  then
					if current_distance <= max_distance  then
					(
						min_distance_found = current_distance
						format "next_support_i: %\n" i
						next_support_i = i
					)
			)

			/*------------------------------------------------------------------------------
				ADD SUPPORTS TO CLUSTER IF NEXT SUPPORT FOUND
			--------------------------------------------------------------------------------*/
			if next_support_i != undefined then
			(
				if cluster.count == 0 then -- create new cluster
					cluster = #(support)

				append cluster supports[next_support_i]

				support_i = next_support_i
			)
			/*------------------------------------------------------------------------------
				IF NEXT SUPPORT CLOSE ENOUGHT IS NOT FOUND
			--------------------------------------------------------------------------------*/
			else
			(
				/* ADD CLUSTER TO SORTED SUPPORTS */
				if cluster.count > 0 then
					append sorted_all cluster

				cluster = #()
			)

			/*------------------------------------------------------------------------------
				GET NEXT NOT TESTED SUPPORT
			--------------------------------------------------------------------------------*/

			if support_i == undefined then
				for i = 1 to supports.count where not proccessed_supports[i] do
					if support_i == undefined then
						support_i = i
		)

		sorted_all -- return
	),

	/** Filter supports by count of beams
	 */
	function _filterSupportsByCountOfBeams &supports =
	(
		--format "\n"; print "BeamGenerator_v._filterSupportsByCountOfBeams()"
		--format "max_connections: %\n" max_connections
		for support in supports do
		(
			beams_of_supports = SUPPORT_MANAGER.getObjectsByType support type:#BEAM
			--format "BEAMS_OF_SUPPORTS: %\n" beams_of_supports
			--format "BEAMS_OF_SUPPORTS: %\n" beams_of_supports.count
		)

		if classOf max_connections == integer and max_connections > 0 then
			supports = for support in supports where (SUPPORT_MANAGER.getObjectsByType support type:#BEAM).count < max_connections collect support

		supports --return
	),

	/** Filter supports with foot
	 */
	function _filterOnlyGroundedSupports &supports =
	(
		--format "\n"; print "BeamGenerator_v._filterSupportsByCountOfBeams()"

		if SUPPORT_OPTIONS.only_ground then
			--supports = for support in supports where support.min.z as integer == 0 collect support
			supports = for support in supports where (support.min.z as integer ) <= 0 collect support
			--for support in supports do format "support.min.z as integer: %\n" (support.min.z as integer)

		supports --return
	),
	--/** Get beam key
	-- */
	--function getBeamKey =
	--(
	--	--format "\n"; print "SupportManager_v.getBeamKey()"
	--	pointers = sort #( this._getSupportKey(support_A) , this._getSupportKey(support_B) )
	--
	--	( pointers[1] + "x" + pointers[2] ) --return
	--),

	/**
	 */
	on create do
	(
		--format "\n"; print "BeamGenerator.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
