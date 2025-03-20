global ON_DELETED_OBJECTS = #()

/** Bind transform event
 */
function bindOnObjectDeletedCallback objs =
(
	--format "\n"; print ".bindOnObjectDeletedCallback()"

	ON_DELETED_OBJECTS = for obj in ON_DELETED_OBJECTS where isValidNode obj collect obj

	if classOf objs != Array then
		objs = #(objs)
	
	/* DO NOT BIND SAME OBJECT AGAIN */ 
	for obj in objs where findItem ON_DELETED_OBJECTS obj == 0 collect obj
	
	/* ADD OBJECTS  */ 
	if objs.count > 0 then
	(
		join ON_DELETED_OBJECTS objs
			
		deleteAllChangeHandlers id:#onDeletedSupportOrBeamEvent
	
		when ON_DELETED_OBJECTS deleted id:#onDeletedSupportOrBeamEvent obj do
		(
			SUPPORT_MANAGER.onObjectDeleted( obj )
			--for obj in BEAMS_TRANSFORM_CHANGED do
				--obj.wirecolor = ( color ( random 1 255) ( random 1 255) ( random 1 255) )
		)
	)
)