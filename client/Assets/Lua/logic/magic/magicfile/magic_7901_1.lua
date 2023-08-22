module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_137_att/Prefabs/Skill_eff_137_att.prefab]],
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[atk]],depth=0.75,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.2,
		},
		[3]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.3,
		},
		[4]={
			args={sound_path={soundpath=[[Audio/Sound/War/fyld1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.3,
		},
		[5]={
			args={
				alive_time=3.5,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_137_hit/Prefabs/Skill_eff_137_full.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic_team_center]],depth=0.45,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0.6,
		},
		[6]={
			args={sound_path={soundpath=[[Audio/Sound/War/fyld2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.6,
		},
		[7]={
			args={face_atk=true,hurt_delta=0,play_anim=true,},
			func_name=[[VicHitInfo]],
			start_time=1.1,
		},
		[8]={
			args={
				alive_time=1.4,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_137_hit/Prefabs/Skill_eff_137_hit.prefab]],
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=1.1,
		},
		[9]={
			args={shake_dis=0.035,shake_rate=15,shake_time=0.2,},
			func_name=[[ShakeScreen]],
			start_time=1.35,
		},
		[10]={
			args={
				alive_time=0.5,
				ease_hide_time=0,
				ease_show_time=0,
				excutor=[[vicobjs]],
				mat_path=[[Material/effect_Fresnel_Blue.mat]],
			},
			func_name=[[ActorMaterial]],
			start_time=1.4,
		},
		[11]={args={},func_name=[[End]],start_time=1.8,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
