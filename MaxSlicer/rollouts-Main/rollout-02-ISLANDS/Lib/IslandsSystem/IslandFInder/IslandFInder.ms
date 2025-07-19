filein( getFilenamePath(getSourceFileName()) + "/LowestVertIslandFinder/LowestVertIslandFinder.ms" )	--"./LowestVertIslandFinder/LowestVertIslandFinder.ms"
filein( getFilenamePath(getSourceFileName()) + "/IslandPerLayerFinder/IslandPerLayerFinder.ms" )	--"./IslandPerLayerFinder/IslandPerLayerFinder.ms"
filein( getFilenamePath(getSourceFileName()) + "/../../getInternalVertsOfObject/getInternalVertsOfObject.ms" )	--"./../../getInternalVertsOfObject/getInternalVertsOfObject.ms"

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
		 format "\n"; print "IslandFinder_v.findIslandsPerLayer()"
		 
		--if classof obj.baseobject != Editable_Poly or (classof obj.baseobject == Editable_Poly and ( getNumVerts obj.baseobject.mesh != getNumVerts obj.mesh )) then
		(
			obj_snapshot_source = obj
			
			--obj = convertTo ( copy obj ) PolyMeshObject -- copy is faster then snapshot and copy created at current frame of animation
			
			maxOps.CloneNodes obj expandHierarchy:true newNodes:&nnl
		
			obj = nnl[1]
		
			convertTo obj PolyMeshObject
		)
		
		--verts_to_check = #{1..( polyop.getNumVerts obj)}
		lowest_verts = #{}
		
		--try(
			
			/*------------------------------------------------------------------------------
				FIND ISLANDS
			----------------------------------------------------------------------------*/
			islands_data = this._findIslandsPerLayer layer_height method
			
			format "ISLANDS_DATA: %\n" islands_data
			
		--)catch(
		--	
		--	format "\n************ EXCEPTION ************\n%\n***********************************\n" (getCurrentException())
		--	format "\n**************** EXCEPTION File: % ****************\n\n%\n\n**************************************************************************************************************************************\n" filein_path (getCurrentException())
		--  
		--	if obj_snapshot_source != undefined then 
		--		delete obj
		--)
		
		
		if isValidNode obj_snapshot_source and obj_snapshot_source != undefined then 
			delete obj

			
		islands_data --return
	),
	
	/** FIND ISLANDS PER LAYER
	  * 
	  * @param #IslandPerLayerFinder|#LowestVertIslandFinder
	 */
	function _findIslandsPerLayer layer_height method =
	(
		 format "\n"; print "IslandFinder_v._findIslandsPerLayer()"
		
		--format "VertexLayers: %\n" VertexLayers
		--timer_findIslandsPerLayer = timeStamp()
		--method = #LowestVertIslandFinder
		
		select obj
			
		/* GET VERTS WITH NORMAL POINTING DOWN */
		vertex_count = getNumVerts obj.mesh

		verts_all = #{1..(vertex_count)}

		verts_process = this._getVertsToProcess (verts_all)

		/*==============================================================================
			ISLAND PER LAYER FINDER
		================================================================================*/
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

				--IslandPerLayerFinder.islands_data[i][#LOWEST_VERT] = this._getLowestVertOnZaxis( island_data[#NEW_ISLAND] )
				IslandPerLayerFinder.islands_data[i][#LOWEST_VERT] = (( island_data[#NEW_ISLAND] ) as Array )[1]

				verts_get_size = if island_data[#WHOLE_ISLAND] != undefined then island_data[#WHOLE_ISLAND] else island_data[#NEW_ISLAND]

				--if island_data[#WHOLE_ISLAND] != undefined then
				--(
				--	x_positions = for vert in verts_get_size collect verts_pos[vert].x
				--	y_positions = for vert in verts_get_size collect verts_pos[vert].y
				--
				--
				--	x_length = (amax x_positions) - (amin x_positions)
				--	y_length = (amax y_positions) - (amin y_positions)
				--
				--
				--	IslandPerLayerFinder.islands_data[i][#SIZE] = [x_length, y_length]
				--)
			)
			
			-- format "findIslandsPerLayer: % ms\n" (( timeStamp()) - timer_findIslandsPerLayer)
			IslandPerLayerFinder.islands_data --return
		)
		/*==============================================================================
			 LOWEST VERT ISLAND FINDER
		================================================================================*/
		else
		(
			
			 --format "verts_process: %\n" verts_process
			
			LowestVertIslandFinder 	= LowestVertIslandFinder_v(obj)
			
			LowestVertIslandFinder.verts_all	= verts_all
			LowestVertIslandFinder.verts_process	= verts_process
			
			LowestVertIslandFinder.getLowestVertsOfIslands()
	
			
		)
	),
	/** Get vert with min z pos
	  *
	  * @param BitArray verts
	 */
	function _getLowestVertOnZaxis verts =
	(
		--format "\n"; print "VertexGridGetter_v._getLowestVertOnZaxis()"
		verts_pos = in coordsys world meshop.getVerts obj.mesh verts node:obj

		verts_arr = verts as Array

		/* GET LOWEST POINT IN CELL */
		if verts_arr.count > 1 then
		(
			--z_positions = for vert in verts_arr collect MeshDataGetter.getPosition(vert) axis:#Z

			z_positions = for i = 1 to verts_arr.count collect verts_pos[i].z

			--z_positions = for pos in (meshop.getVerts obj.mesh verts node:obj) collect pos.z

			if ( index = findItem z_positions (amin z_positions) ) > 0 then
				verts_arr[index] --return
		)
		else
			verts_arr[1] --return

			--verts_arr[1] --return
	),
	
	private
	
	/** Get verts to process
	 */
	function _getVertsToProcess verts_all =
	(
		format "\n"; print "IslandFinder_v._getVertsToProcess()"
		
		fn bitArraysAreSame arr1 arr2 = ( arr1 - arr2 ).isEmpty

		/* GET VERTEX SELECTION */ 
		verts_sel	= getVertSelection obj.mesh
		
		use_selection = not verts_sel.isEmpty and queryBox ("Use "+verts_sel.numberSet as string +" selected vertices ?") title:"IslandFinder" 
		
		/* USE ALL OR SELECTED VERTS */ 
		verts_process = if use_selection then verts_sel else verts_all
		 --format "verts_process: %\n" verts_process
		
		/* REMOVE HIDDEN VERTS */ 
		visible_verts = -( polyop.getHiddenVerts obj)
		
		if not visible_verts.isEmpty and not bitArraysAreSame verts_process visible_verts then
			verts_process *= visible_verts

		/* REMOVE VERTS POINTING UP */
		verts_normal_down = this._getNormalDownVerts()
		
		if not verts_normal_down.isEmpty then
			verts_process *= verts_normal_down
		
		/* GET ONLY CONVEX VERTS */
		PolyToolsSelect.ConvexConcave 0.0001 2 -- select convex and convex-concave
		----PolyToolsSelect.ConvexConcave 0.05 2 -- select convex and convex-concave
		----PolyToolsSelect.ConvexConcave 0.1 2 -- select convex and convex-concave
		verts_convex = obj.getSelection #Vertex
		
		if not verts_convex.isEmpty then
			verts_process *= verts_convex
		
		/* REMOVE INNER VERTS  */
		inside_verts = getInternalVertsOfObject obj obj verts:verts_process
		format "INSIDE_VERTS: %\n" inside_verts
		
		if not inside_verts.isEmpty then
			verts_process -= inside_verts
		
		
		/* RESULT */ 
		verts_process --return
	),
	
	/** Get bottom verts
	 */
	function _getNormalDownVerts =
	(
		format "\n"; print "IslandFinder_v._getNormalDownVerts()"
		/** Select normal down verts
		 */
		function selectNormalDownVerts =
		(
			--format "\n"; print "IslandFinder_v.selectNormalDownVerts()"
			select this.obj
			
			max modify mode
	
			subObjectLevel = 1
			
 			PolyToolsSelect.Normal 3 140 true
			
			this.obj.getSelection #Vertex
		)
		
		/* RESET X FORM */ 
		if (verts_normal_down = selectNormalDownVerts() ).isEmpty then
		(
			format "\n"; print ("Reset XForm of object: "+obj.name+" in IslandFinder_v._getNormalDownVerts()")
			
			ResetXForm obj

			convertTo obj PolyMeshObject
			
			verts_normal_down = selectNormalDownVerts()
		)
		
		format "verts_normal_down: %\n" verts_normal_down
		verts_normal_down --return
	),


	/**
	 */
	on create do
	(
		--format "\n"; print "IslandFInder.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
