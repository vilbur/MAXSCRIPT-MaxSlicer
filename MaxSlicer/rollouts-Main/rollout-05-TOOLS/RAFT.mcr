filein( getFilenamePath(getSourceFileName()) + "/../../../Lib/SupportManager/SourceObject/SupportObject/RaftBottomSnapper/RaftBottomSnapper.ms" )	--"./../../../Lib/SupportManager/SourceObject/SupportObject/RaftBottomSnapper/RaftBottomSnapper.ms"

/**
 *
 */
macroscript	maxtoprint_raft_snap_to_target
category:	"_Tools"
buttontext:	"SNAP Rafts"
toolTip:	"Snap bottom of rafts to source object"
icon:	"ACROSS:2|width:108"
(
	on execute do
		undo "Snap Rafts" on
		(
			--clearListener(); print("Cleared in:\n"+getSourceFileName())
			_selection = for obj in selection collect obj
		
			/* SEARCH FOR SOURCE OBJECTS IN SLECTION */ 
			source_objects = for obj in _selection where SUPPORT_MANAGER.isType #SOURCE obj != false collect obj

			rafts_selection = if source_objects.count == _selection.count then
				SUPPORT_MANAGER.getObjectsByType ( _selection ) type:#RAFT
			else
				_selection
			
			
			if source_objects.count == 0 then
				source_objects = SUPPORT_MANAGER.getObjectsByType ( _selection ) type:#SOURCE

			
			/* GET SUPPORTS */ 
			rafts =	SUPPORT_MANAGER.getRaftObjects( rafts_selection ) get_nodes:true
			
			format "source_objects: %\n" source_objects
			format "rafts: %\n" rafts
			
			if source_objects.count > 0 and rafts.count > 0 then
			(
				RaftBottomSnapper = RaftBottomSnapper_v( source_objects[1] )
	
				RaftBottomSnapper.snapRaftsToTargetObject rafts
			)
		)
)