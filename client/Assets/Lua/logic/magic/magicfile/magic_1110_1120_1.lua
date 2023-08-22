module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={
				alive_time=1,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_1110_attack1_att/Prefabs/skill_eff_1110_attack1_att_1.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.5,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/xuli.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.5,
		},
		[4]={
			args={
				alive_time=1,
				begin_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_1110_attack1_att/Prefabs/skill_eff_1110_attack1_att_2.prefab]],
					preload=false,
				},
				end_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=5,},
				excutor=[[atkobj]],
				move_time=0.35,
			},
			func_name=[[ShootEffect]],
			start_time=1.25,
		},
		[5]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=-0.5,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.2,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=1.5,
		},
		[6]={
			args={action_name=[[attack1]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=1.5,
		},
		[7]={
			args={
				alive_time=1,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_120_hit/Prefabs/Skill_eff_120_hit.prefab]],
					preload=false,
				},
				effect_dir_type=[[backward]],
				effect_pos={base_pos=[[vic]],depth=0.1,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.5,
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
			start_time=1.5,
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
			start_time=1.65,
		},
		[10]={
			args={
				alive_time=0.8,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_1110_attack1_att/Prefabs/skill_eff_1110_attack1_att_3.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.65,
		},
		[11]={
			args={sound_path={soundpath=[[Audio/Sound/War/dao.ogg]],},},
			func_name=[[PlaySound]],
			start_time=1.65,
		},
		[12]={
			args={sound_path={soundpath=[[Audio/Sound/War/dao.ogg]],},},
			func_name=[[PlaySound]],
			start_time=1.85,
		},
		[13]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.85,
		},
		[14]={
			args={
				alive_time=0.8,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_1110_attack1_att/Prefabs/skill_eff_1110_attack1_att_3.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.85,
		},
		[15]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=2.2,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.2,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=2.2,
		},
		[16]={
			args={excutor=[[atkobj]],face_to=[[lerp_pos]],h_dis=180,time=0.2,v_dis=0,},
			func_name=[[FaceTo]],
			start_time=2.2,
		},
		[17]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=2.4,
		},
		[18]={
			args={action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=2.4,
		},
		[19]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[atk_lineup]],depth=0,relative_angle=0,relative_dis=0,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.15,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=2.4,
		},
		[20]={
			args={
				alive_time=0.8,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_1110_attack1_att/Prefabs/skill_eff_1110_attack1_att_3.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=2.4,
		},
		[21]={args={},func_name=[[End]],start_time=3.7,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}