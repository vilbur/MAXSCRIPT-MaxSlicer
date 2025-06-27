--filein( getFilenamePath(getSourceFileName()) + "/Lib/callMethodByVertexColor/callMethodByVertexColor.ms" )	--"./Lib/callMethodByVertexColor/callMethodByVertexColor.ms"


/*==============================================================================
	
	COLOR_NAMES --"./../../../Lib/COLOR_NAMES/COLOR_NAMES.ms"
	
================================================================================*/


--/**
--  *
--  */
--macroscript	epoly_vertex_color_set_submenu
--category:	"Vertex-Color-Set"
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
category:	"Vertex-Color-Set"
buttonText:	"RED"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &RED|across:3|width:84|height:26"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET red
)

/**
  */
macroscript	epoly_vertex_color_set_green
category:	"Vertex-Color-Set"
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
category:	"Vertex-Color-Set"
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
category:	"Vertex-Color-Set"
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
macroscript	epoly_vertex_color_set_gray
category:	"Vertex-Color-Set"
buttonText:	"GRAY"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &GRAY"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET gray
)

/**
  */
macroscript	epoly_vertex_color_set_orange
category:	"Vertex-Color-Set"
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
macroscript	epoly_vertex_color_set_cyan
category:	"Vertex-Color-Set"
buttonText:	"CYAN"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &CYAN"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_NAMES[#CYAN]
	--callMethodByVertexColor #SET cyan
)

/**
  */
macroscript	epoly_vertex_color_set_yellow
category:	"Vertex-Color-Set"
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
category:	"Vertex-Color-Set"
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
category:	"Vertex-Color-Set"
buttonText:	"MAGENTA"
toolTip:	"Set vertex color to selected verts"
icon:	"MENU:Set &MAGENTA"
(
	on isVisible return subObjectLevel != 0

	on execute do
		callMethodByVertexColor #SET COLOR_NAMES[#MAGENTA]
)
