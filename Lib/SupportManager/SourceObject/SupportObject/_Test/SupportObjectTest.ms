filein( getFilenamePath(getSourceFileName()) + "/../SupportObject.ms" )	--"./../SupportObject.ms"


delete objects


segments = 10
seg_angle = 360 / segments

obj = Cylinder radius:100 height:50 sides:(segments - 2 ) slice:on slicefrom:(360 - seg_angle ) sliceto:seg_angle transform:( Matrix3 [0,-1,0] [0,0,1] [1,0,0] [0, 0, 200])  isSelected:on

modPanel.addModToSelection ( meshsmooth sepBySmGroups:true ) ui:on


