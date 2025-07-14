filein( getFilenamePath(getSourceFileName()) + "/ModifierValue/ModifierValue.ms" )	--"./ModifierValue/ModifierValue.ms"

/** SUPPORT_OPTIONS
  *
  *
  * IMPORTANT: Control id, SupportOptions.porp and Modifiers names MUST HAVE SAME NAME
  *
  *		UI Control id	-> #cbx_bar_width
  *		SupportOptions.prop	-> #bar_width
  *		Modifier.prop	-> #bar_width
  *
 */
struct SupportOptions_v
(
	/* construct */
	main_rollout, -- rollout where values are store in UI
	export_size = 1,
	
	/* DEPENDENCY */
	ModifierValue = ModifierValue_v(),
	
	/* SUPPORT GENERATOR OPTIONS */
	use_normals	= true,

	raft_direction	= 1, -- 1:DOWN|2:NORMAL

	use_nth_vertex	= 1,

	layer_height = 0.05,
	

	/* SOURCE OBJECT */ 
	keep_source_minz_z_pos = false,
	z_pos_lock = 10, -- how many layers is prented between support base and source object ( avoid glue of supports and printed object )
	
	
	/* SUPPORT OBJECT OPTIONS */
	raft_mode = 1, -- 0: CUSTOM | 1: MIN | 2: AUTO
	lock_normal_length = true,
	normal_length	= 3,


	bottom_layers_count = 15,
	live_update_max_objects_count = 1,

	/* SUPPORT MODIFIERS */
	bar_width 	= 1.4, -- default width is 1.4mm

	base_height	= 1.0,
	base_width	= 10.0,

	chamfer_base	= 2,
	top_width	= 0.5,	-- CHAMFER MIN: 0 - CHAMFER MAX: 10

	extend_top	= 0.5,

	foot_enabled = true,

	/* RAFT OPTIONS */
	raft_width 	= 0.5,
	extend_end	= 0.5,


	/* BEAMS OPTIONS */
	use_max_distance	= true,
	only_ground	= true,
	min_distance_beams	= 1.5,	-- beams_min_distance * bar_width = minimal distance of supports to generate beam
	max_distance	= 20,	-- max distance between supports
	max_connections	= 2,	-- max number of beams connected to single support
	beams_count	= 2,	-- count of lines of beam
	
	min_height	= 10,	-- generate beams only if support is higher than this number=
	beams_split	= 1,	--1:SQUARE 2:RECTANGLE


	/* PINS OPTIONS */
	pin_width	= 3.0, -- outter diametter of outter pin
	pin_height	= 5.0, -- outter diametter of outter pin
	pin_gap 	= 0.2, -- size of gap between inner and outter pin

	/* DRAIN HOLES */
	drain_width	= 2,
	drain_top	= 0.1,
	drain_bottom	= 2,

	/* PRIVATE PROPERTIES */
	display_units = 1, -- correct size of platforms, E.g.: IF MODEL IS MADE IN METERS BUT IT IS PRINTED SCALED DOWN TO MILIMETERS

	quiet_mode = false,

	load_value_control_types = #( #SpinnerControl, #CheckBoxControl, #RadioControl, #RadioControl, #ComboBoxControl ),
	
	mat_ids	= Dictionary #( #TOP, 1 /* READ-ONLY */ ) #( #NORMAL, 7 ) #( #MIDDLE, 3 ) #( #BASE, 4 ) #( #BOTTOM, 2 /* READ-ONLY */ ) #( #CHMAFER, 5 ) #( #BEAM, 6 ), -- #top and #bottom are read-only and they are default by Edit Spline

	_DO_NOT_MODIFY_PROPERTIES = #( #display_units, #export_size, #use_nth_vertex , #chamfer_top, #beams_count, #raft_direction, #raft_mode, #max_connections, #beams_count ),

	/** Get value of prop mutated for modifier
	 */
	function getModVal prop_key obj_type: =
	(
		-- format "\n"; print "SupportOptions_v.getModVal()"
		
		/* Mutate value for modifier */
		val = case prop_key of
		(
			#BAR_WIDTH:	ModifierValue.getSweepRadius(#BAR_WIDTH)
			#RAFT_WIDTH:	ModifierValue.getSweepRadius(#RAFT_WIDTH)
			#BASE_WIDTH:	ModifierValue.getBaseWidthValue()
			#DRAIN_WIDTH:	ModifierValue.getDrainWidth()
			#CHAMFER_BASE:	ModifierValue.getChamferBaseValue()
			#TOP_WIDTH:	ModifierValue.getChamferBarValue(obj_type) bar_width:bar_width
		
			default: getProperty this ( prop_key as string )
		)
		
		--/* MULTIPLY BY EXPORT SIZE */ 
		--if superClassOf val == number and EXPORT_SIZE != 1.0 and findItem _DO_NOT_MODIFY_PROPERTIES prop_key == 0 then
		--	val = val / EXPORT_SIZE
		
		val --return
	),
	
	/** Get value of this.property
	 */
	function getProp prop_key =
	(
		--format "\n"; print "SupportOptions_v.getProp()"
		getProperty this ( prop_key as string )
	),
	
	/** FILL PROPERTIES of THIS STRUCT WITH DATA FROM UI
	  * 
	  * CONTROL ID >>> PROPERTY NAME 		E.G.: Rollout.BTN_prop_name >>> SupportOptions.prop_name
	  * 
	  */
	function getValuesFromUi =
	(
		 --format "\n"; print "SupportOptions_v.getValuesFromUi()"

		
		/** get property key from control id E.G.: "SPIN_prop_key" >>> "prop_key"
		  * 
		  * @return string|undefined 
		 */
		function getPropertyKeyFromControlId ctrl_name = substring ctrl_name (( findString ctrl_name "_" ) +1) -1
		
		controls = this.getControlsWithOptionValue (main_rollout) #()


		/** Perform kind of this in loop:
		  *   Options.base_extrude	= roll.SPIN_base_width.value
		  *
		  */
		for ctrl in controls where (prop_key = getPropertyKeyFromControlId ctrl.name ) != undefined and hasProperty SUPPORT_OPTIONS prop_key do
		(
			control_value = case classOf ctrl of
			(
				ComboBoxControl: ctrl.selection -- dropdownlist
				CheckBoxControl: ctrl.state
				RadioCOntrol:    ctrl.state
				default:         ctrl.value
			)
			--format "%: %\n" prop_key control_value
			this.setOptionValue (prop_key) (control_value)
		)
		
		/*==============================================================================
			EXCEPTIONS
		================================================================================*/
		/* IF DIRECTION IS DOWN - ALWAYS USE MIN RAFT LENGTH */ 
		if raft_direction == 1 then
			raft_mode = 1
	),
	
	/** Get controls with option value
	 */
	function getControlsWithOptionValue roll &controls =
	(
		/** Is value control
		 */
		function isValueControl ctrl = findItem load_value_control_types (((classOf ctrl) as string ) as name ) > 0
		
		for ctrl in roll.controls do
			if ( classOf_ctrl = classOf ctrl ) == SubRollout then
				for subroll in ctrl.rollouts do
					this.getControlsWithOptionValue (subroll) (controls)
					
			else if isValueControl(ctrl) then
				append controls ctrl
				
		controls --return
	),
	
	/** Init
	  *
	  */
	function init =
	(
		--format "\n"; print "SupportOptions_v.init()"
		this._setUnitsMuliplier()

		this._convertUnitsToMilimeters()
	),

	/** Set property value of this struct
	 */
	function setOptionValue prop_key val =
	(
		--format "\n"; print "SupportOptions_v.setOptionValue()"
		setProperty this prop_key val
	),
	
	/** Get mat id
	 */
	function getMatId mat_key =
	(
		--format "\n"; print "SupportModifiers_v._getMatId()"
		mat_ids[mat_key] --return
	),

	/** Get node prop data
	 */
	function _getUserProp obj prop_key as_string:false =
	(
		--format "\n"; print "SupportOptions_v._getUserProp()"

		key = ( toLower ( prop_key as string ))

		getUserPropVal obj key asString:as_string --return
	),

	/** Set node prop data
	 */
	function _setUserProp obj prop_key val =
	(
		--format "\n"; print "SupportOptions_v._setUserProp()"
		key = ( toLower ( prop_key as string ))

		setUserPropVal obj key val --return
	),

	/** Set node prop data from node to node
	 */
	function syncProp from_object to_object from_key destination_key: =
	(
		--format "\n"; print "SupportOptions_v._setUserProp()"
		if destination_key == unsupplied then
			destination_key = from_key

		from_key =	( toLower ( from_key as string ))
		destination_key = 	( toLower ( destination_key as string ))

		setUserPropVal to_object from_key ( getUserPropVal from_object destination_key )
	),

	/** Get this pointer
	 */
	function getThisPointer obj =
	(
		--format "\n"; print "SupportOptions_v.getThisPointer()"
		local this_pointer

		if ( this_pointer = this._getUserProp obj #THIS ) == undefined then
		(
			this_pointer = getHandleByAnim obj

			this._setUserProp obj #THIS this_pointer
		)

		this_pointer
	),

	/** Get milimeter value
	 */
	function getMilimeterValue val =
	(
		--format "\n"; print "SupportOptions_v.getMilimeterValue()"
		val / display_units	/ export_size --return
	),


	private

	/** Convert values of properties to milimeters on export
	  *
	  * Current units and export size are get in to the game
	  */
	function _convertUnitsToMilimeters =
	(
		--format "\n"; print "SupportOptions_v._convertUnitsToMilimeters()"
		for prop_key in getPropNames this where ( superClassOf (val = getProperty this prop_key )) == Number do
			if val != undefined and findItem _DO_NOT_MODIFY_PROPERTIES prop_key == 0  then
				setProperty this prop_key (this.getMilimeterValue val)
	),

	/** Set units muliplier
	  *
	  */
	function _setUnitsMuliplier =
	(
		--format "\n"; print "SupportOptions_v.setUnitsMuliplier()"
		display_units = case units.SystemType of -- convert to milimeters
		(
			#millimeters:	1
			#centimeters:	10
			#meters:	1000
			#kilometers:	1000000
			default:	1 -- non metric units
		)
	),
	
	/** ENABLE DISBALE DEPENDENT CONTROLS
	 */
	function _enabledDependantControls =
	(
		--format "\n"; print "SupportOptions_v._enabledDependantControls()"

		/*------------------------------------------------------------------------------
			RAFT MODES
		--------------------------------------------------------------------------------*/
		raft_direction = if ROLLOUT_generator.RB_raft_direction.state == 1 then #DOWN else #NORMAL

		ROLLOUT_generator.RB_raft_mode.enabled = raft_direction == #NORMAL
		
		raft_mode = case ROLLOUT_generator.RB_raft_mode.state of
					(
						0: #CUSTOM
						1: #MIN
						2: #AUTO
					)
		
		ROLLOUT_generator.SPIN_normal_length.enabled = raft_direction == #NORMAL and raft_mode == #CUSTOM 
		
		/*------------------------------------------------------------------------------
			SEEDER
		--------------------------------------------------------------------------------*/
		--
		--radial_grid_enabled = ROLLOUT_SUPPORTS.RB_seeder_mode.state == 1
		--
		--ROLLOUT_SUPPORTS.CBX_segments_count_keep.enabled = radial_grid_enabled
		--ROLLOUT_SUPPORTS.SPIN_segments_count.enabled     = radial_grid_enabled
		
	),

	/**
	 *
	 */
	on create do
	(
		format "\n"; print "SupportOptions_v.create()"
		this._enabledDependantControls()
		
		--format "THIS: %\n" this
		/* CHECK CONTRUCT PROPERTY - DISBALE ON TESTING */ 
		--if rollouts == undefined then
			--messageBox ("UNDEFINED CONSTRUCT PROPERTY\n\nSTRUCT: SupportOptions_v\n\nPROPERTY: rollouts") title:"UNDEFINED PROPETRY"

		--this --return
	)
)