module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={excutor=[[atkobj]],face_to=[[lerp_pos]],h_dis=180,time=0.1,v_dis=0,},
			func_name=[[FaceTo]],
			start_time=0,
		},
		[2]={
			args={alive_time=0.5,color={a=0,b=0,g=0,r=0,},excutor=[[atkobj]],fade_time=0,},
			func_name=[[ActorColor]],
			start_time=0,
		},
		[3]={
			args={
				begin_type=[[current]],
				calc_face=true,
				ease_type=[[Linear]],
				end_relative={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=1,},
				end_type=[[end_relative]],
				excutor=[[atkobj]],
				look_at_pos=true,
				move_time=0.05,
				move_type=[[line]],
			},
			func_name=[[Move]],
			start_time=0,
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
				end_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=5,},
				excutor=[[atkobj]],
				move_time=0.15,
			},
			func_name=[[ShootEffect]],
			start_time=0,
		},
		[5]={
			args={
				alive_time=1,
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
			start_time=0,
		},
		[6]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.05,
		},
		[7]={
			args={sound_path={soundpath=[[Audio/Sound/War/kjj3.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.1,
		},
		[8]={args={},func_name=[[End]],start_time=0.5,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
