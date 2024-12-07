clearListener(); print("Cleared in:\n"+getSourceFileName())

/** Count which method is used more often - append, join or merge bitarrays
 */
function devMethodWithCounter faces_of_verts =
(
	--format "\n"; print ".devMethodWithCounter()"
	_append = 0
	_join   = 0
	_merge = 0

	for face in faces_of_verts do
	(
		face_verts = polyop.getVertsUsingFace obj face

		intesections = for i = 1 to islands.count where not (islands[i] * face_verts).isEmpty collect i

		if intesections.count > 1 then
		(
			_merge += 1

			for i = intesections.count to 2 by -1 do
			(
				islands[intesections[1]] += face_verts

				deleteItem islands intesections[i]
			)
		)
		else if intesections.count == 1 then
		(
			_join += 1

			islands[intesections[1]] += face_verts
		)
		else
		(
			_append += 1
			append islands face_verts
		)

	)
	format "_append: %\n" _append
	format "_join: %\n" _join
	format "_merge: %\n" _merge
)

/** Case method
 */
function faceVertsMethod faces_of_verts =
(
	--format "\n"; print ".faceVertsMethod()"
	face_verts = polyop.getVertsUsingFace obj face

	intesections = for i = 1 to islands.count where not (islands[i] * face_verts).isEmpty collect i


	case intesections.count of
	(
		/* JOIN TO EXISTING BITARRAY */
		(1):	islands[intesections[1]] += face_verts

		/* ADD NEW BITARRAY */
		(0): append islands face_verts

		/* MERGE MULTIPLE BITARRAYS */
		default:
			for i = intesections.count to 2 by -1 do
			(
				islands[intesections[1]] += face_verts

				deleteItem islands intesections[i]
			)
	)
)

/** Detach method
 */
function detachMethod obj faces_of_verts =
(
	--format "\n"; print ".detachMethod()"

	obj_snap = snapshot obj

	convertTo obj_snap PolyMeshObject

	polyop.detachFaces obj_snap faces_of_verts delete:true

	local poGetElementsUsingFace = polyop.getElementsUsingFace

	elements = #()

	while not faces_of_verts.isEmpty do
																									(
		face = (faces_of_verts as array)[1]

		element = poGetElementsUsingFace obj_snap #(face)

		append elements element

		faces_of_verts -= element
	)

	delete obj_snap

	format "elements: %\n" elements
)



/**
 */
function getVertIslandsOfSelection obj =
(
	--format "\n"; print ".faceVertsMethod()"
	islands = #()

	--face_verts = polyop.getVertsUsingFace obj face

	vertex_count = getNumVerts obj.mesh
	format "vertex_count: %\n" vertex_count

	all_verts = #{1..(vertex_count)}

	faces_sel = polyop.getFaceSelection obj
	format "faces_sel: %\n" faces_sel
	/*------ SPLIT TO ISLANDS ------*/
	verts_sel = polyop.getVertsUsingFace obj faces_sel
	format "verts_sel: %\n" verts_sel


	while not verts_sel.isEmpty do
	(
		faces_of_vert = polyop.getFacesUsingVert obj (verts_sel as Array )[1]

		verts_of_faces = polyop.getVertsUsingFace obj faces_of_vert

		--format "verts_of_faces: %\n" verts_of_faces

		intesections = for i = 1 to islands.count where not (islands[i] * verts_of_faces).isEmpty collect i

		case intesections.count of
		(
			/* JOIN TO EXISTING BITARRAY */
			(1):	islands[intesections[1]] += verts_of_faces

			/* ADD NEW BITARRAY */
			(0): append islands verts_of_faces

			/* MERGE MULTIPLE BITARRAYS */
			default:
				for i = intesections.count to 2 by -1 do
				(
					islands[intesections[1]] += verts_of_faces + islands[intesections[i]]

					deleteItem islands intesections[i]
				)
		)

		verts_sel -= verts_of_faces
	)

	format "islands: %\n" islands
	format "islands.count: %\n" islands.count
)

/*------------------------------------------------------------------------------
	PREPARE SCENE
--------------------------------------------------------------------------------*/

delete objects

segments = 10
--segments = 20
--segments = 100
--segments = 200
--segments = 300

obj	= C_Ext FrontLength:16.5237 BackLength:16.5237 SideLength:25.513 centerCreate:on pos:[ 0, 0, 0] isSelected:on FrontWidth:5.53002 BackWidth:5.53002 SideWidth:5.53002 height:11.7704

max modify mode
/*select objects */
convertTo obj PolyMeshObject

obj.EditablePoly.SetSelection #Face #{7, 11}

polyop.setFaceMatID obj  #{7, 11} 2
--obj.EditablePoly.attach Plane_2 obj
--subObjectLevel = 4

modPanel.addModToSelection (tessellate iterations:4 faceType: 1 type: 0 tension: 0  ) ui:on
--modPanel.addModToSelection (tessellate iterations:2 faceType: 1 type: 0 tension: 0  ) ui:on

convertTo obj PolyMeshObject


/*------------------------------------------------------------------------------
	SET TEST DATA
--------------------------------------------------------------------------------*/

global islands = #()


--verts = all_verts - #{23..44, 144..165}
--format "verts: %\n" verts
--faces_of_verts = polyop.getFacesUsingVert obj verts
--format "faces_of_verts: %\n" faces_of_verts


/*------------------------------------------------------------------------------

	RUN TESTT

--------------------------------------------------------------------------------*/



test = timeStamp()

/* DEV */
--devMethodWithCounter (faces_of_verts)

/* SLOW ON HIGH VERTEX COUNT */
--faceVertsMethod (faces_of_verts)

getVertIslandsOfSelection(obj)
/* DETACH FACES AND GET LEMENTS COUNT */
--detachMethod (obj) (faces_of_verts)

--format "faces_of_verts: %\n" faces_of_verts

format "\n test: % ms\n" (( timeStamp()) - test)

format "RESULT: %\n" islands



--gc light:true
