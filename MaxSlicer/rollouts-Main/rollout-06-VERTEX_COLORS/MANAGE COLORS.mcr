filein( getFilenamePath(getSourceFileName()) + "/Lib/callMethodByVertexColor/callMethodByVertexColor.ms" )	--"./Lib/callMethodByVertexColor/callMethodByVertexColor.ms"

filein( getFilenamePath(getSourceFileName()) + "/Lib/openVertexColorSubmenu/openVertexColorSubmenu.ms" )	--"./Lib/openVertexColorSubmenu/openVertexColorSubmenu.ms"

/*==============================================================================
	ROW 1
================================================================================*/
/**
  */
macroscript	epoly_vertex_color_set_by_last_color
category:	"Vertex-Color-Manage-Set"
buttonText:	"S E T"
toolTip:	"Set vertex color to selected vertex.\n\nVertex can be selected in modifiers like:\nEdit Poly|Poly Select\n\nLMB: Green\nCTRL:#RED"
icon:	"across:3|MENU:SET &Color|tooltip:\n\n----------------------\n\nFIX IF NOT WORK PROPERLY:\\n1) Try clean mesh, weld verts and close borders"
--icon:	"tooltip:\n\n----------------------\n\nFIX IF NOT WORK PROPERLY:\\n1) Try clean mesh, weld verts and close borders"
(
	on isVisible return subObjectLevel != 0

	on execute do if ( obj = selection[1] ) != undefined then
	undo "Set Vertex Color" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLOR_NAMES\1-VERTEX COLOR.mcr"

		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
		(
			VertexColorProcessor = VertexColorProcessor_v(obj)

			if VERTEX_COLOR_PARAM != undefined then
				(VertexColorProcessor_v(obj)).setVertexColor (vertex_sel) (VERTEX_COLOR_PARAM)
			else
				openVertexColorSubmenu #SET
		)
	)
)


/**
  */
macroscript	epoly_vertex_color_select_by_selection
category:	"Vertex-Color-Manage"
buttonText:	"S E L E C T"
toolTip:	"Select verts with same color as selected verts.\n\n   IF NOTHING SELECTED, then select ALL COLORED verts"
--icon:	"MENU:&Select Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Verts By Selection" on
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"

		VertexColorProcessor = VertexColorProcessor_v(obj)

		/* SELECT BY SELECTION */
		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
			VertexColorProcessor.byVerts #SELECT vertex_sel

		/* SELECT BY COLOR */
		else
			VertexColorProcessor.byColor #SELECT VERTEX_COLOR_PARAM

	)
)


/**
  */
macroscript	epoly_vertex_color_select_submenu
category:	"Vertex-Color-Manage"
buttonText:	"S E L E C T"
toolTip:	"Open Select Vrtex Color Menu"
icon:	"MENU:&SELECT Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #SELECT
)



/**
  */
macroscript	epoly_vertex_color_property_toggle
category:	"Vertex-Color-Manage"
buttonText:	"S H O W"
toolTip:	"SHOW \ HIDE vertex colors on selcted obejcts"
icon:	"across:3|MENU:true"
(
	--on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	undo "Show Vertex Colors" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"

		if selection.count > 0 then
		(
			state = not selection[1].showVertexColors

			for obj in selection do
			(
				obj.showVertexColors = state
				--obj.vertexColorsShaded = false
				obj.vertexColorType = 0
			)
		)
	)
)


/*==============================================================================
	ROW 2
================================================================================*/

/**
  */
macroscript	epoly_vertex_color_hide_by_selection
category:	"Vertex-Color-Manage"
buttonText:	"HIDE"
toolTip:	"Hide verts with same color as selected verts.\n\nHIDE ONLY WHITE IF VERTEX IS NOT SELECTED"
--icon:	"across:3"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Verts By Selection" on
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"

		VertexColorProcessor = VertexColorProcessor_v(obj)

		/* HIDE BY SELECTION */
		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
			VertexColorProcessor.byVerts #HIDE vertex_sel

		/* HIDE BY COLOR */
		else
			VertexColorProcessor.byColor #HIDE VERTEX_COLOR_PARAM

	)
)


/**
  */
macroscript	epoly_vertex_color_hide_submenu
category:	"Vertex-Color-Manage"
buttonText:	"HIDE"
toolTip:	"Open Hide By Color Menu"
icon:	"MENU:&HIDE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #HIDE
)



/**
  */
