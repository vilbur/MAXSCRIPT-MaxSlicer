
/**
 */
struct VertexLayers_v
(
	/* construct */
	obj,

	/* required */

	/* properties */
	--vertex_count,
	verts_all,
	verts_process, -- canditate for supports
	verts_pos,
	verts_layers, -- #( #{3..8}, 2 ) vertex numbers in layer, if layer is empty, then layer index is stored

	--verts_support = #{},	-- final verts used for supports

	bbox,
	layer_height = 0.05, -- height of print layer in mm

	/* dependency */

	/* reference */
	/* inhered */
	/** Find points
	 */
	function findVertsOfNewIslands verts_all verts_process layer_height =
	(
		format "\n"; print "VertexLayers_v.findVertsOfNewIslands()"

		/* ========= DEV DESELECT ALL VERTS ========= */
		--obj.EditablePoly.SetSelection #Vertex #{}

		format "VERTS_PROCESS: %\n" verts_process
		verts_pos = in coordsys world meshop.getVerts obj.mesh verts_all node:obj

		format "\n"; print "VertexLayers_v._sortVertsToLayers()"

		/* SET ALL VERTS TO LAYERS */
		--if verts_process.numberSet == verts_all.numberSet then
		(
			print "SET ALL VERTS TO LAYERS"
			bbox = nodeGetBoundingBox obj ( Matrix3 1)

			pos_z_min = bbox[1].z

			--mesh_height = bbox[2].z - pos_z_min
			mesh_height = bbox[2].z

			verts_fit = copy verts_all
		)

		if pos_z_min < 0 then
		(
			messageBox ("OBJECT IS BELLOW THE GROUND.\n\nMove object "+obj.name+" above ground please.") title:"FIND ISLANDS ERROR"

			return false
		)

		layers_count = ceil ( mesh_height / layer_height)
		format "LAYERS_COUNT: %\n" layers_count

		this.verts_layers  = #{1..(layers_count + 1)} as Array -- create with

		for vert in verts_fit do
		(
			layer = ceil ( (verts_pos[vert].z ) / layer_height) + 1

			if classOf this.verts_layers [layer] == BitArray then
				this.verts_layers [layer][vert] = true

			else
				this.verts_layers [layer] = #{vert} -- set first vert in layer
		)

		verts_layers --return --return
	),

	/**
	 */
	on create do
	(
		format "\n"; print "VertexLayers.onCreate()"
		print "**************************\n**************************"
	)

)
