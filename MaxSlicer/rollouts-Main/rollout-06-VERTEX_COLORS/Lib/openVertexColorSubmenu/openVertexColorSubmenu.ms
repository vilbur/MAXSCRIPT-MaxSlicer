/** Call vertex color submenu
  *
  * 1) Macro	-> Open Submenu openVertexColorSubmenu()	-- Choose used method
  *     2) Submenu Item	-> Call Function callMethodByVertexColor()	-- Choose color used for method
  *         3) Function	-> Call Desired Vertex Color Method	-- Run used method with choosed color ( Set color|Select By Color|Hide by Color|... )
  *
  
  
  USES:
	COLOR_NAMES: --"./../../../../../Lib/COLOR_NAMES/COLOR_NAMES.ms"
	
	"./../callMethodByVertexColor/callMethodByVertexColor.ms"
  
 */
function openVertexColorSubmenu method =
(
	--format "\n"; print "openVertexColorSubmenu()"
	--format "method: %\n" method


	/* FIRST ITEM */
	first_item_title = case method of
	(
		--#SET:	"Set &Color"
		#SELECT:	"&Select By Selection"
		#HIDE:	"&Hide By Selection"
		#UNHIDE:	"&Unide By Selection"
		#ISOLATE:	"&Isolate By Selection"
	)


	category = "_Epoly-Vertex-Color"

	macro_name = "epoly_vertex_color_" + method as string  + (if method == #SET then "_by_last_color" else "_by_selection")

	/* ITEMS BY COLOR */
	call_method_by_vertex_color = "callMethodByVertexColor #"+ method as string + " " --"./../callMethodByVertexColor/callMethodByVertexColor.ms"

	/* DEFINE MAIN MENU */
	Menu = RcMenu_v name:"TestMenu"


	if method != #SET then
	(
		Menu.item first_item_title	( "macros.run" + "\"" + category + "\"" + "\"" + macro_name + "\""	) -- macros.run "_Epoly-Vertex-Color" "color_set_by_selection"
		
		Menu.separator()
	)
	
	if method == #HIDE then
	(
		Menu.item "&BLACK & WHITE"	( call_method_by_vertex_color + "#( black, white )"	)
		
	)
	
	/* ALL COLORS */ 
	if method == #HIDE or method == #UNHIDE or method == #ISOLATE then
	(
		Menu.item "&ALL COLORS"	( call_method_by_vertex_color + "undefined"	)
		
		Menu.separator()
	)	
	
	/* EACH COLOR */ 
	
	Menu.item "&WHITE"	( call_method_by_vertex_color + "white"	)
	Menu.item "&GRAY"	( call_method_by_vertex_color + "gray"	)
	Menu.item "B&LACK"	( call_method_by_vertex_color + "black"	)
	Menu.separator()
	
	Menu.item "&RED"	( call_method_by_vertex_color + "red"	)
	Menu.item "&GREEN"	( call_method_by_vertex_color + "green"	)
	Menu.item "&BLUE"	( call_method_by_vertex_color + " " + COLOR_NAMES[#BLUE] as string	)

	Menu.separator()
	
	Menu.item "&ORANGE"	( call_method_by_vertex_color + " " + COLOR_NAMES[#ORANGE] as string	)
	Menu.item "&YELLOW"	( call_method_by_vertex_color + "yellow"	)
	Menu.item "&PINK"	( call_method_by_vertex_color + " " + COLOR_NAMES[#PINK] as string	)
	Menu.item "&MAGENTA"	( call_method_by_vertex_color + " " + COLOR_NAMES[#MAGENTA] as string	)


	popUpMenu (Menu.create())

)
