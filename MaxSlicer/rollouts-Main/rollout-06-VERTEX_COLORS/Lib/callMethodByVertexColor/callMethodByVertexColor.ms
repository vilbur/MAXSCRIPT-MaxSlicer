global VERTEX_COLOR_PARAM


/** Call vertex color macro
  
  @param #SELECT|#HIDE|#UNHIDE|#ISOLATE method
  
  @param color|undefined _color to process, IF UNDEFINED THEN ALL COLORED VERTS ARE PROCESSED
  
 */
 
function callMethodByVertexColor method _color =
(
	format "\n"; print "callMethodByVertexColor()"
	format "method: %\n" method
	format "VERTEX_COLOR_PARAM: %\n" VERTEX_COLOR_PARAM

	for obj in selection do
	(
		--obj = selection[1]
		
		if _color != undefined then 
			VERTEX_COLOR_PARAM = _color
	
		VertexColorProcessor = VertexColorProcessor_v(obj)
	
		/* SET VERTEX COLOR */ 
		if method == #SET then
		(
			vertex_sel	= getVertSelection obj.mesh
			
			VertexColorProcessor.setVertexColor vertex_sel VERTEX_COLOR_PARAM
		)
		/* CALL OTHER METHODS */ 
		else
			VertexColorProcessor.byColor method _color
		
		
	)
)