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
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=3,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				jump_num=1,
				jump_power=1,
				look_at_pos=true,
				move_time=0.2,
				move_type=[[jump]],
			},
			func_name=[[Move]],
			start_time=0,
		},
		[2]={
			args={
				alive_time=1,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_6105_attack1_att/Prefabs/skill_eff_6105_attack1_att.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=1.5,relative_angle=-5,relative_dis=3,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.15,
		},
		[3]={
			args={action_name=[[attack1]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.2,
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
			start_time=0.55,
		},
		[5]={args={},func_name=[[End]],start_time=0.88,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
