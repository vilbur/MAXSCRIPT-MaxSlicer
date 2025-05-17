clearListener(); print("Cleared in:\n"+getSourceFileName())


filein( getFilenamePath(getSourceFileName()) + "/../WhenTransfromChangesEnds.ms" )	--"./../WhenTransfromChangesEnds.ms"


--format "WHEN_TRANSFROM_CHANGES_ENDS: %\n" WHEN_TRANSFROM_CHANGES_ENDS
/** When transfrom ends callback
 */
function transfromEndsCallback _objects =
(
	format "\n"; print "WhenTransfromChangesEnds_v.transfromEndsCallback()"
	format "_OBJECTS: %\n" _objects
	
)

/* TEST */
delete objects


for i = 1 to 3 do
(
	box_node = box position:[ (i * 30), 0, 0 ]
	
	WHEN_TRANSFROM_CHANGES_ENDS.bind box_node
	
)

--WHEN_TRANSFROM_CHANGES_ENDS.killTimer()
