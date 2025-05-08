
/** Support modifiers
 */
struct SupportModifiers_v
(
	/* construct */
	/* properties */
	--mod_names = #("BAR WIDTH", "Select Base", "BASE WIDTH", "CHAMFER BASE", "CHAMFER BAR", "Select Ends", "Select Top", "EXTEND"),

	mods_support	=  Array (7),
	mods_raft	=  Array (4),

	/* options */
	/* dependency */
	
	/* reference */
	/* inhered */

	/** Init modifiers
	 */
	function _initModifiers =
	(
		format "\n"; print "SupportModifiers_v.initModifiers()"

		OPTIONS = SUPPORT_OPTIONS

		/* SUPPORT MODIFIERS */
		mods_support[7]	= this._sweepSetup	(sweep	name:"BAR_WIDTH")	--(OPTIONS.getOption #BAR_WIDTH )
		mods_support[6]	= this._volSelectSetup	(Vol__Select	name:"select_base")	(OPTIONS.getMatId  #BASE )
		mods_support[5]	= this._extrudeSetup	(Face_Extrude	name:"BASE_WIDTH")	(OPTIONS.getOption #BASE_WIDTH )
		mods_support[4]	= this._chamferSetup	(Chamfer	name:"chamfer_base")	(OPTIONS.getOption #CHAMFER_BASE )
		mods_support[3]	= this._volSelectSetup	(Vol__Select	name:"select_top")	(OPTIONS.getMatId  #TOP )
		mods_support[2]	= this._chamferSetup	(Chamfer	name:"TOP_WIDTH")	(OPTIONS.getOption #TOP_WIDTH )	--selection_option:#ALL  materialoption:#DIFFERENT
		mods_support[1]	= this._extrudeSetup	(Face_Extrude	name:"EXTEND_TOP")	(OPTIONS.getOption #EXTEND_TOP )

		
		/* RAFT MODIFIERS */
		mods_raft[4]	= this._sweepSetup	(sweep	name:"BAR_WIDTH")	--(OPTIONS.getOption #BAR_WIDTH )
		mods_raft[3]	= this._chamferSetup	(Chamfer	name:"TOP_WIDTH")	(OPTIONS.getOption #TOP_WIDTH )	material_ID:(OPTIONS.getMatId #MIDDLE ) materialoption:#OFF
		mods_raft[2]	= this._volSelectSetup	(Vol__Select	name:"select_ends")	(OPTIONS.getMatId  #MIDDLE )	invert_sel:true
		mods_raft[1]	= this._extrudeSetup	(Face_Extrude	name:"EXTEND_END")	(OPTIONS.getOption #EXTEND_END )
	),

	/** SWEEP Modifier
	  *
	  */
	function _sweepSetup sweep_mod =
	(
		--format "\n"; print "SupportModifiers_v._sweepSetup()"

		/** Reset mod propertis -- sweep mpdofoer keeps its settings if newly created, i dont know why.. oteh modifiers dont do that :D

			QUICK SOLUTION - FOR MORE MODIFIERS OR PROPERTIES SHOULD COMPLEX SOLUTUION EXISTS

		 */
		function resetSweepModProperties sweep_mod =
		(
			sweep_mod.MirrorXZPlane = off
			sweep_mod.MirrorXYPlane = off

			sweep_mod.XOffset = 0
			sweep_mod.yOffset = 0

			sweep_mod.angle = 0
			sweep_mod.SmoothSection = on
			sweep_mod.SmoothPath = off
			sweep_mod.PivotAlignment = 4


			sweep_mod.GenMatIDs = on
			sweep_mod.UseSectionIDs = off
			sweep_mod.UsePathIDs = off
		)

		resetSweepModProperties(sweep_mod)

		sweep_mod.CurrentBuiltInShape = 4 -- Set cylinder

		/* GENERATE MATERIAL ID */
		sweep_mod.UseSectionIDs	= off
		sweep_mod.UsePathIDs	= on

		sweep_mod --return
	),

	--/** Add edit spline
	--  *
	--  */
	--function _addEditSpline =
	--(
	--	format "\n"; print "SupportModifiers_v._addEditSpline()"
	--	modPanel.addModToSelection (Edit_Spline ())
	--),

	/** Add SELECT modifier
	  *
	  */
	function _volSelectSetup vol_sel_mod mat_id invert_sel:false =
	(
		--format "\n"; print "SupportModifiers_v._selectSetup()"

		vol_sel_mod.level	= 2	-- select face
		vol_sel_mod.volume	= 5	-- select by material ID
		vol_sel_mod.matID	= mat_id	-- select face by mat ID
		vol_sel_mod.invert	= invert_sel	-- select face by mat ID

		vol_sel_mod --return
	),

	/** Chamfer
	  *
	  * @param #DIFFERENT|#OFF materialoption
	  */
	function _chamferSetup chamfer_mod amount selection_option:#STACK materialoption:#OFF material_ID: /* minangle:  */ =
	(
		--format "\n"; print "SupportModifiers_v._chamfer()"

		chamfer_mod.selectionoption = case selection_option of
		(
			#STACK:	0 -- from stack
			#ALL:	5 -- all edges
		)
		
		/* AVOID ARTIFACTS if raft is short */ 
		chamfer_mod.limiteffect = true

		/* SET CHAMFER VALUES */
		chamfer_mod.amount 	 = amount

		chamfer_mod.segments = 0

		/* UNSMOOTH OBJECT */
		chamfer_mod.smooth 	= true

		chamfer_mod.SmoothType = 1 -- 0: entrire object | 1: Chamfer only

		chamfer_mod.smooththreshold = 35

		chamfer_mod.materialoption = case materialoption of -- CHAMFER MATERIAL
									(
										#OFF:	0 -- mat_ids off
										#DIFFERENT:	1 -- different mat_ids
									)

		/* ALLOW MATERIAL */
		chamfer_mod.setmaterial	= classOf material_ID == integer

		/* ASSIGN CHAMFER MATERIAL */
		if classOf material_ID == integer then
			chamfer_mod.materialID	= material_ID

		chamfer_mod --return
	),

	/** Add extrude modifier
	  *
	  */
	function _extrudeSetup extrude_mod amount scale: =
	(
		--format "\n"; print "SupportModifiers_v._extrudeBase()"
		extrude_mod.amount	= amount

		--extrude_mod.extrude_center = [0,0,-1000] -- HIDE DUMMY OF MODIFIER
		
		extrude_mod --return
	),

	/**
	 */
	on create do
	(
		--format "\n"; print "SupportModifiers_v.onCreate()"
		this._initModifiers()
	)
)