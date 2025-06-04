global VERTEX_COLOR_PARAM


/** Call vertex color macro
 */
function callMethodByVertexColor method _color =
(
	format "\n"; print "callMethodByVertexColor()"
	format "method: %\n" method
	format "VERTEX_COLOR_PARAM: %\n" VERTEX_COLOR_PARAM

	obj = selection[1]

	VERTEX_COLOR_PARAM = _color

	VertexColorProcessor = VertexColorProcessor_v(obj)


	if method == #SET then
	(
		vertex_sel	= getVertSelection obj.mesh
		
		VertexColorProcessor.setVertexColor vertex_sel VERTEX_COLOR_PARAM
	)
	else
		VertexColorProcessor.byColor method VERTEX_COLOR_PARAM
)