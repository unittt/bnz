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
				move_time=0.5,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0.3,
		},
		[3]={
			args={action_name=[[attack1]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.75,
		},
		[4]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=false,
				hurt_delta=0,
				play_anim=true,
				shot=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.05,
		},
		[5]={
			args={sound_path={soundpath=[[Audio/Sound/War/shuizhu.ogg]],},},
			func_name=[[PlaySound]],
			start_time=1.1,
		},
		[6]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_193_hit/Prefabs/Skill_eff_193_hit.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.1,
		},
		[7]={
			args={
				alive_time=0.7,
				ease_hide_time=0.5,
				ease_show_time=0.5,
				excutor=[[vicobj]],
				mat_path=[[Material/effect_Fresnel_red_blend02.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=1.1,
		},
		[8]={
			args={
				alive_time=1.5,
				begin_pos={base_pos=[[vic]],depth=0.7,relative_angle=0,relative_dis=-0.2,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_193_hit/Prefabs/Skill_eff_193_fly_2.prefab]],
				},
				end_pos={base_pos=[[atk_lineup]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
				move_time=0.8,
			},
			func_name=[[ShootEffect]],
			start_time=1.38,
		},
		[9]={
			args={
				alive_time=1.5,
				begin_pos={base_pos=[[vic]],depth=0.7,relative_angle=0,relative_dis=-0.2,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_193_hit/Prefabs/Skill_eff_193_fly_1.prefab]],
				},
				end_pos={base_pos=[[atk_lineup]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
				move_time=0.8,
			},
			func_name=[[ShootEffect]],
			start_time=1.38,
		},
		[10]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[atk_lineup]],depth=0,relative_angle=0,relative_dis=0,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.4,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=1.5,
		},
		[11]={
			args={action_name=[[idleWar]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=1.92,
		},
		[12]={
			args={excutor=[[atkobj]],face_to=[[default]],time=0,},
			func_name=[[FaceTo]],
			start_time=1.92,
		},
		[13]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_193_hit/Prefabs/Skill_eff_193_body.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[atk]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=2,
		},
		[14]={
			args={
				alive_time=0.5,
				ease_hide_time=0.35,
				ease_show_time=0.45,
				excutor=[[atkobj]],
				mat_path=[[Material/effect_Fresnel_red_blend02.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=2,
		},
		[15]={
			args={face_atk=false,hurt_delta=0,play_anim=false,},
			func_name=[[VicHitInfo]],
			start_time=2.2,
		},
		[16]={args={},func_name=[[End]],start_time=3,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
