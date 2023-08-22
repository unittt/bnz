module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0,
		},
		[2]={
			args={sound_path={soundpath=[[Audio/Sound/War/dao.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.3,
		},
		[3]={
			args={
				alive_time=0.75,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_100_hit/Prefabs/skill_eff_100_hit.prefab]],
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=-1,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0.32,
		},
		[4]={args={face_atk=true,hurt_delta=0,},func_name=[[VicHitInfo]],start_time=0.35,},
		[5]={
			args={
				alive_time=0.6,
				effect={
					is_cached=true,
					path=[[Effect/Magic/skill_eff_100_hit/Prefabs/skill_eff_100_hit.prefab]],
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[vic]],depth=1,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0.47,
		},
		[6]={args={},func_name=[[End]],start_time=0.8,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
