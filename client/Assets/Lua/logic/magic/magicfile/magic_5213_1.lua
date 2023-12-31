module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
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
		[3]={
			args={action_name=[[run]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.4,
		},
		[4]={
			args={action_name=[[attack1]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.7,
		},
		[5]={
			args={face_atk=false,hurt_delta=0,play_anim=true,},
			func_name=[[VicHitInfo]],
			start_time=1.05,
		},
		[6]={
			args={
				alive_time=1.5,
				bind_type=[[empty]],
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_101_hit/Prefabs/Skill_eff_101_hit.prefab]],
				},
				excutor=[[vicobj]],
				height=0.7,
			},
			editor_is_ban=false,
			func_name=[[BodyEffect]],
			start_time=1.1,
		},
		[7]={
			args={alive_time=0.2,excutor=[[vicobj]],mat_path=[[Material/effect_Fresnel_red.mat]],},
			func_name=[[ActorMaterial]],
			start_time=1.1,
		},
		[8]={args={},func_name=[[End]],start_time=1.4,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
