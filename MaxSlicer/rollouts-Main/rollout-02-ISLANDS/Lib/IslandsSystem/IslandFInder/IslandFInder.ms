filein( getFilenamePath(getSourceFileName()) + "/LowestVertIslandFinder/LowestVertIslandFinder.ms" )	--"./LowestVertIslandFinder/LowestVertIslandFinder.ms"
filein( getFilenamePath(getSourceFileName()) + "/IslandPerLayerFinder/IslandPerLayerFinder.ms" )	--"./IslandPerLayerFinder/IslandPerLayerFinder.ms"

/** Island finder
 */
struct IslandFinder_v
(
	/* construct */
	obj,
	
	/* required */
	--verts_process,

	/* properties */
	obj_snapshot_source,
	

	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	/** Find islands per layer
	  * 
	  * @param #IslandPerLayerFinder|#LowestVertIslandFinder
	 */
	function findIslandsPerLayer layer_height method =
	(
		-- format "\n"; print "IslandFinder_v.findIslandsPerLayer()"
		if classof obj != Editable_Poly and ( getNumVerts obj.baseobject.mesh != getNumVerts obj.mesh ) then
		(
			obj_snapshot_source = obj
			
			obj = snapshot obj_snapshot_source
			
			convertTo obj PolyMeshObject
		)
		
		--verts_to_check = #{1..( polyop.getNumVerts obj)}
		lowest_verts = #{}
		
		try(
			islands_data = this._findIslandsPerLayer layer_height method
			
			-- format "LOWEST_VERTS: %\n" islands_data
			
		)catch(
			
			format "\n************ EXCEPTION ************\n%\n***********************************\n" (getCurrentException())
			format "\n**************** EXCEPTION File: % ****************\n\n%\n\n**************************************************************************************************************************************\n" filein_path (getCurrentException())
	   
			if obj_snapshot_source != undefined then 
				delete obj
		)
		
		
		if obj_snapshot_source != undefined then 
			delete obj

			
		islands_data --return
	),
	
	/** Find islands per layer
	  * 
	  * @param #IslandPerLayerFinder|#LowestVertIslandFinder
	 */
	function _findIslandsPerLayer layer_height method =
	(
		-- format "\n"; print "IslandFinder_v._findIslandsPerLayer()"
		
		
		--format "VertexLayers: %\n" VertexLayers
		--timer_findIslandsPerLayer = timeStamp()
		--method = #LowestVertIslandFinder
		/* GET VERTS WITH NORMAL POINTING DOWN */
		max modify mode

		subObjectLevel = 1
		
		vertex_count = getNumVerts obj.mesh

		verts_all = #{1..(vertex_count)}
		-- format "verts_all: %\n" verts_all

		verts_sel	= getVertSelection obj.mesh
		-- format "verts_sel: %\n" verts_sel
		visible_verts = -( polyop.getHiddenVerts obj)
		-- format "visible_verts: %\n" visible_verts
		
		verts_process = if verts_sel.numberSet > 0 then verts_sel else verts_all
		-- format "verts_process: %\n" verts_process
		
		if verts_process.numberSet != visible_verts.numberSet and verts_process.count != visible_verts.count then
			verts_process *= visible_verts

		
		PolyToolsSelect.Normal 3 140 true
		
		verts_normal_down = obj.getSelection #Vertex
		
		/* GET ONLY CONVEX VERTS */
		PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex and convex-concave
		--PolyToolsSelect.ConvexConcave 0.05 2 -- select convex and convex-concave
		--PolyToolsSelect.ConvexConcave 0.1 2 -- select convex and convex-concave

		verts_convex = obj.getSelection #Vertex
		--format "verts_normal_down: %\n" verts_normal_down
		-- format "verts_convex: %\n" verts_convex
		--format "verts_process: %\n" verts_process
		--intersection = (verts_normal_down * verts_convex)
		--format "INTERSECTION: %\n" intersection
		--format "WTF: %\n" (intersection * verts_process)
		--verts_process = intersection * verts_process
		verts_process *= (verts_normal_down * verts_convex) 
		 format "VERTS_PROCESS: %\n" verts_process
		-- format "method: %\n" method

		if method == #IslandPerLayerFinder then
		(
			IslandPerLayerFinder 	= IslandPerLayerFinder_v(obj)
			
			IslandPerLayerFinder.verts_all	= verts_all
			IslandPerLayerFinder.verts_process	= verts_process

			IslandPerLayerFinder.sortVertsToLayers()

			 --for layer_index = 1 to IslandPerLayerFinder.verts_layers.count where classOf ( verts_in_layer = IslandPerLayerFinder.verts_layers[layer_index] ) == BitArray do
				--format "%: %\n" layer_index verts_in_layer

			--format "IslandPerLayerFinder.verts_layers: %\n" IslandPerLayerFinder.verts_layers

			IslandPerLayerFinder.getNewIslandsPerLayer()

			/* ADD ISLAND DATA */
			for i = 1 to IslandPerLayerFinder.islands_data.count do
			(
				island_data = IslandPerLayerFinder.islands_data[i]

				IslandPerLayerFinder.islands_data[i][#LOWEST_VERT] = this.getLowestVertOnZaxis( island_data[#NEW_ISLAND] )

				verts_get_size = if island_data[#WHOLE_ISLAND] != undefined then island_data[#WHOLE_ISLAND] else island_data[#NEW_ISLAND]

				if island_data[#WHOLE_ISLAND] != undefined then
				(
					x_positions = for vert in verts_get_size collect verts_pos[vert].x
					y_positions = for vert in verts_get_size collect verts_pos[vert].y


					x_length = (amax x_positions) - (amin x_positions)
					y_length = (amax y_positions) - (amin y_positions)


					IslandPerLayerFinder.islands_data[i][#SIZE] = [x_length, y_length]
				)
			)
			
			-- format "findIslandsPerLayer: % ms\n" (( timeStamp()) - timer_findIslandsPerLayer)
			IslandPerLayerFinder.islands_data --return
		)
		else
		(
			
			-- format "verts_process: %\n" verts_process
			
			LowestVertIslandFinder 	= LowestVertIslandFinder_v(obj)
			
			LowestVertIslandFinder.verts_all	= verts_all
			LowestVertIslandFinder.verts_process	= verts_process

			LowestVertIslandFinder.getLowestVertsOfIslands()
			
			
			
			
		)
		
	),

	private
	
	
	
	


	/**
	 */
	on create do
	(
		--format "\n"; print "IslandFInder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
