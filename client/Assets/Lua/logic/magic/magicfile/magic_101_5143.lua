module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.25,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0,
		},
		[2]={
			args={action_name=[[attack1]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.2,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/quanji.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.6,
		},
		[4]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.7,
		},
		[5]={
			args={
				alive_time=0.6,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_100_hit/Prefabs/skill_eff_100_hit_blue.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0.5,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0.7,
		},
		[6]={args={},func_name=[[End]],start_time=0.9,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
