
/*

	TODO: MOVE CALLBACK TO FILE

*/
/** Wait when modifier stack will be ready
 */
function waitOnModifiyStackIsReady_SLICER =
(
	--print "Start: waitOnModifiyStackIsReady_SLICER()"
	callbacks.addScript #modPanelObjPostChange "onModifyStackReady_SLICER()" id:#onModifyStackReady_SLICER
)

/**
 */
function waitOnModifiyStackIsReadyKill_SLICER =
(
	--print "Kill: waitOnModifiyStackIsReady_SLICER()"
	try(callbacks.removeScripts #modPanelObjPostChange id:#onModifyStackReady_SLICER)catch()
)

/** Call callback when mod panel is fully loaded
 */
function onModifyStackReady_SLICER =
(
	--format "\n"; print "Callback: onModifyStackReady_SLICER WAIT"
	max modify mode

	if (_modifier = modPanel.getCurrentObject()) != undefined then -- current object is undefined than Modify panel is fully loaded
	(
		--format "\n"; print "Callback: onModifyStackReady_SLICER READY"
		waitOnModifiyStackIsReadyKill_SLICER()

		obj	= selection[1]

		local edit_poly_mod

		/* ACTIVATE FIRST EDIT POLY MODIFIER IN STACK FROM TOP */
		for _mod in obj.modifiers while edit_poly_mod != Edit_Poly where (edit_poly_mod = classOf _mod) == Edit_Poly do
			modPanel.setCurrentObject _mod node:obj

		if edit_poly_mod != Edit_Poly then
			modPanel.setCurrentObject obj.baseObject --node:obj


		if classOf ( _mod = modPanel.getCurrentObject() ) == Editable_Poly then
			_mod.showcage = off

		showEndResult  = true
	)
)
