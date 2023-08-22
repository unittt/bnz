module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={sound_path={soundpath=[[Audio/Sound/War/sz1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.1,
		},
		[3]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.3,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.4,
		},
		[4]={
			args={action_name=[[run]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.4,
		},
		[5]={
			args={sound_path={soundpath=[[Audio/Sound/War/sz2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.5,
		},
		[6]={
			args={action_name=[[attack7]],bak_action_name=[[attack3]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.5,
		},
		[7]={
			args={sound_path={soundpath=[[Audio/Sound/War/sz2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.85,
		},
		[7]={
			args={
				alive_time=1.2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_118_att/Prefabs/Skill_eff_118_att_02.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			editor_is_ban=false,
			func_name=[[StandEffect]],
			start_time=0.85,
		},
		[8]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.88,
		},
		[9]={
			args={
				alive_time=1,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_118_hit/Prefabs/Skill_eff_118_hit_02.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.95,
		},
		[10]={args={},func_name=[[End]],start_time=1.5,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}