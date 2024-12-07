/** Islands rc menu callbacks
 */
struct IslandsRcMenuCallbacks_v
(
	/* construct */

	/* required */

	/* properties */

	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	/** Select all islands in listbox
	 */
	function selectAllIslandsInListbox =
	(
		--format "\n"; print "IslandsSystem_v.selectAllIslandsInListbox()"
		DIALOG_island_manager.ML_island_listbox.selection = #{1..DIALOG_island_manager.ML_island_listbox.items.count}

		deleteUserProp ISLANDS_SYSTEM.obj "VISIBLE_ISLANDS"

		::IslandsCallbacks_v.updateIslandSelectionByRadiobuttonsState()
	),

	/** Select islands by verts
	 */
	function selectIslandsByVerts =
	(
		format "\n"; print "IslandsRcMenuCallbacks_v.selectIslandsByVerts()"
		verts_of_islands = #{}

		islands_data = ISLANDS_SYSTEM.islands_data

		/* Use Editable Poly if it is active, or Edit Poly modifer */
		obj_get_verts =	if classOf (_mod = modPanel.getCurrentObject()) == Editable_Poly then ISLANDS_SYSTEM.obj.baseobject.mesh else ISLANDS_SYSTEM.obj.mesh

		verts_sel = getVertSelection obj_get_verts
		--format "verts_sel: %\n" verts_sel

		verts_baseobject = ISLANDS_SYSTEM.getBaseObjectVerts( verts_sel )
		--format "verts_baseobject: %\n" verts_baseobject

		islands_of_verts = ( for i = 1 to islands_data.count where not (islands_data[i][#NEW_ISLAND] * verts_baseobject ).isEmpty collect i) as BitArray
		--format "islands_of_verts: %\n" islands_of_verts

		for index in islands_of_verts do
			verts_of_islands += islands_data[index][#NEW_ISLAND]
		--format "verts_of_islands: %\n" verts_of_islands
		--format "listbox.items.count: %\n" DIALOG_island_manager.ML_island_listbox.items.count

		items = ISLANDS_SYSTEM.getListboxItemsByIslandsIndex (islands_of_verts)
		--format "items: %\n" items

		if items.numberSet > 0 then
		(
			if classOf _mod == Editable_Poly then
				_mod.SetSelection #VERTEX verts_of_islands

			else if classOf _mod  == Edit_Poly then
				_mod.Select #VERTEX verts_of_islands

			DIALOG_island_manager.ML_island_listbox.selection = items

			ISLANDS_SYSTEM.saveVisibleIslands()
		)
		else if islands_of_verts.numberSet == 0 then
			messageBox "Selected verts are not in any island" title:"ISLANDS MISSING"  beep:false

		else
			messageBox "Islands of selected verts are hidden in list" title:"ISLANDS HIDDEN"  beep:false

	),

	/** Select islands by size
	 */
	function selectIslandsBySize size =
	(
		--format "\n"; print "IslandsRcMenuCallbacks_v.selectIslandsBySize()"
		format "\n"; print "IslandsSystem_v.selectIslandsBySize()"

		/** Is island matchin size
		 */
		function isIslandMatchinSize island_size size size_min size_max =
		(
			--format "\n"; print ".isIslandMatchinSize()"
			--format "island_size: %\n" island_size
			--format "size: %\n" size

			if island_size == undefined and size == #SMALL then
				true --return

			else if island_size != undefined then
			(
				case size of
				(
					(#SMALL):	island_size.x <= size_min or  island_size.y <= size_min
					(#MEDIUM):	(island_size.x > size_min and island_size.x < size_max) or (island_size.y > size_min and island_size.y < size_max)
					(#BIG):	island_size.x >= size_max or  island_size.y >= size_max
				)
			)
			else
				false -- return fallback
		)

		islands_data = ISLANDS_SYSTEM.islands_data
		--islands_by_size = for i = islands_data.count to 1 by -1 where islands_data[i][#SIZE] != undefined and  islands_data[i][#SIZE] > 2 collect i
		size_min = DIALOG_island_manager.SPIN_island_size_min.value
		size_max = DIALOG_island_manager.SPIN_island_size_max.value

		/* GET ISLANDS MATHING SIZE */
		islands_by_size = (for i = 1 to islands_data.count where isIslandMatchinSize islands_data[i][#SIZE] size size_min size_max collect i) as BitArray

		::IslandsRcMenuCallbacks_v.selectIslandsAndUpdateListbox(islands_by_size)
	),

	/** Select single layer islands
	 */
	function selectSingleLayerIslands =
	(
		--format "\n"; print "IslandsRcMenuCallbacks_v.selectSingleLayerIslands()"

		islands_data = ISLANDS_SYSTEM.islands_data

		islands = (for i = 1 to islands_data.count where islands_data[i][#TOP] == undefined collect i) as BitArray

		::IslandsRcMenuCallbacks_v.selectIslandsAndUpdateListbox(islands)
	),

	/** Select verts of islands
	 */
	function selectVertsOfIslands vertex_type =
	(
		--format "\n"; print "IslandsRcMenuCallbacks_v.selectVertsOfIslands()"

		format "vertex_type: %\n" (classOf vertex_type)
		islands_data = ISLANDS_SYSTEM.islands_data

		selected_islands = ISLANDS_SYSTEM.getIslandsOfSelectedItems()

		_listbox = DIALOG_island_manager.ML_island_listbox

		if selected_islands.count == 0 then
			selected_islands = #{1..islands_data.count} as Array

		format "SELECTED_ISLANDS: %\n" selected_islands

		verts = #{}

		for layer_index in selected_islands collect
		(
			if vertex_type == #LOWEST_VERT then
				verts[islands_data[layer_index][vertex_type]] = true

			else if ( island_verts = ISLANDS_DATA[layer_index][vertex_type] ) != undefined then
				verts += island_verts
		)

		if verts.numberSet > 0 then
			ISLANDS_SYSTEM.selectVerts( verts as BitArray )
	),

	/** Isolate slected islands
	 */
	function isolateSlectedIslands state =
	(
		format "\n"; print "IslandsSystem_v.isolateSlectedIslands()"
		--format "state: %\n" state
		obj	= ISLANDS_SYSTEM.obj

		if state then
		(
			selected_islands = ( ISLANDS_SYSTEM.getIslandsOfSelectedItems() ) as Array

			verts = ISLANDS_SYSTEM.getVertsOfIslands(selected_islands)

			subObjectLevel = 1

			hidden_verts =	( polyop.getHiddenVerts obj) - verts

			polyop.unHideAllVerts obj

			if DIALOG_island_manager.CBTN_isolate.state == 1 then
			(
				all_verts = #{1..(getNumVerts obj.mesh)}

				polyop.setHiddenVerts obj (all_verts - verts)
			)
		)
	),

	/** Invert selection
	 */
	function invertSelection =
	(
		--format "\n"; print "IslandsCallbacks_v.invertSelection()"

		_listbox = DIALOG_island_manager.ML_island_listbox

		_listbox.selection = -_listbox.selection
	),

	/** Remove selected islands
	 */
	function removeSelectedIslands =
	(
		--format "\n"; print "IslandsRcMenuCallbacks_v.removeSelectedIslands()"
		--format "\n"; print "IslandsSystem_v.removeSelectedIslands()"
		obj	= ISLANDS_SYSTEM.obj

		_listbox = DIALOG_island_manager.ML_island_listbox

		selected_islands	= (ISLANDS_SYSTEM.getIslandsOfSelectedItems()) as Array
		selected_items 	= ( _listbox.selection as Array ) as BitArray -- remove false bits from BitArray
		--format "selected_items: %\n" selected_items
		--format "selected_items.count: %\n" selected_items.count

		/* CHECK IF DELETED LAYERS ARE NOT aBOVE SLICE PLANE
		*/
		if classOf ( modPanel.getCurrentObject() ) != Editable_Poly and DIALOG_slicer_slider != undefined then
		(
			selected_layers  = ISLANDS_SYSTEM.getLayersOfSelectedItems()
			visible_layers   = #{1..DIALOG_slicer_slider.SPIN_layer_current.value}
			invisible_layers = selected_layers - visible_layers

			if not invisible_layers.isEmpty then
			(
				messageBox ("You are trying to remove islands in sliced layers.\n\n LAYERS: "+ substituteString ( invisible_layers as string ) "#" "" ) title:"REMOVE ISLANDS"

				return false
			)
		)

		/* REMOVE ITEMS FROM LIST AND ISLANDS */
		if selected_islands.count > 0 and queryBox ("REMOVE SELECTED ISALNDS FROM OBJECT ?\n\n"+obj.name ) title:"REMOVE ISLANDS" then
		(
			list_items = _listbox.items

			_listbox.items = for i = 1 to list_items.count where not selected_items[i] collect list_items[i]

			if ( islands_props_data = getUserPropVal obj "ISLANDS_DATA" ) != undefined then
			(
				format "selected_islands.count: %\n" selected_islands.count

				for i = selected_islands.count to 1 by -1 do
					deleteItem islands_props_data selected_islands[i]

				setUserPropVal obj "ISLANDS_DATA" islands_props_data

				/* SELECT FIRST ISLAND UNDER DELETED ITEMS */
				_listbox.selection = selected_items.count

				/* SET WHITE VERTEX COLOR */
				macros.run "_Epoly-Vertex-Color" "epoly_vertex_color_set_white"
			)

		)
	),

	/** Slice at island
	 */
	function sliceAtIsland =
	(
		format "\n"; print "IslandsCallbacks_v.sliceAtIsland()"
		_listbox = DIALOG_island_manager.ML_island_listbox
		--format "_listbox.items: %\n" _listbox.items
		--islands_layers = (for item in _listbox.items collect (filterString item " ")[1] as integer ) --as BitArray -- get list items strings to bitarray

		selected_islands = ISLANDS_SYSTEM.getIslandsOfSelectedItems()
		--format "SELECTED_ISLANDS: %\n" selected_islands

		if selected_islands.numberSet > 0 then
		(
			island_data = ISLANDS_SYSTEM.islands_data[selected_islands.count]
			--format "ISLAND_DATA: %\n" island_data

			verts = ISLANDS_SYSTEM.getVertsFromIslandData(island_data)

			--format "islands_layers: %\n" islands_layers
			--format "_listbox.selection.count: %\n" _listbox.selection.count
			--layer_of_island = (islands_layers)[( _listbox.selection as Array )[1] ]

			layer_of_island = if DIALOG_island_manager.RB_slider_mode.state == 2 and island_data[#TOP] != undefined then island_data[#TOP] else island_data[#BOTTOM]
			--format "LAYER_OF_ISLAND: %\n" layer_of_island

			if not SLICER_SYSTEM.dialogExists() then
				macros.run "_3D-Print" "maxtoprint_create_slicer_dialog"

			SLICER_SYSTEM.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_of_island) (true)

			SLICER_SYSTEM.setSliderValueByLayerIndex(layer_of_island)

			SLICER_SYSTEM.setSpinnerValue(layer_of_island)

			ISLANDS_SYSTEM.selectVerts(verts)

		)
	),

	--/** Create island manager dialog only selected islands
	-- */
	--function createIslandManagerDialogOnlySelectedIslands =
	--(
	--	--format "\n"; print "IslandsRcMenuCallbacks_v.createIslandManagerDialogOnlySelectedIslands()"
	--	selected_islands = ISLANDS_SYSTEM.getIslandsOfSelectedItems()
	--
	--	islands_to_show = case of
	--	(
	--		(relaunch and selected_islands.numberSet >  1):	selected_islands                     -- SHOW ONLY SELECTED ITEMS ON RELAUNCH
	--		(relaunch and selected_islands.numberSet == 1):	#{(ISLANDS_SYSTEM.getFirstIslandFromListbox())..(selected_islands as Array )[1]} -- SHOW ISLANDS UP TO SELECTED ITEM ON RELAUNCH IF ONLY SINGLE ISLAND IS SELECTED
	--		default:	#{1..ISLANDS_SYSTEM.islands_data.count}             -- SHOW ALL ISLANDS
	--	)
	--
	--	createIslandManagerDialog islands_to_show:(ISLANDS_SYSTEM.getIslandsToShowBySlection())
	--),


	/** Select islands and update listbox
	 */
	function selectIslandsAndUpdateListbox islands_indexes =
	(
		--format "\n"; print "IslandsRcMenuCallbacks_v.selectIslandsAndUpdateListbox()"

		/* SELECT ITEMS IN LISTBOX */
		DIALOG_island_manager.ML_island_listbox.selection = ISLANDS_SYSTEM.getListboxItemsByIslandsIndex (islands_indexes)

		--::IslandsCallbacks_v.updateIslandSelectionByRadiobuttonsState()

		/* FIRE LISTBOX CALLBACK */
		::IslandsCallbacks_v.onListboxSelectionEnd()
	),

	private

	/**
	 */
	on create do
	(
		--format "\n"; print "IslandsRcMenuCallbacks.onCreate()"
		--for prop in #(  ) where getProperty ISLANDS_SYSTEM prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of ISLANDS_SYSTEM struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof ISLANDS_SYSTEM as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
