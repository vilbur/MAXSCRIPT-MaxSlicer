
/** Support modifiers
 */
struct SupportModifiers_v
(
	/* construct */
	/* properties */
	--mod_names = #("BAR WIDTH", "Select Base", "BASE WIDTH", "CHAMFER BASE", "CHAMFER BAR", "Select Ends", "Select Top", "EXTEND"),

	mods_support	=  #(),
	mods_raft	=  #(),

	/* options */
	/* dependency */
	
	/* reference */
	/* inhered */

	/** Init modifiers
	 */
	function _initModifiers =
	(
		 -- format "\n"; print "SupportModifiers_v._initModifiers()"
		OPTIONS = SUPPORT_OPTIONS
		
		top_width_support = ( OPTIONS.getModVal #TOP_WIDTH obj_type:#SUPPORT ) / EXPORT_SIZE

		top_width_raft    = ( OPTIONS.getModVal #TOP_WIDTH obj_type:#RAFT ) / EXPORT_SIZE
		
		/*------------------------------------------------------------------------------
			SUPPORT MODIFIERS
		--------------------------------------------------------------------------------*/
		mods_support[8]	= this._sweepSetup	(sweep	name:"BAR_WIDTH")	--(OPTIONS.getModVal #BAR_WIDTH )
		mods_support[7]	= this._volSelectSetup	(Vol__Select	name:"select_base")	(OPTIONS.getMatId  #BASE )
		mods_support[6]	= this._extrudeSetup	(Face_Extrude	name:"BASE_WIDTH")	(OPTIONS.getModVal #BASE_WIDTH / EXPORT_SIZE )
		mods_support[5]	= this._chamferSetup	(Chamfer	name:"chamfer_base")	(OPTIONS.getModVal #CHAMFER_BASE / EXPORT_SIZE )
		mods_support[4]	= this._volSelectSetup	(Vol__Select	name:"select_top")	(OPTIONS.getMatId  #TOP )
		--mods_support[3]	= this._chamferSetup	(Chamfer	name:"TOP_WIDTH")	(OPTIONS.getModVal (#TOP_WIDTH / EXPORT_SIZE) obj_type:#SUPPORT )	 --selection_option:#ALL  materialoption:#DIFFERENT
		mods_support[3]	= this._chamferSetup	(Chamfer	name:"TOP_WIDTH")	( top_width_support )	 --selection_option:#ALL  materialoption:#DIFFERENT
		mods_support[2]	= this._volSelectSetup	(Vol__Select	name:"select_top")	(OPTIONS.getMatId  #TOP )
		mods_support[1]	= this._extrudeSetup	(Face_Extrude	name:"EXTEND_TOP")	(OPTIONS.getModVal #EXTEND_TOP / EXPORT_SIZE )

		
		/*------------------------------------------------------------------------------
			RAFT MODIFIERS
		--------------------------------------------------------------------------------*/
		mods_raft[4]	= this._sweepSetup	(sweep	name:"BAR_WIDTH")	--(OPTIONS.getModVal #BAR_WIDTH )
		mods_raft[3]	= this._chamferSetup	(Chamfer	name:"TOP_WIDTH")	( top_width_raft )	material_ID:(OPTIONS.getMatId #MIDDLE ) materialoption:#OFF
		
		mods_raft[2]	= this._volSelectSetup	(Vol__Select	name:"select_ends")	(OPTIONS.getMatId  #MIDDLE ) invert_sel:true -- SELECT BOTH ENDS
		--mods_raft[2]	= this._volSelectSetup	(Vol__Select	name:"select_top")	(OPTIONS.getMatId  #TOP )
		
		mods_raft[1]	= this._extrudeSetup	(Face_Extrude	name:"EXTEND_END")	(OPTIONS.getModVal #EXTEND_END / EXPORT_SIZE )
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

		/* ADD CUSTOM PARAMETER FOR WIRING */ 
		if chamfer_mod.name as name == #TOP_WIDTH then
			this._addCustomAttributes chamfer_mod "TOP_WIDTH" "Top Width" SUPPORT_OPTIONS.top_width tooltip:"With of support top extension"
			
		
		/* GET SELECTION */ 
		chamfer_mod.selectionoption = case selection_option of
		(
			#STACK:	0 -- from stack
			#ALL:	5 -- all edges
		)
		
		/* AVOID ARTIFACTS if raft is short */ 
		chamfer_mod.limiteffect = true

		/* SET CHAMFER VALUES */
		chamfer_mod.amount = amount 

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
		
		/* ADD CUSTOM PARAMETER FOR WIRING */ 
		if extrude_mod.name as name == #BASE_WIDTH then
			this._addCustomAttributes extrude_mod "BASE_WIDTH" "Base Width" SUPPORT_OPTIONS.base_width tooltip:"With of support base"
			--this._addCustomAttributesToExtrude extrude_mod
		
		extrude_mod.amount	= amount 

		extrude_mod --return
	),
	
	/** ADD CUSTOM PARAMETER FOR WIRING
		
		Custom attribute works as holder of variable value for param wire script.

		
		1. CHANGE of _modifier custom attribute -> fires refresh of another modifier
		2. REFRESH of modifier[mod_name] ->  fires param wiring script
		3. Param wiring script MODIFIES _modifier value ->  fires next step
		4. Param wiring script UPDATE _modifier value
		
		
		CONNECT PARAMETER TO ANOTHER MODIFIER:
		
			obj.modifiers[_modifier].mod_name -> obj.modifiers[#mod_name].amount
		
	 */
	function _addCustomAttributes _modifier mod_name _label default_val tooltip:"" =
	(
		-- format "\n"; print "SupportModifiers_v._addCustomAttributes()"
		-- format "_MOD.NAME: %\n" _modifier.name
		ctrl_name = "spn_" + mod_name
	
		ca_def_string =
			"attributes MaxSlicer
			(
				parameters main rollout:params
				(
					" + mod_name + " type:#float ui:" +ctrl_name+ " default:"+ default_val as string +"
				)
				
				rollout params \"MaxSlicer\"
				(
					spinner " + ctrl_name + " \"" + _label + "\" type:#float range:[ 0.1, 100, 1 ] tooltip:\""+tooltip+"\"
					
					/* FIRES REFRESH OF ANOTHER MODIFIER in order to execute param wiring script */ 
					on "+ctrl_name+" changed val do
					(
						obj = (refs.dependentNodes this)[1]
					
						--format \"ATTRIBUTE CHANGED "+mod_name+"\\n\"
					
						 --format \"obj: %\\n\" obj
						
						obj.modifiers[#"+mod_name+"].amount.controller.update() -- fires refresh other modifiers[mod_name] which fires param wiring script
					)
				)

			)"
	
		-- format "CA_DEF_STRING: %\n" ca_def_string
		custAttributes.add _modifier (execute ca_def_string)
	),
	
	/**
	 */
	on create do
	(
		--format "\n"; print "SupportModifiers_v.onCreate()"
		this._initModifiers()
	)
)