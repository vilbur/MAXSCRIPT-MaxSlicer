/** Support options
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
	rollouts, -- rollout where values are store in UI
	export_size = 1,

	/* SUPPORT GENERATOR OPTIONS */
	use_normals	= true,
	normal_length	= 1,

	second_point_direction	= 1,

	use_nth_vertex	= 1,

	live_update_supports = false,

	/* SUPPORT OBJECT OPTIONS */
	layer_height = 0.05,

	bottom_layers_count = 15,


	/* SUPPORT MODIFIERS */
	bar_width 	= 1.5, -- default width is 1.5mm

	base_height	= 1.0,
	base_width	= 4.0,

	chamfer_base = 2,
	top_width	= 1,	-- CHAMFER MIN: 0 - CHAMFER MAX: 10

	extend_top	= 0.5,

	foot_enabled = true,

	/* RAFT OPTIONS */
	raft_width 	= 0.5,
	extend_end	= 0.5,


	/* BEAMS OPTIONS */
	beams_count = 2,
	max_distance	= 20,	-- max distance between supports
	min_height	= 10,	-- generate beams only if support is higher than this number=
	max_height	= 20,	-- gmax height between of beam split


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

	mat_ids	= Dictionary #( #TOP, 1 /* READ-ONLY */ ) #( #NORMAL, 7 ) #( #MIDDLE, 3 ) #( #BASE, 4 ) #( #BOTTOM, 2 /* READ-ONLY */ ) #( #CHMAFER, 5 ) #( #BEAM, 6 ), -- #top and #bottom are read-only and they are default by Edit Spline

	_DO_NOT_MODIFY_PROPERTIES = #( #DISPLAY_UNITS, #EXPORT_SIZE, #USE_NTH_VERTEX , #CHAMFER_TOP, #BEAMS_COUNT, #SECOND_POINT_DIRECTION ),

	/** FILL PROPERTIES of THIS STRUCT WITH DATA FROM UI
	  * 
	  * CONTROL ID >>> PROPERTY NAME 		E.G.: Rollout.BTN_prop_name >>> SupportOptions.prop_name
	  * 
	  * 
	  */
	function getValuesFromUi =
	(
		format "\n"; print "SupportOptions_v.getValuesFromUi()"
		/** Reg ex replace
		 */
		function regExReplace _string search _replace = ( dotNetObject "System.Text.RegularExpressions.Regex" search ).Replace ( _string as string ) _replace


		if classOf rollouts != Array then
			rollouts = #(rollouts)

		/*------------------------------------------------------------------------------
			HOT FIX - EXPORT SIZE VALUE SHOULD BE CONNECTED TO VilTools3
		--------------------------------------------------------------------------------*/
		export_size = if ROLLOUT_export == undefined then
		(
			format "\n============= WARNING =============\n"

			print "VilTools Exporter does not exists"
			print "Export Size 1 is used"

			1 --return
		)
		else
		  ROLLOUT_export.SPIN_export_size.value

		/*--------------------------------------------------------------------------------*/

		control_type_to_fetch_values = "SPIN|CBX|RB"

		/** 
		  *
		  * Perform kind of this in loop:
		  *   Options.base_extrude	= roll.SPIN_base_width.value
		  */
		for _rollout in rollouts do
		(
			if _rollout != undefined then 
				for ctrl in _rollout.controls where (prop_key = regExReplace ctrl.name ("^("+control_type_to_fetch_values+")_") "") != undefined and hasProperty SUPPORT_OPTIONS prop_key do
					this.setOptionValue prop_key ( if classOf ctrl == CheckBoxControl or classOf ctrl == RadioControl  then ctrl.state else ctrl.value )
			else
				format "SupportOptions_v.getValuesFromUi() - _rollout IS UNDEFINED" 
			
		)
		
		--for _rollout in rollouts do
		--	for ctrl in _rollout.controls where (prop_key = regExReplace ctrl.name ("^("+control_type_to_fetch_values+")_") "") != undefined and hasProperty SUPPORT_OPTIONS prop_key do
		--		this.setOptionValue prop_key ( if classOf ctrl == CheckBoxControl or classOf ctrl == RadioControl  then ctrl.state else ctrl.value )

		--------this.init()
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
		format "\n"; print "SupportOptions_v.setOptionValue()"
		format "%: %\n" prop_key val

		setProperty this prop_key val
		--this.init()
	),

	/** Get value of prop mutated for modifier
	 */
	function getOption prop_key =
	(
		format "\n"; print "SupportOptions_v.getProp()"
		
	
		function getChamferBarValue = (bar_width - top_width) / 2
	
		function getBaseWidthValue = if (base_width_value = (base_width - bar_width) / 2.0 ) > 0 then base_width_value else 0 -- base_width is always > 0
		--function getBaseWidthValue = 5
		
		/* Mutate value for modifier */
		val = case prop_key of
		(
			#BAR_WIDTH:	bar_width	/ 2.0 -- get radius value
			#BASE_WIDTH:	getBaseWidthValue()
			#DRAIN_WIDTH:	drain_width	/ 2.0
			#CHAMFER_BASE:	base_height	/ 2.0
			#TOP_WIDTH:	getChamferBarValue()

			default: getProperty this ( prop_key as string )
		)

		format "%: %\n" prop_key val

		val --return
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

	--
	--/** Make sure that chamfer value is less then bar radius
	--  */
	--function _getChamferBarValue =
	--(
	--	format "\n"; print "SupportModifiers_v._getChamferBarValue()"
	--	format "bar_width: %\n" bar_width
	--	format "top_width: %\n" top_width
	--	--chamfer_step = (bar_width / 2 / 10) -- get value of single step for 0-10 scale
	--
	--	--chamfer_val = chamfer_step * top_width
	--
	--	--if this.bar_width / 2 == chamfer_val then
	--		--chamfer_val -= 0.05
	--
	--	chamfer_val = (bar_width - top_width) / 2
	--	format "chamfer_val: %\n" chamfer_val
	--		
	--	chamfer_val --return
	--),

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

	/** Set base height
	  *
	  */
	function _setBaseHeight =
	(
		--format "\n"; print "SupportOptions_v._setBaseHeight()"
		base_height = this.bottom_layers_count * this.layer_height / export_size
	),

	/**
	 *
	 */
	on create do
	(
		format "\n"; print "SupportOptions_v.create()"
		--format "THIS: %\n" this
		/* CHECK CONTRUCT PROPERTY - DISBALE ON TESTING */ 
		--if rollouts == undefined then
			--messageBox ("UNDEFINED CONSTRUCT PROPERTY\n\nSTRUCT: SupportOptions_v\n\nPROPERTY: rollouts") title:"UNDEFINED PROPETRY"

		--this --return
	)
)