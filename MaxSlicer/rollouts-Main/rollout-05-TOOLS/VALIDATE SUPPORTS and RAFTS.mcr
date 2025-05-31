
/** Check lenghts and angles of supports
 */
function searchInvalidSupports type: =
(
	--format "\n"; print ".searchInvalidSupports()"
	/** Get angle between segments
	 */
	function getAngleBetweenSegments support =
	(
		function getVectorsAngle v1 v2 = acos(dot ( normalize v1) ( normalize v2))

		knot_pos_first  = getKnotPoint support 1 1
		knot_pos_middle = getKnotPoint support 1 2
		knot_pos_last   = getKnotPoint support 1 3

		getVectorsAngle ( knot_pos_first - knot_pos_middle ) ( knot_pos_last - knot_pos_middle ) --return
	)


	/*  roundFloat 123.456 -2 >>> 100.0
		roundFloat 123.456  0 >>> 123.0
		roundFloat 123.456  2 >>> 123.46
	*/
	fn roundFloat val decimal_palces = ( local mult = 10.0 ^ decimal_palces; (floor ((val * mult) + 0.5)) / mult )

	clearListener(); print("Cleared in:\n"+getSourceFileName())
	_selection = ( if selection.count > 0 then selection else objects ) as Array

	--supports = SUPPORT_MANAGER.getObjectsByType _selection type:#SUPPORT
	supports = SUPPORT_MANAGER.getSupportsAndRafts ( selection as Array )

	invalid_supports = Dictionary #( #ANGLE, #() ) #( #SHORT, #() ) #( #CHAMFER, #() ) #( #WIDTH, #() )

	limit_angle = 90
	--treshold    = 0.05
	treshold    = 0

	for support in supports where ( sweep_mod = support.modifiers[#BAR_WIDTH][#Cylinder_Section]) != undefined do
	--for support in supports where ( chamfer_mod = support.modifiers[#TOP_WIDTH]) != undefined and ( sweep_mod = support.modifiers[#BAR_WIDTH][#Cylinder_Section]) != undefined do
	(
		chamfer_mod = support.modifiers[#TOP_WIDTH]
		
		
		num_knots = numKnots support 1
		
		sweep_radius   = sweep_mod.radius
		
		chamfer_amount = if chamfer_mod != undefined then  chamfer_mod.amount else 0
		
		format "sweep_radius: %\n" sweep_radius
		format "chamfer_amount: %\n" chamfer_amount

		shape_lengths = getSegLengths support 1

		segments_lengths = for i = ( numSegments support 1 ) + 1 to shape_lengths.count - 1 collect shape_lengths[i]
		--format "segments_lengths: %\n" segments_lengths

		support_invalid = false
		
		for segment_length in segments_lengths while not support_invalid where segment_length < chamfer_amount do
		(
			support_invalid = true

			append invalid_supports[#SHORT] support
		)
		
				
		if num_knots == 3 then
		(
			_angle = getAngleBetweenSegments(support)
			format "_angle: %\n" _angle

			/* IF ANGLE IS VALID */
			if _angle > limit_angle then
			(
				angle_multiplier = ( 180 / (180 - _angle)) / 2 -- MAX SIZE OF SWEEP RADIUS AND CHAMFER DEPENDS ON ANGLE OF LINES


				format "angle_multiplier: %\n" angle_multiplier
				--format "test: %\n" ( segment_length - limit_lenght < -0.1 )

				/* FOOT SEGMENT IS SHORT - on mostly straight support */
				--if segments_lengths[2] < chamfer_amount then
				for segment_length in segments_lengths while not support_invalid where segment_length < chamfer_amount do
				(
					support_invalid = true
				
					append invalid_supports[#SHORT] support
				)

				if not support_invalid then
					/* LINE SEGMENT MUST BE LONGER THEN RADIUS OF SWEEP MODIFIER */
					for segment_length in segments_lengths while not support_invalid where segment_length < (sweep_radius / angle_multiplier ) do
					(
						format "segment_length: %\n" segment_length

						support_invalid = true

						append invalid_supports[#WIDTH] support
					)


				if not support_invalid then
				(
					limit_lenght = ((sweep_radius + chamfer_amount) / angle_multiplier) - treshold

					/* SEGMENT MUST BE LONGER THEN LIMIT LENGTH */
					for segment_length in segments_lengths while not support_invalid where segment_length < limit_lenght do
					(
						format "segment_length: %\n" segment_length
						support_invalid = true

						append invalid_supports[#CHAMFER] support
					)



				)
				--
				--/* IF SUPPORT IS BEND ENOUGHT */
				----if _angle < 145 and (segments_lengths[1] - treshold ) * angle_multiplier <= limit_lenght then
				----if segment_length - limit_lenght < -0.1 then
				--if segment_length < limit_lenght then
				--(
				--
				--	--for i = 1 to segments_lengths.count - 1 while support_invalid != true where segments_lengths[i] / limit_lenght <= 1 do
				--)
				--
				----else if segments_lengths[2] < sweep_radius then
				--		append invalid_supports[#SHORT] support
			)
			else /* ANGLE IS TOO SHARP - higher priority - support is unprintable */
				append invalid_supports[#ANGLE] support
		)
		else if num_knots == 2 then
		(
			
			format "segments_lengths: %\n" segments_lengths
			format "chamfer_amount: %\n" chamfer_amount
			
			
			if ( chamfer_amount * 2 ) > segments_lengths[1] then
				append invalid_supports[#SHORT] support
		)
		
		else if shape_lengths[shape_lengths.count] < chamfer_amount *2 then
			append invalid_supports[#CHAMFER] support


	)
	
	format "INVALID_SUPPORTS: %\n" invalid_supports

	/* RETURN SINGLE ERROR TYPE */ 
	if type != unsupplied then
		invalid_supports[type] --return

	else /* RETURN ALL ERROR TYPES */ 
		invalid_supports[#ANGLE] + invalid_supports[#SHORT] + invalid_supports[#CHAMFER]  + invalid_supports[#WIDTH]  --return

)

/** Check lenghts and angles of supports by type
 */
function checkLenghtsAndAnglesOfSupports type: =
(
	--format "\n"; print ".checkLenghtsAndAnglesOfSupports()"
	invalid_supports = searchInvalidSupports type:type

	if invalid_supports.count > 0 then
	(
		--if queryBox ( invalid_supports.count as string + " invalid support found.\n\n Select them ?") title:"INVALID SUPPORTS"  then
			select invalid_supports
	)
	else
		messageBox "SUCCESS\n\nAll supports are valid" title:"Check lengths of supports"
)


/**
 *
 */
macroscript	maxtoprint_supports_check
category:	"maxtoprint"
buttontext:	"C H E C K  A L L"
toolTip:	"SEARCH ANDF SELECT NOT VALID SUPORTS\n\n1) IF SUPPORT IS TOO SHORT \n\n2) IF ANGLE BETWEEN RAFT AND FOOT IS LESS THEN 90°\n\n3) IF CHMAFER VALUE IS TOO HIGH"
icon:	"across:4"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr"
		checkLenghtsAndAnglesOfSupports()

		--checkLenghtsAndAnglesOfSupports type:#CHAMFER
	)
)

/**
 *
 */
macroscript	maxtoprint_supports_check_menu
category:	"maxtoprint"
buttontext:	"C H E C K  A L L"
tooltip:	"Open menu"
--toolTip:	"SEARCH ANDF SELECT NOT VALID SUPORTS\n\n1) IF TOO SUPPORT IS TOO SHORT \n\n2) IF ANGLE BETWEEN RAFT AND FOOT IS LESS THEN 90°"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr"

		/* DEFINE MENU */
		Menu = RcMenu_v name:"CheckSupports"

        Menu.item "High &WIDTH"  "checkLenghtsAndAnglesOfSupports type:#WIDTH"
        Menu.item "High &ANGLE"   "checkLenghtsAndAnglesOfSupports type:#ANGLE"
        Menu.item "High &CHAMFER" "checkLenghtsAndAnglesOfSupports type:#CHAMFER"
        Menu.item "Too  &SHORT"   "checkLenghtsAndAnglesOfSupports type:#SHORT"

		popUpMenu (Menu.create())
	)
)


/**
 *
 */
macroscript	maxtoprint_supports_check_short
category:	"maxtoprint"
buttontext:	"Short"
toolTip:	"Test if too support is too short"
icon:	"width:70|offset:[16,0]"
(
	on execute do
        checkLenghtsAndAnglesOfSupports type:#SHORT
)

--/**
-- *
-- */
--macroscript	maxtoprint_supports_check_chamfer
--category:	"maxtoprint"
--buttontext:	"Top"
--toolTip:	"Test if too support is too short"
--(
--	on execute do
--        checkLenghtsAndAnglesOfSupports type:#CHAMFER
--)

/**
 *
 */
macroscript	maxtoprint_supports_check_angle
category:	"maxtoprint"
buttontext:	"Angle"
toolTip:	"Test angle of support"
(
	on execute do
        checkLenghtsAndAnglesOfSupports type:#ANGLE
)

/**
 *
 */
macroscript	maxtoprint_supports_check_width
category:	"maxtoprint"
buttontext:	"Bar Width"
--toolTip:	"Test if too support is too short"
(
	on execute do
        checkLenghtsAndAnglesOfSupports type:#WIDTH
)





































