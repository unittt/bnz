module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={sound_path={soundpath=[[Audio/Sound/War/flbf2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.2,
		},
		[3]={
			args={
				action_name=[[magic]],
				action_time=2,
				bak_action_name=[[attack1]],
				excutor=[[atkobj]],
			},
			func_name=[[PlayAction]],
			start_time=0.3,
		},
		[4]={
			args={
				alive_time=3.6,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_189_full/Prefabs/Skill_eff_189_full.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic_team_center]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.4,
		},
		[5]={
			args={
				alive_time=1.5,
				ease_hide_time=0.7,
				ease_show_time=1,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_blue01.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=1.35,
		},
		[6]={args={},func_name=[[End]],start_time=4,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=false,
}
