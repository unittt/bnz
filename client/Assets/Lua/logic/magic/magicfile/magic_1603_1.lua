module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.4,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1.5,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.2,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.3,
		},
		[3]={
			args={action_name=[[run]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.3,
		},
		[4]={
			args={color={a=0,b=255,g=255,r=255,},excutor=[[atkobj]],fade_time=0.2,},
			func_name=[[ActorColor]],
			start_time=0.3,
		},
		[5]={
			args={
				alive_time=1,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_151_hit/Prefabs/skill_eff_151_att.prefab]],
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=2,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.3,
		},
		[6]={
			args={sound_path={soundpath=[[Audio/Sound/War/pzcj1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.3,
		},
		[7]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_151_hit/Prefabs/skill_eff_151_hit.prefab]],
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.6,
		},
		[8]={
			args={sound_path={soundpath=[[Audio/Sound/War/pzcj2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.6,
		},
		[9]={
			args={face_atk=true,hurt_delta=0,play_anim=true,},
			func_name=[[VicHitInfo]],
			start_time=0.8,
		},
		[10]={
			args={action_name=[[idleWar]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.8,
		},
		[11]={
			args={sound_path={soundpath=[[Audio/Sound/War/pzcj1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=1.1,
		},
		[12]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[atk_lineup]],depth=0,relative_angle=0,relative_dis=0,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=false,
				move_time=0.1,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=1.2,
		},
		[13]={
			args={
				alive_time=1,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_151_hit/Prefabs/skill_eff_151_att.prefab]],
				},
				effect_dir_type=[[backward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=2,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.3,
		},
		[14]={
			args={color={a=255,b=255,g=255,r=255,},excutor=[[atkobj]],fade_time=0.15,},
			func_name=[[ActorColor]],
			start_time=1.45,
		},
		[15]={args={},func_name=[[End]],start_time=1.7,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
