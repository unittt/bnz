module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[attack1]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.05,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/zhaohuan.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.3,
		},
		[4]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/skill_eff_2502_magic_att/Prefabs/skill_eff_2502_magic_att3.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.6,
		},
		[5]={args={},func_name=[[End]],start_time=1.5,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=false,
}
