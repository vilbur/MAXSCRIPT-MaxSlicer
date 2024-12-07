

/**
 *
 */
macroscript	maxtoprint_select_by_z_pos
category:	"maxtoprint"
buttontext:	"Sort by Z pos"
toolTip:	""
icon:	"across:4"
(
	on execute do
	(

		function sortByZpos v1 v2 = result = v1.position.z - v2.position.z

		_selection = selection as Array

		qsort _selection sortByZpos

		select _selection

		for i in _selection do print i
	)
)
