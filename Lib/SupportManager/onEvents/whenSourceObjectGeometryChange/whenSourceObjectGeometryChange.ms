global WHEN_GEOMETRY_CHANGED = #()

/** When attribute change https://help.autodesk.com/view/MAXDEV/2024/ENU/?guid=GUID-513285B3-DBF6-471E-B587-B5BE14D4D875
 */
function whenSourceObjectGeometryChange objs =
(
	if classOf objs == Array then
		join WHEN_GEOMETRY_CHANGED objs

	else
		append WHEN_GEOMETRY_CHANGED objs

	deleteAllChangeHandlers id:#WHEN_GEOMETRY_CHANGED

	when topology WHEN_GEOMETRY_CHANGED changes id:#WHEN_GEOMETRY_CHANGED obj do
	(
		format "WHEN_GEOMETRY_CHANGED: %\n" obj
		
		TEST = callbacks.notificationParam()
		format "TEST: %\n" TEST
	)
)

whenSourceObjectGeometryChange( selection as Array )