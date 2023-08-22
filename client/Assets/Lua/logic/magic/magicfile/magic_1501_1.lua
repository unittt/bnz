module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={sound_path={soundpath=[[Audio/Sound/War/lstx1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.55,
		},
		[3]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_143_att/Prefabs/skill_eff_143_att.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.75,
		},
		[4]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.9,
		},
		[5]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_143_full/Prefabs/skill_eff_143_full.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic_team_center]],depth=0,relative_angle=120,relative_dis=-4,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.7,
		},
		[6]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_143_full/Prefabs/skill_eff_143_full2.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic_team_center]],depth=0,relative_angle=20,relative_dis=2.4,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.7,
		},
		[7]={
			args={sound_path={soundpath=[[Audio/Sound/War/lstx2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=1.7,
		},
		[8]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
				shot=true,
			},
			func_name=[[VicHitInfo]],
			start_time=2.8,
		},
		[9]={
			args={
				alive_time=0.25,
				ease_hide_time=0.35,
				ease_show_time=0.1,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_Green01.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=2.8,
		},
		[10]={
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
				excutor=[[vicobjs]],
				height=0.15,
			},
			func_name=[[BodyEffect]],
			start_time=2.8,
		},
		[11]={args={},func_name=[[End]],start_time=3.3,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
