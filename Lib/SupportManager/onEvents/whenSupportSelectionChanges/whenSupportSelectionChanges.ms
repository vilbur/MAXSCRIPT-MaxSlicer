

global WHEN_SUPPORT_SELECT_CHANGED = #()

/** When attribute change https://help.autodesk.com/view/MAXDEV/2024/ENU/?guid=GUID-513285B3-DBF6-471E-B587-B5BE14D4D875
 */
function whenSupportSelectionChanges objs =
(
	if classOf objs == Array then
		join WHEN_SUPPORT_SELECT_CHANGED objs

	else
		append WHEN_SUPPORT_SELECT_CHANGED objs

	WHEN_SUPPORT_SELECT_CHANGED = for obj in WHEN_SUPPORT_SELECT_CHANGED where isValidNode obj collect obj
	
	deleteAllChangeHandlers id:#WHEN_SUPPORT_SELECT_CHANGED

	when select WHEN_SUPPORT_SELECT_CHANGED changes id:#WHEN_SUPPORT_SELECT_CHANGED obj do
	(
		format "WHEN_SUPPORT_SELECT_CHANGED: %.isSelected = %\n" obj obj.isSelected
		--if not isValidNode obj then
		--	deleteItem WHEN_SUPPORT_SELECT_CHANGED ( findItem WHEN_SUPPORT_SELECT_CHANGED obj )
		--else
		--	if isValidNode obj and obj.isSelected and obj == selection[1] then
		--	(
		--		format "whenSupportSelectionChanges: % was selected.\n" obj.name
		--		
		--		roll = if getUserProp obj "RAFT_KEY" != undefined then ROLLOUT_RAFTS else ROLLOUT_SUPPORTS
		--		format "roll: %\n" roll
		--		--roll = if getUserProp obj "RAFT_KEY" != undefined then ROLLOUT_RAFTS else ROLLOUT_SUPPORTS
		--		if roll != undefined then 
		--			roll.open = true
		--	)
			--else
				--format "whenSupportSelectionChanges: % was deselected.\n" obj.name
	)
)

--whenSupportSelectionChanges( selection as Array )



