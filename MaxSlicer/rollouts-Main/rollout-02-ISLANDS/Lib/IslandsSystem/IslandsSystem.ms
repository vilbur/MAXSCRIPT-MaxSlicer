filein( getFilenamePath(getSourceFileName()) + "/IslandFinder/IslandFinder.ms" )	--"./IslandFinder/IslandFinder.ms"
filein( getFilenamePath(getSourceFileName()) + "/../IslandManagerDialog/islandsRcMenu.ms" )	--"./../IslandManagerDialog/islandsRcMenu.ms"
filein( getFilenamePath(getSourceFileName()) + "/IslandsCallbacks.ms" )	--"./IslandsCallbacks.ms"
filein( getFilenamePath(getSourceFileName()) + "/../IslandManagerDialog/islandsRcMenuCallbacks.ms" )	--"./../IslandManagerDialog/islandsRcMenuCallbacks.ms"
filein( getFilenamePath(getSourceFileName()) + "/../IslandManagerDialog/createIslandManagerDialog.ms" )	--"./../IslandManagerDialog/createIslandManagerDialog.ms"

/** Islands system
  
	global ISLANDS_SYSTEM
  
 */
struct IslandsSystem_v
(
	/* construct */


	/* required */
	obj,

	/* properties */
	islands_data,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */


	/** Get verts of selected islands from listbox
	 */
	function getVertsOfIslands island_indexes =
	(
		--format "\n"; print "IslandsSystem_v.getVertsOfIslands()"
		verts = #{1..(getNumVerts obj.mesh)} * #{}

		for island_index in island_indexes do
			verts += this.getVertsFromIslandData (islands_data[island_index])

		verts --return
	),

	/** Get verts from island data
	 */
	function getVertsFromIslandData island_data =
	(
		--format "\n"; print "IslandsSystem_v.getVertsFromIslandData()"
		--format "STATE: %\n" (DIALOG_island_manager.RB_slider_mode.state)
		case DIALOG_island_manager.RB_slider_mode.state of
		(
			0:	island_data[#NEW_ISLAND]
			1:	#{island_data[#LOWEST_VERT]}
			2:	if island_data[#WHOLE_ISLAND] != undefined then island_data[#WHOLE_ISLAND] else island_data[#NEW_ISLAND]
		)
	),

	/** Select islands of verts
	 */
	function selectVertsOfIslands island_indexes =
	(
		--format "\n"; print "IslandsSystem_v.selectVertsOfIslands()"
		verts = this.getVertsOfIslands(island_indexes)

		/* SLECT VERTS OF SELECTED ISLANDS */
		this.selectVerts (verts)

		verts --return
	),

	/** Isolate slected islands
	 */
	function isolateIslands islands =
	(
		--format "\n"; print "IslandsSystem_v.isolateIslands()"

		verts = this.getVertsOfIslands(islands)

		subObjectLevel = 1

		if ( hidden_verts = polyop.getHiddenVerts obj ) != undefined then
		(

			hidden_verts -= verts

			polyop.unHideAllVerts obj

			if DIALOG_island_manager.CBTN_isolate.state == 1 then
			(
				all_verts = #{1..(getNumVerts obj.mesh)}

				polyop.setHiddenVerts obj (all_verts - verts)
			)
		)
	),

	/** Get layer of island
	 */
	function getLayerOfClosestIsland layer_current increment =
	(
		--format "\n"; print "SlicerCallbacks_v.getLayerOfClosestIsland()"
		--format "layer_current: %\n" layer_current
		islands_layers = (for item in DIALOG_island_manager.ML_island_listbox.items collect (filterString item " ")[1] as integer ) as BitArray -- get list items strings to bitarray
		--format "ISLANDS_LAYERS: %\n" islands_layers
		layer_next = layer_current + increment

		if layer_next < 1 then layer_next = 1

		if islands_layers[layer_next] == false then
		(
			/* GO ISLAND UP */
			if increment > 0 and layer_current < islands_layers.count then
				for i = layer_next to islands_layers.count while not islands_layers[i] do
					layer_next = i + 1

			/* GO ISLAND DOWN */
			else if increment < 0 and layer_current > 1  then
				for i = layer_next to 1 by -1 while not islands_layers[i]  do
					layer_next = i - 1

		)


		layer_next
	),

	/** Select islands verts
	 */
	function selectVerts verts =
	(
		--format "\n"; print "IslandsSystem_v.selectVerts()"
		--format "VERTS: %\n" verts

		/** Select verts editable poly
		 */
		function selectVertsEditablePoly obj verts isolate =
		(
			--format "\n"; print "IslandsSystem_v.selectVertsEditablePoly()"

			if ( hidden_verts = polyop.getHiddenVerts obj ) != undefined then
			(
				--format "HIDDEN_VERTS: %\n" hidden_verts
				all_verts = #{1..(getNumVerts obj.mesh)}

				hidden_verts -= verts

				/* HIDE HIDDEN VERTS OR ISOALTE ONLY SELECTED */
				if hidden_verts.numberSet > 0 or isolate then
				(
					polyop.unHideAllVerts obj

					if isolate == 1 then
						hidden_verts = (all_verts - verts)

					polyop.setHiddenVerts obj hidden_verts
				)
			)

			obj.baseobject.SetSelection #Vertex #{}

			obj.baseobject.SetSelection #VERTEX verts
		)

		/** Select verts edit poly
		 */
		function selectVertsEditPoly _mod verts isolate =
		(
			--format "\n"; print "IslandsSystem_v.selectVertsEditPoly()"
			--format "\n**************************************************\n"
			/** Pass vertex selection from editable poly baseobject to edit poly modifier based on vertex position
			  *
			  * #return BitArray of vertex indexes of Edit Poly Modifier
			 */
			function getMeshVertsByBaseobject obj verts_baseobject verts_mesh_all =
			(
				--format "\n"; print "IslandsSystem_v.getMeshVertsByBaseobject()"
				verts_edit_poly = #()

				verts_pos_baseobjects =  in coordsys world polyop.getVerts obj.baseobject verts_baseobject node:obj

				--verts_mesh_pos  = for vert in verts_mesh_all collect getVert obj.mesh vert
				verts_mesh_pos = in coordsys world polyop.getVerts obj verts_mesh_all node:obj
				--format "verts_mesh_pos: %\n" verts_mesh_pos

				for vert_pos in verts_pos_baseobjects where (index = findItem verts_mesh_pos (vert_pos)) > 0 do
					append verts_edit_poly index

				verts_edit_poly as BitArray --return
			)


			verts_mesh_all	= #{1..( getNumVerts obj.mesh )}
			verts_base_all	= #{1..( polyop.getNumVerts obj.baseobject)}
			verts_base_hidden	= polyop.getHiddenVerts obj.baseobject

			--format "verts: %\n" verts
			/* GET EDIT POLY VERTS */
			if verts_base_all.numberSet != verts_mesh_all.numberSet then
				verts = getMeshVertsByBaseobject(obj)(verts)(verts_mesh_all)

			--format "verts: %\n" verts
			if not isolate then
			(
				actionMan.executeAction 0 "40021"  -- Selection: Select All

				visible_verts	= (getVertSelection obj.mesh) + verts

				_mod.ButtonOp #UnhideAllVertex
				--
				--_mod.SetSelection #VERTEX #{}
				--
				--_mod.Select #VERTEX visible_verts
				--
				--_mod.ButtonOp #HideUnselectedVertex

				_mod.SetSelection #VERTEX #{}

				_mod.Select #VERTEX verts
			)
			else /* UNHIDE ONLY SELECTED VERTS */
			(
				_mod.ButtonOp #UnhideAllVertex

				_mod.SetSelection #VERTEX #{}

				_mod.Select #VERTEX verts

				--_mod.ButtonOp #HideUnselectedVertex

			)
		)

		isolate_verts = DIALOG_island_manager.CBTN_isolate.state == 1

		subObjectLevel = 1

		if classOf (_mod = modPanel.getCurrentObject()) == Editable_Poly then
			selectVertsEditablePoly (obj)(verts)(isolate_verts)

		else if classOf _mod  == Edit_Poly then
			selectVertsEditPoly (_mod)(verts)(isolate_verts)

	),

	/** Get islands to show by slection
	 */
	function getIslandsToShowBySelection =
	(
		--format "\n"; print "IslandsSystem_v.getIslandsToShowBySelection()"
		selected_islands = this.getIslandsOfSelectedItems()

		islands_to_show = case of
		(
			(selected_islands.numberSet >  1):	selected_islands	-- SHOW ONLY SELECTED ITEMS ON RELAUNCH
			(selected_islands.numberSet == 1):	#{(this._getFirstIslandFromListbox())..(selected_islands as Array )[1]}	-- SHOW ISLANDS UP TO SELECTED ITEM ON RELAUNCH IF ONLY SINGLE ISLAND IS SELECTED
			default:	#{1..islands_data.count}	-- SHOW ALL ISLANDS
		)

		setUserPropVal obj "VISIBLE_ISLANDS" islands_to_show --asString:true

		islands_to_show --return

	),

	/** Get vertex numbers of Editable Poly by verts of Edit Poly
	  *
	  * 1) Get selected verts in modifier like Edit Poly|Poly Select
	  * 2) Find same vertex by position in Editable Poly baseobject
	  *
	  * #return BitArray of vertex indexes of Editable Poly Baseobject
	 */
	function getBaseObjectVerts verts =
	(
		-- format "\n"; print "IslandsSystem_v._getBaseObjectVerts()"
		-- format "verts: %\n" verts


		max modify mode

		is_edit_poly = classof (_mod	= modPanel.getCurrentObject() ) == Edit_Poly

		if is_edit_poly and verts.numberSet > 0 \
		and ( vertex_count_mesh = getNumVerts obj.mesh ) != ( vertex_count_baseobject = polyop.getNumVerts obj.baseobject) then
		(
			verts_baseobject = #{}

			verts_base_all	= #{1..vertex_count_baseobject}

			verts_positions = in coordsys world polyop.getVerts obj verts node:obj

			verts_pos_baseobjects = in coordsys world  polyop.getVerts obj.baseobject #{1..vertex_count_baseobject} node:obj

			for vert_pos in verts_positions where (vert = findItem verts_pos_baseobjects (vert_pos)) > 0 do
				verts_baseobject[vert] = true

			verts_baseobject --return
		)
		else
			verts --return
	),


	/*------------------------------------------------------------------------------
		LISTBOX
	------------------------------------------------------------------------------*/

	/** Save visible islands
	 */
	function saveVisibleIslands =
	(
		--format "\n"; print "IslandsSystem_v.saveVisibleIslands()"
		visible_islands = this._getIslandIndexes (DIALOG_island_manager.ML_island_listbox.items)

		setUserPropVal obj "VISIBLE_ISLANDS" visible_islands
	),

	/** Load visible islands
	 */
	function loadVisibleIslands =
	(
		--format "\n"; print "IslandsSystem_v.loadVisibleIslands()"
		getUserPropVal obj "VISIBLE_ISLANDS"
	),

	/** Select layer listbox
	 */
	function selectIslandByLayerInListbox layer_indexes =
	(
		-- format "\n"; print "IslandsSystem_v.selectIslandByLayerInListbox()"
		if classOf layer_indexes != BitArray then
			layer_indexes = #{layer_indexes}

		items = this._getListItemByLayer (layer_indexes)
		--format "ITEMS: %\n" items

		DIALOG_island_manager.ML_island_listbox.selection = items

		if ( slider_value = DIALOG_island_manager.ML_island_listbox.items.count - items.count  ) > 0 then
			DIALOG_island_manager.SLIDER_island_select.value = slider_value
	),

	/** Get listbox items by island index
	  *
	  * @prams BitArray indexes of islands from this.islands_data
	  *
	  * @returnn BitArray indexes of listbox items
	 */
	function getListboxItemsByIslandsIndex island_indexes =
	(
		--format "\n"; print "IslandsSystem_v._getListboxItemsByIslandIndex()"
		list_items = DIALOG_island_manager.ML_island_listbox.items

		( for i = 1 to  list_items.count where island_indexes[ this._getIslandIndexFromTitle list_items[i] ] collect i ) as BitArray
	),

	/** Get selected islands from list box
	 */
	function getIslandsOfSelectedItems =
	(
		-- format "\n"; print ".getIslandsOfSelectedItems()"
		_listbox = DIALOG_island_manager.ML_island_listbox

		selected_items = for i in _listbox.selection collect _listbox.items[i]

		this._getIslandIndexes ( selected_items )
	),

	/** Get layers of selected items
	 */
	function getLayersOfSelectedItems =
	(
		--format "\n"; print "IslandsSystem_v.getLayersOfSelectedItems()"
		_listbox = DIALOG_island_manager.ML_island_listbox
		--list_items = _listbox.items

		--( for i = 1 to list_items.count where _listbox.selection[i] collect this._getIslandLayerFromTitle(list_items[i])) as BitArray

		( for i in _listbox.selection collect this._getIslandLayerFromTitle(_listbox.items[i]) ) as BitArray

	),


	/** Fit zpozitions
	 */
	function fitZpozitions islands_data layer_height =
	(
		 format "\n"; print "IslandsSystem_v.fitZpozitions()"
		 format "islands_data: %\n" islands_data
		 
		first_island = islands_data[1]

		bottom_layer = first_island[#BOTTOM]
		lowest_vert  = first_island[#LOWEST_VERT]
		-- format "bottom_layer: %\n" bottom_layer
		-- format "lowest_vert: %\n" lowest_vert

		vert_pos = (in coordsys world meshop.getVerts obj.baseobject.mesh lowest_vert node:obj)[1]
		--format "vert_pos.z: %\n" vert_pos.z
		vert_pos_bottom_layer = ( vert_pos.z / layer_height ) as integer + 1
		--format "vert_pos_bottom_layer: %\n" vert_pos_bottom_layer
		/* MOVE Z POSITIONS OF ISLANDS IF Z POSITION OF OBJECT CHANGED */
		if bottom_layer != vert_pos_bottom_layer then
		(
			difference = vert_pos_bottom_layer - bottom_layer

			for island_data in islands_data do
			(
				--format "\n\n"
				--format "island_data[#TOP]: %\n" island_data[#TOP]
				--format "island_data[#BOTTOM]: %\n" island_data[#BOTTOM]

				if island_data[#TOP] != undefined then
					island_data[#TOP] += difference

				island_data[#BOTTOM] += difference
				--format "island_data[#BOTTOM]: %\n" island_data[#BOTTOM]
			)

		)

		--format "vert_pos: %\n" vert_pos
		--format "vert_pos_bottom_layer: %\n" vert_pos_bottom_layer

		islands_data --return
	),

	/** Get first island from listbox
	 */
	function _getFirstIslandFromListbox =
	(
		--format "\n"; print "._getFirstIslandFromListbox()"
		_listbox = DIALOG_island_manager.ML_island_listbox

		this._getIslandIndexFromTitle (_listbox.items[_listbox.items.count]) --return
	),

	private

	/** Get island indexes
	 */
	function _getIslandIndexes list_items =
	(
		--format "\n"; print "IslandsSystem_v._getIslandIndexes()"
		( for list_item in list_items collect this._getIslandIndexFromTitle(list_item) ) as BitArray
	),

	/** Get island by layer
	 */
	function _getListItemByLayer layer_indexes =
	(
		--format "\n"; print "IslandsSystem_v._getListItemByLayer()"
		--format "layer_indexes: %\n" layer_indexes

		list_items = DIALOG_island_manager.ML_island_listbox.items

		( for i = 1 to  list_items.count where layer_indexes[ this._getIslandLayerFromTitle list_items[i] ] collect i ) as BitArray
	),

	/** Get island item title
	 */
	function _getIslandIndexFromTitle list_item =
	(
		format "\n"; print "IslandsSystem_v._getIslandIndexFromTitle()"
		format "list_item: %\n" list_item
		(filterString list_item ":")[2] as Number

		--( substring list_item (( findString list_item "island_index:" )+1) -1 ) as Number
	),

	/** Get island item title
	 */
	function _getIslandLayerFromTitle list_item =
	(
		--format "\n"; print "IslandsSystem_v._getIslandIndexFromTitle()"
		--format "TEST: %\n" ((filterString list_item " ")[1] as Number)

		(filterString list_item " ")[1] as Number
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "IslandsSystem.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
