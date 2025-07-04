/** Epoly verts selector
 */
struct EpolyVertsSelector_v
(
	/* construct */
	obj,
	_mod,

	/* required */
	

	/* properties */
	obj_snapshot, -- store snapshot
	sub_object_level,
	vertex_count,
	
	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	
	/** Set selection
	 */
	function setSelection sel_bitarray subobject:#VERTEX =
	(
		-- format "\n"; print "VertSelector_v.setSelection()"
		-- format "sel_bitarray: %\n" sel_bitarray
		-- format "subobject: %\n" subobject

		--/** Pass vertex selection to editable poly
		--  *
		--  * 1) Get selected verts in modifier like Edit Poly|Poly Select
		--  * 2) Find same vertex by position in Editable Poly baseobject
		--  *
		--  * #return BitArray of vertex indexes of Editable Poly Baseobject
		-- */
		--function getVertsByBaseobject obj verts =
		--(
		--	--format "\n"; print "VertexColorProcessor_v.getBaseObjectVerts()"
		--	verts_baseobject = #()
		--
		--	--verts_mesh_all	= #{1..( getNumVerts obj.mesh  )} as Array
		--	verts_base_all	= #{1..( polyop.getNumVerts obj.baseobject)} as Array
		--
		--	verts_pos_baseobjects = polyop.getVerts obj.baseobject verts_base_all --node:obj
		--
		--	--if verts.count > 0 then
		--	(
		--		verts_sel_pos  = for vert in verts collect getVert obj.mesh vert
		--
		--		for vert_pos in verts_sel_pos where (index = findItem verts_pos_baseobjects (vert_pos)) > 0 do
		--			append verts_baseobject index
		--	)
		--
		--	verts_baseobject --return
		--)

		max modify mode

		setSelectionLevel _mod subobject

		if classOf _mod == Edit_Poly then
		(
			_mod.SetSelection #VERTEX #{}
			
			_mod.Select subobject sel_bitarray
		)
		else if classOf _mod  == Editable_Poly then
			_mod.SetSelection subobject sel_bitarray
			
			setSelectionLevel obj sub_object_level
	),
	
	/** Hide verts
	  * 
	  * @param BitArray|#ALL verts
	 */
	function hideVerts verts =
	(
		-- format "\n"; print "EpolyVertsSelector_v.hideVerts()"
		-- format "classOf _mod: %\n" (classOf _mod)

		if verts == #ALL then
			verts = this._getAllVerts()

		-- format "verts: %\n" verts
		if classOf _mod == Edit_Poly then
		(
			subObjectLevel = 1
			
			selected_verts = _mod.getSelection #VERTEX
			
			_mod.SetSelection #VERTEX #{}
		
			_mod.Select #VERTEX verts
			
			_mod.ButtonOp #HideVertex
			
			_mod.Select #VERTEX selected_verts
		)
		else if classOf _mod  == Editable_Poly then
			polyop.setHiddenVerts obj verts
		
		setSelectionLevel obj sub_object_level
	),
	
	/** Isolate verts
	 */
	function isolateVerts verts =
	(
		-- format "\n"; print "EpolyVertsSelector_v.isolateVerts()"
		all_verts = this._getAllVerts()
		
		this.unhideVerts verts
		
		this.hideVerts (all_verts - verts)
		
	),
	
	/** Unhide verts
	  *
	  * @param BitArray|#ALL verts	  
	 */
	function unhideVerts verts =
	(
		-- format "\n"; print "EpolyVertsSelector_v.unhideVerts()"
		if verts == #ALL then
			verts = this._getAllVerts()
			
		if classOf _mod == Edit_Poly then
		(
			subObjectLevel = 1
			
			selected_verts = _mod.getSelection #VERTEX
			
			hidden_verts = this._getHiddenVerts()

			hidden_verts -= verts
			
			_mod.ButtonOp #UnhideAllVertex
			
			this.hideVerts hidden_verts

			this.deleteSnapshot()

		)
		else if classOf _mod  == Editable_Poly then
		(
			hidden_verts = polyop.getHiddenVerts obj
			
			hidden_verts -= verts
			
			polyop.unHideAllVerts obj
			
			polyop.setHiddenVerts obj hidden_verts
		)
		
	),
	
	/** Hide verts
	 */
	function getHiddenVerts =
	(
		-- format "\n"; print "EpolyVertsSelector_v.getHiddenVerts()"
		
		hidden_verts = this._getHiddenVerts()

		this.deleteSnapshot()
			
		hidden_verts --return
	),

	/** Delete snapshot
	 */
	function deleteSnapshot =
	(
		--format "\n"; print "EpolyVertsSelector_v.deleteSnapshot()"
		-- format "DELETE SNAPSHOT\n"

		delete obj_snapshot
	),
	
	private

	/** Get all verts
	 */
	function _getAllVerts =
	(
		--format "\n"; print "EpolyVertsSelector_v._getAllVerts()"
		
		if vertex_count == undefined then 
			vertex_count = this._getVertexCount()
		
		#{1..vertex_count} --return
	),
	
	/** Get vertex count
	 */
	function _getVertexCount =
	(
		-- format "\n"; print "EpolyVertsSelector_v._getVertexCount()"
		-- format "COUNT\n"
		if classOf _mod == Edit_Poly then
		(
			show_end_result = showEndResult 
			
			/* "DISABLE" MODIFIERS  ABOVE, IF EDIT POLY IS IN MIDDLE OF STACK  */ 
			if modPanel.getModifierIndex obj _mod > 1 then
				showEndResult = false
			
			vertex_count = getNumVerts obj.mesh
			
			showEndResult = show_end_result
			
			vertex_count --return
		)
		else if classOf _mod  == Editable_Poly then
			polyop.getNumVerts obj
	),
	
	/** Hide verts
	 */
	function _getHiddenVerts =
	(
		--format "\n"; print "EpolyVertsSelector_v.hideVerts()"
		if classOf _mod == Edit_Poly then
		(
			this._snapshotObjAsEditablePoly()
			
			polyop.getHiddenVerts obj_snapshot
		)
		else if classOf _mod  == Editable_Poly then
			polyop.getHiddenVerts obj
	),

	
	/** Snapshot obj as editable poly
	 */
	function _snapshotObjAsEditablePoly =
	(
		--format "\n"; print "EpolyVertsSelector_v._snapshotObjAsEditablePoly()"
		
		-- format "SNAPSHOT\n"
		obj_snapshot = snapshot obj
	
		convertTo obj_snapshot PolyMeshObject
	),


	/**
	 */
	on create do
	(
		--format "\n"; print "EpolyVertsSelector.onCreate()"
		if _mod == undefined then
			_mod = modPanel.getCurrentObject()
			
		sub_object_level = getSelectionLevel(_mod)
	)

)
