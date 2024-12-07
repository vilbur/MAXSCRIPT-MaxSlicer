clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../getLowestVertsInGrid.ms" )	--"./../getLowestVertsInGrid.ms"



/** Prepre ene
 */
function prepareScene =
(
	--format "\n"; print ".prepreEne()"
	delete objects

	obj = Plane width:100 length:100 pos:[ 50, 20, 50 ] widthsegs:100 lengthsegs:100 isSelected:on
	--obj = Plane width:60 length:30 pos:[ 50, 20, 50 ] widthsegs:10 lengthsegs:10 isSelected:on
	--obj = Plane width:40 length:30 pos:[ 50, 20, 50 ] widthsegs:40 lengthsegs:30 isSelected:on


	--obj = Plane width:20 length:20 pos:[ 50, 20, 50 ] widthsegs:10 lengthsegs:10 isSelected:on
	--obj = Plane width:20 length:20 pos:[ 50, 20, 50 ] widthsegs:4 lengthsegs:4 isSelected:on

	modPanel.addModToSelection (Noisemodifier scale:10 strength:[0,0,10] ) ui:on

	--rotate obj ( angleaxis 180 [1,0,0])

	macros.run "Modifier Stack" "Convert_to_Poly"

	--obj = selection[1]

)


prepareScene()
GetLowestVertsInGrid 	= GetLowestVertsInGrid_v( objects[1] )

--points_grid = GetLowestVertsInGrid.getVertsInGrid( )



--for points_in_square in GetLowestVertsInGrid.points_grid do
--	format "points_in_square: %\n" points_in_square


GetLowestVertsInGrid.selectLowestVerts()


--
--/*------------------------------------------------------------------------------
--
--	TEST OF GETTING CELLS OF VERTS BY POSITION
--
----------------------------------------------------------------------------------*/
--
--GetLowestVertsInGrid.getVertsInGrid()
--
--format "points_grid: %\n"	GetLowestVertsInGrid.points_grid
--format "points_grid.count: %\n"	GetLowestVertsInGrid.points_grid.count
--format "points_grid[1].count: %\n"	GetLowestVertsInGrid.points_grid[1].count
--
--points_grid = GetLowestVertsInGrid.points_grid
--
--
--format "points_grid[1][1]: %\n" points_grid[1][1]
--format "points_grid[1][2]: %\n" points_grid[1][2]
--
--format "points_grid[2][1]: %\n" points_grid[2][1]
--format "points_grid[2][2]: %\n" points_grid[2][2]
--
--
--
--_mod = modPanel.getCurrentObject()
--
--
--subObjectLevel = 1
----_mod.SetSelection #Vertex (points_grid[1][1])
----_mod.SetSelection #Vertex (points_grid[ 1 ][ 2 ])
----_mod.SetSelection #Vertex (points_grid[ 2 ][ 2 ])
----_mod.SetSelection #Vertex (points_grid[ 3 ][ 2 ])
