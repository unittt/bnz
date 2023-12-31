module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.2,
		},
		[3]={
			args={
				alive_time=2.7,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_211_hit/Prefabs/Skill_eff_211_hit.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[4]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
				shot=true,
			},
			func_name=[[VicHitInfo]],
			start_time=2.2,
		},
		[5]={
			args={shake_dis=0.2,shake_rate=2,shake_time=0.1,},
			func_name=[[ShakeScreen]],
			start_time=2.3,
		},
		[6]={args={},func_name=[[End]],start_time=3,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
