
/** Select supports by beams count
 */
function selectSupportsByBeamsCount count =
(
	--format "\n"; print ".selectSupportsByBeamsCount()"

	_objects = (if selection.count > 0 then selection else objects) as Array

	--source_objects = SUPPORT_MANAGER.getObjectsByType ( _objects ) type:#SOURCE -- hierarchy:shift

	supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT
	format "supports.count: %\n" supports.count
	--beams = SUPPORT_MANAfilein @"filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr""GER.getObjectsByType supports type:#BEAM

	bemas_of_supports = for support in supports collect SUPPORT_MANAGER.getObjectsByType support type:#BEAM
	--SUPPORT_MANAGER.getObjectsByType beams type:#SUPPORT
	--format "bemas_of_supports.count: %\n" bemas_of_supports.count
	--format "source_objects: %\n" source_objects
	supports_by_count = for i = 1 to bemas_of_supports.count where bemas_of_supports[i].count == count collect supports[i]

	if supports_by_count.count > 0 then
		select supports_by_count

)


/**
 *
 */
macroscript	maxtoprint_select_verts_by_supports
category:	"maxtoprint"
buttontext:	"SUPPORT ↔ VERT"
toolTip:	"Select verts of source object which belongs to selected supports"
icon:	"across:3"
(

	/** Select supports by vert
	 */
	function selectSupportsByVerts =
	(
		format "\n"; print ".selectSupportsByVert()"

		obj	= selection[1]

		--source_objects = SUPPORT_MANAGER.getObjectsByType ( obj ) type:#SOURCE -- hierarchy:shift
		--format "source_objects: %\n" source_objects
		vertex_sel	= getVertSelection obj.mesh

		SourceObjects = SUPPORT_MANAGER.getSourceObjects ( selection as Array )
		--format "SourceObjects: %\n" SourceObjects

		SourceObject = SourceObjects[1]

		supports = for index in SourceObject.Supports.keys where vertex_sel[index] collect SourceObject.Supports[index].support_obj

		if supports.count > 0 then
			select supports

	)

	/** Select verts by supports
	 */
	function selectVertsBySupports =
	(
		format "\n"; print ".selectVertsBySupports()"
		_objects = selection as Array

		source_objects = SUPPORT_MANAGER.getObjectsByType ( _objects ) type:#SOURCE -- hierarchy:shift

		format "source_objects: %\n" source_objects

		supports = SUPPORT_MANAGER.getObjectsByType _objects type:#SUPPORT

		format "supports: %\n" supports

		SourceObjects = SUPPORT_MANAGER.getSourceObjects source_objects

		for SourceObject in SourceObjects do
		(
			--format "SourceObject: %\n" SourceObject
			indexes =( for index in SourceObject.Supports.keys where SourceObject.Supports[index].support_obj.isSelected collect index) as BitArray

			format "indexes: %\n" indexes

			obj = SourceObject.obj.baseobject

			max modify mode

			verts_hidden = polyop.getHiddenVerts obj

			polyop.setHiddenVerts obj (verts_hidden - indexes )

			obj.SetSelection #VERTEX indexes

		)

		if SourceObjects.count == 1 then
		(
			select SourceObjects[1].obj

			subObjectLevel = 1
		)
		else if SourceObjects.count > 1 then
			select ( 	for SourceObject in SourceObjects collect SourceObject.obj )
	)

	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr"

		if subObjectLevel == 0 then
			selectVertsBySupports()

		else if subObjectLevel == 1 then
			selectSupportsByVerts()
	)
)

/**
 *
 */
macroscript	maxtoprint_select_supports_on_ground
category:	"maxtoprint"
buttontext:	"ON GROUND"
toolTip:	"Select supports which are on ground"
--icon:	"across:4"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-SELECTION-TOOLS\SUPPORT SELECTION.mcr"

		supports = SUPPORT_MANAGER.getObjectsByType ( selection as Array ) type:#SUPPORT -- hierarchy:shift

		supports_on_ground = for support in supports where support.min.z as integer == 0 collect support

		select supports_on_ground
	)
)

/**
 *
 */
macroscript	maxtoprint_select_supports_not_on_ground
category:	"maxtoprint"
buttontext:	"ON GROUND"
toolTip:	"Select supports which are NOT on ground"
--icon:	"across:4"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-SELECTION-TOOLS\SUPPORT SELECTION.mcr"

		supports = SUPPORT_MANAGER.getObjectsByType ( selection as Array ) type:#SUPPORT -- hierarchy:shift

		supports_on_ground = for support in supports where support.min.z as integer != 0 collect support

		select supports_on_ground
	)
)

