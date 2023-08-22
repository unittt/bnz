module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[attack2]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.5,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/lstx.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.8,
		},
		[4]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_143_full/Prefabs/skill_eff_143_full.prefab]],
					preload=false,
				},
				effect_dir_type=[[right]],
				effect_pos={base_pos=[[vic_team_center]],depth=0,relative_angle=65,relative_dis=2.75,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[5]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_143_full/Prefabs/skill_eff_143_full2.prefab]],
					preload=false,
				},
				effect_dir_type=[[left]],
				effect_pos={base_pos=[[vic_team_center]],depth=0,relative_angle=115,relative_dis=-3,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[6]={
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
			start_time=2,
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
			start_time=2,
		},
		[8]={args={},func_name=[[End]],start_time=2.2,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}