

function testVectorInCone v1 v2 angle_treshold =
(
	dot_product = dot (normalize v1) (normalize v2)
	
	 theAngle = acos(dot_product)

	 theAngle <= angle_treshold
	 --theAngle < angle_treshold
)
			
first_knot_pos = getUserPropVal obj "FIRST_KNOT_POS" 
normal_world  = getUserPropVal obj "NORMAL_WORLD" 
obj_pos =  getUserPropVal obj "POS" 


dir_vector_new = normalize ( obj_pos - first_knot_pos)

is_in_range = testVectorInCone normal_world dir_vector_new 45

--if is_in_range then obj_pos else [0,0,0]
if is_in_range then obj_pos else [ 1.22363, -51.3882, 0 ]






function testVectorInCone v1 v2 angle_treshold =
(
	dot_product = dot (normalize v1) (normalize v2)
	
	 theAngle = acos(dot_product)

	 theAngle <= angle_treshold
	 --theAngle < angle_treshold
)
			
first_knot_pos = getUserPropVal obj "FIRST_KNOT_POS" 
normal_world  = [0,0,-1]
obj_pos =  getUserPropVal obj "POS" 


dir_vector_new = normalize ( obj_pos - first_knot_pos)

is_in_range = testVectorInCone normal_world dir_vector_new 45

--if is_in_range then obj_pos else [0,0,0]
if is_in_range then obj_pos else [ 1.22363, -51.3882, 0 ]
