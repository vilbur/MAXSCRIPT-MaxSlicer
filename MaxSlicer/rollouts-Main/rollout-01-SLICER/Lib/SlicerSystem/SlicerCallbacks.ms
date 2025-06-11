filein( getFilenamePath(getSourceFileName()) + "/../../../rollout-07-VERTEX_SELECTION/Lib/EpolyVertsSelector/EpolyVertsSelector.ms" )	--"./../../../rollout-07-VERTEX_SELECTION/Lib/EpolyVertsSelector/EpolyVertsSelector.ms"

/** Slicer callbacks
 */
struct SlicerCallbacks_v
(
	/* construct */


	/* required */


	/* properties */
	--dialog = DIALOG_slicer_slider,

	/* private */
	/* dependency */
	/* reference */
	/* inhered */

	/** Slider changed
	 */
	function onSliderChanged slice_index =
	(
		--format "\n"; print "SlicerCallbacks_v.sliderChanged()"
		--format "SLICER_SYSTEM.slice_start: %\n" SLICER_SYSTEM.slice_start

		layer_index = slice_index + SLICER_SYSTEM.slice_start

		

		if (shift_mode = this._getShiftMode()) == #LAYERS then
		(
			slice_modes = SLICER_SYSTEM.slice_modes
	
			--/* SET DEAUFLT SLICE TOP */
			--if not (slice_modes[#SLICE_PLANE_TOP] and slice_modes[#SLICE_PLANE_BOTTOM]) then
			--	slice_modes[#SLICE_PLANE_TOP] = true
			--
			--/* ADD MODIFIERS */
			--if slice_modes[#SLICE_PLANE_TOP] then
				SLICER_SYSTEM.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_index) (true)
			
		)
		else if shift_mode == #VERTS then
			this._showVertsInLayer(layer_index)
		
		/* SYNC SPINNER VALUE */
		SLICER_SYSTEM.setSpinnerValue(layer_index)
	),

	/** Spinner changed
	 */
	function onSpinnerChanged layer_index =
	(
		--format "\n"; print "SlicerCallbacks_v.spinnerChanged()"
		--format "layer_index: %\n" layer_index
		if (shift_mode = this._getShiftMode()) == #LAYERS then
			/* UPDATE MODIFIER */
			SLICER_SYSTEM.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_index) (true)

		else if shift_mode == #VERTS then
			this._showVertsInLayer(layer_index)
			
		/* SYNC SLIDER VALUE */
		SLICER_SYSTEM.setSliderValue(layer_index)
	),

	/** Plus minus button
	  
	  * CTRL: Go next\previous island - if slider dialog is opened
	 */
	function onPlusMinusButton increment =
	(
		--format "\n"; print "SlicerCallbacks_v.plusMinusButton()"

		/** Get positions of selected verts
		 */
		function _getPositionsOfSelectedVerts =
		(
			--format "\n"; print "SlicerCallbacks_v._getPositionsOfSelectedVerts()"
			if classOf ( _mod = modPanel.getCurrentObject() ) == Edit_Poly then
			(
				obj = SLICER_SYSTEM.obj

				vertex_sel	= getVertSelection obj.mesh

				in coordsys world polyop.getVerts obj vertex_sel node:obj --return vertex positions
			)
		)
		
		/** Find verts by positions and reselect verts
		 */
		function _findAndReselectVerts verts_pos =
		(
			if verts_pos != undefined and classOf ( _mod = modPanel.getCurrentObject() ) == Edit_Poly then
			(
			format "\n"; print "SlicerCallbacks_v._findAndReselectVerts() DISABLED"

				--obj = SLICER_SYSTEM.obj
				--
				--verts_edit_poly = #{}
				----format "test: %\n" (getNumVerts obj.mesh )
				--
				--
				--if (verts_count =  getNumVerts obj.mesh ) > 0 then -- prevent set slice plane below object`s min z
				--(
				--	verts_pos_after_slice = in coordsys world  polyop.getVerts obj #{1..verts_count} node:obj
				--
				--	for vert_pos in verts_pos where (vert = findItem verts_pos_after_slice (vert_pos)) > 0 do
				--		verts_edit_poly[vert] = true
				--
				--	_mod.ButtonOp #UnhideAllVertex
				--
				--	_mod.SetSelection #VERTEX #{}
				--
				--	_mod.Select #VERTEX verts_edit_poly
				--
				--	_mod.ButtonOp #HideUnselectedVertex
				--)
			)
		)

		layer_current	= DIALOG_slicer_slider.SPIN_layer_current.value

		--shift_mode	= this._getShiftMode()
		
		shift_island = keyboard.altPressed
		
		
		/*------------------------------------------------------------------------------
			GET NEXT LAYER INDEX
		--------------------------------------------------------------------------------*/
		/* SHIFT: Go 1mm up\down */
		if not shift_island then
		(

			increment_const = case of
			(
				--( keyboard.controlPressed and keyboard.shiftPressed ): 100
				( keyboard.shiftPressed ):	100
				( keyboard.controlPressed ):	10
				default: 1
			)

			layer_next = layer_current + ( increment * increment_const )

		)
		/* CTRL: Go next\previous island - if slider dialog is opened */
		else if shift_island and DIALOG_island_manager != undefined then
			layer_next = ISLANDS_SYSTEM.getLayerOfClosestIsland(layer_current)(increment)

		/* GO 1 layer up\down */
		else
			layer_next = layer_current + increment

			
		if (shift_mode = this._getShiftMode()) == #LAYERS then
		(
			/*==============================================================================
	
				UPDATE LAYER
	
			================================================================================*/
			
			if layer_next > 0 and layer_next >= SLICER_SYSTEM.slice_start then
			(
				if not shift_island then
					vertex_sel_pos = _getPositionsOfSelectedVerts()
				--format "layer_next: %\n" layer_next
				--format "slice_start: %\n" SLICER_SYSTEM.slice_start
	
				with redraw off
				(
					/*------------------------------------------------------------------------------
						UPDATE SLICE MODIFIER
					--------------------------------------------------------------------------------*/
					SLICER_SYSTEM.setSlicePlaneModifier (#SLICE_PLANE_TOP) (#TRUE) (layer_next) (true)
	
					_findAndReselectVerts(vertex_sel_pos)

					/*------------------------------------------------------------------------------
						UPDATE ISLAND MANAGER
					--------------------------------------------------------------------------------*/
					if shift_island and DIALOG_island_manager != undefined then
					(
						ISLANDS_SYSTEM.selectIslandByLayerInListbox #{layer_next}
					
						if subObjectLevel != undefined and subObjectLevel > 0 then
						(
							selected_islands = ISLANDS_SYSTEM.getIslandsOfSelectedItems()
							format "Selected Islands: %\n" selected_islands
					
							ISLANDS_SYSTEM.selectVertsOfIslands(selected_islands)
						)
					)
				)
			)
		)
		else if shift_mode == #VERTS then
			this._showVertsInLayer(layer_next)
	
		/*------------------------------------------------------------------------------
			SYNC SLIDER VALUE
		--------------------------------------------------------------------------------*/
		SLICER_SYSTEM.setSliderValueByLayerIndex( layer_next )

		/*------------------------------------------------------------------------------
			SYNC SPINNER VALUE
		--------------------------------------------------------------------------------*/
		SLICER_SYSTEM.setSpinnerValue(layer_next)
	),

	/** Show verts in layer
	 */
	function _showVertsInLayer layer_index =
	(
		--format "\n"; print "SlicerCallbacks_v._showVertsInLayer()"
		--format "SHIFT VERTS\n"
		--format "SLICER_SYSTEM.verts_layers: %\n" SLICER_SYSTEM.verts_layers
		--SLICER_SYSTEM.deleteModifiers()
		
		if ( SLICER_SYSTEM.verts_layers ) == undefined then 
			SLICER_SYSTEM.setVertsLayers()
		
		obj = SLICER_SYSTEM.obj
		
		max modify mode

		subObjectLevel = 1

		obj.EditablePoly.SetSelection #Vertex #{}
		
		verts_in_layer = SLICER_SYSTEM.verts_layers[layer_index]
		--format "verts_in_layer: %\n" verts_in_layer
		
		if classOf verts_in_layer == BitArray then
		(
			EpolyVertsSelector = EpolyVertsSelector_v( obj )
			
			/* ISOLATE */ 
			EpolyVertsSelector.isolateVerts verts_in_layer
			
			/* SELECT */ 
			EpolyVertsSelector.setSelection verts_in_layer
			
		)
	),
	
	/** Get shift mode
	 */
	function _getShiftMode =
	(
		--format "\n"; print "SlicerCallbacks_v._getShiftMode()"
		#( #LAYERS, #VERTS )[DIALOG_slicer_slider.DDL_slider_snaps.selection as integer ]
	),
	
	/** Desroy slider dialog and delete modifiers
	 */
	function desroySliderDialogAndDeleteModifiers =
	(
		--format "\n"; print "SlicerCallbacks_v.desroySliderDialogAndDeleteModifiers()"

		SLICER_SYSTEM.desroySliderDialog()

		SLICER_SYSTEM.deleteModifiers()
	),
	
	

	/**
	 */
	on create do
	(
		--format "\n"; print "SlicerCallbacks.onCreate()"
	)
)