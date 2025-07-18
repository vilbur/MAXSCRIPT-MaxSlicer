clearListener(); print("Cleared in:\n"+getSourceFileName())

filein( getFilenamePath(getSourceFileName()) + "/../IslandFinder.ms" )	--"./../IslandFinder.ms"


obj	= selection[1]

deleteUserProp obj "ISLANDS_DATA"

ISLANDS_SYSTEM = IslandsSystem_v(obj)

ISLANDS_SYSTEM.islands_data = (IslandFinder_v(obj)).findIslandsPerLayer(layer_height) #LowestVertIslandFinder
format "ISLANDS_SYSTEM.islands_data: %\n" ISLANDS_SYSTEM.islands_data


lowest_verts = for lowest_verts_data in ISLANDS_SYSTEM.islands_data collect
--format "lowest_verts_data: %\n" lowest_verts_data
	lowest_verts_data[#lowest_vert]


format "lowest_verts: %\n" (lowest_verts as BitArray )

/* SAVE ISlANDS DATA TO OBJECT */
--setUserPropVal obj "ISLANDS_DATA" ISLANDS_SYSTEM.islands_data
