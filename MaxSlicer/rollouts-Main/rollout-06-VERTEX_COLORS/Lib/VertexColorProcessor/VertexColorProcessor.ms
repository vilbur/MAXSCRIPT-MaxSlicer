/** Manage verts and their vertex colors
  * 
  * Set vertex COlor
  * Select Verts by color
  * Hide, unhide and isolate verts by colors
  * 
 */
struct VertexColorProcessor_v
(
	/* construct */
	obj,
	--obj_mesh,
	--obj_baseobject,

	/* required */

	/* properties */
	curr_mod,


	/* private */
	/* dependency */
	VertexColors,
	--MeshVertToColorVertexConvert,

	/* reference */
	/* inhered */

	/** Test map verts
	 */
	function _initObject =
	(
		--format "\n"; print "VertexColorProcessor_v._initObject()"
		--format "TEST: %\n" ( polyop.getMapSupport obj 0)

		if obj != undefined or classOf obj.baseobject != Editable_Poly then
		(
			if not polyop.getMapSupport obj 0 then
				polyop.setMapSupport obj 0 true

			--if classOf curr_mod != Editable_Poly then
				--this.obj = obj.baseobject

			true --return
		)
		else
		(
			messageBox "Select Editable Poly Object" title:"VertexColorProcessor"

			false --return
		)
	),

	/** Set vertex color
	 */
	function setVertexColor verts clr =
	(
		--format "4) --------------- SET VERTEX COLOR\n"

		--format "\n"; print "VertexColorProcessor_v.setVertexColor()"
		--format "obj: %\n" obj
		--format "verts: %\n" verts
		--format "clr: %\n" clr
		--format "VertexColors: %\n" VertexColors
		VertexColors.MeshVertToColorVertexConvert.get_single_vert = true

		verts_base = this._getBaseObjectVerts(verts)
		--format "VERTS_BASE: %\n" verts_base

		start_map_verts = timeStamp()
		--format "start_map_verts()\n"


		vertex_count	= getNumVerts obj.mesh
		CPV_verts 	= getNumCPVVerts obj.mesh

		--format "vertex_count: %\n" vertex_count
		--format "CPV_verts: %\n" CPV_verts

		 if getNumVerts obj.baseobject.mesh != getNumCPVVerts obj.baseobject.mesh then
			this.resetCPVVerts()

		--map_verts = (VertexColors.MeshVertToColorVertexConvert.meshVertsToMapVerts (verts_base) flat:true )

		--start_update_chache = timeStamp()
		this._updateCache(verts_base)(clr as string )
		--format "update_chache: % ms\n" (( timeStamp()) - start_update_chache)

		--start_setVertColor = timeStamp()
		polyop.setVertColor obj 0 verts_base (clr)
		--format "setVertColor: % ms\n" (( timeStamp()) - start_setVertColor)

		/* REDRAW VIEWPORT - redrawViews() is hiding verts */
		subObjectLevel = 0
		subObjectLevel = 1
	),

	/** Process operation on verts by vertex color
	  *
	  * @param color|#(color)|undefined colors to manipulate - USE ALL COLORED IF UNDEFINED
	  * @param name method #SELECT|#HIDE|#UNHIDE|#ISOLATE
	 */
	function byColor method colors =
	(
		--format "\n"; print "VertexColorProcessor_v.byColor()"
		--format "method: %\n" method
		--format "colors: %\n" colors
		verts_by_colors = #{}

		/* GET VERTS BY COLORS */ 
		if colors != undefined then
		(
			if classOf colors != Array then colors = #(colors)
			
			all_verts_by_colors = VertexColors.getVertsAndColors()
	
			for clr in colors where (verts_of_color = all_verts_by_colors[ clr as string ]) != undefined do
				verts_by_colors += verts_of_color
			
		)
		/* GET ALL COLORED VERTS */ 
		else
			verts_by_colors = VertexColors.getColoredVerts()
			
		this._callMethod (method) (verts_by_colors)
	),

	/** Process operation on verts by vertex color of given verts
	  *
	  * @param name method #SELECT|#HIDE|#UNHIDE|#ISOLATE
	 */
	function byVerts method verts =
	(
		--format "\n"; print "VertexColorProcessor_v.byVerts()"
		--format "method: %\n" method
		--format "3: %\n" verts

		verts_by_colors = #{}

		all_verts_by_colors = VertexColors.getVertsAndColors()
		--for colors_data in all_verts_by_colors do format "COLOR: %	VERTS: %\n" colors_data.key colors_data.value

		for clr in all_verts_by_colors.keys where not ( all_verts_by_colors[clr] * verts ).isEmpty do
			verts_by_colors += all_verts_by_colors[clr]

		this._callMethod (method) (verts_by_colors)
	),

	/** Reset vertex colors channel
	 */
	function resetCPVVerts =
	(
		--format "\n"; print "VertexColorProcessor_v.resetCPVVerts()"
		--format "\n----------\nRESET CPV VERTS\n"
		/* GET ALL VERTS SORTED BY COLORS */
		colors = VertexColors.getVertsAndColors()

        polyOp.defaultMapFaces obj 0
        polyOp.setVertColor obj 0 #all white

		removeDictValue colors (white as string )

		--for colors_data in colors do format "\n********\n\nCOLOR: %\nVERTS: %\n" colors_data.key colors_data.value

		for colors_data in colors do
			this.setVertexColor colors_data.value (execute colors_data.key)
	),

	private

	/** Call method
	 */
	function _callMethod method verts =
	(
		--format "\n"; print "VertexColorProcessor_v._callMethod()"
		subObjectLevel = 1

		case method of
		(
			 #SELECT:	this._selectVerts	(verts)
			 #HIDE:	this._hideVerts	(verts)
			 #UNHIDE:	this._unhideVerts	(verts)
			 #ISOLATE:	this._isolateVerts	(verts)
		)
	),

	/** Select final selection
	 */
	function _selectVerts verts_baseobject =
	(
		format "\n"; print "VertexColorProcessor_v.selectVerts()"
		format "verts_baseobject: %\n" verts_baseobject
		--format "classOf curr_mod: %\n" (classOf curr_mod)
		--max modify mode
		--subObjectLevel = 1

		curr_mod.SetSelection #VERTEX #{}

		if classOf curr_mod == Edit_Poly then
			curr_mod.Select #VERTEX (this._getEditPolyVerts (verts_baseobject))
		--(
		--	edit_poly_verts = this._getEditPolyVerts (verts_baseobject)
		--	format "edit_poly_verts: %\n" edit_poly_verts
		--	curr_mod.Select #VERTEX (edit_poly_verts)
		--)

		else if classOf curr_mod  == Editable_Poly then
			curr_mod.SetSelection #VERTEX verts_baseobject
	),

	/**  hide verts
	 */
	function _hideVerts verts =
	(
		--format "\n"; print "VertexColorProcessor_v._HideVerts()"

		if classOf curr_mod == Edit_Poly then
		(
			curr_mod.SetSelection #VERTEX #{}

			curr_mod.Select #VERTEX verts

			curr_mod.ButtonOp #HideVertex
		)
		else if classOf curr_mod  == Editable_Poly then
			polyop.setHiddenVerts curr_mod verts

	),

	/**  unhide verts
	 */
	function _unhideVerts verts_unhide =
	(
		format "\n"; print "VertexColorProcessor_v._unhideVerts()"

		if classOf curr_mod == Edit_Poly then
		(
			verts_mesh_all	= #{1..( getNumVerts obj.mesh)}

			curr_mod.SetSelection #VERTEX verts_mesh_all

			visible_verts	= curr_mod.GetSelection #Vertex

			hidden_verts = verts_mesh_all - visible_verts - verts_unhide

			curr_mod.ButtonOp #UnhideAllVertex

			curr_mod.SetSelection #VERTEX #{}

			curr_mod.SetSelection #VERTEX hidden_verts

			curr_mod.ButtonOp #HideVertex

			curr_mod.Select #VERTEX visible_verts
		)
		else if classOf curr_mod  == Editable_Poly then
		(
			--verts_mesh_all	= #{1..( getNumVerts obj.mesh)} as Array
			vertex_sel	= getVertSelection obj.mesh

			hidden_verts = 	polyop.getHiddenVerts obj

			polyop.unHideAllVerts obj

			polyop.setHiddenVerts obj ( hidden_verts - verts_unhide )
		)
	),

	/**  hide verts
	 */
	function _isolateVerts isolate_verts =
	(
		--format "\n"; print "VertexColorProcessor_v._HideVerts()"
		verts_mesh_all	= #{1..( getNumVerts obj.mesh)}

		if classOf curr_mod == Edit_Poly then
			curr_mod.ButtonOp #UnhideAllVertex

		else if classOf curr_mod  == Editable_Poly then
			polyop.unHideAllVerts obj

		this._hideVerts( verts_mesh_all - isolate_verts )

	),

	fn round p3 dp =
	(
		local tempArr = #(p3.x,p3.y,p3.z)
		local mult = 10.00^(dp as float)
		local rp3Arr = for c in tempArr collect ((floor ((c * mult)+0.5)) / mult)
		point3 rp3Arr[1] rp3Arr[2] rp3Arr[3]
	),

	/** Get vertex numbers of Editable Poly by verts of Edit Poly
	  *
	  * 1) Get selected verts in modifier like Edit Poly|Poly Select
	  * 2) Find same vertex by position in Editable Poly baseobject
	  *
	  * #return BitArray of vertex indexes of Editable Poly Baseobject
	 */
	function _getBaseObjectVerts verts =
	(
		format "\n"; print "VertexColorProcessor_v._getBaseObjectVerts()"
		format "verts: %\n" verts
		format "classof curr_mod: %\n" (classof curr_mod)


		if classof curr_mod == Edit_Poly and verts.numberSet > 0 and ( vertex_count_mesh = getNumVerts obj.mesh ) != ( vertex_count_baseobject = polyop.getNumVerts obj.baseobject) then
		(
			verts_baseobject = #{}

			verts_base_all	= #{1..vertex_count_baseobject}

			timer_verts_positions = timeStamp()
			verts_positions = in coordsys world polyop.getVerts obj verts node:obj
			format "verts_positions: % ms\n" (( timeStamp()) - timer_verts_positions)

			timer_verts_pos_baseobjects = timeStamp()
			verts_pos_baseobjects = in coordsys world  polyop.getVerts obj.baseobject verts_base_all node:obj
			format "verts_pos_baseobjects: % ms\n" (( timeStamp()) - timer_verts_pos_baseobjects)


			timer_loop = timeStamp()
			for vert_pos in verts_positions where (vert = findItem verts_pos_baseobjects (vert_pos)) > 0 do
				verts_baseobject[vert] = true

			format "loop: % ms\n" (( timeStamp()) - timer_loop)

			verts_baseobject --return
		)
		else
			verts --return
	),

	/** Pass vertex selection from editable poly baseobject to edit poly modifier based on vertex position
	  *
	  * #return BitArray of vertex indexes of Edit Poly Modifier
	 */
	function _getEditPolyVerts verts_baseobject  =
	(
		format "\n"; print "VertexColorProcessor_v._getEditPolyVerts()"
		verts_edit_poly = #()

		verts_mesh_all = #{1..( getNumVerts obj.mesh)}

		verts_pos_baseobjects =  in coordsys world polyop.getVerts obj.baseobject verts_baseobject node:obj

		--verts_mesh_pos  = for vert in verts_mesh_all collect getVert obj.mesh vert
		verts_mesh_pos = in coordsys world polyop.getVerts obj verts_mesh_all node:obj
		--format "verts_mesh_pos: %\n" verts_mesh_pos

		for vert_pos in verts_pos_baseobjects where (vert = findItem verts_mesh_pos (vert_pos)) > 0 do
			append verts_edit_poly vert

		verts_edit_poly as BitArray --return
	),


	/** Update cache
	 */
	function _updateCache verts clr =
	(
		--format "\n"; print "VertexColorProcessor_v._updateCache()"

		pointer = (getHandleByAnim obj) as string

		if (colors_cahce = VERTEX_COLORS_CACHE[pointer]) != undefined then
		(
			colors = VERTEX_COLORS_CACHE[pointer] = VertexColors.getAllVertsAndColors()


			/* remove verts from other colors */
			for _color in colors.keys do VERTEX_COLORS_CACHE[pointer][_color] -= verts

			/* remove verts from other colors */
			for colors_data in colors where colors_data.value.isEmpty do removeDictValue VERTEX_COLORS_CACHE[pointer] colors_data.key

			/* add verts to color */
			if colors[clr] == undefined then
				VERTEX_COLORS_CACHE[pointer][clr] = verts
			else
				VERTEX_COLORS_CACHE[pointer][clr] += verts

			--for colors_data in VERTEX_COLORS_CACHE[pointer] do format "COLOR: %	VERTS: %\n" colors_data.key colors_data.value

			VERTEX_COLORS_CACHE[pointer] --return
		)
		else
			colors_cahce --return
	),

	/**
	 */
	on create do
	(
		format "\n"; print "IslandsSystem.VertexColorProcessor_v()"

		format "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
		--messageBox "Yupiii" title:"Title"  beep:false
		curr_mod	= modPanel.getCurrentObject()
		--format "curr_mod: %\n" curr_mod

		if this._initObject() then
			VertexColors	= VertexColors_v(obj)

		--MeshVertToColorVertexConvert	= MeshVertToColorVertexConvertor_v(obj)

		--VertexColors.MeshVertToColorVertexConvert = MeshVertToColorVertexConvert
	)
)
