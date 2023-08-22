module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.32,
		},
		[3]={
			args={
				alive_time=1.75,
				bind_type=[[pos]],
				body_pos=[[waist]],
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_132_hit/Prefabs/skill_eff_132_hit.prefab]],
				},
				excutor=[[vicobj]],
				height=0.15,
			},
			func_name=[[BodyEffect]],
			start_time=0.85,
		},
		[4]={
			args={sound_path={soundpath=[[Audio/Sound/War/baozha.ogg]],},},
			func_name=[[PlaySound]],
			start_time=1,
		},
		[5]={
			args={face_atk=true,hurt_delta=0,play_anim=true,},
			func_name=[[VicHitInfo]],
			start_time=1.1,
		},
		[6]={args={},func_name=[[End]],start_time=2,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}