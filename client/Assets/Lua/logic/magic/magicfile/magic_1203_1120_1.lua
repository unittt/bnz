module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[attack8]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.35,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/wfcb.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.7,
		},
		[4]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_125_hit/Prefabs/skill_eff_125_hit.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[5]={
			args={
				consider_hight=false,
				damage_follow=false,
				face_atk=false,
				hurt_delta=0,
				play_anim=false,
			},
			func_name=[[VicHitInfo]],
			start_time=1.6,
		},
		[6]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_157_hit/Prefabs/skill_eff_157_hit.prefab]],
				},
				excutor=[[vicobjs]],
				height=0.25,
			},
			func_name=[[BodyEffect]],
			start_time=1.6,
		},
		[7]={args={},func_name=[[End]],start_time=1.7,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
