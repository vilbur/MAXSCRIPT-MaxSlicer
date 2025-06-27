/** Modifier value
 */
struct ModifierValue_v
(
	/** Get sweep radius
	  
		@param #BAR_WIDTH|#RAFT_WIDTH prop_name
	  
	 */
	function getSweepRadius prop_name bar_width: =
	(
		 -- format "\n"; print "ModifierValue_v.getSweepRadius()"
		-- format "SUPPORT_OPTIONS.bar_width: %\n" SUPPORT_OPTIONS.bar_width
		
		if bar_width == unsupplied then 
			bar_width = getProperty SUPPORT_OPTIONS ( prop_name as string )

		bar_width / 2.0
	),
	
	/** Get base width value
	 */
	function getBaseWidthValue bar_width: base_width: =
	(
		--format "\n"; print "ModifierValue_v.getBaseWidthValue()"
		if bar_width == unsupplied then 
			bar_width = SUPPORT_OPTIONS.bar_width
			
		if base_width == unsupplied then 
			base_width = SUPPORT_OPTIONS.base_width
			
		
		if (base_width_value = (base_width - bar_width) / 2.0 ) > 0 then base_width_value else 0 -- base_width is always > 0
	),
	
	/** Get chamfer bar value
	  
		@param #BAR_WIDTH|#RAFT_WIDTH prop_name

	 */
	function getChamferBarValue obj_type bar_width: top_width: =
	(
		 -- format "\n"; print "ModifierValue_v.getChamferBarValue()"
		prop_name = if obj_type == #RAFT then "raft_width" else "bar_width"
		
		if bar_width == unsupplied then 
			bar_width = getProperty SUPPORT_OPTIONS prop_name
			
		if top_width == unsupplied then 
			top_width = SUPPORT_OPTIONS.top_width
			
		-- format "bar_width: %\n" bar_width
		-- format "top_width: %\n" top_width
		(bar_width - top_width) / 2.0
	),
	
	/** Get chamfer base value
	 */
	function getChamferBaseValue base_height: =
	(
		--format "\n"; print "ModifierValue_v.getChamferBaseValue()"
		if base_height == unsupplied then 
			base_height = SUPPORT_OPTIONS.base_height
		
		
		base_height / 2.0
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
