/** Pins manager
 */
struct PinsGenerator_v
(
	/* construct */
	Options,

	/* properties */
	obj,

	/* dependency */
	SceneLayers = SceneLayers_v(),

	/* reference */
	/* inhered */

	/** Create pins
	 */
	function createPins obj =
	(
		format "\n"; print "PinsGenerator_v.createPins()"

		this.obj = obj

		if subObjectLevel == 1 then
		(
			vertex_sel	= getVertSelection obj.mesh --else #{} -- ignore vertex selection if not suobject level active

			if vertex_sel.numberSet > 0 then
			(
				verts_data = (MeshDataGetter_v(obj)).getVertexData verts:vertex_sel positions:true normals:true
				--verts_to_generate =  this._getVertsToGenerateFromObjects (reset_verts)

				format "VERTS_DATA: %\n" verts_data

				for i = 1 to verts_data[#VERTS].numberSet do
					this.generatePin verts_data[#POSITIONS][i] normal:verts_data[#NORMALS][i]
			)

		)
		--else if subObjectLevel == 4 then
		--(
		--	face_sel	= getFaceSelection obj.mesh --else #{} -- ignore vertex selection if not suobject level active
		--
		--	faces_data = (MeshDataGetter_v(obj)).getFaceData faces_to_get:face_sel
		--
		--	this.generatePin faces_data[#VERTS] normal:faces_data[#POSITIONS]
		--
		--)


	),

	private



	/** Generate pin
	 */
	function generatePin pos normal: =
	(
		format "\n"; print "PinsGenerator_v.generatePin()"
		format "Options.pin_width: %\n" Options.pin_width
		format "Options.pin_gap: %\n" Options.pin_gap

		pin_name = uniqueName ( obj.name + "-pin-" )

		pin_inner  = Radial name:pin_name	pos:pos wirecolor:obj.wirecolor radius:(Options.pin_width / 2)
		pin_outter = Radial name:(pin_name+"-outter")	pos:pos wirecolor:obj.wirecolor radius:((Options.pin_width / 2) + Options.pin_gap )  xray:true

		freeze pin_outter

		 pins = #(pin_inner, pin_outter )

		pin_inner.parent = obj
		pin_outter.parent = pin_inner

		this._rotateToNormal(pin_inner) (normal)

		this._addExtrudeModifier (pin_outter)
		--this._addExtrudeModifier (pin_inner)

		this._addShellModifier(pin_inner)

		obj.layer.addNodes(pins)

		SceneLayers.moveToLayer pins layer_type:#PRINT mode:#MOVE

		--paramWire.connect pin_outter.baseObject[#radius] pin_inner.baseObject[#radius] ("radius - " + Options.pin_gap as string )
		paramWire.connect pin_inner.baseObject[#radius] pin_outter.baseObject[#radius] ("radius + " + Options.pin_gap as string )


		--paramWire.connect2way pin_outter.transform.controller[#Position] pin_inner.transform.controller[#Position] "Position" "Position"
		--paramWire.connect2way pin_outter.transform.controller[#Rotation] pin_inner.transform.controller[#Rotation] "Rotation" "Rotation"
		--paramWire.connect2way pin_outter.transform.controller[#Scale] pin_inner.transform.controller[#Scale] "Scale" "Scale"

		pins --return
	),

	/** Add extrudee modifier
	 */
	function _addExtrudeModifier obj =
	(
		--format "\n"; print "PinsGenerator_v._addExtrudeeModifier()"
		extrude_mod = Extrude name:"OUTTER PIN HEIGHT" capStart:true capEnd:true amount:(Options.pin_height)

		addModifier obj extrude_mod

	),

	/** Add shell modifier
	 */
	function _addShellModifier obj =
	(
		format "\n"; print "PinsGenerator_v._addShellModifie()"

		format "Options.pin_height: %\n" Options.pin_height
		shell_mod = Shell name:"INNER PIN HEIGHT" outerAmount:Options.pin_height innerAmount:(Options.pin_height/4)

		addModifier obj shell_mod
	),

	/** Rotate to normal
	 */
	function _rotateToNormal pin_outter normal  =
	(
		format "\n"; print "PinsGenerator_v._rotateToNormal()"
		format "normal: %\n" normal
		pos_second = copy pin_outter.pos
		--normal = normal * -1
		--pos_second += 10.0 * ( normalize( normal ) * -1) -- MOVE POSITION ALONG NORMAL
		pos_second += 10 * normalize( normal ) -- MOVE POSITION ALONG NORMAL

		this._alignToVector pin_outter pin_outter.pos pos_second


	),

	/** Align to ctor
	 */
	function _alignToVector obj point_to_rotate obj_pos =
	(
		format "\n"; print "HelperObject_v._alignToVector()"
		--format "obj	= % \n" obj
		--format "% %\n" point_to_rotate obj_pos

		dir = normalize (obj_pos - point_to_rotate)
		--format "dir: %\n" dir


		axis = #z

		vec = case axis of
		(
			#x: obj.transform[1]
			#y: obj.transform[2]
			#z: obj.transform[3]
		)

		tm  = obj.transform
		vec = normalize vec
		dir = normalize dir

		angle_vectors = acos (dot vec dir) -- get angle between

		axis_of_plane_defined_by_vectors = normalize (cross dir vec)

		rtm = AngleAxis (angle_vectors) ( axis_of_plane_defined_by_vectors )

		obj.transform = Translate ( Rotate ( ScaleMatrix tm.scale) (tm.rotation*rtm)) tm.pos

		if pos == true then
			obj.pos = point_to_rotate
	),



	/**
	 */
	on create do
	(
		--format "\n"; print "PinsGenerator.onCreate()"
		--for prop in #(  ) where getProperty this prop == undefined do -- CHECK CONSTRUCT PROPERTIES -- Array of this struct properties necessary to run
		--	throw ("\n\n\nUNDEFINED CONSTRUCT PROPERTY\n\n\nSTRUCT:\n\n"+ ((filterString( classof this as string )"(:")[2]) +"\n\n\nPROPERTY:\n\n"+ prop )
	)

)