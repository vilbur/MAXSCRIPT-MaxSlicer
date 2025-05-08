/** Modifier value
 */
struct ModifierValue_v
(
	/** Get sweep radius
	 */
	function getSweepRadius =
	(
		format "\n"; print "ModifierValue_v.getSweepRadius()"
		format "SUPPORT_OPTIONS.bar_width: %\n" SUPPORT_OPTIONS.bar_width
		SUPPORT_OPTIONS.bar_width / 2.0
	),
	
	/** Get base width value
	 */
	function getBaseWidthValue =
	(
		--format "\n"; print "ModifierValue_v.getBaseWidthValue()"
		if (base_width_value = (SUPPORT_OPTIONS.base_width - SUPPORT_OPTIONS.bar_width) / 2.0 ) > 0 then base_width_value else 0 -- base_width is always > 0
	),
	
	/** Get chamfer bar value
	 */
	function getChamferBarValue bar_width: =
	(
		--format "\n"; print "ModifierValue_v.getChamferBarValue()"
		if bar_width == unsupplied then 
			bar_width = SUPPORT_OPTIONS.bar_width
		
		(SUPPORT_OPTIONS.bar_width - SUPPORT_OPTIONS.top_width) / 2.0
	),
	
	/** Get chamfer base value
	 */
	function getChamferBaseValue =
	(
		--format "\n"; print "ModifierValue_v.getChamferBaseValue()"
		SUPPORT_OPTIONS.base_height / 2.0
	),
	
	/** Get drain width
	 */
	function getDrainWidth =
	(
		--format "\n"; print "ModifierValue_v.getDrainWidth()"
		SUPPORT_OPTIONS.drain_width / 2.0
	),

	private
	

	/**
	 */
	on create do	()
)
