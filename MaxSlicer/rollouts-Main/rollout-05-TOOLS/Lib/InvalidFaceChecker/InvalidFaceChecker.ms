/** Invalid face checker
 */
struct InvalidFaceChecker_v
(
	/* construct */
	obj,

	/* required */
	

	/* properties */
	invalid_faces = Dictionary #( 3, #{} ) #( 4, #{} ), -- maps [original vert index] -> [new vert index]


	/* private */
	/* dependency */
	/* reference */
	/* inhered */
	/** Search
	 */
	function search =
	(
		--format "\n"; print "InvalidFaceChecker_v.search()"
		face_count = polyop.getNumFaces obj
		face_vert_map = #()
		face_list = #()
		
		
		face_sel	= getFaceSelection obj
		
		--faces_all = #{1..face_count}
		format "face_sel.numberSet: %\n" face_sel.numberSet
		
		faces_process = if face_sel.numberSet > 0 then face_sel else #{1..face_count}
		
		format "faces_process: %\n" faces_process
		--for f = 1 to face_count do
		for f = 1 to face_count where faces_process[f] do
		(
			face_verts = polyop.getFaceVerts obj f
			verts_count = face_verts.count
			format "verts_count: %\n" verts_count

			if this._isDegeneratedFace obj f face_verts then
			(
				
				if invalid_faces[verts_count] == undefined then 
					invalid_faces[verts_count] = #{}
				
				invalid_faces[verts_count][f] = true

				--if face_verts.count == 4 then
				--	obj.TurnDiagonal f 1
				
			)
		)
		
		--invalid_faces --return
		
	),
	

	private
	
	function _isDegeneratedFace obj face face_verts =
	(
		--format "\n"; print "InvalidFaceChecker._isDegeneratedFace()"
		format "\n=================\n\n"
		format "FACE: %\n" face
	
		is_face_flat = false
		
		verts_count = face_verts.count
		
		tri_count = verts_count - 3

		all_triangulations = this._getAllTriangleCombinations ( for i = 1 to verts_count collect i )
		
		format "all_triangulations: %\n" all_triangulations
		format "all_triangulations.count: %\n" all_triangulations.count
		
		verts_pos = for vert in face_verts collect polyop.getVert obj vert
		--
		trianlges_valid = #()
		trianlges_invalid = #()
		--
		--format "TRIANGLES: %\n" all_triangulations
		--/*------------------------------------------------------------------------------
		--	SEARCH FOR FLAT TRIANLGES 
		----------------------------------------------------------------------------------*/
		--
		--if verts_count == 3 then
		--(
		--	is_face_flat = this._isTriangleFlat verts_pos
		--	
		--	if is_face_flat then
		--		append trianlges_invalid tri_verts
		--	else
		--		append trianlges_valid tri_verts
		--)
		--else
		--	for tri_verts in all_triangulations  do
		--	(
		--		is_face_flat = this._isTriangleFlat ( this._getVertexPositions verts_pos tri_verts )
		--		
		--		if is_face_flat then
		--			append trianlges_invalid tri_verts
		--		else
		--			append trianlges_valid tri_verts
		--		
		--	)
		--format "face_verts: %\n" (face_verts as Array )
		--
		--format "trianlges_valid:   %\n" trianlges_valid
		--format "trianlges_invalid: %\n" trianlges_invalid
		--
		--if trianlges_invalid.count > 0 and trianlges_valid.count > 0 and  tri_count > 0 then
		--(
		--	/* SEARCH FOR shared edge of trianlges */ 
		--	for i = 1 to tri_count do
		--	(
		--		local edge_found
		--		
		--		for x = 1 to trianlges_valid.count do 
		--			for y = x + 1 to trianlges_valid.count while edge_found == undefined where x != y do
		--			(
		--				format "trianlges_valid[x]: %\n" trianlges_valid[x]
		--				format "trianlges_valid[y]: %\n" trianlges_valid[y]
		--				verts_x = for face_vert in trianlges_valid[x] collect face_verts[face_vert]
		--				verts_y = for face_vert in trianlges_valid[y] collect face_verts[face_vert]
		--				
		--				if (edge_verts = ( verts_x as BitArray * verts_y as BitArray ) as Array ).count == 2 then
		--				(
		--					edge_found = true
		--					format "---------\n"
		--					--format "edge_verts: %\n" edge_verts
		--					format "edge_verts: %\n" edge_verts
		--					v1 = face_verts[edge_verts[1]]
		--					v2 = face_verts[edge_verts[2]]
		--					format "v1: %\n" v1
		--					format "v2: %\n" v2
		--					--polyop.setDiagonal obj face v1 v2
		--					result = polyop.setDiagonal obj face v1 v2
		--					format "result: %\n" result
		--					--obj.TurnDiagonal face i
		--
		--					
		--				)
		--			)
		--	)
		--)
		
		trianlges_invalid.count > 0 --return
	),
	
	/* 
	Get all unique triangle combinations from polygon vertex array
	Each triangle is a unique set of 3 vertex indices from the input array
	*/
	function _getAllTriangleCombinations vert_array =
	(
		-- Local variables for the function
		format "\n"; print "InvalidFaceChecker._getAllTriangleCombinations()"
		format "vert_array: %\n" vert_array
		local n = vert_array.count
		local resultTriangulations = #()
		local v_first, v_last, v_k
		local subPoly_A, subPoly_B
		local triangulations_A, triangulations_B
		local combinedTriangulation
	
		-- A polygon must have at least 3 vertices.
		if n < 3 then return #()
	
		-- Base case: If the polygon is already a triangle, there is only one triangulation: itself.
		if n == 3 then return #( #(vert_array) )
	
		-- Define the main diagonal we will use to split the polygon.
		v_first = vert_array[1]
		v_last = vert_array[n]
	
		-- Recursive Step: Iterate through all possible intermediate vertices (v_k)
		-- to form a triangle (v_first, v_k, v_last) and two sub-polygons.
		for k = 2 to (n - 1) do
		(
			v_k = vert_array[k]
			local new_triangle = #(v_first, v_k, v_last)
	
			-- Create the first sub-polygon from v_first to v_k
			subPoly_A = for i = 1 to k collect vert_array[i]
			triangulations_A = getAllTriangulations subPoly_A
	
			-- Create the second sub-polygon from v_k to v_last
			subPoly_B = for i = k to n collect vert_array[i]
			triangulations_B = getAllTriangulations subPoly_B
	
			-- Combine the triangulations from the two sub-polygons.
	
			if triangulations_A.count == 0 and triangulations_B.count > 0 then
			(
				-- Case: The first sub-polygon was just a line (2 verts), so it has no triangulations.
				-- Add the new triangle to each triangulation of the second sub-polygon.
				for t_B in triangulations_B do
				(
					append resultTriangulations (t_B + #(new_triangle))
				)
			)
			else if triangulations_A.count > 0 and triangulations_B.count == 0 then
			(
				-- Case: The second sub-polygon was just a line.
				-- Add the new triangle to each triangulation of the first sub-polygon.
				for t_A in triangulations_A do
				(
					append resultTriangulations (t_A + #(new_triangle))
				)
			)
			else if triangulations_A.count > 0 and triangulations_B.count > 0 then
			(
				-- Case: Both sub-polygons returned triangulations.
				-- Create a new combined triangulation from every possible pair.
				for t_A in triangulations_A do
				(
					for t_B in triangulations_B do
					(
						-- It's crucial to use deepcopy to avoid modifying arrays that are being iterated over.
						combinedTriangulation = deepcopy t_A
						for tri in t_B do append combinedTriangulation tri
						append combinedTriangulation #(new_triangle)
						append resultTriangulations combinedTriangulation
					)
				)
			)
		)
	
		return resultTriangulations
	),
	/** Is triangle flat
	 */
	function _isTriangleFlat verts_pos =
	(
		--format "\n"; print ".isTriangleFlat()"
		-- compute triangle area via cross product
		v1 = verts_pos[2] - verts_pos[1]
		v2 = verts_pos[3] - verts_pos[2]
		
		area = length (cross v1 v2) * 0.5

		area < 1e-5 --return
	),
	
	/** Get vertex positions
	 */
	function _getVertexPositions verts_pos tri_verts =
	(
		for vert in tri_verts collect verts_pos[vert]
		
	),
	
	/**
	 */
	on create do
	(
		--format "\n"; print "InvalidFaceChecker.onCreate()"
		if not ( isValidNode obj and isKindOf obj Editable_Poly ) then
		(
			messageBox ("Object is not editable mesh") --title:"Title"  beep:false
			
			exit
		)
	)

)
