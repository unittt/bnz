module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=1,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[magic]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.45,
		},
		[3]={
			args={
				alive_time=1.5,
				bind_type=[[pos]],
				body_pos=[[foot]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_152_att/Prefabs/skill_eff_152_att.prefab]],
					preload=false,
				},
				excutor=[[atkobj]],
				height=0.3,
			},
			func_name=[[BodyEffect]],
			start_time=0.45,
		},
		[4]={
			args={
				alive_time=0.3,
				ease_hide_time=0.5,
				ease_show_time=0.1,
				excutor=[[atkobj]],
				mat_path=[[Material/effect_Fresnel_red.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=0.55,
		},
		[5]={
			args={
				excutor=[[vicobj]],
				face_to=[[fixed_pos]],
				pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				time=0.25,
			},
			func_name=[[FaceTo]],
			start_time=0.65,
		},
		[6]={
			args={sound_path={soundpath=[[Audio/Sound/War/xycf1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.9,
		},
		[7]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=2,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				jump_num=1,
				jump_power=0.01,
				look_at_pos=true,
				move_time=0.2,
				move_type=[[jump]],
			},
			func_name=[[Move]],
			start_time=0.9,
		},
		[8]={
			args={face_atk=true,hurt_delta=0,play_anim=true,},
			func_name=[[VicHitInfo]],
			start_time=0.95,
		},
		[9]={
			args={sound_path={soundpath=[[Audio/Sound/War/xycf2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=1,
		},
		[10]={
			args={
				alive_time=1,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_152_hit/Prefabs/skill_eff_152_hit.prefab]],
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0.75,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			editor_is_ban=false,
			func_name=[[StandEffect]],
			start_time=1.05,
		},
		[11]={args={},func_name=[[End]],start_time=1.63,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
