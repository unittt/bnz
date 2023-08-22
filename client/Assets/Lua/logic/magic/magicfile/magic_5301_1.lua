module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={sound_path={soundpath=[[Audio/Sound/War/zs1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[3]={
			args={
				alive_time=1.5,
				bind_type=[[pos]],
				body_pos=[[head]],
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_115_att/Prefabs/skill_eff_115_att.prefab]],
				},
				excutor=[[atkobj]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=0.3,
		},
		[4]={
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
			start_time=0.7,
		},
		[5]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.7,
		},
		[6]={
			args={sound_path={soundpath=[[Audio/Sound/War/fangyu.ogg]],},},
			editor_is_ban=false,
			func_name=[[PlaySound]],
			start_time=1,
		},
		[7]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
				shot=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.2,
		},
		[8]={
			args={
				alive_time=0.5,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_100_hit/Prefabs/skill_eff_100_hit.prefab]],
					preload=false,
				},
				excutor=[[vicobj]],
				height=0.25,
			},
			func_name=[[BodyEffect]],
			start_time=1.3,
		},
		[9]={args={},func_name=[[End]],start_time=1.55,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
