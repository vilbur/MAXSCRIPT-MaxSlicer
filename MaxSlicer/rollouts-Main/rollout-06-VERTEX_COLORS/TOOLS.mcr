/**
  */
macroscript	epoly_vertex_color_copy_paste
category:	"_Epoly-Vertex-Color"
buttonText:	"Copy \ Paste"
tooltip:	"Copy vertex color"
icon:	"across:2"
(
	--on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	--on execute do
		
)

/**
  */
macroscript	epoly_vertex_color_channel_info
category:	"_Epoly-Vertex-Color"
buttonText:	"Channel Info"
toolTip:	"Open or Update Channel Info Dialog"
--icon:	"across:3"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	(
		channelInfo.Dialog ()

		channelInfo.Update ()

	)
)

/**
  */
macroscript	epoly_vertex_color_list_vertex_colors
category:	"_Epoly-Vertex-Color"
buttonText:	"List Colors"
toolTip:	"List Vertex Colors"
--icon:	"across:4|MENU:true"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	(
		obj	= selection[1]
		/* SET NEW CLASS INSTANCE */
		VertexColors = VertexColors_v(obj)


		/* GET ALL VERTS SORTED BY COLORS */
		colors = VertexColors.getVertsAndColors()

		for colors_data in colors do format "\n********\n\nCOLOR: %\nVERTS: %\nCOUNT: %\n" colors_data.key colors_data.value colors_data.value.numberSet

	)
)

/**
  */
macroscript	epoly_vertex_color_reset_vertex_colors
category:	"_Epoly-Vertex-Color"
buttonText:	"RESET CPVVerts"
toolTip:	"Reset Vertex Colors"
icon:	"across:2"
(
	on isVisible return subObjectLevel != undefined and subObjectLevel != 0

	on execute do
	if queryBox "Reest Vertex Colors ?" title:"RESET VERTEX COLORS" then
	(
		for obj in selection do
		(
			obj	= selection[1]
			
			/* REMOVE VERTEX PAINT MODIFIER */ 
			if obj.modifiers[#VertexPaint] != undefined then
			(
				
				for i = obj.modifiers.count to 1 by -1 where classOf obj.modifiers[i] == VertexPaint do
				(
					deleteModifier obj i
					--format "obj.modifiers[i].name: %\n" obj.modifiers[i].name
					prev_mod = i - 1
					
					/* REMOVE MODIFIER ABOVE VertexPaint modifier */ 
					if  obj.modifiers[prev_mod].name == "VERTEX PAINT SELECT" then
						deleteModifier obj prev_mod
				)
			)
			/* RESET EDITABLE POLY VERTEX COLORS */ 
			else if classOf obj.baseobject == Editable_Poly then
			(
				/* SET NEW CLASS INSTANCE */
				VertexColorProcessor = VertexColorProcessor_v(obj)
		
				VertexColorProcessor.resetCPVVerts()
		
				messageBox "Vertex Colors Reseted" title:"VERTEX COLOR"
			)
			
		)
	)
)

--/**
--  */
--macroscript	epoly_vertex_color_mod_delete
--category:	"_Epoly-Vertex-Color"
--buttonText:	"Remove Vertex Paint"
--toolTip:	"Reset Vertex Colors"
--icon:	"across:2"
--(
--	on isVisible return subObjectLevel != undefined and subObjectLevel != 0
--
--	on execute do
--	if queryBox "Reest Vertex Colors ?" title:"RESET VERTEX COLORS" then
--
--	(
--		obj	= selection[1]
--		/* SET NEW CLASS INSTANCE */
--		VertexColorProcessor = VertexColorProcessor_v(obj)
--
--		VertexColorProcessor.resetCPVVerts()
--
--		messageBox "Vertex Colors Reseted" title:"VERTEX COLOR"
--	)
--)