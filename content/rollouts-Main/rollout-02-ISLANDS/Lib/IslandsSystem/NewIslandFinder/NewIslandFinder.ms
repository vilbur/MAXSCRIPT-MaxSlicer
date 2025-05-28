/** 
  *	
  */
struct NewIslandFinder_v
(
	/* construct */
	obj,

	/* required */
	

	/* properties */
	verts_pos,
	layer_height = 0.05,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Get verts
	 */
	function getVerts =
	(
		--format "\n"; print "NewIslandFinder_v.getVerts()"
		--obj = selection[1] 
		
		subObjectLevel = 1
		
		with redraw off
		(
			
		if classof (_mod = modPanel.getCurrentObject()) == Edit_Poly then
			_mod.ButtonOp #UnhideAllVertex
		else
			_mod.unhideAll #VERTEX
		
		PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex
		
		convex_sel	= getVertSelection obj.mesh
		
		PolyToolsSelect.ConvexConcave 0.0001 1 -- select concave
		
		concave_sel	= getVertSelection obj.mesh
		
		--PolyToolsSelect.Normal 3 90 true
		PolyToolsSelect.Normal 3 120 true
		
		normal_down	= getVertSelection obj.mesh
		
		--convex_down_verts = convex_sel * normal_down
		convex_down_verts = (convex_sel - concave_sel) * normal_down
		
		)
		--redrawViews()
		
		--convex_down_verts --return
		--concave_sel --return
		--convex_sel --return
		
		this._isVertexLowestOnZ(convex_down_verts)
	),

	private
	/*
	Loop through each vertex of editable poly and
	check if it's the lowest among all its edge neighbors
	*/
	function _isVertexLowestOnZ verts =
	(
		format "\n"; print "NewIslandFinder_v._isVertexLowestOnZ()"
	
		vert_count = getNumVerts obj.mesh
		verts_all = #{1..vert_count}
	
		verts_pos = this._getVertsPositions verts
		--verts = this.sortVerticesByZ verts verts_pos
	
		proceded_verts = #{}
		lowest_verts = #{}
		
		timer_test = timeStamp()
		counter = 0
	
		-- prebuild face map
		--format "prebuild face map\n"
		--face_map = #()
		--for v in verts do
		--(
		--	face_map[v] = polyop.getFacesUsingVert obj #{v}
		--)
		--
		---- prebuild neighbor map
		--format "prebuild neighbor map\n"
		--neighbor_map = #()
		--for v in verts do
		--(
		--	neighbor_map[v] = polyop.getVertsUsingFace obj face_map[v]
		--)
	
		format "Loop verts\n"
		for vert in verts where not proceded_verts[vert] do
		(
			if mod counter 1000 == 0 then
				format "layer: % of: %\n" counter verts.count
	
			is_lowest = true
			vert_pos_z = verts_pos[vert].z
			--neighbor_verts = neighbor_map[vert]
			neighbor_verts = polyop.getVertsUsingFace obj (  polyop.getFacesUsingVert obj vert )
	
			for n in neighbor_verts while is_lowest where n != vert do
			(
				if verts_pos[n].z < vert_pos_z then
					is_lowest = false
			)
	
			if is_lowest then
			(
				lowest_verts[vert] = true
				proceded_verts += neighbor_verts
			)
	
			counter += 1
		)
	
		format "TEST: % ms\n" ((timeStamp()) - timer_test)
	
		lowest_verts -- return
	),

	--/* 
	--Loop through each vertex of editable poly and 
	--check if it's the lowest among all its edge neighbors 
	--*/
	--
	--function _isVertexLowestOnZ verts =
	--(
	--	format "\n"; print "NewIslandFinder_v._isVertexLowestOnZ()"
	--	vert_count = getNumVerts obj.mesh
	--	verts_all = #{1..vert_count}
	--	
	--	verts_pos = this._getVertsPositions verts
	--	
	--	verts = this.sortVerticesByZ verts verts_pos
	--		format "verts: %\n" verts
	--		--verts_pos_round = this._roundZposToLayerHeight verts
	--
	--		proceded_verts = #{}
	--		proceded_edges = #{}
	--		lowest_verts = #{}
	--		
	--		timer_test = timeStamp()
	--
	--		counter = 0 
	--		format "Loop verts\n"
	--		--for vert in verts do
	--		for vert in verts where not proceded_verts[vert] do
	--		(
	--			if mod counter 1000 == 0 then (
	--				--format "layer: % of: %\n" counter verts.numberSet
	--				format "layer: % of: %\n" counter verts.count
	--
	--			
	--			)
	--			--format "\n"
	--			--format "vert: %\n" vert
	--			is_lowest = true
	--			
	--			vert_pos = verts_pos[vert]
	--			--vert_pos = verts_pos_round[vert]
	--			
	--			--edges = polyop.getEdgesUsingVert obj #{vert}
	--			faces = polyop.getFacesUsingVert obj #{vert}
	--			
	--			--for _edge in edges where proceded_edges[_edge] do edges[_edge] = false
	--			--edges -= proceded_edges
	--			--neighbor_verts = polyop.getVertsUsingEdge obj edges
	--			neighbor_verts = polyop.getVertsUsingFace obj faces
	--			
	--			
	--			--proceded_edges += edges
	--			--format "neighbor_verts: %\n" neighbor_verts
	--			for n in neighbor_verts while is_lowest where n != vert do
	--				if verts_pos[n].z < vert_pos.z then
	--				is_lowest = false
	--
	--		--if not edges.isEmpty and is_lowest then
	--		if is_lowest then
	--		(
	--			lowest_verts[vert] = true
	--			
	--			proceded_verts += neighbor_verts
	--		)
	--		counter += 1
	--		
	--	)
	--	format "TEST: % ms\n" (( timeStamp()) - timer_test)
	--
	--	lowest_verts --return
	--),
	
	/*
	Returns array of vertices sorted by their Z position
	*/
	function sortVerticesByZ vertices positions =
	(
		format "\n"; print "NewIslandFinder_v.sortVerticesByZ()"

		/* comparison function used by qsort */
		fn compareByZ a b =
		(
			if a[2] < b[2] then -1
			else if a[2] > b[2] then 1
			else 0  -- return
		)
	
		verts_array = vertices as Array
	
		vert_with_z = for i = 1 to verts_array.count collect
		(
			#(
				verts_array[i],     -- vertex node
				positions[i].z   -- Z position
			)
		)
	
		qsort vert_with_z compareByZ
		format "vert_with_z: %\n" vert_with_z
		for i = 1 to vert_with_z.count collect vert_with_z[i][1]  -- return
	),

	/** Get verts positions
	 */
	function _getVertsPositions verts =
	(
		format "\n"; print "NewIslandFinder_v._getVertsPositions()"
		
		vert_count = getNumVerts obj.mesh
		verts_all = #{1..vert_count}
		
		in coordsys world meshop.getVerts obj.mesh verts_all node:obj
	),
	
	/** Round zpos to layer height
	 */
	function _roundZposToLayerHeight verts =
	(
		format "\n"; print "NewIslandFinder_v._roundZposToLayerHeight()"
		function roundedValue original_value = floor (original_value / layer_height) * layer_height
		
		verts_pos_round = deepCopy verts_pos
		
		for vert in verts do
			verts_pos_round[vert].z = roundedValue verts_pos[vert].z
			
		verts_pos_round --return
	),
	
	/**
	 */
	on create do
	(
		--format "\n"; print "NewIslandFinder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
