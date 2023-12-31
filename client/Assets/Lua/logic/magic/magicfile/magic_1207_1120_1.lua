module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=false,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[attack8]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.1,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/ffwb1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.3,
		},
		[4]={
			args={
				alive_time=3.2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_123_att/Prefabs/skill_eff_123_att.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.45,
		},
		[5]={
			args={sound_path={soundpath=[[Audio/Sound/War/ffwb2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.7,
		},
		[6]={
			args={
				alive_time=3.2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_129_att/Prefabs/Skill_eff_129_att.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[7]={
			args={sound_path={soundpath=[[Audio/Sound/War/ffwb3.ogg]],},},
			func_name=[[PlaySound]],
			start_time=2,
		},
		[8]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_129_1_att/Prefabs/skill_eff_129_1_att_body.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=2.3,
		},
		[9]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=false,
				hurt_delta=0,
				play_anim=false,
			},
			func_name=[[VicHitInfo]],
			start_time=2.5,
		},
		[10]={args={},func_name=[[End]],start_time=3.2,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
