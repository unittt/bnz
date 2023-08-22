module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={sound_path={soundpath=[[Audio/Sound/War/xuli.ogg]],},},
			editor_is_ban=false,
			func_name=[[PlaySound]],
			start_time=0,
		},
		[3]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.3,
		},
		[4]={
			args={sound_path={soundpath=[[Audio/Sound/War/zs1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.7,
		},
		[5]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_177_hit/Prefabs/skill_eff_177_hit.prefab]],
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.8,
		},
		[6]={
			args={face_atk=false,hurt_delta=0,play_anim=false,},
			func_name=[[VicHitInfo]],
			start_time=1.3,
		},
		[7]={args={},func_name=[[End]],start_time=1.9,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}