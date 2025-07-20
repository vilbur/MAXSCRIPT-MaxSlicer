clearListener(); print("Cleared in:\n"+getSourceFileName())

/*
    Wirecolor Selector Script for 3ds Max
    
    Description:
    This script scans all visible geometric objects in the current scene,
    identifies their unique wirecolors, and creates a floating dialog window.
    For each unique color found, a corresponding button is created in the dialog.
    When a user clicks a button, the script selects all visible objects
    that have that specific wirecolor.

    How to Use:
    1. Open the Scripting Editor in 3ds Max (Scripting > New Script).
    2. Copy and paste this entire script into the editor window.
    3. Run the script (Ctrl+E or Tools > Evaluate All).
    4. A new dialog titled "Select by Wirecolor" will appear.
*/

(
    -- Use a try-catch block to safely close any existing version of this dialog
    -- This prevents errors if you run the script multiple times.
    try(cui.UnRegisterDialogBar WirecolorSelectorFloater)catch()
    try(destroyDialog WirecolorSelectorFloater)catch()



    -- 2. CREATE THE ROLLOUT DIALOG AND DYNAMIC BUTTONS
    -- =================================================

    rollout WirecolorSelectorFloater "Select by Wirecolor"
    (
        -- This function will perform the selection logic.
        -- It takes a color value as an argument.
        fn selectObjectsByColor theColor =
        (
            clearSelection() -- Deselect everything first
            
            -- Build an array of objects that match the color criteria.
            local objectsToSelect = for o in visibleObjects where o.wirecolor == theColor collect o
            
            -- Select the collected objects.
            select objectsToSelect
            
            -- Optional: Print a confirmation message to the MAXScript Listener.
            format "Selected % objects with wirecolor: %\n" objectsToSelect.count theColor
        )
        
        -- == CORRECTED UI DEFINITION ==
        -- An 'if/then/else' block is not a valid rollout clause, which caused the syntax error.
        -- Instead, we use separate clauses that are valid.

        -- Clause 1: A 'for' loop to generate the buttons.
        -- This is a valid way to create multiple controls. If 'uniqueColors' is empty, this loop does nothing.
        -- We store the color in the button's 'userData' property to be retrieved later.
		/** Init
		 */
		function init  =
		(
			--format "\n"; print ".init()"
			-- 1. GATHER UNIQUE WIRECOLORS FROM VISIBLE OBJECTS
			-- =================================================
			
			-- An array to hold the unique color values found in the scene.
			local uniqueColors = #()
			
			-- An array to hold the objects that will be considered.
			-- We filter for geometry that is not hidden.
			local visibleObjects = for obj in geometry where not obj.isHiddenInVpt and not obj.ishidden collect obj
			
			-- Loop through each visible object to get its wirecolor.
			for obj in visibleObjects do
			(
		
				-- 'findItem' returns 0 if the item is not found in the array.
				-- This is an efficient way to check for uniqueness.
				if (findItem uniqueColors obj.wirecolor) == 0 then
				(
					-- If the color is not already in our array, add it.
					append uniqueColors obj.wirecolor
				)
			)
					
				for c in uniqueColors do
				(
					button btn ("Select " + (c as string)) color:c across:2 align:#left userData:c
				)
			)

        -- Clause 2: A single event handler for ALL buttons named 'btn'.
        -- 'source' is a special variable that refers to the specific control that triggered the event.
        -- We get the color from the 'userData' we stored on the specific button that was pressed.
        -- This fixes a bug where all buttons would have used the same color.
        on btn pressed do
        (
            selectObjectsByColor source.userData
        )
        
        -- Clause 3: An 'if...do' statement to generate the label.
        -- This is a valid clause that will only execute if the condition is true.
        --if uniqueColors.count == 0 do
        --(
        --    label lbl_no_objects "No visible objects found in the scene."
        --)
		
		on WirecolorSelectorFloater open do

		(
			init()
		)
		
    )

    -- 3. DISPLAY THE DIALOG
    -- =======================
    
    -- Create the floating dialog window from the rollout definition.
    -- The height is calculated dynamically based on the number of colors found.
    -- The width is adjusted based on whether we need to show buttons or just the message.
    --local dialogWidth = if uniqueColors.count > 0 then 350 else 250
    --local dialogHeight = if uniqueColors.count > 0 then (ceil(uniqueColors.count / 2.0) * 25 + 40) else 50
    --createDialog WirecolorSelectorFloater dialogWidth dialogHeight
    createDialog WirecolorSelectorFloater 256	1024
)
