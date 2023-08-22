module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.35,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/jplt1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.35,
		},
		[4]={
			args={
				alive_time=3,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_124_hit/Prefabs/skill_eff_124_hit.prefab]],
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0.7,
		},
		[5]={
			args={sound_path={soundpath=[[Audio/Sound/War/jplt2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.7,
		},
		[6]={
			args={face_atk=false,hurt_delta=0,play_anim=false,},
			func_name=[[VicHitInfo]],
			start_time=1.2,
		},
		[7]={args={},func_name=[[End]],start_time=1.3,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}