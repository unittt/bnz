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
				excutor=[[atkobj]],
				face_to=[[look_at]],
				pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				time=0.3,
			},
			func_name=[[FaceTo]],
			start_time=0.3,
		},
		[4]={
			args={sound_path={soundpath=[[Audio/Sound/War/spl1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.3,
		},
		[5]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1.5,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.3,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.4,
		},
		[6]={
			args={
				alive_time=0.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_100_hit/Prefabs/skill_eff_100_hit.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0.85,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.5,
		},
		[7]={
			args={
				alive_time=1.5,
				begin_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=-0.1,},
				delay_time=1.5,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_154_hit/Prefabs/skill_eff_154_hit.prefab]],
					preload=false,
				},
				end_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0.1,},
				excutor=[[vicobj]],
				move_time=0.01,
			},
			editor_is_ban=false,
			func_name=[[ShootEffect]],
			start_time=0.5,
		},
		[8]={
			args={sound_path={soundpath=[[Audio/Sound/War/spl2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.5,
		},
		[9]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
				shot=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.6,
		},
		[10]={args={},func_name=[[End]],start_time=1,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
