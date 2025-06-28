

global WHEN_SOURCE_OBJ_SELECT_CHANGED = #()

/** When attribute change https://help.autodesk.com/view/MAXDEV/2024/ENU/?guid=GUID-513285B3-DBF6-471E-B587-B5BE14D4D875
 */
function whenSourceObjectSelectionChanges objs =
(
	if classOf objs == Array then
		join WHEN_SOURCE_OBJ_SELECT_CHANGED objs

	else
		append WHEN_SOURCE_OBJ_SELECT_CHANGED objs
		
	WHEN_SOURCE_OBJ_SELECT_CHANGED = for obj in WHEN_SOURCE_OBJ_SELECT_CHANGED where isValidNode obj collect obj

	deleteAllChangeHandlers id:#WHEN_SOURCE_OBJ_SELECT_CHANGED

	when select WHEN_SOURCE_OBJ_SELECT_CHANGED changes id:#WHEN_SOURCE_OBJ_SELECT_CHANGED obj do
	(
		--format "WHEN_SOURCE_OBJ_SELECT_CHANGED: %\n" obj
		if obj.isSelected then
			format "% was selected.\n" obj.name
		else
			format "% was deselected.\n" obj.name
		
		
	)
)

--whenSourceObjectSelectionChanges( selection as Array )



