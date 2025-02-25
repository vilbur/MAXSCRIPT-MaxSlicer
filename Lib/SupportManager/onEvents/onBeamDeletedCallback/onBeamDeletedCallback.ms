

global ON_DELETED_OBJECTS = #()

/** Bind transform event
 */
function bindBeamOnDeleteCallback objs =
(
	--format "\n"; print ".bindBeamOnDeleteCallback()"

	ON_DELETED_OBJECTS = for obj in ON_DELETED_OBJECTS where isValidNode obj collect obj

	if classOf objs == Array then
		join ON_DELETED_OBJECTS objs
	else
		append ON_DELETED_OBJECTS objs

	--format "ON_DELETED_OBJECTS: %\n" ON_DELETED_OBJECTS
	deleteAllChangeHandlers id:#onDeletedSupportOrBeamEvent

	when ON_DELETED_OBJECTS deleted id:#onDeletedSupportOrBeamEvent obj do
	(
		--appendIfUnique BEAMS_TRANSFORM_CHANGED obj
		--
		--waitForSupportDeselectCallbackStart()
		--format "obj: %\n" obj
		--for obj in BEAMS_TRANSFORM_CHANGED do
			--obj.wirecolor = ( color ( random 1 255) ( random 1 255) ( random 1 255) )
		SUPPORT_MANAGER.onObjectDeleted( obj )
	)
)
