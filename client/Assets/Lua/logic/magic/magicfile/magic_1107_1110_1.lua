module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[run]],action_time=0,excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.48,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/wjgy1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.48,
		},
		[4]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1.7,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.2,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.5,
		},
		[5]={
			args={
				alive_time=0.8,
				begin_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				delay_time=0,
				ease_type=[[Unset]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_122_att/Prefabs/Skill_eff_122_att_07.prefab]],
					preload=false,
				},
				end_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=2,},
				excutor=[[vicobj]],
				move_time=0.25,
			},
			func_name=[[ShootEffect]],
			start_time=0.5,
		},
		[6]={
			args={action_name=[[attack2]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.6,
		},
		[7]={
			args={
				alive_time=1.4,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_122_att/Prefabs/Skill_eff_122_att_03.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.65,
		},
		[8]={
			args={
				alive_time=1.4,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_122_att/Prefabs/Skill_eff_122_att_04.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[9]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.8,
		},
		[10]={
			args={shake_dis=0.1,shake_rate=10,shake_time=0.5,},
			func_name=[[ShakeScreen]],
			start_time=0.9,
		},
		[11]={args={},func_name=[[End]],start_time=1.2,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
