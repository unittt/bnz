module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[magic]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/wwdz1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.45,
		},
		[4]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_155_att/Prefabs/Skill_eff_155_att.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.45,
		},
		[5]={
			args={
				begin_type=[[current]],
				calc_face=false,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=2,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=false,
				move_time=0.25,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=1,
		},
		[6]={
			args={action_name=[[run]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=1,
		},
		[7]={
			args={sound_path={soundpath=[[Audio/Sound/War/wwdz2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=1,
		},
		[8]={
			args={sound_path={soundpath=[[Audio/Sound/War/wwdz3.ogg]],},},
			func_name=[[PlaySound]],
			start_time=1.1,
		},
		[9]={
			args={
				alive_time=1.5,
				bind_type=[[empty]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_155_att/Prefabs/Skill_eff_155_att_3.prefab]],
					preload=false,
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.2,
		},
		[10]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_155_att/Prefabs/Skill_eff_155_att_2.prefab]],
					preload=false,
				},
				effect_dir_type=[[backward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1.8,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.3,
		},
		[11]={
			args={action_name=[[attack6]],bak_action_name=[[attack5]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=1.3,
		},
		[12]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
				shot=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.72,
		},
		[13]={
			args={
				alive_time=0.15,
				ease_hide_time=0,
				ease_show_time=0.05,
				excutor=[[vicobj]],
				mat_path=[[Material/effect_Fresnel_Ble_red.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=1.72,
		},
		[14]={
			args={shake_dis=0.05,shake_rate=10,shake_time=0.15,},
			func_name=[[ShakeScreen]],
			start_time=1.72,
		},
		[15]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_101_hit/Prefabs/Skill_eff_101_hit.prefab]],
					preload=false,
				},
				excutor=[[vicobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.72,
		},
		[16]={args={},func_name=[[End]],start_time=2.5,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
