module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_143_att/Prefabs/skill_eff_143_att.prefab]],
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.5,
		},
		[3]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.5,
		},
		[4]={
			args={sound_path={soundpath=[[Audio/Sound/War/lstx.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.5,
		},
		[5]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_143_full/Prefabs/skill_eff_143_full.prefab]],
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic_team_center]],depth=0,relative_angle=90,relative_dis=0.3,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=1.7,
		},
		[6]={
			args={face_atk=true,hurt_delta=0,play_anim=true,},
			func_name=[[VicHitInfo]],
			start_time=3,
		},
		[7]={
			args={
				alive_time=0.5,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_100_hit/Prefabs/skill_eff_100_hit.prefab]],
				},
				excutor=[[vicobjs]],
				height=0.15,
			},
			func_name=[[BodyEffect]],
			start_time=3,
		},
		[8]={args={},func_name=[[End]],start_time=3.2,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
