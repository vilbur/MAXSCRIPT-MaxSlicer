filein( getFilenamePath(getSourceFileName()) + "/createSlicerDialog.ms" )	--"./createSlicerDialog.ms"

filein( getFilenamePath(getSourceFileName()) + "/SlicerCallbacks.ms" )	--"./SlicerCallbacks.ms"

filein( getFilenamePath(getSourceFileName()) + "/onModifyStackReady_SLICER.ms" )	--"./onModifyStackReady_SLICER.ms"



/** Methods synchronizing islands dialog controls functions
 */
struct SlicerSystem_v
(
	/* construct */
	/* required */
	_objects,
	obj,

	export_size = DIALOG_content.SPIN_export_size.value,
	layer_height	= DIALOG_content.SPIN_layer_height.value,

	/* properties */
	layers_count, --
	slice_start, --
	slice_count, -- number of prit layers used for objects bbox z dimension

	min_z,

	/* private */
	slice_modes = Dictionary #( #SLICE_PLANE_TOP, true ) #( #SLICE_PLANE_BOTTOM, false ),

	slice_modifiers = Dictionary #NAME,

	viewport_height,
	display_units,
	/* dependency */
	/* reference */
	/* inhered */




	/** Set slice plane modifier
	  *
	  * @param int|float layer_index_or_z_pos position where slice plane is elevated
	  *		1) FLOAT:	z pozition in world units
	  *		2) INTEGER:	index of print layer
	  *
	  */
	function setSlicePlaneModifier mode state layer_index_or_z_pos cap_state =
	(
		format "\n"; print "IslandsCallbacks_v.setSlicePlaneModifier()"
		--format "slice_mod: %\n" slice_modifiers[mode]
		--format "layer_index_or_z_pos: %\n" layer_index_or_z_pos
		if ( slice_mod = slice_modifiers[mode] ) == undefined then
			return false

		z_pos = if classOf layer_index_or_z_pos == integer then this._getPlaneZpozition (layer_index_or_z_pos) else layer_index_or_z_pos
		--format "z_pos: %\n" z_pos
		/* SET SLICE PLANE POSITION */
		final_TM = Matrix3 1

		final_TM.position.z = z_pos

		slice_mod.cap = cap_state

		--this._saveEditPolyVertsVisibily()

		/*  UPDATE MODIFIER PROPERTIES */
		slice_mod.slice_plane.transform = final_TM

		slice_mod.Slice_Type = (if mode == #SLICE_PLANE_TOP then 2 else 3 )

		redrawViews()

	),

	/** Move slider
	 */
	function moveSlider direction =
	(
		--format "\n"; print "IslandsSystem_v.moveSlider()"
		--format "EventFired:	% \n" EventFired.type
		--format "%\n" EventFired.type
		format "DIALOG_slicer_slider.SLIDER_slicer.value: %\n" DIALOG_slicer_slider.SLIDER_slicer.value
	),

	/** Set obejcts
	 */
	function setObjectsBySelection =
	(
		format "\n"; print "SlicerSystem_v.setObjectsBySelection()"
		_objects = for obj in selection where superClassOf obj == GeometryClass collect obj

		obj = _objects[1]

		viewport_height = this.getViewportHeight()

		this.toggleModifiers(false)

		bbox	= nodeGetBoundingBox obj ( Matrix3 1) -- return array of max\min positions E.G.: bbox[1].z | bbox[2].z

		min_z = bbox[1].z
		max_z = bbox[2].z
		format "min_z: %\n" min_z

		this.toggleModifiers(true)

		select _objects

		layers_count = (max_z / layer_height) as integer
		format "layer_height: %\n" layer_height
		format "layers_count: %\n" layers_count

		slice_count = (( max_z - min_z ) / layer_height ) as integer
		format "slice_count: %\n" slice_count

		slice_start = ( min_z  / layer_height ) as integer + 1
		format "slice_start: %\n" slice_start
	),

	/** Add slice_modifiers
	 */
	function addModifiers =
	(
		--format "\n"; print "SlicerSystem_v.addModifiers()"
		/** Add slice mod
		 */
		function addSliceMod obj slice_mod =
		(
			--format "\n"; print "SlicerSystem_v.addSliceMod()"
			addModifier obj slice_mod

			mod_TM =	(getModContextTM obj slice_mod)	* (  obj.transform )
			--format "mod_TM	= % \n" mod_TM
			setModContextTM obj slice_mod mod_TM
		)

		for slice_mode_data in slice_modes where slice_mode_data.value do
		(
			slice_modifier = slice_modifiers[slice_mode_data.key]

			/* GET OBJECTS WITH MODIFIER INS */
			objects_with_modifier = refs.dependentNodes slice_modifier

			--format "OBJECTS_WITH_MODIFIER: %\n" objects_with_modifier
			/* ADD MODIIFER WHERE IS NOT */
			for obj in _objects where findItem objects_with_modifier obj == 0 do
			(
				/* ADD POLY SELECT MODIFIER  */
				--addModifier obj  (Poly_Select name:"SLICE_SELECT_OBJ" )

				/* ADD SLICE MODIFIER  */
				addSliceMod (obj)	(slice_modifier)

				/* ADD SLICE MODIFIER  */
				addModifier obj  (Edit_Poly name:"SLICE_EDIT_VERTS" )
			)
		)
	),

	--/** Delete modifiers
	-- */
	--function deleteModifiers =
	--(
	--	format "\n"; print "SlicerSystem_v.deleteModifiers()"
	--	for key in slice_modifiers.keys do
	--	(
	--		slice_modifier = slice_modifiers[key]
	--
	--		/* GET OBJECTS WITH MODIFIER INS */
	--		if (objects_with_modifier = refs.dependentNodes slice_modifiers[key]).count > 0 then
	--			for obj in objects_with_modifier do
	--			deleteModifier obj slice_modifiers[key]
	--	)
	--
	--	for obj in objects \
	--		where (poly_select_mod = obj.modifiers[#SLICE_SELECT_OBJ]) != undefined \
	--		or    (edit_poly_mod  = obj.modifiers[#SLICE_EDIT_VERTS]) != undefined do
	--		(
	--			format "obj.name: %\n" obj.name
	--			format "poly_select_mod: %\n" poly_select_mod
	--			format "edit_poly_mod: %\n" edit_poly_mod
	--			if poly_select_mod != undefined then
	--				deleteModifier obj poly_select_mod
	--			
	--			if edit_poly_mod != undefined then
	--				deleteModifier obj edit_poly_mod				
	--		)
	--),

	/** Toggle slice_modifiers
	 */
	function toggleModifiers state =
	(
		--format "\n"; print "SlicerSystem_v.toggleModifiers()"
		--format "slice_modes: %\n" slice_modes

		for slice_mode_data in slice_modes where slice_mode_data.value do
		(
			/* GET ALL INSANCES OF MODIFIER IN SCENE */
			modifiers_in_scene = this._getModifiersInScene( slice_mode_data.key )

			/* GET NEW INSANCE MODIFIER */
			if ( slice_modifier = modifiers_in_scene[1] ) != undefined and slice_modifier.enabled != state then
				slice_modifier.enabled = state
		)
	),


	/** When attribute change https://help.autodesk.com/view/MAXDEV/2024/ENU/?guid=GUID-513285B3-DBF6-471E-B587-B5BE14D4D875
	 */
	function whenSelectionChange  =
	(
		deleteAllChangeHandlers id:#WHEN_SLICED_OBJECTS_SELECTED

		--when select WHEN_SLICED_OBJECTS_SELECTED changes id:#WHEN_SLICED_OBJECTS_SELECTED obj do
		when select this._objects changes id:#WHEN_SLICED_OBJECTS_SELECTED obj do
			if obj.isSelected then
				waitOnModifiyStackIsReady_SLICER()
	),

	/** Set slider by modifier
	 */
	function setSliderByModifier =
	(
		--format "\n"; print "SlicerSystem_v.setSliderByModifier()"
		slice_pos = slice_modifiers[#SLICE_PLANE_TOP].slice_plane.transform.position.z

		layer_index = this.posToLayerIndex(slice_pos)

		this.setSpinnerValue(layer_index + slice_start)

		this.setSliderValue(layer_index)
	),

	/** Desroy
	 */
	function desroySliderDialog =
	(
		--format "\n"; print ".desroy()"
		--removeSlicePlaneModifiers( selection )
		cui.UnRegisterDialogBar DIALOG_slicer_slider

		destroyDialog DIALOG_slicer_slider
	),

	/** Get Layer index by position in world
	 */
	function posToLayerIndex pos =
	(
		--format "\n"; print "SlicerSystem_v.posToLayerIndex()"


		/*  Round float to iteger
		*/
		fn roundToInteger val = floor (val  + 0.5)  as integer

		--display_units = case units.SystemType of -- convert to milimeters
		--(
		--	#millimeters:	1
		--	#centimeters:	10
		--	#meters:	1000
		--	#kilometers:	1000000
		--	default:	1 -- non metric units
		--)

		--export_size = DIALOG_content.SPIN_export_size.value
		--layer_height	= DIALOG_content.SPIN_layer_height.value
		--current_layer = DIALOG_slicer_slider.SPIN_layer_current.value

		pos -= min_z
		--
		--format "pos: %\n" pos
		--format "display_units: %\n" display_units
		--format "layer_height: %\n" layer_height
		--format "export_size: %\n" export_size
		/* MOVE SLICE PLANE TO SELCTION BOTTOM */
		layer_index = roundToInteger ((pos * display_units) / layer_height	/ export_size)

		layer_index --return
	),

	/** Toggle slice plane position
	  * @param #TOP|BOTTOM|CENTER pos
	 */
	function toggleSlicePlanePosition pos: =
	(
		--format "\n"; print "SlicerSystem_v.toggleIcepPlanePosition()"
		--print "createslicerSliderDialog SLIDER_slicer rightClick"
		/** Toggle slice slice_modifiers
		 */
		function toggleSliceModifiers state mod_names:#( #SLICE_PLANE_TOP, #SLICE_PLANE_BOTTOM ) =
		(
			for obj in selection do
				for mod_name in mod_names where ( _mod = obj.modifiers[mod_name] ) != undefined do
					_mod.enabled = state
		)

		/** Get values of wolrd aligned bbox
		  * @return float
		 */
		function getBbox obj minmax axis = getProperty (( nodeGetBoundingBox obj ( Matrix3 1) )[if minmax == #min then 1 else 2 ]) axis

		/** Get next item
		 */
		function getNextItem arr index = if (next_pos = arr[index + 1]) != undefined then next_pos else arr[1]


		if selection.count > 0 then
		(
			if SET_slicer == undefined then
				SET_slicer = Dictionary #("SELECTION", "" ) #("TRANSFROM", Matrix3 1 )

			current_layer	= DIALOG_slicer_slider.SPIN_layer_current.value
			selection_pointer = (for obj in selection collect getHandleByAnim obj) as string


			/* GET OBEJCT DIMENSIONS AND Z POSITIONS OF LAYERS */
			if SET_slicer["SELECTION"] != selection_pointer or SET_slicer["TRANSFROM"] != $.transform then -- get new data if selection or transform of selection changed
			(
				--format "SELECTION CHANGED	= % \n" SET_slicer

				toggleSliceModifiers (false)

				selection_min	= amin(for obj in selection collect getBbox (obj) (#min) (#z) )
				selection_max	= amax(for obj in selection collect getBbox (obj) (#max) (#z) )
				selection_center	= (selection_min + selection_max ) / 2

				layer_index_min = posToLayerIndex( selection_min ) --+1 -- Without 1 then first layer under object is selected
				layer_index_max = posToLayerIndex( selection_max )
				layer_index_center = posToLayerIndex( selection_center )

				layer_positions = #( layer_index_min, layer_index_center, layer_index_max )

				SET_slicer["SELECTION"]	= selection_pointer
				SET_slicer["LAYER_POSITIONS"]	= layer_positions
			)

			layer_positions = SET_slicer["LAYER_POSITIONS"]

			current_pos_index = findItem layer_positions current_layer

			layer_index = case pos of
			(
				(#TOP):	selection_max
				(#BOTTOM):	layer_index_min
				(#CENTER):	layer_index_center

				default: case of
				(
					( keyboard.controlPressed):	layer_positions[1] -- GET SELECOIN  MIN IF CTRL RPESSED
					((next_item = getNextItem(layer_positions)(current_pos_index)) != undefined ):	next_item	-- GET NEXT PREDEFINED POSITION
					default:	layer_positions[2]	-- GET SELECTION CENTER AS DEFAULT
				)
			)

			this.toggleSliceModifiers (true)

			this.updateSlicePlaneSystem ( layer_index )

			/* DEVELOP FIXING */
			SET_slicer = undefined
		)
	),

	/** Set slider value
	 */
	function setSliderValue val =
	(
		if DIALOG_slicer_slider != undefined then
			DIALOG_slicer_slider.SLIDER_slicer.value = val
	),

	/** Set slider value
	 */
	function setSliderValueByLayerIndex layer_index =
	(
		this.setSliderValue(layer_index - SLICER_SYSTEM.slice_start)
	),

	/** Set spinner value
	 */
	function setSpinnerValue layer_index =
	(
		if DIALOG_slicer_slider != undefined then
			DIALOG_slicer_slider.SPIN_layer_current.value = layer_index
	),


	/** Dialog exists
	 */
	function dialogExists =
	(
		--format "\n"; print "SlicerSystem_v.dialogExists()"

		GetDialogPos DIALOG_slicer_slider != [0,0]
	),

	private

	/** Save edit poly verts visibily
	 */
	function _saveEditPolyVertsVisibily =
	(
		format "\n"; print "SlicerSystem_v._saveEditPolyVertsVisibily()"

		if classOf (obj.modifiers[1] ) == Edit_Poly then
			max modify mode

		if classOf ( _mod = modPanel.getCurrentObject() ) == Edit_Poly then
		(
			hidden_verts = meshop.getHiddenVerts obj.mesh

--$.modifiers[#Edit_Poly].Select #Vertex #{1..100}


			--meshop.setHiddenVerts obj.mesh #{1..100}

		)

	),

	/** Set slice_modifiers array
	 */
	function _setModifiers =
	(
		--format "\n"; print "SlicerSystem_v._setModifiers()"
		for slice_mode_data in slice_modes where slice_mode_data.value do
		(
			mod_name = slice_mode_data.key

			mods_in_scene = this._getModifiersInScene( mod_name )

			this.slice_modifiers[mod_name] = if ( slice_mod = mods_in_scene[1] ) != undefined then
				mods_in_scene[1]
			else
				SliceModifier name:( mod_name as string ) setmaterial:on materialID:3  Faces___Polygons_Toggle:0
		)
	),

	/** Set slider params
	 */
	function _setSliderParams =
	(
		--_slider = DIALOG_slicer_slider.SPIN_layer_current

		--DIALOG_slicer_slider.SPIN_layer_current.range.y = this.slice_count
	),

	/** Get height of maximized viewport to find out height of docked dialog
	 */
	function getViewportHeight =
	(
		--print "Dialog_v._getViewportHeight()"
		is_maximized	= viewport.numViews == 1

		height_of_ui	= 0 -- Add heigh
		dialog_title_height	= 30

		--if( trackbar.visible ) then
		--	height_of_ui	+= 27
		--
		--if( timeSlider.isVisible() ) then
		--	height_of_ui	+= 18

		if not( is_maximized ) then
			actionMan.executeAction 0 "50026"  -- Tools: Maximize Viewport Toggle

		viewport_area_size = getViewSize()
		--format "viewport_area_size	= % \n" viewport_area_size
		if not( is_maximized ) then
			actionMan.executeAction 0 "50026"  -- Tools: Maximize Viewport Toggle

		(viewport_area_size[2] as integer) + height_of_ui - dialog_title_height --return
	),

	/** Set print slicer
	  *
	  */
	function _getPlaneZpozition layer_index =
	(
		--format "\n"; print "SlicerSystem_v._getPlaneZpozition()"
		--volume_height	= (PrinterVolume_v(DIALOG_content.SPIN_export_size.value)).printer_size.z
		--format "LAYER_INDEX: %\n" layer_index
		--layer_height	= DIALOG_content.SPIN_layer_height.value
		--layer_current	= DIALOG_slicer_slider.SLIDER_slicer.value
		--slice_count	= volume_height / layer_height

		layers_count = slice_start + slice_count

		if layer_index < 0 or layer_index > layers_count then
			layer_index = 	if layer_index < 0  then 0 else layers_count

		layer_index * layer_height  --return z poz
	),

	/** Get slice_modifiers in scene
	 */
	function _getModifiersInScene mod_name =
	(
		--format "\n"; print "SlicerSystem_v._getModifiersInScene()"
		--format "mod_name: %\n" mod_name

		--for mod_in_scene in getClassInstances ( SliceModifier ) do
		--format "mod_in_scene.name: %\n" mod_in_scene.name

		mod_name = mod_name as name

		for mod_in_scene in getClassInstances ( SliceModifier ) where mod_in_scene.name as name == mod_name collect mod_in_scene
	),

	/** Compare arrays
	 */
	function _objectsChanged =
	(
		--format "\n"; print "SlicerSystem_v.compareArrays()"
		with PrintAllElements on _objects as string == ( selection as Array ) as string
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SlicerSystem.onCreate()"

		this._setModifiers()

		display_units = case units.SystemType of -- convert to milimeters
		(
			#millimeters:	1
			#centimeters:	10
			#meters:	1000
			#kilometers:	1000000
			default:	1 -- non metric units
		)
	)
)