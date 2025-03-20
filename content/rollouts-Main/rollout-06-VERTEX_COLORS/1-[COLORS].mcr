--filein( getFilenamePath(getSourceFileName()) + "/Lib/callMethodByVertexColor/callMethodByVertexColor.ms" )	--"./Lib/callMethodByVertexColor/callMethodByVertexColor.ms"


/*==============================================================================
	Color Set
================================================================================*/


--/**
--  *
--  */
--macroscript	epoly_vertex_color_set_submenu
--category:	"_Epoly-Vertex-Color"
--buttonText:	"Color Set"
--toolTip:	""
--icon:	"MENU:&Color Set"
--(
--	on isVisible return subObjectLevel != 0
--
--	on execute do
--		openVertexColorSubmenu #SET
--)

/**
  */
macroscript	epoly_vertex_color_set_red
category:	"_Epoly-Vertex-Color"
buttonText:	"RED"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &RED|across:4|width:84|height:26"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET red
)

/**
  */
macroscript	epoly_vertex_color_set_green
category:	"_Epoly-Vertex-Color"
buttonText:	"GREEN"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &GREEN"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET green
)

/**
  */
macroscript	epoly_vertex_color_set_blue
category:	"_Epoly-Vertex-Color"
buttonText:	"BLUE"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &BLUE"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_NAMES[#BLUE]
)

/**
  */
macroscript	epoly_vertex_color_set_white
category:	"_Epoly-Vertex-Color"
buttonText:	"WHITE"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &WHITE"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET white
)

/**
  */
macroscript	epoly_vertex_color_set_orange
category:	"_Epoly-Vertex-Color"
buttonText:	"ORANGE"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &ORANGE"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_NAMES[#ORANGE]
	--callMethodByVertexColor #SET orange
)
/**
  */
macroscript	epoly_vertex_color_set_yellow
category:	"_Epoly-Vertex-Color"
buttonText:	"YELLOW"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &YELLOW"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET yellow
)
/**
  */
macroscript	epoly_vertex_color_set_pink
category:	"_Epoly-Vertex-Color"
buttonText:	"PINK"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &PINK"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_NAMES[#PINK]
)

/**
  */
macroscript	epoly_vertex_color_set_magenta
category:	"_Epoly-Vertex-Color"
buttonText:	"MAGENTA"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &MAGENTA"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_NAMES[#MAGENTA]
)
