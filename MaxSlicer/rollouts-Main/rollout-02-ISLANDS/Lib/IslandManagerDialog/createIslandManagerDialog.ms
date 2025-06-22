/** Create island manager dialog
  *
  * @param #ALL|#SAVED
 */
function createIslandManagerDialog islands_to_show: =
(
	--clearListener(); print("Cleared in:\n"+getSourceFileName())
	format "\n"; print ".createIslandManagerDialog()"
	--format "ISLANDS_SYSTEM.islands_data: %\n" ISLANDS_SYSTEM.islands_data

	/** Get item titile
	 */
	function getItemTitile island_index =
	(
		/*
		   MAX SIZE AND DISPLAY UNITS - HOTFIX CODE

		   CREATE FUNCTION IslandsSystem_v.getMinMaxSize()

		*/
		display_units = case units.SystemType of -- convert to milimeters
		(
			#millimeters:	1
			#centimeters:	10
			#meters:	1000
			#kilometers:	1000000
			default:	1 -- non metric units
		)

		--_size_max = DIALOG_island_manager.SPIN_island_size_max.value / display_units
		_size_max = 10 / display_units
		--format "_size_max: %\n" _size_max
		/** Get heigh island
		 */
		function getHeighIslandX island_data        = if island_data[#TOP] != undefined and island_data[#TOP] - island_data[#BOTTOM] > 10  then "↕" else ""
		function getIslandSizeCharacter island_data _size_max = if island_data[#SIZE] != undefined and (island_data[#SIZE].x > _size_max or island_data[#SIZE].y > _size_max )  then "↔" else ""
		--format "\n"; print ".getItemTitile()"
		island_data = ISLANDS_SYSTEM.islands_data[island_index]

		whitespace = "                          "

		size_marks = getHeighIslandX(island_data) + getIslandSizeCharacter(island_data)(_size_max)

		if size_marks.count > 0 then
			size_marks = " " + size_marks

		--ISLANDS_SYSTEM.islands_data[island_index][#BOTTOM] as string +  "                          #" + island_index as string
		ISLANDS_SYSTEM.islands_data[island_index][#BOTTOM] as string + size_marks + whitespace+ "island_index:" + island_index as string
	)


	/*------------------------------------------------------------------------------
		GET LSIBOX ITEMS
	--------------------------------------------------------------------------------*/
	--selected_islands = ISLANDS_SYSTEM.getSelectedIslandsFromListBox()

	islands = if islands_to_show == unsupplied and ( visible_islands_saved = ISLANDS_SYSTEM.loadVisibleIslands() ) != undefined then
		visible_islands_saved

	else if islands_to_show == unsupplied or islands_to_show.numberSet == 0 then
		#{1..ISLANDS_SYSTEM.islands_data.count}

	else
		islands_to_show
		
	format "islands: %\n" islands

	islands = islands as Array
	
	--items = for i = ISLANDS_SYSTEM.islands_data.count to 1 by -1 where islands[i] collect  getItemTitile (i)
	
	--items = for i = islands.count to 1 by -1  collect getItemTitile (islands[i])
	items = for i = islands.count to 1 by -1  collect islands[i] as string


	/*------------------------------------------------------------------------------
		DIALOG
	--------------------------------------------------------------------------------*/
    --Dialog 	    = Dialog_v "" id:#DIALOG_island_manager ini:(getSourceFileName()) --min_size:[48, -1] max_size:[48, -1]

	min_size = [ 96, -1 ]

    Dialog 	    = Dialog_v "Islands" id:#DIALOG_island_manager ini:(getSourceFileName()) width:min_size.x min_size:min_size --max_size:[48, -1]

	_Controls   = Dialog.Controls() --group:"Main Controls"

	item_height = 13

	viewport_height = Dialog.getViewportHeight()

	items_count = items.count

	listbox_pos_z = 50

	--height_other_controls = 126
	height_other_controls = 122

    max_item_length = amax(for i = ISLANDS_SYSTEM.islands_data.count to 1 by -1 collect (ISLANDS_SYSTEM.islands_data[i][#BOTTOM] as string ).count)

	label_text = if islands_to_show != unsupplied and islands_to_show.numberSet > 0 then islands_to_show.numberSet as string +"\\"+ ISLANDS_SYSTEM.islands_data.count as string else ISLANDS_SYSTEM.islands_data.count as string + " Islands"

	--width_listbox = (max_item_length * 10 ) + 16
	width_listbox = max_item_length * 10

	slider_width = 32

	space_for_listbox = viewport_height - height_other_controls


	listbox_height = (space_for_listbox / item_height) as integer -- number of max visible items in listbox


	/* FIT LISTBOX HEIGHT TO ITEMS COUNT AND ALIGN TO BOTTOM */
	if items_count < listbox_height then
	(
		listbox_height_in_px = items.count * item_height

		listbox_pos_z += viewport_height - listbox_height_in_px - height_other_controls -- 4 -- 2 px to set position pixel perfect

		listbox_height = items.count
	)
	else
	/* ADD WIDTH FOR SCROLLBAR IF ITMES IS MORE THEN FIT TO LSITBOX */
		width_listbox += 20

	/*------------------------------------------------------------------------------
		CONTROLS
	--------------------------------------------------------------------------------*/
    btn_exit = _Controls.control #BUTTON "Exit" across:1 width:64 height:24 align:#center offset:[ -10, -4 ] border:false tooltip:"Exit and remove slicer from all objects"

    label_count = _Controls.control #LABEL label_text id:#LABEL_islands_count across:1 width:64 height:24 offset:[ -8, 2 ]

	/*------ MULTILISTBOX ------*/
	_multilistbox = _Controls.control #MULTILISTBOX "" \
	id:#ML_island_listbox	\
	width:width_listbox	\
	height:listbox_height	\
	items:items			\
	across:2			\
	ini:false			\
                   pos:[ 4, listbox_pos_z ]

	/*------ SLIDER ------*/
    _slider = _Controls.control #SLIDER "" \
                    id:#SLIDER_island_select	\
                    range:[ 1, items_count ,0 ]	\
                    params:#(#orient, #vertical, #type, #integer)	\
                    ticks:(items_count - 1)	\
                    width:slider_width	\
                    height:((listbox_height + 1) * item_height)	\
                    across:2	\
                    ini:false	\
                    pos:[ width_listbox + 4, listbox_pos_z - 4 ]

	/*------ CECKBUTTON ------*/
	btn_isloate = _Controls.control #CHECKBUTTON "ISOLATE" id:#CBTN_isolate height:32


	/*------ RADIOBUTTONS ------*/
	_radio = _Controls.control #RADIOBUTTONS "" id:#RB_slider_mode items:#("   ↓   ","   ↑   ") params:#( #UNSELECT, true ) across:1 offset:[ -10, 2 ] --align:#center  --width:96

	/*------ SPINNER ------*/
	_size_min = _Controls.control #SPINNER "" id:#SPIN_island_size_min across:2 type:#integer range:[0,100,2] width:40 offset:[ -20, 0]
	_size_max = _Controls.control #SPINNER "" id:#SPIN_island_size_max across:2 type:#integer range:[0,100,5] width:40 offset:[ -20, 0]


	/*------------------------------------------------------------------------------
		EVENTS
	--------------------------------------------------------------------------------*/
	btn_exit.Event #PRESSED "::IslandsCallbacks_v.destroyIslandsDialog()" border:false tooltip:"Exit slicer"

	/* ISOLATE BUTTON */ 
	btn_isloate.Event #CHANGED    "::IslandsCallbacks_v.isolateSlectedIslands(val)" tooltip:"Show only verts of selected islands"
	btn_isloate.Event #RIGHTCLICK "::IslandsCallbacks_v.unhideVerts()" tooltip:"Unhide Verts"

	/* RADIO BUTTONS  */ 
	_radio.Event #CHANGED "::IslandsCallbacks_v.updateIslandSelectionByRadiobuttonsState()"
	_radio.Event #RIGHTCLICK "::IslandsCallbacks_v.updateIslandSelectionByRadiobuttonsState()"

	/* LIST */ 
	_multilistbox.Event #SELECTIONEND "::IslandsCallbacks_v.onListboxSelectionEnd()"
	_multilistbox.Event #RIGHTCLICK   "::IslandsCallbacks_v.onListboxRightclick()"  tooltip:"Open submenu.\n\nCTRL+RMB: Select Islands by verts\n\nSHIFT+RMB: Slice on selected island"

	/* SLIDER */ 
	_slider.Event #CHANGED     "::IslandsCallbacks_v.onSliderChanged(val)" tooltip:"SHIFT: Select islands"
	_slider.Event #SLIDE       "::IslandsCallbacks_v.onListboxSelectionEnd()"
	_slider.Event #RIGHTCLICK  "::IslandsCallbacks_v.toggleSelectIslandMode()"

	/* SPINNERS */ 
	_size_min.Event #CHANGED "format \"EventFired: %\n\" EventFired"
	_size_max.Event #CHANGED "format \"EventFired: %\n\" EventFired"

	--Dialog.min_size = [32, -1]
	--Dialog.create width:(width_listbox + slider_width) height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	--Dialog.create width:(96) height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	Dialog.create width:min_size.x height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	--Dialog.create height:#VIEWPORT --bgcolor:( color 60 130 140 )

	--format "DIALOG_slicer_slider: %\n" DIALOG_slicer_slider
	--format "cui.getDockState DIALOG_slicer_slider: %\n" (cui.getDockState DIALOG_slicer_slider)


	/*
			KEEP DOCKED ON THE LEFT SIDE BY SLICER
	*/
	if DIALOG_slicer_slider != undefined and GetDialogPos DIALOG_slicer_slider != [0,0] and cui.getDockState DIALOG_slicer_slider == #CUI_DOCK_RIGHT then
	(
		cui.FloatDialogBar DIALOG_slicer_slider

		Dialog.dock #RIGHT

		cui.DockDialogBar DIALOG_slicer_slider #CUI_DOCK_RIGHT
	)
	else
		Dialog.dock #RIGHT


)
