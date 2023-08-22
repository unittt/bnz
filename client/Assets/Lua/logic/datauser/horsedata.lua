module(...)

ANIM_MAP_COMMON = {
	
}

ANIM_MAP_FLY = {
	["run"] = "idleCity",
}

DATA = {
	[1] = {shape=5120, anim_map = ANIM_MAP_COMMON},
	[2] = {shape=5122, anim_map = ANIM_MAP_FLY, 
			height_info={
				fly_height =0.5,
				head_height=2.8, 
				foot_height=0.8, 
				collider_height=2,}
	},
}

