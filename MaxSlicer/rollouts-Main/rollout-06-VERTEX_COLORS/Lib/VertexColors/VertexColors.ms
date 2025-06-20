filein( getFilenamePath(getSourceFileName()) + "/MeshVertToColorVertexConvertor/MeshVertToColorVertexConvertor.ms" )	--"./MeshVertToColorVertexConvertor/MeshVertToColorVertexConvertor.ms"


global VERTEX_COLORS_CACHE = Dictionary #string

/** Vertex colors getter

 * SINGLE MESH VERT CAN APPEAR IN MULTIPLE COLORS - Each map vert can has its own color
 *
 *
 * IMPORTANT:
 *		 METHODS USING MESH VERTS:
 *				meshop.getVertsByColor()
 *				polyop.setVertColor()
 *
 *		 METHODS USING MAP VERTS:
 *				getvertcolor()
 *
 *
 *
 * NOTES FOR METHODS:
 *		1) getvertcolor()	INPUT CPV vertex
 *		2) getVertsByColor()	RETURN MESH VERTEX
 *
 */
struct VertexColors_v
(
	/* construct */
	obj, -- Editable_Poly

	/* required */
	/* properties */
	obj_snapshot,
	
	--obj.mesh,

	verts_by_colors	= Dictionary #STRING, -- KEY:color as string VALUE:#{ verts of color }
	/* private */
	/* dependency */

	/* reference */
	/* inhered */
	MeshVertToColorVertexConvert,


	/** Get vertex colors of selection
	 */
	function getVertexColorsOfSelection flat:false =
	(
		--format "\n"; print "VertexColors_v.getVertexColorsOfSelkection()"

		vertex_sel	= getVertSelection obj.mesh

		verts_by_colors =  this.getVertsAndColors verts:vertex_sel

		if flat then this.flatternColors(verts_by_colors) else verts_by_colors --return
	),

	--/** Flattern colors
	-- */
	--function flatternColors verts_by_colors =
	--(
	--	--format "\n"; print "VertexColors_v.flatternColors()"
	--	verts_by_colors_flat = #{}
	--
	--	for color_verts in verts_by_colors do verts_by_colors_flat += color_verts.value
	--
	--	verts_by_colors_flat --return
	--),

	/** Get verts and their colors
	  *
	  * @return Dictionary
	  * 
	  * 		1) If flat:false -> return KEY: color as string	VALUE: BitArray of vert indexes
	  * 		2) If flat:false -> return KEY: vert index	VALUE: color as string
	  * 
	  */
	function getVertsAndColors verts:#{} exclude:#() flat:false =
	(
		 --format "\n"; print "VertexColors_v.getVertsAndColors()"
		 --format "obj: %\n" obj
		--format "verts: %\n" verts
		--format "flat: %\n" flat
		--format "verts.numberSet: %\n" verts.numberSet
		if verts.numberSet == 0 then
			verts = #{1..(getNumVerts obj.mesh)}

		this._getVertsByColors (verts) exclude:exclude
		
		if flat then
		(
			colored_verts = Dictionary #INTEGER

			for vertex_color in verts_by_colors.keys where findItem exclude ( vertex_color as string ) == 0 do
				--format "vertex_color: %\n" vertex_color
				for vert in verts_by_colors[vertex_color as string ] do 
					colored_verts[vert] = vertex_color

			colored_verts --return
		)
		else
			verts_by_colors --return

	),

	/** Get verts only of colors which are not excluded
	  *
	  * @param #(color as string) exclude verts of colors in array will not be returned DEFAULT: get all non white verts
	  *
	  * @return BitArray of vertex indexes
	 */
	function getColoredVerts verts:#{} exclude:#() =
	(
		-- format "\n"; print "VertexColors_v.getColoredVerts()"

		appendIfUnique exclude ( white as string )

		if verts.numberSet == 0 then
			verts = #{1..(getNumVerts obj.mesh)}
		
		this._getVertsByColors (verts) exclude:exclude

		colored_verts = #{}

		for vertex_color in verts_by_colors.keys where findItem exclude ( vertex_color as string ) == 0 do colored_verts +=  verts_by_colors[vertex_color]
		-- format "colored_verts: %\n" colored_verts
		colored_verts --return
	),

	/** Get verts of same colors as give verts
	 */
	function getVertsWithSameColors verts =
	(
		--format "\n"; print "VertexColors_v.getVertsWithSameColors()"
		verts_by_colors_flat = #{}

		this._getVertsByColors (verts)

		for color_verts in verts_by_colors do verts_by_colors_flat += color_verts.value

		verts_by_colors_flat --return
	),

	/** Get vert color
	 */
	function _getVertColor mesh_vert =
	(
		--format "\n"; print "VertexColors_v._getVertColor()"

		--format "verts_by_colors: %\n" verts_by_colors
		map_verts_of_mesh_vert = MeshVertToColorVertexConvert.meshVertsToMapVerts (mesh_vert) flat:true

		color_of_vert = this._searchNewVertexColor (verts_by_colors) (map_verts_of_mesh_vert)

		color_of_vert --return
	),

	/** Get all verts and lors
	 */
	function getAllVertsAndColors =
	(
		-- format "\n"; print "VertexColors_v.getAllVertsAndColors()"
		local color_of_vert
			
		verts_get_colors = #{1..obj.mesh.numverts}

		colors = Dictionary #STRING

		white_clr = white as string

		MeshVertToColorVertexConvert.get_single_vert = true

		/* IF VERTEX COLORS EXISTS */
		if  getNumCPVVerts obj.mesh != 0 then
		(
	--format "\n===================================\n"
			while not verts_get_colors.isEmpty do
			(
				--format "\n"
				
				mesh_vert = ( verts_get_colors as Array )[1]
				
				verts_get_colors[mesh_vert] = false
				
				map_verts_of_mesh_vert = makeUniqueArray (MeshVertToColorVertexConvert.meshVertsToMapVerts (mesh_vert) flat:true )
	
				color_of_vert = this._searchNewVertexColor (colors) (map_verts_of_mesh_vert)
	
				mesh_verts_by_color = meshop.getVertsByColor obj.mesh color_of_vert 0.01 0.01 0.01 	-- get all verts by that color
	
				colors[ color_of_vert as string ] = mesh_verts_by_color
	
				verts_get_colors -= mesh_verts_by_color
			)
	
			/* REMOVE MULTI COLORED VERTS FROM WHITE - (if one of vert colors is not white, then vert is not white) */
			if this.whiteVertsExists(colors) then
				for clr in colors.keys  where clr != white_clr do
					colors[white_clr] -= colors[clr]
		)

		colors --return
	),

	private

	/** Get colors of verts
	 */
	function _getVertsByColors verts_get_colors exclude: =
	(
		 -- format "\n"; print "VertexColors_v._getVertsByColors()"
		--format "verts_get_colors: %\n" verts_get_colors
		pointer = (getHandleByAnim  obj) as string

		colors = VERTEX_COLORS_CACHE[pointer]

		all_verts_empty = #{1..obj.mesh.numverts}

		all_verts_empty *= #{}

		if colors == undefined then
			colors = VERTEX_COLORS_CACHE[pointer] = this.getAllVertsAndColors()

		verts_by_colors = Dictionary #STRING

		for colors_data in colors where not (verts_of_color = (colors_data.value * verts_get_colors)).isEmpty do
			if findItem exclude colors_data.key == 0 then
				verts_by_colors[ colors_data.key ] = (all_verts_empty + verts_of_color)

		verts_by_colors --return
	),

	/** Loop map verts of single mesh vert
	  *
	  * Test if vertex color is new
	  *
	  * @retrun color of map vertex
	 */
	function _searchNewVertexColor colors map_verts =
	(
		--format "\n"; print "VertexColors_v._searchNewVertexColor()"
		local color_of_vert

		i = 1

		while map_verts[i] != undefined and hasDictValue colors ( (color_of_vert = getvertcolor obj.mesh map_verts[i]) as string )  do
			i += 1

		color_of_vert --return
	),

	/** White verts exists
	 */
	function whiteVertsExists colors = hasDictValue colors ( white as string ),

	/**
	 */
	on create do
	(
		--format "2) --------------- VERTEXCOLORS\n"

		if classOf obj.baseobject != Editable_Poly then
		(
			obj_snapshot = obj
			
			this.obj = snapshotAsMesh obj
		)
		
		MeshVertToColorVertexConvert	= MeshVertToColorVertexConvertor_v(this.obj)
	)
)