macroscript	epoly_vertex_color_unhide_by_selection
category:	"Vertex-Color-Manage"
buttonText:	"UNHIDE"
toolTip:	"Unhide verts with same color as selected verts"
--icon:	"MENU:&UNHIDE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0


	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Verts By Selection" on
	(
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"

		VertexColorProcessor = VertexColorProcessor_v(obj)

		if (vertex_sel = getVertSelection obj.mesh).numberSet > 0 then
			VertexColorProcessor.byVerts #UNHIDE vertex_sel
	)
)


/**
  */
macroscript	epoly_vertex_color_unhide_submenu
category:	"Vertex-Color-Manage"
buttonText:	"UNHIDE"
toolTip:	"Open Unhide By Color Menu"
icon:	"MENU:&UNHIDE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #UNHIDE
)


/**
  */
macroscript	epoly_vertex_color_isolate_by_selection
category:	"Vertex-Color-Manage"
buttonText:	"ISOLATE"
toolTip:	"Hide verts by vertex color of selected verts.White color is used, if nothing selected.\n\nCTRL: ISOLATE MODE (Show all verts of selected colors ).\n\nQUICK SCRIPT, TESTED ONLY ON EDITABLE POLY"
icon:	""
(
	on execute do if ( obj = selection[1] ) != undefined then
	undo "Hide Colored Verts" on
	(
		--clearListener(); print("Cleared in:\n"+getSourceFileName())
		--filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\MANAGE VERTEX COLORS.mcr"
		VertexColorProcessor = VertexColorProcessor_v(obj)

		vertex_sel	= getVertSelection obj.mesh

		VertexColorProcessor.byVerts #ISOLATE vertex_sel

	)
)

/**
  */
macroscript	epoly_vertex_color_isolate_submenu
category:	"Vertex-Color-Manage"
buttonText:	"ISOLATE"
toolTip:	"Open Isolate By Color Menu"
icon:	"MENU:&ISOLATE Color"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
		openVertexColorSubmenu #ISOLATE
)


--/**
--  *
--  */
--macroscript	epoly_vertex_color_unhide_submenu
--category:	"Vertex-Color-Manage"
--buttonText:	"Menu"
--toolTip:	""
--icon:	"MENU:&Hide Color"
--(
--	on isVisible return subObjectLevel != undefined and subObjectLevel != 0
--
--	on execute do
--		openVertexColorSubmenu "color_unhide"
--)

--
--/**
--  *
--  */
--macroscript	epoly_vertex_color_reset
--category:	"Vertex-Color-Manage"
--buttonText:	"RESET Color"
--toolTip:	"Hide verts by vertex color of selected verts.White color is used, if nothing selected.\n\nCTRL: ISOLATE MODE (Show all verts of selected colors ).\n\nQUICK SCRIPT, TESTED ONLY ON EDITABLE POLY"
--icon:	"across:4|MENU:true"
--(
--	on execute do
--	undo "Reset Vertex Color" on
--	(
--		--clearListener(); print("Cleared in:\n"+getSourceFileName())
--		filein @"C:\Users\vilbur\AppData\Local\Autodesk\3dsMax\2023 - 64bit\ENU\scripts\MAXSCRIPT-MaxToPrint\content\rollouts-Main\rollout-VERTEX COLORS\VERTEX COLOR.mcr"
--
--
--		obj = selection[1]
--
--		--if getNumCPVVerts obj.mesh > 0 then
--		if polyop.getNumMapVerts obj.baseObject 0 > 0 then
--		(
--			--vertex_sel = getVertSelection obj.mesh
--
--			verts = passVertexSelectionToEditablePoly()
--
--			if verts.isEmpty then
--				verts = #ALL
--
--
--			--/* GET SELECTED OR ALL VERTS */
--			--verts = if vertex_sel.isEmpty then
--			--(
--			--	all_verts =  #{1..(getNumVerts obj.mesh)}
--			--	white_verts = meshop.getVertsByColor obj.mesh white 0.001 0.001 0.001
--			--
--			--	all_verts - white_verts
--			--)
--			--else
--			--	vertex_sel
--
--
--			polyop.setVertColor  obj.baseobject 0 verts white
--
--			--print ("VERTEX COLOR OF "+ (if vertex_sel.isEmpty then "ALL"else "SELECTED") +" SET TO WHITE")
--
--		)
--		else
--			messageBox ("There is not any vertex color on object:\n\n"+obj.name) title:"NO VERTEX COLOR"
--	)
--)
