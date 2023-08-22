module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.05,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/fjcy1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.2,
		},
		[4]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_114_full/Prefabs/Skill_eff_114_full.prefab]],
					preload=false,
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic_team_center]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.6,
		},
		[5]={
			args={sound_path={soundpath=[[Audio/Sound/War/fjcy2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.6,
		},
		[6]={
			args={action_name=[[hit2]],excutor=[[vicobjs]],},
			func_name=[[PlayAction]],
			start_time=1.25,
		},
		[7]={
			args={action_name=[[hit1]],excutor=[[vicobjs]],},
			func_name=[[PlayAction]],
			start_time=1.3,
		},
		[8]={
			args={action_name=[[hit1]],excutor=[[vicobjs]],},
			func_name=[[PlayAction]],
			start_time=1.3,
		},
		[9]={
			args={action_name=[[hit2]],excutor=[[vicobjs]],},
			func_name=[[PlayAction]],
			start_time=1.45,
		},
		[10]={
			args={
				alive_time=0.25,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_Green01.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=1.7,
		},
		[11]={
			args={shake_dis=0.05,shake_rate=10,shake_time=0.2,},
			func_name=[[ShakeScreen]],
			start_time=1.7,
		},
		[12]={
			args={
				alive_time=1,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_110_hit/Prefabs/Skill_eff_110_hit02.prefab]],
				},
				excutor=[[vicobjs]],
				height=0,
			},
			func_name=[[BodyEffect]],
			start_time=1.7,
		},
		[13]={
			args={face_atk=false,hurt_delta=0,play_anim=true,},
			func_name=[[VicHitInfo]],
			start_time=1.7,
		},
		[14]={args={},func_name=[[End]],start_time=2.3,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}