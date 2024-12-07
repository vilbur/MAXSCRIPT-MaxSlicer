/** set limits of normals max angle or point2 min and max angles
  *
  * EXAMPLES OF VALUES:
  * 		x = undefined,	-- normal will not be used
  * 		y = 90,	-- normals with angle 0-90°
  * 		y = [45, 90],	-- normals with angle 45-90°
  *
 */
struct NormalLimits_v
(
	/* properties */
	x,
	y,
	z,
	absolute = false, -- IF TRUE then normals are compared in absolute value, OPESSITE SIDE OF NORMALS IS SELECTED TOO

	/** Get limit value of give axis
	  *
	  * @return point2 min and max angles
	 */
	function get axis =
	(
		if ( val = getProperty this axis ) != undefined and superClassOf val == Number then
			val = [ 0, val ]

		val
	),
	/** Limits exists
	 */
	function limitsExists = (for axis in #( #X, #Y, #Z ) where getProperty this axis != undefined collect axis).count > 0

)