/**
 *
 */
macroscript	maxtoprint_select_by_direction
category:	"maxtoprint"
buttontext:	"BY DIRECTION"
toolTip:	"Select only supports with normal DOWN"
--icon:	"across:2"
(

	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr"

		supports = SUPPORT_MANAGER.getObjectsByType ( selection as Array ) type:#SUPPORT -- hierarchy:shift


		filtered = for support in supports where getUserPropVal support "DIRECTION" == [0,0,-1] collect support

		select filtered
	)
)

/**
 *
 */
macroscript	maxtoprint_select_supports_with_beams
category:	"maxtoprint"
buttontext:	"BY BEAMS"
toolTip:	"Select supports without beams"
icon:	"across:2"
(
	on execute do
		selectSupportsByBeamsCount 0
)

/**
 *
 */
macroscript	maxtoprint_select_supports_with_beams_by_count
category:	"maxtoprint"
buttontext:	"BY BEAMS"
toolTip:	"Select supports by beams count"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr"


		/* DEFINE MAIN MENU */
		Menu = RcMenu_v name:"GenerateBeamsMenu"

		Menu.item "With 1 beam" ( "selectSupportsByBeamsCount 1" )
		Menu.item "With 2 beam" ( "selectSupportsByBeamsCount 2" )
		Menu.item "With 3 beam" ( "selectSupportsByBeamsCount 3" )
		Menu.item "With 4 beam" ( "selectSupportsByBeamsCount 4" )

		popUpMenu (Menu.create())
	)
)

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

	supports = SUPPORT_MANAGER.getObjectsByType _selection type:#SUPPORT

	invalid_supports = Dictionary #( #ANGLE, #() ) #( #SHORT, #() ) #( #CHAMFER, #() ) #( #WIDTH, #() )

	limit_angle = 90
	--treshold    = 0.05
	treshold    = 0

	for support in supports where ( chamfer_mod = support.modifiers[#CHAMFER_BAR]) != undefined and ( sweep_mod = support.modifiers[#BAR_WIDTH][#Cylinder_Section]) != undefined and (num_knots = numKnots support 1) <= 3 do
	(
		sweep_radius   = sweep_mod.radius
		chamfer_amount = chamfer_mod.amount
		format "sweep_radius: %\n" sweep_radius
		format "chamfer_amount: %\n" chamfer_amount

		shape_lengths = getSegLengths support 1

		segments_lengths = for i = ( numSegments support 1 ) + 1 to shape_lengths.count - 1 collect shape_lengths[i]
		format "segments_lengths: %\n" segments_lengths

		support_invalid = false

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
		else if shape_lengths[shape_lengths.count] < chamfer_amount *2 then
			append invalid_supports[#CHAMFER] support


	)
	format "INVALID_SUPPORTS: %\n" invalid_supports

	if type != unsupplied then
		invalid_supports[type] --return

	else
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
buttontext:	"C H E C K"
toolTip:	"SEARCH ANDF SELECT NOT VALID SUPORTS\n\n1) IF SUPPORT IS TOO SHORT \n\n2) IF ANGLE BETWEEN RAFT AND FOOT IS LESS THEN 90°\n\n3) IF CHMAFER VALUE IS TOO HIGH"
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
buttontext:	"C H E C K"
tooltip:	"Open menu"
--toolTip:	"SEARCH ANDF SELECT NOT VALID SUPORTS\n\n1) IF TOO SUPPORT IS TOO SHORT \n\n2) IF ANGLE BETWEEN RAFT AND FOOT IS LESS THEN 90°"
(
	on execute do
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxSlicer\content\rollouts-Main\rollout-11-SUPPORTS\SELECTION.mcr"

		/* DEFINE MENU */
		Menu = RcMenu_v name:"CheckSupports"

        Menu.item "High &RADIUS"    "checkLenghtsAndAnglesOfSupports type:#SHORT"
        Menu.item "High &ANGLE"    "checkLenghtsAndAnglesOfSupports type:#ANGLE"
        Menu.item "High &CHAMFER" "checkLenghtsAndAnglesOfSupports type:#CHAMFER"
        Menu.item "Too  &SHORT"    "checkLenghtsAndAnglesOfSupports type:#SHORT"

		popUpMenu (Menu.create())
	)
)
