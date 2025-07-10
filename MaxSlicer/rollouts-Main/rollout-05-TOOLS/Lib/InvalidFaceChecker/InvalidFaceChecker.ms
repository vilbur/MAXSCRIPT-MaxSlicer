/** Search for invalid polygons or faces which triangle has area near zero
	
	A) Verts of face are in line
	
	B) If polygon has degenerated triangle then
		1) Retriangulate polygon if it is possible
		2) Add to invalid faces if can`t be retriangulated
  
  
	@retrun BitArray of invalid faces
 */
struct InvalidFaceChecker_v
(
	/* construct */
	obj,

	/* required */
	

	/* properties */
	--invalid_faces = Dictionary #( 3, #{} ) #( 4, #{} ), -- maps [original vert index] -> [new vert index]
	invalid_faces = #{},
	retriangluted_faces = #{},

	/* private */
	area_treshold = 1e-5,
	--area_treshold = 0.001,
	
	
	/* dependency */
	/* reference */
	/* inhered */
	/** Search
	 */
	function search =
	(
		--format "\n"; print "InvalidFaceChecker_v.search()"
		/** First index
		 */
		function firstBit bit_array = amin( bit_array as Array )
		
		face_count = polyop.getNumFaces obj
		face_vert_map = #()
		face_list = #()
		
		face_sel	= getFaceSelection obj
		--format "face_sel.numberSet: VertSelector_v%\n" face_sel.numberSet
		
		faces_process = if face_sel.numberSet > 0 then face_sel else #{1..face_count}
		
		for face = 1 to face_count where faces_process[face] do
		(
			--format "\n=================\n\n"
			--format "FACE: %\n" face
			face_verts = polyop.getFaceVerts obj face

			verts_count = face_verts.count

			/* GET POSITIONS */ 
			verts_pos = for vert in face_verts collect polyop.getVert obj vert
			
			/*------------------------------------------------------------------------------
				TEST POLYGON
			--------------------------------------------------------------------------------*/
			if face_verts.count > 3 then
			(

				/* GET POSSIBLE TRIANGULATIONS */ 
				all_triangulations = this._getAllTriangulations ( face_verts )
				
				--for triangulation in all_triangulations do
					--format "triangulation: %\n" triangulation
				
				all_triangulations_pos = this._getAllTriangulations ( verts_pos )
				
				/* FIND INVALID FACES */ 
				valid_triangulations = this._validateTriangulations (all_triangulations_pos)
				--format "valid_triangulations: %\n" valid_triangulations
				
				/* IF ANY VALID COMBINATION EXISTS */ 
				if not valid_triangulations.isEmpty then
				(
					/* IF ALL COMNINATIONS ARE VALID */
					face_is_valid = valid_triangulations.numberSet == all_triangulations.count
					--format "IS_FACE_VALID: %\n" face_is_valid
					
					/* IF VALID TRIANGULATION EXISTS */ 
					if not face_is_valid then
						/* RETRIANGULATE POLYGON */ 
						this._retriangulatePolygon face face_verts ( all_triangulations[firstBit(valid_triangulations)] )
				)
				else /* FACE IS BROKEN - E.G.: two verts are on same pos */
					invalid_faces[face] = true

			)
			/*------------------------------------------------------------------------------
				TEST TRIANGLE
			--------------------------------------------------------------------------------*/
			else
				invalid_faces[face] = this._isTriangleFlat verts_pos

		)
		format "invalid_faces: %\n" invalid_faces
		invalid_faces --return
	),
	

	private
	
	/** Retriangulate polygon
	 */
	function _retriangulatePolygon face face_verts triangulation =
	(
		--format "\n"; print "InvalidFaceChecker_v._retriangulatePolygon()"

		
		/* SEARCH FOR shared edge of trianlges */ 
		for a = 1 to triangulation.count do
		(
			edge_found = false
			
			for b = a + 1 to triangulation.count while not edge_found where a != b do
			(
				face_A = triangulation[a] as BitArray 
				face_B = triangulation[b] as BitArray 
				
				if (edge_verts = ( face_A * face_B ) as Array ).count == 2 then
				(
					edge_found = true
					
					v1 = findItem face_verts edge_verts[1]
					v2 = findItem face_verts edge_verts[2]
					--format "v1: %\n" v1
					--format "v2: %\n" v2
					/* CONNECT VERTS BY HIDDEN EDGE */ 
					polyop.setDiagonal obj face v1 v2 -- setDiagonal uses NUMBER OF VERT IN FACE but not indexof vertex in MESH
					
					retriangluted_faces[face] = true
				)
			)
			
		)
	),
	
	
	/** Test triangulations
	 */
	function _validateTriangulations triangulations =
	(
		--format "\n"; print "InvalidFaceChecker_v._validateTriangulations triangulations()"
		
		valid_triangulations = #{}
		
		--for triangulation in triangulations do
		for i = 1 to triangulations.count do 
		(
			triangulation = triangulations[i]
			
			is_invalid = false
			
			/* TEST EACH TRIANLGE OF POLYGON */ 	
			for triangle in triangulation while not is_invalid do
				is_invalid = this._isTriangleFlat (triangle)
			
			/* ADD TO RESULT */ 
			if not is_invalid then
				valid_triangulations[i] = true
		)
		
		valid_triangulations --return
	),
	
	--/** If edge exists
	-- */
	--function _ifEdgeExists vert_A vert_B =
	--(
	--	--format "\n"; print "InvalidFaceChecker_v._ifEdgeExists()"
	--	
	--	
	--	format "all_edges: %\n" (meshop.getEdgesUsingVert obj_snapshot #{1..4})
	--	
	--	all_edges = meshop.getEdgesUsingVert obj_snapshot #{1..4}
	--	format "\n\n----------------\n"
	--	
	--	for _edge in all_edges do
	--		format "verts of edge %: %\n" _edge ( meshop.getVertsUsingEdge obj_snapshot _edge )
	--	
	--	
	--	format "\n\n----------------\n"
	--	
	--	edges_A = meshop.getEdgesUsingVert obj_snapshot vert_A
	--	edges_B = meshop.getEdgesUsingVert obj_snapshot vert_B
	--	
	--	edge_exists = false
	--	
	--	for _edge in edges_A where edges_B[_edge] do edge_exists = true
	--	
	--	
	--	format "edge_exists: %\n" edge_exists
	--	edge_exists --return
	--),
	
	/* 
	Get all unique triangle combinations from polygon vertex array
	Each triangle is a unique set of 3 vertex indices from the input array
	*/
	function _getAllTriangulations verts_numbers =
	(
		-- Local variables for the function
		--format "\n"; print "InvalidFaceChecker._getAllTriangulations()"
		--format "verts_numbers: %\n" verts_numbers
		local n = verts_numbers.count
		local resultTriangulations = #()
		local v_first, v_last, v_k
		local subPoly_A, subPoly_B
		local triangulations_A, triangulations_B
		local combinedTriangulation
	
		-- A polygon must have at least 3 vertices.
		if n < 3 then return #()
	
		-- Base case: If the polygon is already a triangle, there is only one triangulation: itself.
		if n == 3 then return #( #(verts_numbers) )
	
		-- Define the main diagonal we will use to split the polygon.
		v_first = verts_numbers[1]
		v_last = verts_numbers[n]
	
		-- Recursive Step: Iterate through all possible intermediate vertices (v_k)
		-- to form a triangle (v_first, v_k, v_last) and two sub-polygons.
		for k = 2 to (n - 1) do
		(
			v_k = verts_numbers[k]
			local new_triangle = #(v_first, v_k, v_last)
	
			-- Create the first sub-polygon from v_first to v_k
			subPoly_A = for i = 1 to k collect verts_numbers[i]
			triangulations_A = this._getAllTriangulations subPoly_A
	
			-- Create the second sub-polygon from v_k to v_last
			subPoly_B = for i = k to n collect verts_numbers[i]
			triangulations_B = this._getAllTriangulations subPoly_B
	
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
	
		resultTriangulations --return
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
		--format "area: %\n" area
		--format "TEST: %\n" (area < 1e-5)

		--area <  --return
		area < area_treshold --return 
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

		--obj_snapshot = snapshotAsMesh obj -- or use Editable_Mesh directly
	)
)
