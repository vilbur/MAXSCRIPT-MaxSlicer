/** Islands callbacks
 */
struct IslandsCallbacks_v
(
	/* construct */


	/* required */


	/* properties */


	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Slider changed
	 */
	function onSliderChanged slider_val =
	(
		--format "\n"; print "IslandsCallbacks_v.sliderChanged()"
		--format "slider_val: %\n" slider_val
		_listbox = DIALOG_island_manager.ML_island_listbox

		item = _listbox.items.count - slider_val

		/* UPDATE LISTBOX SELECTION */
		_listbox.selection = if keyboard.shiftPressed then
		(
			listbox_selection = _listbox.selection

			listbox_selection[item] = true

			listbox_selection --return
		)
		else
			#{item}

		--select_whole_island = DIALOG_island_manager.RB_slider_mode.state
		--
		--island_data = islands_data[item]
		--
		--if island_data[#NEW_ISLAND] != undefined then
		--(
		--	--verts = islands_data[#WHOLE_ISLAND]
		--	--verts = islands_data[#NEW_ISLAND]
		--	verts = this.getVertsFromIslandData (island_data)
		--
		--	if keyboard.shiftPressed then
		--		verts += polyop.getVertSelection obj
		--
		--	--format "VERTS: %\n" verts
		--	this.selectIslandsVerts (verts)
		--
		--)

		--this.selectIslandByLayerInListbox (item)
	),

	/** On slide end
	 */
	function onSlideEnd =
	(
		--format "\n"; print "IslandsCallbacks_v.onSlideEnd()"
		--format "EventFired	= % \n" EventFired

	),

	/** On listbox item selected
	 */
	function onListboxSelectionEnd =
	(
		format "\n"; print "IslandsCallbacks_v.onListboxSelectionEnd()"
		--format "EventFired	= % \n" EventFired
		_listbox = DIALOG_island_manager.ML_island_listbox

		selected_islands = ISLANDS_SYSTEM.getIslandsOfSelectedItems()

		if selected_islands.numberSet > 0 then
		(
			verts = ISLANDS_SYSTEM.selectVertsOfIslands(selected_islands)

			for index in selected_islands do
			(
				data = ISLANDS_SYSTEM.islands_data[index]
				format "selected_island %: BOTTOM: %  TOP: %  NEW_ISLAND: %  WHOLE_ISLAND: % \n" index data[#BOTTOM] data[#TOP] data[#NEW_ISLAND] data[#WHOLE_ISLAND]
			)

			/* UPDATE SLIDER VALUE TO TOP MOST OF SELECTED ISLANDS */
			--if selected_islands.count > 0 then
			DIALOG_island_manager.SLIDER_island_select.value = _listbox.items.count - (_listbox.selection as Array )[1] + 1
		)
	),

	/** On listbox rightclick
	 */
	function onListboxRightclick =
	(
		--format "\n"; print "IslandsCallbacks_v.onListboxRightclick()"
		selected_items = DIALOG_island_manager.ML_island_listbox.selection.numberSet > 0
		vertex_sel	    = (getVertSelection selection[1].mesh).numberSet > 0

		--format "selected_items: %\n" selected_items
		--format "1: %\n" (keyboard.controlPressed and vertex_sel)
		--format "2: %\n" (keyboard.shiftPressed and selected_items)
		--format "3: %\n" (keyboard.shiftPressed and vertex_sel and not selected_items)
		--format "vertex_sel: %\n" (vertex_sel)
		--format "selected_items: %\n" selected_items

		case of
		(
			( keyboard.controlPressed and vertex_sel ):	::IslandsRcMenuCallbacks_v.selectIslandsByVerts()
			( keyboard.shiftPressed and selected_items ):	::IslandsRcMenuCallbacks_v.sliceAtIsland()
			( keyboard.shiftPressed and vertex_sel and not selected_items ):	(::IslandsRcMenuCallbacks_v.selectIslandsByVerts(); ::IslandsRcMenuCallbacks_v.sliceAtIsland())

			default: islandsRcMenu()
		)
	),

	/** Update island selection by radiobuttons state
	 */
	function updateIslandSelectionByRadiobuttonsState =
	(
		--format "\n"; print "IslandsCallbacks_v.updateIslandSelectionByRadiobuttonsState()"
		islands_states = #( #NEW_ISLAND, #LOWEST_VERT, #WHOLE_ISLAND )

		::IslandsRcMenuCallbacks_v.selectVertsOfIslands ( islands_states[DIALOG_island_manager.RB_slider_mode.state +1] )
	),

	/** Select all islands in listbox
	 */
	function selectAllIslandsInListbox =
	(
		--format "\n"; print "IslandsCallbacks_v.selectAllIslandsInListbox()"
		_listbox = IALOG_island_manager.ML_island_listbox


		_listbox.selection = #{1.._listbox.items.count}

		--ISLANDS_SYSTEM.updateIslandSelectionByRadiobuttonsState()
	),

	/** Isolate slected islands
	 */
	function isolateSlectedIslands state =
	(
		--format "\n"; print "IslandsCallbacks_v.isolateSlectedIslands()"
		if state then
		(
			selected_islands = ( ISLANDS_SYSTEM.getIslandsOfSelectedItems() ) as Array

			ISLANDS_SYSTEM.isolateIslands(selected_islands)
		)
	),

	/** Unhide all verts
	 */
	function unhideVerts =
	(
		--format "\n"; print "IslandsCallbacks_v.unhideAllVerts()"
		max modify mode

		if classOf (_mod = modPanel.getCurrentObject()) == Editable_Poly then
			_mod.unhideAll #Vertex

		else if classOf _mod  == Edit_Poly then
			_mod.ButtonOp #UnhideAllVertex

	),

	/** Toggle select island mode
	 */
	function toggleSelectIslandMode =
	(
		--format "\n"; print ".toggleSelectIslandMode()"
		--format "DIALOG_island_manager.RB_slider_mode.state: %\n" DIALOG_island_manager.RB_slider_mode.state
		--DIALOG_island_manager.RB_slider_mode.state = not DIALOG_island_manager.RB_slider_mode.state
		--format "DIALOG_island_manager.RB_slider_mode_last_state: %\n" DIALOG_island_manager.RB_slider_mode_last_state
		--format "DIALOG_island_manager.RB_slider_mode.state: %\n" DIALOG_island_manager.RB_slider_mode.state

		DIALOG_island_manager.RB_slider_mode.state = case DIALOG_island_manager.RB_slider_mode.state of
		(
			0:	1
			1:	2
			2:	0
		)
	),

	/** Destroy dialog
	 */
	function destroyIslandsDialog =
	(
		--format "\n"; print "IslandsCallbacks_v.destroyDialog()"
		try( cui.UnRegisterDialogBar DIALOG_island_manager )catch()
		try( destroyDialog           DIALOG_island_manager )catch()
	),

	private


	/**
	 */
	on create do
	(
		--format "\n"; print "IslandsCallbacks.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)
