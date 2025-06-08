global DIALOG_slicer_slider

global SET_slicer

/*------------------------------------------------------------------------------
	DEV DESTROY
--------------------------------------------------------------------------------*/
	--try(
	--	cui.UnRegisterDialogBar DIALOG_slicer_slider
	--
	--	destroyDialog DIALOG_slicer_slider
	--
	--)catch()

/** Create slicer dialog
  *
  */
function createSlicerDialog =
(
	format "\n"; print "createSlicerDialog()"


	--getViewportHeight()
	--format "DIALOG_slicer_slider == undefined	= % \n" (DIALOG_slicer_slider == undefined)
	--if DIALOG_slicer_slider == undefined then

	SlicerCallbacks = "::SlicerCallbacks_v"

	--controls_height = 86
	controls_height = 96

	--slider_height = SLICER_SYSTEM.viewport_height - ( mod SLICER_SYSTEM.viewport_height 10 ) - 70 -- round viewport height to ceil 10 E.G.: 1789 >>> 1780
	slider_height = SLICER_SYSTEM.viewport_height - controls_height -- round viewport height to ceil 10 E.G.: 1789 >>> 1780

	--if slider_height > slider_ticks then
		--slider_ticks /= 10

	--slider_ticks  = SLICER_SYSTEM.slice_count
	--slider_ticks = (floor ( slider_ticks / 10 ) ) * 10
	slider_ticks = (ceil ( SLICER_SYSTEM.slice_count / 100 ) ) * 10
	--slider_ticks = 100

	--format "SLICER_SYSTEM.slice_count: %\n" SLICER_SYSTEM.slice_count
	--format "SLICER_SYSTEM.viewport_height: %\n" SLICER_SYSTEM.viewport_height
	--format "slider_height: %\n" slider_height
	--format "slider_ticks: %\n" slider_ticks

	/*------------------------------------------------------------------------------
		DIALOG
	--------------------------------------------------------------------------------*/
	min_size = [ 42, -1 ]

    Dialog 	    = Dialog_v "" id:#DIALOG_slicer_slider width:min_size.x min_size:min_size --ini:(getSourceFileName()) --min_size:[48, -1] max_size:[48, -1]

	_Controls   = Dialog.Controls() --group:"Main Controls"

	/*------------------------------------------------------------------------------
		CONTROLS
	------------------------------------------------------------------------------*/
	tooltip_btn = "Shift slider 1 layer UP \ DOWN\n\nCTRL:  Go 10 layers UP \ DOWN\n\nSHIFT: Go 100 layers UP \ DOWN\n\nALT:  Go NEXT\PREVIOUS island"

	btn_exit = _Controls.control #BUTTON "IN\OUT" width:42 height:24 offset:[ 12, -4 ] border:false tooltip:"Exit and remove slicer from all objects"


    /*------ SLIDER ------*/
    _slider = _Controls.control #SLIDER "Slicer" \
                    id:	#SLIDER_slicer	\
                    range:	[0, SLICER_SYSTEM.slice_count, 0]	\
                    type:	#INTEGER	\
                    params:	#(#orient, #vertical  )	\
                    ticks:	100	\
                    width:	44	\
                    height:	slider_height	\
                    across:	1	\
                    offset:	[ -6, -4 ]	\
                    ini:	false

	btn_plus_minus = _Controls.control #BUTTON "+ \ -"across:1  width:42 height:32 offset:[ -4, -4 ] tooltip:tooltip_btn


	_spinner = _Controls.control #SPINNER "" id:#SPIN_layer_current across:1 range:[ SLICER_SYSTEM.slice_start, SLICER_SYSTEM.layers_count, 0] width:46 type:#integer offset:[ -6, 0 ]

	_dropdown = _Controls.control #DROPDOWNLIST "" id:#DDL_slider_snaps  width:64  items:#( "layers", "verts" ) offset:[ -16, 0 ] --ini:false --params:#( #UNSELECT, true ) across:1 offset:[ 4, 2 ] --align:#center  --width:96


	/*------------------------------------------------------------------------------
		EVENTS
	--------------------------------------------------------------------------------*/
	
	/* EXIT BUTTON */ 
	btn_exit.Event #PRESSED    "macros.run @_3D-Print@ @print_create_slicerdialog@ " tooltip:"SLICE CURRENT SELECTED OBJECT"
	btn_exit.Event #RIGHTCLICK "::SlicerCallbacks_v.desroySliderDialogAndDeleteModifiers()" tooltip:"EXIT SLICE MODE"

	/* SLIDER */ 
	_slider.Event #CHANGED     "::SlicerCallbacks_v.onSliderChanged(val)"
	_slider.Event #BUTTONDOWN	"flagForeground SLICER_SYSTEM.obj true"
	_slider.Event #BUTTONUP	"flagForeground SLICER_SYSTEM.obj false"

	/* SPINNER */ 
	_spinner.Event #CHANGED "::SlicerCallbacks_v.onSpinnerChanged(val)"

	/* PLUS \ MINUS BUTTON  */ 
	btn_plus_minus.Event #PRESSED    "::SlicerCallbacks_v.onPlusMinusButton( 1 )"
	btn_plus_minus.Event #RIGHTCLICK "::SlicerCallbacks_v.onPlusMinusButton( -1 )"

	--_dropdown.Event #CHANGED "SLICER_SYSTEM.changeSliderSnamps"

	/*------------------------------------------------------------------------------
		CREATE DIALOG
	--------------------------------------------------------------------------------*/
	--Dialog.create width:min_size.x height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )
	--Dialog.create width:(42) height:#VIEWPORT lockWidth:false --style:#()   --bgcolor:( color 60 130 140 )
	Dialog.create height:#VIEWPORT --style:#()  --lockWidth:false --bgcolor:( color 60 130 140 )

	Dialog.dock #RIGHT



)