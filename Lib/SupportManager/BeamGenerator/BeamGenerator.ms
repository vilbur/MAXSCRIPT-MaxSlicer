/** Beam generator
 */
struct BeamGenerator_v
(
	/* construct */
	/* required */
	/* properties */
	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Generate beam
	 */
	function generateBeam support_A support_B =
	(
		format "\n"; print "BeamGenerator_v.generateBeam()"
		format "support_A: %\n" support_A
		format "support_B: %\n" support_B
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
	function generateBeamsChain supports max_distance =
	(
		format "\n"; print "BeamGenerator_v.generateBeamsChain()"
		format "supports: %\n" supports
		new_beams = #()

		sorted_supports = this._sortSupportsByDistance(supports) (max_distance)

		for supports_in_cluster in sorted_supports do
			format "SUPPORTS_IN_CLUSTER %: %\n" supports_in_cluster.count supports_in_cluster

		for supports_in_cluster in sorted_supports do
			for i = 1 to supports_in_cluster.count - 1 do
				append new_beams (this.generateBeam supports_in_cluster[i] supports_in_cluster[i + 1])

		new_beams --return
	),

	/** Generate beams to closest supports
	 */
	function generateBeamsToClosestSupports _objects max_distance: use_only_selected_supports:false max_connections: only_ground:true =
	(
		format "\n"; print ".generateBeamsToClosestSupports()"

		procesed_supports = #()
		new_beams = #()

		source_objects = SUPPORT_MANAGER.getObjectsByType ( _objects ) type:#SOURCE -- hierarchy:shift
		format "source_objects: %\n" source_objects

		objects_support = for obj in _objects where SUPPORT_MANAGER.isType #SUPPORT obj != false collect obj

		objects_rafts    = for obj in _objects where SUPPORT_MANAGER.isType #RAFT    obj != false collect obj

		supports = objects_support + objects_rafts

		/* USE ALL SUPPORTS OF SOURCE OBJECT OR ONLY SELECTED */
		supports_to_connect = if not use_only_selected_supports then SUPPORT_MANAGER.getObjectsByType source_objects type:#SUPPORT else supports

		/* DO NOT USE SUPPORTS WHICH HAS MAX BEAMS COUNT ALREADY */
		this._filterSupportsByCountOfBeams (max_connections) (&supports_to_connect)

		/* USE ONLY SUPPORTS TOUCHING GROUND - dont use rafts and supports without foot */
		this._filterOnlyGroundedSupports(only_ground)(&supports_to_connect)

		format "supports_to_connect.count: %\n" supports_to_connect.count
		format "MAX_DISTANCE: %\n" max_distance

		--format "supports_to_connect: %\n" supports_to_connect

		for support in supports where findItem procesed_supports support == 0 do
		(
			local closest_support

			min_distance = 9999999

			/* COMPARE DISTANCES OF SUPPORTS  */
			for support_other in supports_to_connect \
				where support_other != support \ -- avoid compare same support
				and ( dist = distance support support_other ) < min_distance \	 -- TEST MIN DISTANCE BETWEEN SUPPORTS
				and dist <= max_distance \                                       -- TEST MAX DISTANCE BETWEEN SUPPORTS
				and not this.beamExists support support_other \ -- TEST IF BEAM EXISTS ALLERADY
			do
			(
				min_distance = dist

				closest_support = support_other
				--format "CLOSEST_SUPPORT: %\n" closest_support

				if findItem supports support_other > 0 then
					appendIfUnique procesed_supports support
			)

			if closest_support != undefined then
			(
				if (new_beam = this.generateBeam support closest_support) != undefined then
					append new_beams new_beam

				if classOf max_connections == integer and max_connections > 0 and (SUPPORT_MANAGER.getObjectsByType closest_support type:#BEAM).count >= max_connections then
					deleteItem supports_to_connect ( findItem supports_to_connect closest_support )
			)
		)

		new_beams --return
	),

	/** connected with beams
	 */
	function beamExists support_A support_B =
	(
		format "\n"; print "SupportManager_v.beamExists()"
		SUPPORT_MANAGER.BeamObjects[this._getBeamKey support_A support_B] != undefined
	),


	private


	/** Get beam key
	 */
	function _getBeamKey support_A support_B =
	(
		format "\n"; print "SupportManager_v.getBeamKey()"
		pointers = sort #( this._getSupportKey(support_A) , this._getSupportKey(support_B) )
		format "pointers: %\n" pointers
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
		format "max_distance: %\n" max_distance
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

			/* AVOID TESTING SUPPORT AGAIN */
            proccessed_supports[support_i] = true

			support_i      = undefined
			next_support_i = undefined

			--format "SUPPORT_OPTIONS.max_distance: %\n" SUPPORT_OPTIONS.max_distance
			/*------------------------------------------------------------------------------
				LOOP SUPPORTS AND FIND CLOSEST SUPPORT
			--------------------------------------------------------------------------------*/
			for i = 1 to supports.count where not proccessed_supports[i] do
			(
				--format "distance: %\n" (distance support_pos supports[i].pos)
				if (current_distance = distance support_pos supports[i].pos ) < min_distance_found then
					--if not use_max_distance or current_distance <= SUPPORT_OPTIONS.max_distance  then
					if current_distance <= max_distance  then
					(
						min_distance_found = current_distance

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
	function _filterSupportsByCountOfBeams max_connections &supports =
	(
		--format "\n"; print "BeamGenerator_v._filterSupportsByCountOfBeams()"

		if classOf max_connections == integer and max_connections > 0 then
			supports = for support in supports where (SUPPORT_MANAGER.getObjectsByType support type:#BEAM).count < max_connections collect support

		supports --return
	),

	/** Filter supports with foot
	 */
	function _filterOnlyGroundedSupports only_ground &supports =
	(
		--format "\n"; print "BeamGenerator_v._filterSupportsByCountOfBeams()"

		if only_ground then
			supports = for support in supports where support.min.z as integer == 0 collect support

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
